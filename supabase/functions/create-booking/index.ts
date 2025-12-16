import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import Stripe from 'https://esm.sh/stripe@14.5.0';
import {
  validateAuth,
  createSupabaseClient,
  logEvent,
  successResponse,
  errorResponse,
  calculatePlatformFee,
} from '../_shared/utils.ts';
import { BookingData, ApiResponse } from '../_shared/types.ts';

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
    logEvent('info', 'Create booking request', { user_id: user.id });

    // Parse request body
    const bookingData: BookingData = await req.json();

    // Validate required fields
    if (
      !bookingData.guide_id ||
      !bookingData.service_id ||
      !bookingData.booking_date ||
      !bookingData.time_slot ||
      !bookingData.number_of_participants
    ) {
      return errorResponse('Missing required fields', 400);
    }

    // Validate visitor profile exists
    const { data: visitorProfile, error: visitorError } = await supabase
      .from('visitor_profiles')
      .select('id')
      .eq('user_id', user.id)
      .single();

    if (visitorError || !visitorProfile) {
      return errorResponse('Visitor profile not found', 404);
    }

    // Check guide availability
    const bookingDate = new Date(bookingData.booking_date);
    const startOfDay = new Date(bookingDate);
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date(bookingDate);
    endOfDay.setHours(23, 59, 59, 999);

    // Check for existing bookings at the same time
    const { data: existingBookings, error: bookingCheckError } = await supabase
      .from('bookings')
      .select('id')
      .eq('guide_id', bookingData.guide_id)
      .eq('time_slot', bookingData.time_slot)
      .gte('booking_date', startOfDay.toISOString())
      .lte('booking_date', endOfDay.toISOString())
      .in('status', ['pending', 'confirmed', 'in_progress']);

    if (bookingCheckError) {
      throw bookingCheckError;
    }

    if (existingBookings && existingBookings.length > 0) {
      return errorResponse('Guide is not available at this time', 409);
    }

    // Check for blocked dates
    const { data: blockedDates, error: blockedError } = await supabase
      .from('blocked_dates')
      .select('id')
      .eq('guide_id', bookingData.guide_id)
      .lte('start_date', bookingDate.toISOString())
      .gte('end_date', bookingDate.toISOString());

    if (blockedError) {
      throw blockedError;
    }

    if (blockedDates && blockedDates.length > 0) {
      return errorResponse('Guide has blocked this date', 409);
    }

    // Fetch service details for pricing validation
    const { data: service, error: serviceError } = await supabase
      .from('guide_services')
      .select('price, service_types(name_en)')
      .eq('id', bookingData.service_id)
      .eq('is_active', true)
      .single();

    if (serviceError || !service) {
      return errorResponse('Service not found or inactive', 404);
    }

    // Calculate pricing
    const serviceFee =
      service.price * bookingData.number_of_participants;
    const platformFee = calculatePlatformFee(serviceFee);
    const totalAmount = serviceFee + platformFee;

    // Validate amount matches
    if (Math.abs(totalAmount - bookingData.total_amount) > 0.01) {
      return errorResponse('Invalid amount calculation', 400);
    }

    // Create Stripe payment intent
    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
      apiVersion: '2023-10-16',
    });

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(totalAmount * 100), // Convert to cents
      currency: 'usd',
      metadata: {
        guide_id: bookingData.guide_id,
        visitor_id: visitorProfile.id,
        service_id: bookingData.service_id,
        booking_date: bookingData.booking_date,
        time_slot: bookingData.time_slot,
      },
      automatic_payment_methods: {
        enabled: true,
      },
    });

    logEvent('info', 'Payment intent created', {
      payment_intent_id: paymentIntent.id,
      amount: totalAmount,
    });

    // Create booking record
    const { data: booking, error: insertError } = await supabase
      .from('bookings')
      .insert({
        guide_id: bookingData.guide_id,
        visitor_id: visitorProfile.id,
        service_id: bookingData.service_id,
        booking_date: bookingData.booking_date,
        time_slot: bookingData.time_slot,
        number_of_participants: bookingData.number_of_participants,
        pickup_location: bookingData.pickup_location,
        destinations: bookingData.destinations,
        special_requests: bookingData.special_requests,
        total_amount: totalAmount,
        service_fee: serviceFee,
        platform_fee: platformFee,
        status: 'pending',
        payment_intent_id: paymentIntent.id,
        payment_status: 'pending',
      })
      .select()
      .single();

    if (insertError) {
      // Cancel payment intent if booking creation fails
      await stripe.paymentIntents.cancel(paymentIntent.id);
      throw insertError;
    }

    logEvent('info', 'Booking created', { booking_id: booking.id });

    // Get guide details for notification
    const { data: guideProfile, error: guideError } = await supabase
      .from('guide_profiles')
      .select('user_id, users(first_name, last_name)')
      .eq('id', bookingData.guide_id)
      .single();

    if (!guideError && guideProfile) {
      // Send notification to guide (call send-notification function)
      try {
        const notificationPayload = {
          user_id: guideProfile.user_id,
          title: 'New Booking Request',
          body: `You have a new booking request for ${bookingData.booking_date}`,
          data: {
            type: 'new_booking',
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

        logEvent('info', 'Notification sent to guide', {
          guide_id: bookingData.guide_id,
        });
      } catch (notifError) {
        // Don't fail the booking if notification fails
        logEvent('warn', 'Failed to send notification', notifError);
      }
    }

    return successResponse(
      {
        booking_id: booking.id,
        payment_intent_client_secret: paymentIntent.client_secret,
        total_amount: totalAmount,
        status: 'pending',
      },
      'Booking created successfully'
    );
  } catch (error) {
    return errorResponse(
      error.message || 'Failed to create booking',
      500,
      error
    );
  }
});
