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

/**
 * POST /api/stripe/connect-account
 * Creates a Stripe Connect Express account for a guide
 */
export async function POST(req: NextRequest) {
  try {
    const { guide_id, email, country = 'HT' } = await req.json();

    if (!guide_id || !email) {
      return NextResponse.json(
        { error: 'Missing required fields: guide_id, email' },
        { status: 400 }
      );
    }

    // Check if guide already has a Stripe account
    const { data: existingGuide, error: fetchError } = await supabase
      .from('guide_profiles')
      .select('stripe_account_id')
      .eq('id', guide_id)
      .single();

    if (fetchError) {
      throw fetchError;
    }

    if (existingGuide?.stripe_account_id) {
      return NextResponse.json(
        { error: 'Guide already has a Stripe account' },
        { status: 400 }
      );
    }

    // Create Stripe Connect Express account
    const account = await stripe.accounts.create({
      type: 'express',
      country: country,
      email: email,
      capabilities: {
        card_payments: { requested: true },
        transfers: { requested: true },
      },
      business_type: 'individual',
      metadata: {
        guide_id: guide_id,
      },
    });

    // Save Stripe account ID to guide profile
    const { error: updateError } = await supabase
      .from('guide_profiles')
      .update({
        stripe_account_id: account.id,
        stripe_onboarding_status: 'pending',
      })
      .eq('id', guide_id);

    if (updateError) {
      // Rollback: delete the Stripe account
      await stripe.accounts.del(account.id);
      throw updateError;
    }

    console.log('✅ Stripe Connect account created:', {
      guide_id,
      account_id: account.id,
    });

    return NextResponse.json({
      success: true,
      account_id: account.id,
      details_submitted: account.details_submitted,
      charges_enabled: account.charges_enabled,
      payouts_enabled: account.payouts_enabled,
    });
  } catch (error: any) {
    console.error('❌ Error creating Stripe Connect account:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to create Connect account' },
      { status: 500 }
    );
  }
}

/**
 * GET /api/stripe/connect-account?guide_id=xxx
 * Retrieves Stripe Connect account status for a guide
 */
export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const guide_id = searchParams.get('guide_id');

    if (!guide_id) {
      return NextResponse.json(
        { error: 'Missing guide_id parameter' },
        { status: 400 }
      );
    }

    // Get guide's Stripe account ID
    const { data: guide, error: fetchError } = await supabase
      .from('guide_profiles')
      .select('stripe_account_id, stripe_onboarding_status')
      .eq('id', guide_id)
      .single();

    if (fetchError || !guide) {
      return NextResponse.json({ error: 'Guide not found' }, { status: 404 });
    }

    if (!guide.stripe_account_id) {
      return NextResponse.json({
        success: true,
        has_account: false,
        onboarding_status: 'not_started',
      });
    }

    // Retrieve account from Stripe
    const account = await stripe.accounts.retrieve(guide.stripe_account_id);

    // Update onboarding status in database
    let onboardingStatus = 'pending';
    if (account.details_submitted && account.charges_enabled) {
      onboardingStatus = 'complete';
    } else if (account.details_submitted) {
      onboardingStatus = 'submitted';
    }

    await supabase
      .from('guide_profiles')
      .update({ stripe_onboarding_status: onboardingStatus })
      .eq('id', guide_id);

    return NextResponse.json({
      success: true,
      has_account: true,
      account_id: account.id,
      details_submitted: account.details_submitted,
      charges_enabled: account.charges_enabled,
      payouts_enabled: account.payouts_enabled,
      onboarding_status: onboardingStatus,
      requirements: account.requirements,
    });
  } catch (error: any) {
    console.error('❌ Error fetching Stripe Connect account:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to fetch Connect account' },
      { status: 500 }
    );
  }
}
