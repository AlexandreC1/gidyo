import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import Stripe from 'https://esm.sh/stripe@14.5.0';
import {
  validateAuth,
  createSupabaseClient,
  logEvent,
  successResponse,
  errorResponse,
} from '../_shared/utils.ts';
import { ApiResponse } from '../_shared/types.ts';

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'authorization, content-type',
      },
    });
  }

  try {
    // This function can be called by admin or scheduled job
    // For scheduled job, use service role key
    const authHeader = req.headers.get('Authorization');
    const supabase = createSupabaseClient(authHeader);

    // Parse request body
    const { payout_id, guide_id } = await req.json();

    if (!payout_id && !guide_id) {
      return errorResponse('Missing payout_id or guide_id', 400);
    }

    let payoutsToProcess: any[] = [];

    if (payout_id) {
      // Process single payout
      const { data: payout, error: payoutError } = await supabase
        .from('payouts')
        .select('*')
        .eq('id', payout_id)
        .single();

      if (payoutError || !payout) {
        return errorResponse('Payout not found', 404);
      }

      payoutsToProcess = [payout];
    } else if (guide_id) {
      // Process all pending payouts for guide
      const { data: payouts, error: payoutsError } = await supabase
        .from('payouts')
        .select('*')
        .eq('guide_id', guide_id)
        .eq('status', 'pending')
        .lte('scheduled_for', new Date().toISOString());

      if (payoutsError) {
        throw payoutsError;
      }

      payoutsToProcess = payouts || [];
    }

    if (payoutsToProcess.length === 0) {
      return successResponse(
        { processed: 0 },
        'No payouts to process'
      );
    }

    logEvent('info', 'Processing payouts', {
      count: payoutsToProcess.length,
    });

    const results = [];

    for (const payout of payoutsToProcess) {
      try {
        // Verify payout is pending
        if (payout.status !== 'pending') {
          logEvent('warn', 'Skipping non-pending payout', {
            payout_id: payout.id,
            status: payout.status,
          });
          continue;
        }

        // Get guide payment settings
        const { data: guideProfile, error: guideError } = await supabase
          .from('guide_profiles')
          .select('user_id, payout_method, stripe_account_id, moncash_number')
          .eq('id', payout.guide_id)
          .single();

        if (guideError || !guideProfile) {
          throw new Error('Guide profile not found');
        }

        const payoutMethod = guideProfile.payout_method || 'stripe';
        let transferId = null;

        // Process payout based on method
        if (payoutMethod === 'stripe') {
          // Process Stripe transfer
          if (!guideProfile.stripe_account_id) {
            throw new Error('Guide has no Stripe account configured');
          }

          const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
            apiVersion: '2023-10-16',
          });

          const transfer = await stripe.transfers.create({
            amount: Math.round(payout.amount * 100), // Convert to cents
            currency: 'usd',
            destination: guideProfile.stripe_account_id,
            metadata: {
              payout_id: payout.id,
              guide_id: payout.guide_id,
              booking_id: payout.booking_id,
            },
          });

          transferId = transfer.id;

          logEvent('info', 'Stripe transfer created', {
            payout_id: payout.id,
            transfer_id: transferId,
            amount: payout.amount,
          });
        } else if (payoutMethod === 'moncash') {
          // Process MonCash transfer (placeholder - implement MonCash API)
          if (!guideProfile.moncash_number) {
            throw new Error('Guide has no MonCash number configured');
          }

          // TODO: Implement MonCash API integration
          // For now, just log and mark as processing
          transferId = `moncash_${Date.now()}`;

          logEvent('info', 'MonCash transfer initiated', {
            payout_id: payout.id,
            moncash_number: guideProfile.moncash_number,
            amount: payout.amount,
          });
        } else if (payoutMethod === 'bank') {
          // Process bank transfer (placeholder)
          transferId = `bank_${Date.now()}`;

          logEvent('info', 'Bank transfer initiated', {
            payout_id: payout.id,
            amount: payout.amount,
          });
        }

        // Update payout status
        const { error: updateError } = await supabase
          .from('payouts')
          .update({
            status: 'processing',
            transfer_id: transferId,
            processed_at: new Date().toISOString(),
          })
          .eq('id', payout.id);

        if (updateError) {
          throw updateError;
        }

        // Send confirmation notification to guide
        try {
          const notificationPayload = {
            user_id: guideProfile.user_id,
            title: 'Payout Processed',
            body: `Your payout of $${payout.amount.toFixed(2)} is being processed`,
            data: {
              type: 'payout_processed',
              payout_id: payout.id,
              amount: payout.amount,
            },
          };

          const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
          const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;

          await fetch(`${supabaseUrl}/functions/v1/send-notification`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              Authorization: `Bearer ${anonKey}`,
            },
            body: JSON.stringify(notificationPayload),
          });
        } catch (notifError) {
          logEvent('warn', 'Failed to send payout notification', notifError);
        }

        results.push({
          payout_id: payout.id,
          status: 'processing',
          transfer_id: transferId,
          amount: payout.amount,
        });
      } catch (payoutError) {
        // Mark payout as failed
        await supabase
          .from('payouts')
          .update({
            status: 'failed',
            error_message: payoutError.message,
            processed_at: new Date().toISOString(),
          })
          .eq('id', payout.id);

        logEvent('error', 'Payout processing failed', {
          payout_id: payout.id,
          error: payoutError.message,
        });

        results.push({
          payout_id: payout.id,
          status: 'failed',
          error: payoutError.message,
        });
      }
    }

    return successResponse(
      {
        processed: results.length,
        results,
      },
      `Processed ${results.length} payout(s)`
    );
  } catch (error) {
    return errorResponse(
      error.message || 'Failed to process payout',
      500,
      error
    );
  }
});
