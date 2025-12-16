import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
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
    // Validate authentication (admin only)
    const { user, supabase } = await validateAuth(req);

    // Check if user is admin
    const { data: adminData, error: adminError } = await supabase
      .from('users')
      .select('role')
      .eq('id', user.id)
      .single();

    if (adminError || adminData?.role !== 'admin') {
      return errorResponse('Unauthorized: Admin access required', 403);
    }

    logEvent('info', 'Guide verification request', {
      admin_id: user.id,
    });

    // Parse request body
    const { guide_id, status, rejection_reason } = await req.json();

    // Validate required fields
    if (!guide_id || !status) {
      return errorResponse('Missing required fields: guide_id, status', 400);
    }

    // Validate status
    if (!['approved', 'rejected'].includes(status)) {
      return errorResponse('Status must be either "approved" or "rejected"', 400);
    }

    if (status === 'rejected' && !rejection_reason) {
      return errorResponse('rejection_reason required when rejecting', 400);
    }

    // Fetch guide profile
    const { data: guideProfile, error: guideError } = await supabase
      .from('guide_profiles')
      .select('*, users(id, first_name, last_name, email)')
      .eq('id', guide_id)
      .single();

    if (guideError || !guideProfile) {
      return errorResponse('Guide profile not found', 404);
    }

    // Check if guide is in pending status
    if (guideProfile.verification_status !== 'pending') {
      return errorResponse(
        `Guide verification status is already ${guideProfile.verification_status}`,
        400
      );
    }

    const now = new Date();

    // Update verification status
    const updateData: any = {
      verification_status: status,
      verified_at: status === 'approved' ? now.toISOString() : null,
      is_verified: status === 'approved',
      verified_by: user.id,
    };

    if (status === 'rejected') {
      updateData.rejection_reason = rejection_reason;
      updateData.rejected_at = now.toISOString();
    }

    const { data: updatedProfile, error: updateError } = await supabase
      .from('guide_profiles')
      .update(updateData)
      .eq('id', guide_id)
      .select()
      .single();

    if (updateError) {
      throw updateError;
    }

    logEvent('info', 'Guide verification updated', {
      guide_id,
      status,
      admin_id: user.id,
    });

    // Send notification to guide
    try {
      let notificationTitle: string;
      let notificationBody: string;
      let notificationType: string;

      if (status === 'approved') {
        notificationTitle = 'Congratulations! You are verified!';
        notificationBody =
          'Your guide profile has been approved. You can now start accepting bookings.';
        notificationType = 'guide_verified';
      } else {
        notificationTitle = 'Verification Update';
        notificationBody = `Your guide profile verification was not approved. Reason: ${rejection_reason}`;
        notificationType = 'guide_rejected';
      }

      const notificationPayload = {
        user_id: guideProfile.user_id,
        title: notificationTitle,
        body: notificationBody,
        data: {
          type: notificationType,
          guide_id: guide_id,
          ...(status === 'rejected' && { rejection_reason }),
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

      logEvent('info', 'Verification notification sent', {
        guide_id,
        user_id: guideProfile.user_id,
      });
    } catch (notifError) {
      logEvent('warn', 'Failed to send verification notification', notifError);
    }

    // Send welcome email if approved (placeholder)
    if (status === 'approved') {
      logEvent('info', 'TODO: Send welcome email', {
        guide_email: guideProfile.users?.email,
        guide_name: `${guideProfile.users?.first_name} ${guideProfile.users?.last_name}`,
      });
    }

    // Create verification log entry
    try {
      await supabase.from('verification_logs').insert({
        guide_id,
        admin_id: user.id,
        status,
        rejection_reason: status === 'rejected' ? rejection_reason : null,
        verified_at: now.toISOString(),
      });
    } catch (logError) {
      logEvent('warn', 'Failed to create verification log', logError);
    }

    // If approved, activate guide profile
    if (status === 'approved') {
      try {
        await supabase
          .from('guide_profiles')
          .update({
            is_active: true,
            profile_active_since: now.toISOString(),
          })
          .eq('id', guide_id);

        logEvent('info', 'Guide profile activated', { guide_id });
      } catch (activationError) {
        logEvent('warn', 'Failed to activate guide profile', activationError);
      }
    }

    return successResponse(
      {
        guide_id: updatedProfile.id,
        verification_status: updatedProfile.verification_status,
        is_verified: updatedProfile.is_verified,
        verified_at: updatedProfile.verified_at,
        verified_by: user.id,
        ...(status === 'rejected' && {
          rejection_reason: updatedProfile.rejection_reason,
        }),
      },
      `Guide ${status === 'approved' ? 'approved' : 'rejected'} successfully`
    );
  } catch (error) {
    return errorResponse(
      error.message || 'Failed to verify guide',
      500,
      error
    );
  }
});
