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
 * POST /api/stripe/account-link
 * Generates a Stripe onboarding link for guides to complete their account setup
 */
export async function POST(req: NextRequest) {
  try {
    const { guide_id, return_url, refresh_url } = await req.json();

    if (!guide_id) {
      return NextResponse.json(
        { error: 'Missing required field: guide_id' },
        { status: 400 }
      );
    }

    // Get guide's Stripe account ID
    const { data: guide, error: fetchError } = await supabase
      .from('guide_profiles')
      .select('stripe_account_id')
      .eq('id', guide_id)
      .single();

    if (fetchError || !guide) {
      return NextResponse.json({ error: 'Guide not found' }, { status: 404 });
    }

    if (!guide.stripe_account_id) {
      return NextResponse.json(
        { error: 'Guide does not have a Stripe account. Create one first.' },
        { status: 400 }
      );
    }

    // Default URLs if not provided
    const baseUrl = process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000';
    const returnUrl = return_url || `${baseUrl}/guide/settings/payments?setup=complete`;
    const refreshUrl = refresh_url || `${baseUrl}/guide/settings/payments?setup=refresh`;

    // Create account link for onboarding
    const accountLink = await stripe.accountLinks.create({
      account: guide.stripe_account_id,
      refresh_url: refreshUrl,
      return_url: returnUrl,
      type: 'account_onboarding',
    });

    console.log('✅ Stripe account link created:', {
      guide_id,
      account_id: guide.stripe_account_id,
    });

    return NextResponse.json({
      success: true,
      url: accountLink.url,
      expires_at: accountLink.expires_at,
    });
  } catch (error: any) {
    console.error('❌ Error creating Stripe account link:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to create account link' },
      { status: 500 }
    );
  }
}

/**
 * POST /api/stripe/login-link
 * Generates a login link for guides to access their Stripe Express dashboard
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
      .select('stripe_account_id')
      .eq('id', guide_id)
      .single();

    if (fetchError || !guide) {
      return NextResponse.json({ error: 'Guide not found' }, { status: 404 });
    }

    if (!guide.stripe_account_id) {
      return NextResponse.json(
        { error: 'Guide does not have a Stripe account' },
        { status: 400 }
      );
    }

    // Create login link
    const loginLink = await stripe.accounts.createLoginLink(
      guide.stripe_account_id
    );

    console.log('✅ Stripe login link created:', {
      guide_id,
      account_id: guide.stripe_account_id,
    });

    return NextResponse.json({
      success: true,
      url: loginLink.url,
    });
  } catch (error: any) {
    console.error('❌ Error creating Stripe login link:', error);
    return NextResponse.json(
      { error: error.message || 'Failed to create login link' },
      { status: 500 }
    );
  }
}
