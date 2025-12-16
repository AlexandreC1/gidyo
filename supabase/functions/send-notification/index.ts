import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import {
  createSupabaseClient,
  logEvent,
  successResponse,
  errorResponse,
} from '../_shared/utils.ts';
import { NotificationPayload, ApiResponse } from '../_shared/types.ts';

// Firebase Admin SDK initialization (using REST API approach)
async function sendFCMNotification(
  fcmToken: string,
  title: string,
  body: string,
  data?: Record<string, any>
) {
  const fcmServerKey = Deno.env.get('FCM_SERVER_KEY');
  if (!fcmServerKey) {
    throw new Error('FCM_SERVER_KEY not configured');
  }

  const message = {
    to: fcmToken,
    notification: {
      title,
      body,
      sound: 'default',
    },
    data: data || {},
    priority: 'high',
  };

  const response = await fetch('https://fcm.googleapis.com/fcm/send', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `key=${fcmServerKey}`,
    },
    body: JSON.stringify(message),
  });

  if (!response.ok) {
    const errorData = await response.json();
    throw new Error(`FCM error: ${JSON.stringify(errorData)}`);
  }

  return await response.json();
}

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
    // Can be called by authenticated users or service role
    const authHeader = req.headers.get('Authorization');
    const supabase = createSupabaseClient(authHeader);

    // Parse request body
    const payload: NotificationPayload = await req.json();

    // Validate required fields
    if (!payload.user_id || !payload.title || !payload.body) {
      return errorResponse('Missing required fields: user_id, title, body', 400);
    }

    logEvent('info', 'Send notification request', {
      user_id: payload.user_id,
      title: payload.title,
    });

    // Fetch user's FCM token
    const { data: userData, error: userError } = await supabase
      .from('users')
      .select('fcm_token, notification_preferences')
      .eq('id', payload.user_id)
      .single();

    if (userError || !userData) {
      return errorResponse('User not found', 404);
    }

    // Check notification preferences
    const notificationPrefs = userData.notification_preferences || {};
    const notificationType = payload.data?.type;

    // Check if user has disabled this type of notification
    if (notificationType && notificationPrefs[notificationType] === false) {
      logEvent('info', 'Notification blocked by user preferences', {
        user_id: payload.user_id,
        type: notificationType,
      });

      return successResponse(
        { sent: false, reason: 'blocked_by_preferences' },
        'Notification blocked by user preferences'
      );
    }

    // Save notification to database
    const { data: notification, error: insertError } = await supabase
      .from('notifications')
      .insert({
        user_id: payload.user_id,
        title: payload.title,
        body: payload.body,
        data: payload.data || {},
        type: notificationType || 'general',
        is_read: false,
      })
      .select()
      .single();

    if (insertError) {
      throw insertError;
    }

    logEvent('info', 'Notification saved to database', {
      notification_id: notification.id,
    });

    // Send push notification if FCM token exists
    let fcmResult = null;
    if (userData.fcm_token) {
      try {
        fcmResult = await sendFCMNotification(
          userData.fcm_token,
          payload.title,
          payload.body,
          {
            ...payload.data,
            notification_id: notification.id,
          }
        );

        logEvent('info', 'FCM notification sent', {
          notification_id: notification.id,
          fcm_message_id: fcmResult.message_id,
        });

        // Update notification as sent
        await supabase
          .from('notifications')
          .update({ sent_at: new Date().toISOString() })
          .eq('id', notification.id);
      } catch (fcmError) {
        // Log FCM error but don't fail the request
        logEvent('warn', 'Failed to send FCM notification', {
          notification_id: notification.id,
          error: fcmError.message,
        });

        // If token is invalid, clear it from user record
        if (
          fcmError.message.includes('InvalidRegistration') ||
          fcmError.message.includes('NotRegistered')
        ) {
          await supabase
            .from('users')
            .update({ fcm_token: null })
            .eq('id', payload.user_id);

          logEvent('info', 'Cleared invalid FCM token', {
            user_id: payload.user_id,
          });
        }
      }
    } else {
      logEvent('info', 'No FCM token found for user', {
        user_id: payload.user_id,
      });
    }

    return successResponse(
      {
        notification_id: notification.id,
        sent_via_fcm: !!fcmResult,
        fcm_result: fcmResult,
      },
      'Notification sent successfully'
    );
  } catch (error) {
    return errorResponse(
      error.message || 'Failed to send notification',
      500,
      error
    );
  }
});
