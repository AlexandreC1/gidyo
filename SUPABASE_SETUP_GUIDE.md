# GIDYO Supabase Setup Guide

Complete step-by-step guide to set up Supabase for the GIDYO mobile app.

---

## 📋 Prerequisites

- Node.js installed (for Supabase CLI)
- Git installed
- A Supabase account (free tier is fine)
- Flutter development environment set up

---

## Part 1: Create Supabase Project

### Step 1: Sign Up for Supabase

1. Go to [https://supabase.com](https://supabase.com)
2. Click **"Start your project"** or **"Sign Up"**
3. Sign up with GitHub, Google, or email
4. Verify your email if required

### Step 2: Create a New Project

1. Click **"New Project"**
2. Fill in project details:
   - **Name**: `gidyo` or `gidyo-production`
   - **Database Password**: Create a strong password (SAVE THIS!)
   - **Region**: Choose closest to Haiti (e.g., `us-east-1`)
   - **Pricing Plan**: Free tier is fine for development
3. Click **"Create new project"**
4. Wait 2-3 minutes for project to initialize

### Step 3: Get Your Project Credentials

Once the project is ready:

1. Go to **Settings** → **API** in the left sidebar
2. You'll see:
   - **Project URL**: `https://xxxxxxxxxxxxx.supabase.co`
   - **API Keys**:
     - `anon` key (public) - Safe to use in Flutter app
     - `service_role` key (secret) - NEVER expose in mobile app
3. **COPY THESE VALUES** - you'll need them soon

---

## Part 2: Install Supabase CLI

### Option 1: Using npm (Recommended)

```bash
npm install -g supabase
```

### Option 2: Using Homebrew (Mac)

```bash
brew install supabase/tap/supabase
```

### Option 3: Using Scoop (Windows)

```bash
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

### Verify Installation

```bash
supabase --version
```

You should see something like: `1.x.x`

---

## Part 3: Link Local Project to Supabase

### Step 1: Login to Supabase CLI

```bash
cd ~/gidyo
supabase login
```

This will open your browser for authentication. Log in with the same account you used to create the project.

### Step 2: Get Your Project Reference ID

1. Go to your Supabase project dashboard
2. Look at the URL: `https://app.supabase.com/project/xxxxxxxxxxxxx`
3. The part after `/project/` is your **Project Reference ID**
4. Or find it in **Settings** → **General** → **Reference ID**

### Step 3: Link Project

```bash
cd ~/gidyo
supabase link --project-ref YOUR_PROJECT_REF_HERE
```

Example:
```bash
supabase link --project-ref abcdefghijklmnop
```

When prompted for the database password, enter the password you created in Step 2.

---

## Part 4: Apply Database Migrations

### Step 1: Review Migrations

The project has 3 migration files:

```bash
ls supabase/migrations/
```

You should see:
- `001_initial_schema.sql` - Main database schema
- `002_seed_data.sql` - Sample data
- `20241218_fcm_notifications.sql` - Firebase notifications

### Step 2: Apply Migrations to Supabase

```bash
cd ~/gidyo
supabase db push
```

This will:
- Upload all migrations to your Supabase project
- Create all tables, indexes, and policies
- Set up Row Level Security (RLS)

### Step 3: Verify Database Setup

1. Go to Supabase Dashboard → **Table Editor**
2. You should see all 13 tables:
   - users
   - guide_profiles
   - visitor_profiles
   - service_types
   - guide_services
   - bookings
   - reviews
   - conversations
   - messages
   - guide_availability
   - payouts
   - saved_guides
   - notifications

---

## Part 5: Set Up Storage Buckets

### Step 1: Create Storage Buckets

1. Go to **Storage** in the Supabase dashboard
2. Click **"Create a new bucket"**
3. Create these 4 buckets:

#### Bucket 1: profile-photos
- **Name**: `profile-photos`
- **Public**: ✅ Yes (publicly accessible)
- **File size limit**: 5 MB
- **Allowed MIME types**: `image/*`

#### Bucket 2: guide-videos
- **Name**: `guide-videos`
- **Public**: ✅ Yes
- **File size limit**: 50 MB
- **Allowed MIME types**: `video/*`

#### Bucket 3: review-photos
- **Name**: `review-photos`
- **Public**: ✅ Yes
- **File size limit**: 5 MB
- **Allowed MIME types**: `image/*`

#### Bucket 4: chat-media
- **Name**: `chat-media`
- **Public**: ❌ No (private, RLS protected)
- **File size limit**: 10 MB
- **Allowed MIME types**: `image/*,video/*,audio/*`

### Step 2: Set Up Storage Policies

For each bucket, create RLS policies:

#### profile-photos policies:
```sql
-- Anyone can read
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
USING (bucket_id = 'profile-photos');

-- Users can upload their own
CREATE POLICY "Users can upload their own profile photo"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'profile-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can update their own
CREATE POLICY "Users can update their own profile photo"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'profile-photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);
```

Apply similar policies for other buckets.

---

## Part 6: Enable Realtime

### Step 1: Enable Realtime for Tables

1. Go to **Database** → **Replication**
2. Find and enable realtime for these tables:
   - ✅ `messages` (for chat)
   - ✅ `bookings` (for booking updates)
   - ✅ `notifications` (for push notifications)

### Step 2: Test Realtime (Optional)

In the Supabase dashboard SQL editor:

```sql
-- Insert a test message
INSERT INTO messages (conversation_id, sender_id, content)
VALUES ('test-id', auth.uid(), 'Hello!');
```

---

## Part 7: Configure Environment Variables

### Step 1: Create Flutter Environment File

Create `.env` file in the mobile directory:

```bash
cd ~/gidyo/mobile
touch .env
```

### Step 2: Add Supabase Credentials

Edit `mobile/.env`:

```env
# Supabase Configuration
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here

# Stripe Configuration (get from Stripe dashboard)
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx

# Google Maps API Key (get from Google Cloud Console)
GOOGLE_MAPS_API_KEY=AIzaSyxxxxxxxxxxxxxxxxx
```

### Step 3: Add Flutter Environment Package

The project should already have `flutter_dotenv` or similar. If not:

```bash
cd ~/gidyo/mobile
flutter pub add flutter_dotenv
```

### Step 4: Load Environment Variables

Check `lib/main.dart` to ensure environment variables are loaded:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const MyApp());
}
```

### Step 5: Update pubspec.yaml

Ensure `.env` is included in assets:

```yaml
flutter:
  assets:
    - .env
    - assets/images/
    - assets/animations/
```

---

## Part 8: Test the Connection

### Step 1: Create Test File

Create `mobile/lib/test_supabase.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> testSupabaseConnection() async {
  try {
    // Test database connection
    final response = await Supabase.instance.client
        .from('service_types')
        .select()
        .limit(1);

    print('✅ Supabase connection successful!');
    print('Response: $response');
  } catch (e) {
    print('❌ Supabase connection failed: $e');
  }
}
```

### Step 2: Run Test

In `main.dart`, temporarily add:

```dart
await testSupabaseConnection();
```

### Step 3: Run App

```bash
cd ~/gidyo/mobile
flutter run
```

Check console for success message.

---

## Part 9: Seed Initial Data (Optional)

### Step 1: Add Sample Service Types

Go to Supabase Dashboard → **SQL Editor**

```sql
-- Insert sample service types
INSERT INTO service_types (name_en, name_fr, name_ht, description_en, base_price, price_unit, is_active) VALUES
('City Tour', 'Visite de la ville', 'Vizit vil la', 'Guided tour of the city', 50.00, 'per_person', true),
('Airport Pickup', 'Transfert aéroport', 'Pran nan ayewopò', 'Pickup from airport', 30.00, 'per_group', true),
('Beach Day Trip', 'Excursion à la plage', 'Trip nan plaj', 'Full day beach excursion', 75.00, 'per_person', true),
('Historical Tour', 'Visite historique', 'Tout istwa', 'Historical sites tour', 60.00, 'per_person', true),
('Custom Tour', 'Tour personnalisé', 'Tour espesyal', 'Customized tour experience', 100.00, 'per_day', true);
```

### Step 2: Create Test User (via Supabase Auth)

1. Go to **Authentication** → **Users**
2. Click **"Add user"** → **"Create new user"**
3. Enter email and password
4. User will be created in `auth.users`
5. You need to manually create a record in `users` table linking to this auth user

---

## Part 10: Set Up Authentication

### Step 1: Configure Auth Providers

1. Go to **Authentication** → **Providers**
2. Enable providers you want:
   - ✅ Email (enabled by default)
   - ☐ Google (optional - needs OAuth setup)
   - ☐ Facebook (optional - needs OAuth setup)

### Step 2: Configure Email Templates (Optional)

1. Go to **Authentication** → **Email Templates**
2. Customize:
   - Confirmation email
   - Reset password email
   - Magic link email

### Step 3: Set Auth Redirects

1. Go to **Authentication** → **URL Configuration**
2. Add redirect URLs:
   - `yourapp://callback` (for mobile deep links)
   - `http://localhost:3000` (for web testing)

---

## Part 11: Set Up Stripe (Payment Processing)

### Step 1: Create Stripe Account

1. Go to [https://stripe.com](https://stripe.com)
2. Sign up for account
3. Get API keys from **Developers** → **API keys**

### Step 2: Add Stripe Keys to Supabase

1. Go to Supabase → **Settings** → **Vault**
2. Add secrets:
   - `STRIPE_SECRET_KEY` (server-side, for Edge Functions)
   - `STRIPE_PUBLISHABLE_KEY` (client-side, for Flutter)

### Step 3: Update Flutter .env

```env
STRIPE_PUBLISHABLE_KEY=pk_test_xxxxxxxxxxxxx
```

---

## Part 12: Enable Firebase Cloud Messaging (FCM)

### Already configured! ✅

The migration `20241218_fcm_notifications.sql` was already applied.

### What you need:

1. **Firebase Project** (you may already have one)
2. **FCM Server Key** from Firebase Console
3. Add to Supabase → **Settings** → **Vault** → `FCM_SERVER_KEY`

---

## ✅ Verification Checklist

After completing all steps, verify:

- [ ] ✅ Supabase project created
- [ ] ✅ Supabase CLI installed and logged in
- [ ] ✅ Project linked to local repository
- [ ] ✅ All 3 migrations applied successfully
- [ ] ✅ All 13 tables visible in Table Editor
- [ ] ✅ 4 storage buckets created
- [ ] ✅ Realtime enabled for messages, bookings, notifications
- [ ] ✅ `.env` file created with credentials
- [ ] ✅ Flutter app connects to Supabase successfully
- [ ] ✅ Row Level Security policies in place
- [ ] ✅ Auth provider configured
- [ ] ✅ Sample service types inserted

---

## 🚨 Security Best Practices

### ✅ DO:
- ✅ Use `anon` key in Flutter app (safe, public)
- ✅ Keep `service_role` key secret (server-only)
- ✅ Add `.env` to `.gitignore` (already done)
- ✅ Use Row Level Security on all tables
- ✅ Validate input on client AND server
- ✅ Use HTTPS only (Supabase enforces this)

### ❌ DON'T:
- ❌ Expose `service_role` key in mobile app
- ❌ Commit `.env` file to Git
- ❌ Disable RLS on production tables
- ❌ Store sensitive data unencrypted

---

## 🐛 Troubleshooting

### Problem: "Cannot connect to Supabase"

**Solution:**
1. Check `.env` file has correct URL and key
2. Ensure `.env` is loaded in `main.dart`
3. Verify internet connection
4. Check Supabase project is not paused (free tier pauses after inactivity)

### Problem: "Permission denied" errors

**Solution:**
1. Check RLS policies are correct
2. Ensure user is authenticated
3. Verify user has correct role (visitor/guide)

### Problem: "Table not found"

**Solution:**
1. Re-run migrations: `supabase db push`
2. Check migrations applied: Supabase Dashboard → Database → Migrations

### Problem: "Storage upload fails"

**Solution:**
1. Check bucket exists and is public
2. Verify storage policies allow upload
3. Check file size doesn't exceed limit

---

## 📚 Next Steps

After Supabase is set up:

1. **Test Authentication** - Sign up a test user
2. **Create Test Data** - Add sample guides and services
3. **Test Bookings** - Create a test booking flow
4. **Test Chat** - Send test messages
5. **Test Notifications** - Send test FCM notifications

---

## 🔗 Useful Links

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart/introduction)
- [Row Level Security Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Storage Guide](https://supabase.com/docs/guides/storage)
- [Realtime Guide](https://supabase.com/docs/guides/realtime)

---

## 💬 Need Help?

If you encounter issues:

1. Check Supabase Dashboard → **Logs** for errors
2. Check Flutter console for error messages
3. Review RLS policies in Table Editor
4. Test queries in SQL Editor

---

**Setup completed! 🎉**

Your GIDYO app is now connected to Supabase and ready for development!
