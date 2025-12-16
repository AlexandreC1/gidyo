import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

// Create Supabase client with service role
export function createSupabaseClient(authHeader?: string) {
  const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
  const supabaseKey = authHeader
    ? authHeader.replace('Bearer ', '')
    : Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  return createClient(supabaseUrl, supabaseKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

// Validate authentication
export async function validateAuth(req: Request) {
  const authHeader = req.headers.get('Authorization');
  if (!authHeader) {
    throw new Error('Missing authorization header');
  }

  const supabase = createSupabaseClient(authHeader);
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();

  if (error || !user) {
    throw new Error('Unauthorized');
  }

  return { user, supabase };
}

// Log event
export function logEvent(
  level: 'info' | 'warn' | 'error',
  message: string,
  data?: any
) {
  const timestamp = new Date().toISOString();
  const logEntry = {
    timestamp,
    level,
    message,
    ...(data && { data }),
  };
  console.log(JSON.stringify(logEntry));
}

// Create success response
export function successResponse<T>(data: T, message?: string) {
  return new Response(
    JSON.stringify({
      success: true,
      data,
      ...(message && { message }),
    }),
    {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    }
  );
}

// Create error response
export function errorResponse(message: string, status = 400, error?: any) {
  logEvent('error', message, error);
  return new Response(
    JSON.stringify({
      success: false,
      error: message,
    }),
    {
      status,
      headers: { 'Content-Type': 'application/json' },
    }
  );
}

// Calculate platform fee (10%)
export function calculatePlatformFee(amount: number): number {
  return Math.round(amount * 0.1 * 100) / 100;
}

// Calculate guide payout (90% of total)
export function calculateGuidePayout(amount: number): number {
  return Math.round(amount * 0.9 * 100) / 100;
}
