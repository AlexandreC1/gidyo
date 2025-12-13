# Getting Started with GIDYO

This guide will help you set up and run the GIDYO platform locally.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** 18+ and npm
- **Flutter SDK** 3.0+
- **Git**
- **Supabase CLI** (optional for local development)
- **Code Editor** (VS Code recommended)

## Project Structure

```
gidyo/
├── web/                    # Next.js 14 landing page
├── mobile/                 # Flutter mobile app (visitor + guide)
├── supabase/              # Database migrations & edge functions
└── docs/                  # Documentation
```

## Step 1: Clone the Repository

```bash
git clone <repository-url>
cd gidyo
```

## Step 2: Set Up Supabase

### Option A: Use Supabase Cloud (Recommended for Production)

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note your project URL and anon key from the project settings
3. Apply migrations:
   ```bash
   cd supabase
   supabase link --project-ref <your-project-ref>
   supabase db push
   ```

### Option B: Run Supabase Locally

1. Install Supabase CLI:
   ```bash
   npm install -g supabase
   ```

2. Start local Supabase:
   ```bash
   cd supabase
   supabase start
   ```

3. Note the local URLs and keys displayed

## Step 3: Set Up the Web Landing Page

1. Navigate to the web directory:
   ```bash
   cd web
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Create `.env.local` file:
   ```env
   NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. Run the development server:
   ```bash
   npm run dev
   ```

5. Open [http://localhost:3000](http://localhost:3000) in your browser

## Step 4: Set Up the Mobile App

1. Navigate to the mobile directory:
   ```bash
   cd mobile
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Create `.env` file:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. Run the app:
   ```bash
   # For Android
   flutter run

   # For iOS (macOS only)
   flutter run -d ios

   # For web (testing)
   flutter run -d chrome
   ```

## Step 5: Seed the Database (Optional)

To populate the database with sample data:

```bash
cd supabase
# If using Supabase Cloud
supabase db push

# If using local Supabase
# Migrations are automatically applied on start
```

## Verification Checklist

- [ ] Supabase project is running and accessible
- [ ] Web landing page loads at http://localhost:3000
- [ ] Mobile app runs on emulator/device
- [ ] Database tables are created
- [ ] Sample data is loaded

## Common Issues & Solutions

### Issue: Next.js build fails

**Solution**: Delete `.next` folder and `node_modules`, then run:
```bash
rm -rf .next node_modules
npm install
npm run dev
```

### Issue: Flutter dependencies conflict

**Solution**: Clean and reinstall:
```bash
flutter clean
flutter pub get
```

### Issue: Supabase connection fails

**Solution**:
- Verify your `.env` files have the correct URLs and keys
- Check if Supabase project is running
- Ensure firewall isn't blocking connections

### Issue: Database migrations fail

**Solution**:
```bash
# Reset local database
supabase db reset

# Or re-apply migrations
supabase db push --force
```

## Next Steps

After setup, you can:

1. **Explore the landing page** - View all components and sections
2. **Test the mobile app** - Navigate through visitor and guide flows
3. **Review the database schema** - Check tables in Supabase Studio
4. **Read the architecture docs** - Understand the system design
5. **Start development** - Pick a feature and start building!

## Development Workflow

### Web Development
```bash
cd web
npm run dev          # Start dev server
npm run build        # Build for production
npm run lint         # Run ESLint
```

### Mobile Development
```bash
cd mobile
flutter run          # Run app
flutter test         # Run tests
flutter build apk    # Build Android APK
flutter build ios    # Build iOS app
```

### Database Changes
```bash
cd supabase
supabase migration new <migration_name>  # Create new migration
supabase db push                         # Apply migrations
supabase db reset                        # Reset local database
```

## Environment Variables

### Web (.env.local)
```env
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
```

### Mobile (.env)
```env
SUPABASE_URL=
SUPABASE_ANON_KEY=
STRIPE_PUBLISHABLE_KEY=
```

### Supabase (Dashboard)
```env
STRIPE_SECRET_KEY=
MONCASH_API_KEY=
FCM_SERVER_KEY=
```

## Helpful Resources

- [Next.js Documentation](https://nextjs.org/docs)
- [Flutter Documentation](https://docs.flutter.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

## Getting Help

If you encounter issues:

1. Check the [documentation](./architecture/overview.md)
2. Review [common issues](#common-issues--solutions)
3. Search existing GitHub issues
4. Create a new issue with detailed information

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on how to contribute to this project.
