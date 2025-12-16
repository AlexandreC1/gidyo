import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import {
  validateAuth,
  createSupabaseClient,
  logEvent,
  successResponse,
  errorResponse,
  calculateGuidePayout,
  calculatePlatformFee,
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
    // Validate authentication
    const { user, supabase } = await validateAuth(req);
    logEvent('info', 'Complete booking request', { user_id: user.id });

    // Parse request body
    const { booking_id, tip_amount } = await req.json();

    if (!booking_id) {
      return errorResponse('Missing booking_id', 400);
    }

    // Verify guide profile exists
    const { data: guideProfile, error: guideError } = await supabase
      .from('guide_profiles')
      .select('id, user_id')
      .eq('user_id', user.id)
      .single();

    if (guideError || !guideProfile) {
      return errorResponse('Guide profile not found', 404);
    }

    // Fetch booking details
    const { data: booking, error: bookingError } = await supabase
      .from('bookings')
      .select(
        `
        *,
        visitor:visitor_profiles!bookings_visitor_id_fkey(
          user_id,
          users(first_name, last_name)
        ),
        guide:guide_profiles!bookings_guide_id_fkey(
          user_id,
          users(first_name, last_name)
        )
      `
      )
      .eq('id', booking_id)
      .eq('guide_id', guideProfile.id)
      .single();

    if (bookingError || !booking) {
      return errorResponse('Booking not found', 404);
    }

    // Verify booking is in confirmed or in_progress status
    if (
      booking.status !== 'confirmed' &&
      booking.status !== 'in_progress'
    ) {
      return errorResponse(
        `Cannot complete booking with status: ${booking.status}`,
        400
      );
    }

    // Verify payment was captured
    if (booking.payment_status !== 'captured') {
      return errorResponse('Payment not captured yet', 400);
    }

    const now = new Date();

    // Calculate guide payout
    const serviceFee = booking.service_fee || booking.total_amount * 0.9;
    const platformFee =
      booking.platform_fee || calculatePlatformFee(serviceFee);
    const tipAmountValue = tip_amount || 0;
    const guidePayout = calculateGuidePayout(booking.total_amount) + tipAmountValue;

    // Update booking status to completed
    const { data: updatedBooking, error: updateError } = await supabase
      .from('bookings')
      .update({
        status: 'completed',
        completed_at: now.toISOString(),
        tip_amount: tipAmountValue,
        guide_payout: guidePayout,
      })
      .eq('id', booking_id)
      .select()
      .single();

    if (updateError) {
      throw updateError;
    }

    logEvent('info', 'Booking completed', {
      booking_id,
      guide_payout: guidePayout,
    });

    // Create payout record (will be processed by scheduled payout job)
    const { data: payout, error: payoutError } = await supabase
      .from('payouts')
      .insert({
        guide_id: guideProfile.id,
        booking_id: booking.id,
        amount: guidePayout,
        service_fee: serviceFee,
        platform_fee: platformFee,
        tip_amount: tipAmountValue,
        status: 'pending',
        scheduled_for: new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000).toISOString(), // 7 days later
      })
      .select()
      .single();

    if (payoutError) {
      logEvent('warn', 'Failed to create payout record', payoutError);
    } else {
      logEvent('info', 'Payout scheduled', {
        payout_id: payout.id,
        scheduled_for: payout.scheduled_for,
      });
    }

    // Update guide stats
    try {
      const { data: stats } = await supabase
        .from('guide_profiles')
        .select('total_earnings')
        .eq('id', guideProfile.id)
        .single();

      await supabase
        .from('guide_profiles')
        .update({
          total_earnings: (stats?.total_earnings || 0) + guidePayout,
        })
        .eq('id', guideProfile.id);
    } catch (statsError) {
      logEvent('warn', 'Failed to update guide earnings', statsError);
    }

    // Request review from visitor
    try {
      const visitorUserId = booking.visitor.user_id;

      const notificationPayload = {
        user_id: visitorUserId,
        title: 'How was your experience?',
        body: `Rate your experience with ${
          booking.guide?.users?.first_name || 'your guide'
        }`,
        data: {
          type: 'review_request',
          booking_id: booking.id,
          guide_id: booking.guide_id,
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

      logEvent('info', 'Review request sent to visitor', {
        visitor_id: booking.visitor_id,
      });
    } catch (notifError) {
      logEvent('warn', 'Failed to send review request', notifError);
    }

    // Request review from guide about visitor
    try {
      const guideUserId = booking.guide.user_id;

      const notificationPayload = {
        user_id: guideUserId,
        title: 'Trip Completed!',
        body: `Rate your experience with ${
          booking.visitor?.users?.first_name || 'the visitor'
        }`,
        data: {
          type: 'guide_review_request',
          booking_id: booking.id,
          visitor_id: booking.visitor_id,
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

      logEvent('info', 'Review request sent to guide', {
        guide_id: booking.guide_id,
      });
    } catch (notifError) {
      logEvent('warn', 'Failed to send guide review request', notifError);
    }

    return successResponse(
      {
        booking_id: updatedBooking.id,
        status: updatedBooking.status,
        completed_at: updatedBooking.completed_at,
        guide_payout: guidePayout,
        payout_scheduled_for: payout?.scheduled_for,
      },
      'Booking completed successfully'
    );
  } catch (error) {
    return errorResponse(
      error.message || 'Failed to complete booking',
      500,
      error
    );
  }
});
