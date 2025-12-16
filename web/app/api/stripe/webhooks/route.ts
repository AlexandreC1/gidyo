import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';
import { createClient } from '@supabase/supabase-js';
import { headers } from 'next/headers';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2023-10-16',
});

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

/**
 * POST /api/stripe/webhooks
 * Handles Stripe webhook events
 */
export async function POST(req: NextRequest) {
  try {
    const body = await req.text();
    const headersList = headers();
    const signature = headersList.get('stripe-signature');

    if (!signature) {
      return NextResponse.json(
        { error: 'Missing stripe-signature header' },
        { status: 400 }
      );
    }

    // Verify webhook signature
    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
    } catch (err: any) {
      console.error('❌ Webhook signature verification failed:', err.message);
      return NextResponse.json(
        { error: `Webhook Error: ${err.message}` },
        { status: 400 }
      );
    }

    console.log('✅ Webhook received:', event.type);

    // Handle different event types
    switch (event.type) {
      case 'payment_intent.succeeded':
        await handlePaymentIntentSucceeded(event.data.object);
        break;

      case 'payment_intent.payment_failed':
        await handlePaymentIntentFailed(event.data.object);
        break;

      case 'payment_intent.canceled':
        await handlePaymentIntentCanceled(event.data.object);
        break;

      case 'charge.refunded':
        await handleChargeRefunded(event.data.object);
        break;

      case 'transfer.created':
        await handleTransferCreated(event.data.object);
        break;

      case 'transfer.failed':
        await handleTransferFailed(event.data.object);
        break;

      case 'account.updated':
        await handleAccountUpdated(event.data.object);
        break;

      case 'capability.updated':
        await handleCapabilityUpdated(event.data.object);
        break;

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    return NextResponse.json({ received: true });
  } catch (error: any) {
    console.error('❌ Error processing webhook:', error);
    return NextResponse.json(
      { error: error.message || 'Webhook processing failed' },
      { status: 500 }
    );
  }
}

/**
 * Handles successful payment intent
 */
async function handlePaymentIntentSucceeded(paymentIntent: Stripe.PaymentIntent) {
  console.log('💰 Payment succeeded:', paymentIntent.id);

  const bookingId = paymentIntent.metadata.booking_id;

  if (bookingId) {
    // Update booking payment status
    const { error } = await supabase
      .from('bookings')
      .update({
        payment_status: 'succeeded',
        paid_at: new Date().toISOString(),
      })
      .eq('id', bookingId);

    if (error) {
      console.error('Failed to update booking:', error);
    } else {
      console.log('✅ Booking payment status updated:', bookingId);
    }

    // Send notification to guide
    try {
      const { data: booking } = await supabase
        .from('bookings')
        .select('guide_id, guide_profiles(user_id)')
        .eq('id', bookingId)
        .single();

      if (booking) {
        await fetch(`${process.env.NEXT_PUBLIC_SUPABASE_URL}/functions/v1/send-notification`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${process.env.SUPABASE_SERVICE_ROLE_KEY}`,
          },
          body: JSON.stringify({
            user_id: booking.guide_profiles.user_id,
            title: 'Payment Received',
            body: 'A booking payment has been successfully processed',
            data: {
              type: 'payment_succeeded',
              booking_id: bookingId,
            },
          }),
        });
      }
    } catch (notifError) {
      console.error('Failed to send notification:', notifError);
    }
  }
}

/**
 * Handles failed payment intent
 */
async function handlePaymentIntentFailed(paymentIntent: Stripe.PaymentIntent) {
  console.log('❌ Payment failed:', paymentIntent.id);

  const bookingId = paymentIntent.metadata.booking_id;

  if (bookingId) {
    // Update booking payment status
    const { error } = await supabase
      .from('bookings')
      .update({
        payment_status: 'failed',
        payment_error: paymentIntent.last_payment_error?.message || 'Payment failed',
      })
      .eq('id', bookingId);

    if (error) {
      console.error('Failed to update booking:', error);
    }
  }
}

/**
 * Handles canceled payment intent
 */
async function handlePaymentIntentCanceled(paymentIntent: Stripe.PaymentIntent) {
  console.log('🚫 Payment canceled:', paymentIntent.id);

  const bookingId = paymentIntent.metadata.booking_id;

  if (bookingId) {
    // Update booking status
    const { error } = await supabase
      .from('bookings')
      .update({
        payment_status: 'canceled',
        status: 'canceled',
        canceled_at: new Date().toISOString(),
      })
      .eq('id', bookingId);

    if (error) {
      console.error('Failed to update booking:', error);
    }
  }
}

/**
 * Handles charge refunded
 */
async function handleChargeRefunded(charge: Stripe.Charge) {
  console.log('🔄 Charge refunded:', charge.id);

  const paymentIntentId = charge.payment_intent as string;

  if (paymentIntentId) {
    // Find booking by payment intent
    const { data: booking } = await supabase
      .from('bookings')
      .select('id')
      .eq('payment_intent_id', paymentIntentId)
      .single();

    if (booking) {
      // Update booking status
      await supabase
        .from('bookings')
        .update({
          payment_status: 'refunded',
          status: 'canceled',
          refunded_at: new Date().toISOString(),
          refund_amount: charge.amount_refunded / 100,
        })
        .eq('id', booking.id);

      console.log('✅ Booking refunded:', booking.id);
    }
  }
}

/**
 * Handles transfer created (payout to guide)
 */
async function handleTransferCreated(transfer: Stripe.Transfer) {
  console.log('💸 Transfer created:', transfer.id);

  const guideId = transfer.metadata.guide_id;
  const payoutId = transfer.metadata.payout_id;

  if (payoutId) {
    // Update payout status
    await supabase
      .from('payouts')
      .update({
        status: 'processing',
        transfer_id: transfer.id,
        processed_at: new Date().toISOString(),
      })
      .eq('id', payoutId);
  }
}

/**
 * Handles transfer failed
 */
async function handleTransferFailed(transfer: Stripe.Transfer) {
  console.log('❌ Transfer failed:', transfer.id);

  const payoutId = transfer.metadata.payout_id;

  if (payoutId) {
    // Update payout status
    await supabase
      .from('payouts')
      .update({
        status: 'failed',
        error_message: 'Transfer failed',
      })
      .eq('id', payoutId);
  }
}

/**
 * Handles account updated (connected account status changes)
 */
async function handleAccountUpdated(account: Stripe.Account) {
  console.log('🔄 Account updated:', account.id);

  const guideId = account.metadata.guide_id;

  if (guideId) {
    // Update guide's account status
    let onboardingStatus = 'pending';

    if (account.details_submitted && account.charges_enabled) {
      onboardingStatus = 'complete';
    } else if (account.details_submitted) {
      onboardingStatus = 'submitted';
    }

    await supabase
      .from('guide_profiles')
      .update({
        stripe_onboarding_status: onboardingStatus,
      })
      .eq('id', guideId);

    console.log('✅ Guide onboarding status updated:', onboardingStatus);
  }
}

/**
 * Handles capability updated
 */
async function handleCapabilityUpdated(capability: Stripe.Capability) {
  console.log('🔄 Capability updated:', capability.id, capability.status);

  // You can track capability status changes here if needed
}
