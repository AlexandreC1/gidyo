# GIDYO Mobile - Visitor & Guide Apps

Flutter mobile application for both visitors and guides on the GIDYO platform.

## Tech Stack

- **Framework**: Flutter
- **Architecture**: Clean Architecture + Provider
- **Backend**: Supabase
- **Languages**: Dart

## Getting Started

1. Install dependencies:
```bash
flutter pub get
```

2. Create `.env` file:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

3. Run the app:
```bash
# Development
flutter run

# For specific platform
flutter run -d ios
flutter run -d android
```

## Project Structure

```
mobile/
├── lib/
│   ├── core/                 # Core functionality
│   │   ├── constants/        # App constants
│   │   ├── utils/            # Utility functions
│   │   ├── errors/           # Error handling
│   │   └── network/          # Network layer
│   ├── features/             # Feature modules
│   │   ├── auth/             # Authentication
│   │   ├── booking/          # Booking management
│   │   ├── chat/             # Messaging
│   │   ├── guide/            # Guide features
│   │   └── profile/          # User profiles
│   └── shared/               # Shared components
│       ├── widgets/          # Reusable widgets
│       └── theme/            # App theming
└── test/                     # Unit & widget tests
```

## Architecture

Following Clean Architecture principles:

- **Presentation Layer**: UI components, pages, state management
- **Domain Layer**: Business logic, entities, use cases
- **Data Layer**: Models, repositories, data sources

## Features

### Visitor App
- Browse and search guides
- Book services
- Real-time chat
- Review and ratings
- Payment integration

### Guide App
- Profile management
- Availability calendar
- Booking management
- Earnings tracking
- Chat with visitors

## Build for Production

```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## Dependencies

Key packages:
- `supabase_flutter` - Backend integration
- `provider` - State management
- `go_router` - Navigation
- `flutter_map` - Maps integration
- `image_picker` - Image upload

## Environment Variables

- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key
- `STRIPE_PUBLISHABLE_KEY` - Stripe public key
