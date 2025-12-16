import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16',
});

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const PLATFORM_FEE_PERCENTAGE = 0.1; // 10% platform fee

/**
 * POST /api/stripe/create-payment-intent
 * Creates a payment intent for a booking with automatic transfer to guide's connected account
 */
export async function POST(req: NextRequest) {
  try {
    const {
      amount,
      currency = 'usd',
      guide_id,
      booking_id,
      metadata = {},
    } = await req.json();

    // Validate required fields
    if (!amount || !guide_id) {
      return NextResponse.json(
        { error: 'Missing required fields: amount, guide_id' },
        { status: 400 }
      );
    }

    // Validate amount
    if (amount <= 0) {
      return NextResponse.json(
        { error: 'Amount must be greater than 0' },
        { status: 400 }
      );
    }

    // Get guide's Stripe account
    const { data: guide, error: fetchError } = await supabase
      .from('guide_profiles')
      .select('stripe_account_id, stripe_onboarding_status')
      .eq('id', guide_id)
      .single();

    if (fetchError || !guide) {
      return NextResponse.json({ error: 'Guide not found' }, { status: 404 });
    }

    if (!guide.stripe_account_id) {
      return NextResponse.json(
        { error: 'Guide has not set up their payout account' },
        { status: 400 }
      );
    }

    // Verify guide account is ready to receive payments
    const account = await stripe.accounts.retrieve(guide.stripe_account_id);

    if (!account.charges_enabled) {
      return NextResponse.json(
        {
          error:
            'Guide account is not ready to accept payments. Complete onboarding first.',
        },
        { status: 400 }
      );
    }

    // Calculate platform fee and transfer amount
    const amountInCents = Math.round(amount * 100);
    const platformFeeInCents = Math.round(amountInCents * PLATFORM_FEE_PERCENTAGE);
    const transferAmountInCents = amountInCents - platformFeeInCents;

    // Create payment intent with automatic transfer to connected account
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInCents,
      currency: currency,
      automatic_payment_methods: {
        enabled: true,
      },
      transfer_data: {
        destination: guide.stripe_account_id,
        amount: transferAmountInCents,
      },
      metadata: {
        guide_id,
        booking_id: booking_id || '',
        platform_fee: platformFeeInCents.toString(),
        transfer_amount: transferAmountInCents.toString(),
        ...metadata,
      },
      description: `Booking payment for guide ${guide_id}`,
    });

    console.log('✅ Payment intent created:', {
      payment_intent_id: paymentIntent.id,
      amount: amount,
      guide_id,
      platform_fee: platformFeeInCents / 100,
      transfer_amount: transferAmountInCents / 100,
    });

    // Save payment intent to booking if booking_id provided
    if (booking_id) {
      await supabase
        .from('bookings')
        .update({
          payment_intent_id: paymentIntent.id,
          payment_status: 'pending',
        })
        .eq('id', booking_id);
    }

    return NextResponse.json({
      success: true,
      payment_intent_id: paymentIntent.id,
      client_secret: paymentIntent.client_secret,
      amount: amount,
      platform_fee: platformFeeInCents / 100,
      transfer_amount: transferAmountInCents / 100,
    });
  } catch (error: any) {
    console.error('❌ Error creating payment intent:', error);

    // Handle specific Stripe errors
    let errorMessage = 'Failed to create payment intent';
    let statusCode = 500;

    if (error.type === 'StripeCardError') {
      errorMessage = error.message;
      statusCode = 400;
    } else if (error.type === 'StripeInvalidRequestError') {
      errorMessage = error.message;
      statusCode = 400;
    }

    return NextResponse.json({ error: errorMessage }, { status: statusCode });
  }
}

/**
 * GET /api/stripe/create-payment-intent?payment_intent_id=xxx
 * Retrieves payment intent status
 */
export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const payment_intent_id = searchParams.get('payment_intent_id');

    if (!payment_intent_id) {
      return NextResponse.json(
        { error: 'Missing payment_intent_id parameter' },
        { status: 400 }
      );
    }

    const paymentIntent = await stripe.paymentIntents.retrieve(
      payment_intent_id
    );

    return NextResponse.json({
      success: true,
      payment_intent_id: paymentIntent.id,
      status: paymentIntent.status,
      amount: paymentIntent.amount / 100,
      currency: paymentIntent.currency,
      metadata: paymentIntent.metadata,
    });
  } catch (error: any) {
    console.error('❌ Error retrieving payment intent:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to retrieve payment intent' },
      { status: 500 }
    );
  }
}
