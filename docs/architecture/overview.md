# GIDYO Architecture Overview

## System Architecture

GIDYO is built as a multi-platform marketplace connecting international visitors with vetted local guides in Haiti.

### High-Level Architecture

```
┌─────────────────┐
│  Marketing Web  │  (Next.js 14)
│   Landing Page  │
└────────┬────────┘
         │
         │
┌────────▼────────┐     ┌──────────────────┐
│  Visitor App    │     │   Guide App      │
│   (Flutter)     │◄───►│   (Flutter)      │
└────────┬────────┘     └────────┬─────────┘
         │                       │
         │                       │
         └───────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │   Supabase Backend    │
         ├───────────────────────┤
         │ • PostgreSQL Database │
         │ • Authentication      │
         │ • Storage             │
         │ • Realtime            │
         │ • Edge Functions      │
         └───────────────────────┘
                     │
         ┌───────────┴───────────┐
         │                       │
         ▼                       ▼
┌────────────────┐      ┌───────────────┐
│ Payment APIs   │      │  Notification │
│ • Stripe       │      │  Services     │
│ • MonCash      │      │  • FCM        │
└────────────────┘      └───────────────┘
```

## Components

### 1. Marketing Web (`/web`)
- **Purpose**: Public-facing marketing website
- **Tech**: Next.js 14, TypeScript, Tailwind CSS
- **Features**:
  - Landing page showcasing platform benefits
  - Guide discovery and browsing
  - Service catalog
  - SEO optimization
  - Multi-language support (EN/FR/HT)

### 2. Visitor Mobile App (`/mobile`)
- **Purpose**: Mobile app for travelers
- **Tech**: Flutter, Dart
- **Features**:
  - Browse and search guides
  - Service booking with calendar
  - Real-time chat with guides
  - Payment processing
  - Review and ratings
  - Favorites/saved guides
  - Trip planning

### 3. Guide Mobile App (`/mobile`)
- **Purpose**: Mobile app for local guides
- **Tech**: Flutter, Dart (same codebase as visitor app)
- **Features**:
  - Profile management with video intro
  - Service listing and pricing
  - Availability calendar
  - Booking management
  - Chat with visitors
  - Earnings dashboard
  - Payout requests

### 4. Supabase Backend (`/supabase`)
- **Database**: PostgreSQL with Row Level Security
- **Authentication**: Email/password, OAuth, phone
- **Storage**: Profile photos, guide videos, review images
- **Realtime**: Live chat, booking updates
- **Edge Functions**: Payment processing, notifications

## Data Flow

### Booking Flow
```
Visitor App → Search Guides → View Profile → Check Availability
     ↓
Select Service & Date → Create Booking → Payment
     ↓
Supabase Database → Notification to Guide
     ↓
Guide App → Accept/Reject Booking → Notification to Visitor
     ↓
On Completion → Review & Rating → Payout to Guide
```

### Chat Flow
```
Visitor/Guide → Send Message → Supabase Realtime
     ↓
Other Party Receives → Push Notification (if offline)
     ↓
Message History Stored in Database
```

## Security

### Authentication
- JWT-based authentication via Supabase Auth
- Secure password hashing
- Email verification required
- Phone number verification for guides

### Data Security
- Row Level Security (RLS) on all tables
- User data isolated by user_id
- Encrypted data transmission (HTTPS/WSS)
- Secure storage bucket policies

### Payment Security
- PCI compliance via Stripe
- No credit card data stored locally
- Secure webhook verification
- Transaction logging

## Scalability

### Database
- PostgreSQL with proper indexing
- Connection pooling
- Prepared statements
- Query optimization

### Realtime
- Supabase Realtime for live features
- WebSocket connections
- Presence tracking
- Broadcast channels

### Storage
- CDN for static assets
- Image optimization
- Lazy loading
- Progressive image loading

## Deployment

### Web
- **Platform**: Vercel
- **CI/CD**: GitHub Actions
- **Environment**: Production, Staging

### Mobile
- **Android**: Google Play Store
- **iOS**: Apple App Store
- **CI/CD**: Codemagic or Bitrise

### Backend
- **Platform**: Supabase Cloud
- **Database**: Managed PostgreSQL
- **Functions**: Edge runtime (Deno)

## Monitoring & Analytics

- **Error Tracking**: Sentry
- **Analytics**: Google Analytics, Mixpanel
- **Performance**: Lighthouse, Firebase Performance
- **Logs**: Supabase Dashboard, CloudWatch

## Multi-Language Support

All user-facing content supports:
- English (EN) - Primary
- French (FR) - Secondary
- Haitian Creole (HT) - Local

## Future Enhancements

- AI-powered guide recommendations
- Group booking capabilities
- Video calls for virtual tours
- Integration with travel booking platforms
- Admin dashboard for platform management
- Analytics and reporting tools
