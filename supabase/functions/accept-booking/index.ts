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
    // Validate authentication
    const { user, supabase } = await validateAuth(req);
    logEvent('info', 'Accept booking request', { user_id: user.id });

    // Parse request body
    const { booking_id } = await req.json();

    if (!booking_id) {
      return errorResponse('Missing booking_id', 400);
    }

    // Verify guide profile exists
    const { data: guideProfile, error: guideError } = await supabase
      .from('guide_profiles')
      .select('id')
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
          users(first_name, last_name, email)
        ),
        service:guide_services!bookings_service_id_fkey(
          service_types(name_en)
        )
      `
      )
      .eq('id', booking_id)
      .eq('guide_id', guideProfile.id)
      .single();

    if (bookingError || !booking) {
      return errorResponse('Booking not found', 404);
    }

    // Verify booking is in pending status
    if (booking.status !== 'pending') {
      return errorResponse(
        `Booking is already ${booking.status}`,
        400
      );
    }

    // Check if booking hasn't expired (24 hours)
    const createdAt = new Date(booking.created_at);
    const expiresAt = new Date(createdAt.getTime() + 24 * 60 * 60 * 1000);
    const now = new Date();

    if (now > expiresAt) {
      // Auto-decline expired booking
      await supabase
        .from('bookings')
        .update({
          status: 'declined',
          declined_at: now.toISOString(),
          decline_reason: 'Request expired (no response within 24 hours)',
        })
        .eq('id', booking_id);

      return errorResponse('Booking request has expired', 410);
    }

    // Capture or confirm payment
    let paymentCaptured = false;
    if (booking.payment_intent_id) {
      try {
        const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
          apiVersion: '2023-10-16',
        });

        // Get payment intent status
        const paymentIntent = await stripe.paymentIntents.retrieve(
          booking.payment_intent_id
        );

        if (
          paymentIntent.status === 'requires_capture' ||
          paymentIntent.status === 'succeeded'
        ) {
          // Payment is ready or already captured
          paymentCaptured = true;
          logEvent('info', 'Payment already captured or ready', {
            payment_intent_id: booking.payment_intent_id,
          });
        } else if (paymentIntent.status === 'requires_payment_method') {
          // Payment not completed yet - this is okay, visitor will complete it
          logEvent('info', 'Payment pending visitor completion', {
            payment_intent_id: booking.payment_intent_id,
          });
        }
      } catch (stripeError) {
        logEvent('warn', 'Failed to check payment intent', stripeError);
      }
    }

    // Update booking status to confirmed
    const { data: updatedBooking, error: updateError } = await supabase
      .from('bookings')
      .update({
        status: 'confirmed',
        confirmed_at: now.toISOString(),
        ...(paymentCaptured && { payment_status: 'captured' }),
      })
      .eq('id', booking_id)
      .select()
      .single();

    if (updateError) {
      throw updateError;
    }

    logEvent('info', 'Booking confirmed', { booking_id });

    // Update guide stats
    try {
      const { data: stats } = await supabase
        .from('guide_profiles')
        .select('total_bookings')
        .eq('id', guideProfile.id)
        .single();

      await supabase
        .from('guide_profiles')
        .update({
          total_bookings: (stats?.total_bookings || 0) + 1,
        })
        .eq('id', guideProfile.id);
    } catch (statsError) {
      logEvent('warn', 'Failed to update guide stats', statsError);
    }

    // Send confirmation notification to visitor
    if (booking.visitor) {
      try {
        const visitorUserId = booking.visitor.user_id;
        const serviceName =
          booking.service?.service_types?.name_en || 'service';

        const notificationPayload = {
          user_id: visitorUserId,
          title: 'Booking Confirmed!',
          body: `Your ${serviceName} booking has been confirmed for ${new Date(
            booking.booking_date
          ).toLocaleDateString()}`,
          data: {
            type: 'booking_confirmed',
            booking_id: booking.id,
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

        logEvent('info', 'Confirmation sent to visitor', {
          visitor_id: booking.visitor_id,
        });
      } catch (notifError) {
        logEvent('warn', 'Failed to send notification', notifError);
      }
    }

    // Send confirmation email (placeholder for future implementation)
    logEvent('info', 'TODO: Send confirmation email', {
      visitor_email: booking.visitor?.users?.email,
    });

    return successResponse(
      {
        booking_id: updatedBooking.id,
        status: updatedBooking.status,
        confirmed_at: updatedBooking.confirmed_at,
      },
      'Booking accepted successfully'
    );
  } catch (error) {
    return errorResponse(
      error.message || 'Failed to accept booking',
      500,
      error
    );
  }
});
