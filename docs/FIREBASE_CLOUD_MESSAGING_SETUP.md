# Firebase Cloud Messaging (FCM) Setup Guide

## Overview

This guide covers the complete setup of Firebase Cloud Messaging for the GIDYO mobile app with a focus on **security best practices**.

## Security Features Implemented

### 1. Input Validation & Sanitization
- **XSS Prevention**: All notification content (title, body) is sanitized to remove HTML tags and special characters
- **ID Validation**: Booking IDs, message IDs, and user IDs are validated with regex (alphanumeric, dashes, underscores only)
- **Path Validation**: Deep link paths are validated against a whitelist and checked for safe characters
- **Length Limits**: All inputs have maximum length constraints to prevent buffer overflow attacks

### 2. Authorization & Access Control
- **Row-Level Security**: Supabase RLS ensures users can only access their own FCM tokens and notifications
- **User Authentication**: All repository methods check for authenticated users before operations
- **Route Whitelisting**: Deep link navigation only allows pre-approved route prefixes

### 3. Data Protection
- **Secure Token Storage**: FCM tokens are stored in Supabase with RLS enabled
- **No Sensitive Data**: Notification payloads never contain passwords, API keys, or PII
- **Encrypted Transport**: All communication uses HTTPS/TLS

### 4. Additional Security Measures
- **Type Safety**: Freezed models ensure compile-time type checking
- **Unknown Type Handling**: Invalid notification types default to "unknown" and are logged
- **Error Handling**: Comprehensive try-catch blocks prevent app crashes from malformed data
- **Logging**: All security events are logged for audit trails

## Architecture

```
┌─────────────────────────────────────────────────┐
│              Flutter App                        │
├─────────────────────────────────────────────────┤
│  NotificationService (Singleton)                │
│  ├─ FCM Token Management                        │
│  ├─ Permission Handling                         │
│  ├─ Foreground Message Handler                  │
│  └─ Background Message Handler                  │
├─────────────────────────────────────────────────┤
│  DeepLinkService                                │
│  ├─ Route Validation                            │
│  ├─ Navigation Handler                          │
│  └─ Security Checks                             │
├─────────────────────────────────────────────────┤
│  NotificationRepository                         │
│  ├─ FCM Token Storage (Supabase)                │
│  ├─ Notification History                        │
│  └─ User Preferences                            │
└─────────────────────────────────────────────────┘
          │                         │
          ▼                         ▼
    Firebase Console          Supabase Backend
    (Send Notifications)      (Store Tokens & Prefs)
```

## Setup Instructions

### Prerequisites

1. Firebase project created
2. iOS & Android apps registered in Firebase Console
3. APNs certificate/key configured (iOS)
4. google-services.json downloaded (Android)
5. GoogleService-Info.plist downloaded (iOS)

### Step 1: Firebase Console Setup

#### Android Setup
1. Go to Firebase Console → Project Settings → Your Apps
2. Click "Add app" → Select Android
3. Enter package name: `com.gidyo.mobile` (or your actual package name)
4. Download `google-services.json`
5. Place file at: `android/app/google-services.json`

#### iOS Setup
1. Go to Firebase Console → Project Settings → Your Apps
2. Click "Add app" → Select iOS
3. Enter bundle ID: `com.gidyo.mobile` (or your actual bundle ID)
4. Download `GoogleService-Info.plist`
5. Place file at: `ios/Runner/GoogleService-Info.plist`
6. Open Xcode → Add file to project

#### iOS APNs Configuration
1. Get APNs Authentication Key:
   - Go to Apple Developer → Certificates, Identifiers & Profiles
   - Click Keys → Create new key
   - Enable "Apple Push Notifications service (APNs)"
   - Download `.p8` file

2. Upload to Firebase:
   - Firebase Console → Project Settings → Cloud Messaging
   - Under "Apple app configuration"
   - Upload APNs Authentication Key
   - Enter Key ID and Team ID

### Step 2: Database Setup (Supabase)

Create the required tables with RLS enabled:

```sql
-- User devices table for storing FCM tokens
CREATE TABLE user_devices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL UNIQUE,
  platform TEXT NOT NULL CHECK (platform IN ('android', 'ios', 'web')),
  last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_devices ENABLE ROW LEVEL SECURITY;

-- Users can only read/write their own devices
CREATE POLICY "Users can manage their own devices"
  ON user_devices
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Create index for faster lookups
CREATE INDEX idx_user_devices_user_id ON user_devices(user_id);
CREATE INDEX idx_user_devices_fcm_token ON user_devices(fcm_token);

-- Notification preferences table
CREATE TABLE notification_preferences (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  booking_notifications BOOLEAN DEFAULT true,
  message_notifications BOOLEAN DEFAULT true,
  payment_notifications BOOLEAN DEFAULT true,
  marketing_notifications BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE notification_preferences ENABLE ROW LEVEL SECURITY;

-- Users can only manage their own preferences
CREATE POLICY "Users can manage their own notification preferences"
  ON notification_preferences
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Notifications history table
CREATE TABLE notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Users can only see their own notifications
CREATE POLICY "Users can view their own notifications"
  ON notifications
  FOR SELECT
  USING (auth.uid() = user_id);

-- Create indexes
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_read_at ON notifications(read_at) WHERE read_at IS NULL;

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_user_devices_updated_at
  BEFORE UPDATE ON user_devices
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_preferences_updated_at
  BEFORE UPDATE ON notification_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### Step 3: Backend Integration (Supabase Edge Functions)

Create Edge Functions to send notifications:

```typescript
// supabase/functions/send-notification/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const FIREBASE_SERVER_KEY = Deno.env.get('FIREBASE_SERVER_KEY')

serve(async (req) => {
  try {
    const { userId, type, title, body, data } = await req.json()

    // Initialize Supabase client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // Get user's FCM tokens
    const { data: devices, error } = await supabase
      .from('user_devices')
      .select('fcm_token')
      .eq('user_id', userId)

    if (error || !devices || devices.length === 0) {
      return new Response(
        JSON.stringify({ error: 'No devices found' }),
        { status: 404 }
      )
    }

    // Check user's notification preferences
    const { data: prefs } = await supabase
      .from('notification_preferences')
      .select('*')
      .eq('user_id', userId)
      .single()

    // Check if user has this notification type enabled
    const prefKey = `${type}_notifications`
    if (prefs && prefs[prefKey] === false) {
      return new Response(
        JSON.stringify({ message: 'User has disabled this notification type' }),
        { status: 200 }
      )
    }

    // Send notification to each device
    const results = await Promise.all(
      devices.map(async (device) => {
        const response = await fetch('https://fcm.googleapis.com/fcm/send', {
          method: 'POST',
          headers: {
            'Authorization': `key=${FIREBASE_SERVER_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            to: device.fcm_token,
            notification: { title, body },
            data: {
              type,
              ...data,
            },
            priority: 'high',
          }),
        })
        return response.json()
      })
    )

    // Store notification in history
    await supabase
      .from('notifications')
      .insert({
        user_id: userId,
        type,
        title,
        body,
        data,
      })

    return new Response(
      JSON.stringify({ success: true, results }),
      { status: 200 }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    )
  }
})
```

### Step 4: Android Build Configuration

Ensure `android/build.gradle` includes:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

And `android/app/build.gradle` includes:

```gradle
apply plugin: 'com.google.gms.google-services'

dependencies {
    // Firebase dependencies are auto-included via flutter plugins
}
```

### Step 5: iOS Xcode Configuration

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner → Signing & Capabilities
3. Click "+ Capability" → Add:
   - **Push Notifications**
   - **Background Modes** (enable "Remote notifications")
   - **Associated Domains** (add `applinks:app.gidyo.com`)

### Step 6: Testing

#### Test FCM Token Registration

```dart
// In your app, after login:
final token = NotificationService.instance.fcmToken;
print('FCM Token: $token');

// Verify token is saved to Supabase
final repo = NotificationRepository(Supabase.instance.client);
await repo.saveFCMToken(token!);
```

#### Test Notification from Firebase Console

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter title and body
4. Click "Send test message"
5. Enter your FCM token
6. Click "Test"

#### Test Deep Linking

Send a notification with custom data:
```json
{
  "to": "YOUR_FCM_TOKEN",
  "notification": {
    "title": "New Booking Request",
    "body": "John wants to book Airport Pickup"
  },
  "data": {
    "type": "booking_request",
    "booking_id": "123",
    "screen": "/guide/bookings"
  }
}
```

## Notification Triggers

Implement these triggers in your Supabase Edge Functions or database triggers:

### 1. New Booking Request → Guide
```sql
CREATE OR REPLACE FUNCTION notify_guide_new_booking()
RETURNS TRIGGER AS $$
BEGIN
  -- Call Edge Function to send notification
  PERFORM net.http_post(
    url := current_setting('app.settings.edge_functions_url') || '/send-notification',
    body := jsonb_build_object(
      'userId', NEW.guide_id,
      'type', 'booking',
      'title', 'New Booking Request',
      'body', 'You have a new booking request',
      'data', jsonb_build_object(
        'booking_id', NEW.id,
        'screen', '/guide/bookings'
      )
    )
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER booking_created_notify_guide
  AFTER INSERT ON bookings
  FOR EACH ROW
  EXECUTE FUNCTION notify_guide_new_booking();
```

### 2. Booking Confirmed → Visitor
### 3. Booking Cancelled → Both
### 4. New Message → Recipient
### 5. Payment Received → Guide
### 6. Review Received → Guide
### 7. Guide Approved → Guide

(Similar trigger patterns for each event)

## Notification Payload Structure

All notifications should follow this structure:

```typescript
{
  notification: {
    title: string,      // Sanitized, max 100 chars
    body: string,       // Sanitized, max 500 chars
  },
  data: {
    type: 'booking_request' | 'booking_confirmed' | 'booking_cancelled' |
          'new_message' | 'payment_received' | 'review_received' | 'guide_approved',
    booking_id?: string,  // UUID format
    message_id?: string,  // UUID format
    user_id?: string,     // UUID format
    screen?: string,      // Must start with / and contain only safe chars
  }
}
```

## Security Checklist

- [ ] Firebase Server Key stored securely (environment variable, not in code)
- [ ] Supabase RLS enabled on all tables
- [ ] Input validation implemented on all notification data
- [ ] Route whitelisting configured in DeepLinkService
- [ ] APNs certificate/key uploaded to Firebase
- [ ] Test notifications working on both platforms
- [ ] Deep linking working correctly
- [ ] User preferences respected (no notifications if disabled)
- [ ] Notification history viewable by users
- [ ] Old notifications auto-deleted after 30 days
- [ ] Error logging configured
- [ ] Production APNs environment configured for release builds

## Troubleshooting

### Android: Notifications not appearing
1. Check `google-services.json` is in `android/app/`
2. Verify package name matches Firebase Console
3. Check Android 13+ notification permission granted
4. View logs: `adb logcat | grep FCM`

### iOS: Notifications not appearing
1. Check `GoogleService-Info.plist` added to Xcode project
2. Verify bundle ID matches Firebase Console
3. Check APNs key uploaded to Firebase
4. Ensure Push Notifications capability enabled
5. View logs in Xcode console

### Token not saving to Supabase
1. Check user is authenticated
2. Verify RLS policies are correct
3. Check Supabase URL and anon key
4. View logs in NotificationRepository

### Deep links not working
1. Verify AndroidManifest.xml has intent filter
2. Check Info.plist has URL schemes
3. Test with: `adb shell am start -a android.intent.action.VIEW -d "gidyo://app.gidyo.com/bookings"`
4. Verify route is in whitelist

## Production Deployment

Before deploying to production:

1. **Update iOS APNs environment**:
   ```xml
   <key>aps-environment</key>
   <string>production</string>
   ```

2. **Update notification color** (Android):
   Edit `android/app/src/main/res/values/colors.xml`

3. **Configure Firebase Analytics** (optional)

4. **Set up monitoring**: Track notification delivery rates and errors

5. **Test on real devices**: Both Android and iOS

6. **Update backend**: Ensure Edge Functions use production Firebase Server Key

## Additional Resources

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [APNs Overview](https://developer.apple.com/documentation/usernotifications)

## Support

For issues or questions:
1. Check logs in `Logger` class
2. Review Supabase logs in dashboard
3. Check Firebase Console → Cloud Messaging → Reports
4. Contact development team

---

**Last Updated**: December 2024
**Version**: 1.0.0
