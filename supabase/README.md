# GIDYO Supabase Backend

Backend configuration, database migrations, and edge functions for GIDYO.

## Tech Stack

- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **Realtime**: Supabase Realtime
- **Edge Functions**: Deno

## Setup

1. Install Supabase CLI:
```bash
npm install -g supabase
```

2. Login to Supabase:
```bash
supabase login
```

3. Link to your project:
```bash
supabase link --project-ref your-project-ref
```

4. Apply migrations:
```bash
supabase db push
```

## Project Structure

```
supabase/
├── migrations/           # Database migrations
│   └── 001_initial_schema.sql
├── functions/           # Edge functions
└── config.toml         # Supabase configuration
```

## Database Schema

### Core Tables

1. **users** - Base user table for all user types
2. **guide_profiles** - Extended profile for guides
3. **visitor_profiles** - Extended profile for visitors
4. **service_types** - Catalog of available services
5. **guide_services** - Services offered by each guide
6. **bookings** - Reservation records
7. **reviews** - Ratings and feedback
8. **conversations** - Chat threads
9. **messages** - Individual messages
10. **guide_availability** - Guide schedules
11. **payouts** - Payment tracking for guides
12. **saved_guides** - Visitor favorites
13. **notifications** - Push notifications

## Migrations

Create a new migration:
```bash
supabase migration new migration_name
```

Apply migrations:
```bash
supabase db push
```

Reset database (development only):
```bash
supabase db reset
```

## Row Level Security

All tables have RLS enabled with policies for:
- User privacy (own data only)
- Public read access where appropriate
- Role-based permissions (visitor/guide/admin)

## Storage Buckets

Create required storage buckets:
- `profile-photos` - User profile images
- `guide-videos` - Guide introduction videos
- `review-photos` - Review images
- `chat-media` - Chat attachments

## Edge Functions

Deploy edge functions:
```bash
supabase functions deploy function_name
```

## Environment Variables

Set in Supabase Dashboard:
- `STRIPE_SECRET_KEY` - Stripe API key
- `MONCASH_API_KEY` - MonCash API key
- `FCM_SERVER_KEY` - Firebase Cloud Messaging key

## Realtime

Enable realtime for:
- `messages` table (chat)
- `bookings` table (booking updates)
- `notifications` table (push notifications)

## Local Development

Start local Supabase:
```bash
supabase start
```

Access local services:
- API: http://localhost:54321
- Studio: http://localhost:54323
- Inbucket (emails): http://localhost:54324

## Production

Link to production project:
```bash
supabase link --project-ref production-ref
```

Deploy to production:
```bash
supabase db push --db-url your-production-db-url
```
