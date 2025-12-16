# GIDYO Supabase Edge Functions

This directory contains serverless Edge Functions for the GIDYO platform, deployed on Supabase.

## Functions Overview

### 1. create-booking
Creates a new booking with payment processing and notifications.

**Endpoint:** `POST /functions/v1/create-booking`

**Authentication:** Required (Visitor)

**Request Body:**
```json
{
  "guide_id": "uuid",
  "service_id": "uuid",
  "booking_date": "2024-01-15T00:00:00Z",
  "time_slot": "09:00 AM - 12:00 PM",
  "number_of_participants": 2,
  "pickup_location": "Hotel ABC",
  "destinations": ["Citadelle Laferrière", "Sans-Souci Palace"],
  "special_requests": "Vegetarian lunch preferred",
  "total_amount": 110.0
}
```

**Features:**
- Validates guide availability
- Checks for booking conflicts
- Verifies blocked dates
- Calculates pricing (service fee + platform fee)
- Creates Stripe payment intent
- Inserts booking record
- Sends notification to guide

---

### 2. accept-booking
Accepts a pending booking request.

**Endpoint:** `POST /functions/v1/accept-booking`

**Authentication:** Required (Guide)

**Request Body:**
```json
{
  "booking_id": "uuid"
}
```

**Features:**
- Verifies booking ownership
- Checks expiration (24 hours)
- Confirms payment status
- Updates booking to confirmed
- Updates guide stats
- Sends confirmation to visitor

---

### 3. complete-booking
Marks a booking as completed and schedules payout.

**Endpoint:** `POST /functions/v1/complete-booking`

**Authentication:** Required (Guide)

**Request Body:**
```json
{
  "booking_id": "uuid",
  "tip_amount": 10.0
}
```

**Features:**
- Verifies booking is in progress
- Calculates guide payout (90% + tips)
- Creates payout record (7-day delay)
- Updates guide earnings stats
- Sends review requests to both parties

---

### 4. process-payout
Processes pending payouts to guides.

**Endpoint:** `POST /functions/v1/process-payout`

**Authentication:** Service Role (Admin/Scheduled Job)

**Request Body:**
```json
{
  "payout_id": "uuid"
}
```
or
```json
{
  "guide_id": "uuid"
}
```

**Features:**
- Processes Stripe transfers
- Handles MonCash payments
- Supports bank transfers
- Updates payout status
- Sends confirmation notifications
- Handles invalid payment methods

---

### 5. send-notification
Sends push notifications via Firebase Cloud Messaging.

**Endpoint:** `POST /functions/v1/send-notification`

**Authentication:** Service Role or User

**Request Body:**
```json
{
  "user_id": "uuid",
  "title": "Booking Confirmed",
  "body": "Your booking has been confirmed",
  "data": {
    "type": "booking_confirmed",
    "booking_id": "uuid"
  }
}
```

**Features:**
- Fetches FCM token from user record
- Checks notification preferences
- Saves notification to database
- Sends FCM push notification
- Handles invalid tokens
- Supports custom data payloads

---

### 6. verify-guide
Admin function to verify or reject guide applications.

**Endpoint:** `POST /functions/v1/verify-guide`

**Authentication:** Required (Admin only)

**Request Body:**
```json
{
  "guide_id": "uuid",
  "status": "approved",
  "rejection_reason": "Optional reason if rejected"
}
```

**Features:**
- Admin role verification
- Updates verification status
- Activates guide profile if approved
- Sends welcome notification
- Creates verification log
- Handles rejection workflow

---

## Setup and Deployment

### Prerequisites
- Supabase CLI installed: `npm install -g supabase`
- Deno runtime installed
- Supabase project created

### Local Development

1. **Install Supabase CLI:**
```bash
npm install -g supabase
```

2. **Link to your project:**
```bash
supabase link --project-ref your-project-ref
```

3. **Set up environment variables:**
```bash
cp .env.example .env
# Edit .env with your credentials
```

4. **Serve functions locally:**
```bash
supabase functions serve
```

5. **Test a function:**
```bash
curl -i --location --request POST 'http://localhost:54321/functions/v1/create-booking' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{"guide_id":"...","service_id":"...",...}'
```

### Deployment

1. **Deploy all functions:**
```bash
supabase functions deploy
```

2. **Deploy a specific function:**
```bash
supabase functions deploy create-booking
```

3. **Set environment secrets:**
```bash
supabase secrets set STRIPE_SECRET_KEY=sk_test_...
supabase secrets set FCM_SERVER_KEY=...
supabase secrets set SUPABASE_SERVICE_ROLE_KEY=...
```

4. **View logs:**
```bash
supabase functions logs create-booking
```

---

## Environment Variables

All functions require these environment variables:

| Variable | Description | Required |
|----------|-------------|----------|
| SUPABASE_URL | Your Supabase project URL | Yes |
| SUPABASE_ANON_KEY | Public anon key | Yes |
| SUPABASE_SERVICE_ROLE_KEY | Service role key (admin access) | Yes |
| STRIPE_SECRET_KEY | Stripe API secret key | Yes (booking/payout) |
| FCM_SERVER_KEY | Firebase Cloud Messaging key | Yes (notifications) |
| MONCASH_CLIENT_ID | MonCash API client ID | Optional |
| MONCASH_SECRET_KEY | MonCash API secret | Optional |

---

## Database Tables Required

These functions interact with the following tables:

- `users` - User authentication and profiles
- `guide_profiles` - Guide information and settings
- `visitor_profiles` - Visitor information
- `bookings` - Booking records
- `guide_services` - Services offered by guides
- `service_types` - Service categories
- `blocked_dates` - Guide unavailability
- `payouts` - Payout records
- `notifications` - Notification history
- `verification_logs` - Guide verification audit log

---

## Error Handling

All functions follow a consistent error response format:

```json
{
  "success": false,
  "error": "Error message here"
}
```

Success responses:

```json
{
  "success": true,
  "data": { ... },
  "message": "Optional success message"
}
```

---

## Scheduled Jobs

Some functions can be called by scheduled jobs:

### Daily Payout Processing
Run `process-payout` daily to process pending payouts:

```sql
-- Create a scheduled job in Supabase
SELECT cron.schedule(
  'process-pending-payouts',
  '0 2 * * *', -- Daily at 2 AM
  $$
  SELECT net.http_post(
    url := 'https://your-project.supabase.co/functions/v1/process-payout',
    headers := '{"Authorization": "Bearer YOUR_SERVICE_ROLE_KEY"}'::jsonb,
    body := '{}'::jsonb
  );
  $$
);
```

### Auto-decline Expired Bookings
Create a database trigger or scheduled job to auto-decline bookings after 24 hours.

---

## Security Considerations

1. **Authentication:** All user-facing functions validate JWT tokens
2. **Authorization:** Guide/visitor-specific actions verify ownership
3. **Admin Functions:** verify-guide checks admin role
4. **Input Validation:** All inputs are validated before processing
5. **Error Logging:** Errors logged but sensitive data redacted
6. **Payment Security:** Stripe handles PCI compliance
7. **Rate Limiting:** Consider adding rate limits in production

---

## Testing

Test each function with curl or Postman:

```bash
# Create booking
curl -X POST http://localhost:54321/functions/v1/create-booking \
  -H "Authorization: Bearer $AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d @test-data/create-booking.json

# Accept booking
curl -X POST http://localhost:54321/functions/v1/accept-booking \
  -H "Authorization: Bearer $GUIDE_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"booking_id":"uuid-here"}'
```

---

## Support

For issues or questions:
- Check Supabase function logs
- Review error messages in response
- Verify environment variables are set
- Check database table schemas match requirements
