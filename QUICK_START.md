# GIDYO Quick Start Guide

Fast setup guide to get GIDYO running locally.

---

## 🚀 Quick Setup (5 Minutes)

### 1. Clone & Install Dependencies

```bash
# Navigate to project
cd ~/gidyo

# Install Flutter dependencies
cd mobile
flutter pub get

# Go back to root
cd ..
```

### 2. Set Up Supabase (First Time Only)

```bash
# Install Supabase CLI
npm install -g supabase

# Login to Supabase
supabase login

# Link to your project (get project-ref from Supabase dashboard)
supabase link --project-ref YOUR_PROJECT_REF

# Apply database migrations
supabase db push
```

### 3. Configure Environment Variables

```bash
# Copy example env file
cd mobile
cp .env.example .env

# Edit .env with your actual values
code .env
```

Required values:
- `SUPABASE_URL` - From Supabase Dashboard → Settings → API
- `SUPABASE_ANON_KEY` - From Supabase Dashboard → Settings → API
- `STRIPE_PUBLISHABLE_KEY` - From Stripe Dashboard → Developers → API keys
- `GOOGLE_MAPS_API_KEY` - From Google Cloud Console

### 4. Run the App

```bash
# Check available devices
flutter devices

# Run on connected device/emulator
flutter run
```

---

## 📱 Common Commands

### Flutter Commands

```bash
# Run app
flutter run

# Run with hot reload
flutter run --debug

# Build APK
flutter build apk

# Run tests
flutter test

# Clean build
flutter clean && flutter pub get

# Analyze code
flutter analyze
```

### Supabase Commands

```bash
# Start local Supabase (for local development)
supabase start

# Stop local Supabase
supabase stop

# Apply migrations
supabase db push

# Reset database (WARNING: deletes all data)
supabase db reset

# View database diff
supabase db diff

# Generate new migration
supabase migration new migration_name
```

### Git Commands

```bash
# Check status
git status

# Add all changes
git add .

# Commit changes
git commit -m "Your message"

# Push to GitHub
git push origin main

# Pull latest changes
git pull origin main
```

---

## 🗂️ Project Structure

```
gidyo/
├── mobile/                    # Flutter mobile app
│   ├── lib/
│   │   ├── core/             # Core utilities, constants, theme
│   │   ├── features/         # Feature modules (auth, booking, etc.)
│   │   ├── shared/           # Shared widgets (animations, buttons, etc.)
│   │   └── main.dart         # App entry point
│   ├── assets/               # Images, animations, Lottie files
│   ├── .env                  # Environment variables (not in Git)
│   └── pubspec.yaml          # Dependencies
├── supabase/                 # Supabase backend
│   ├── migrations/           # Database migrations
│   └── functions/            # Edge functions
├── docs/                     # Documentation
└── README.md                 # Project overview
```

---

## 🔧 Development Workflow

### 1. Feature Development

```bash
# 1. Pull latest changes
git pull origin main

# 2. Create feature branch (optional)
git checkout -b feature/your-feature-name

# 3. Make changes in VS Code
code .

# 4. Test changes
flutter run

# 5. Commit and push
git add .
git commit -m "Add your feature"
git push origin main
```

### 2. Database Changes

```bash
# 1. Create new migration
supabase migration new add_new_table

# 2. Edit migration file in supabase/migrations/

# 3. Apply migration
supabase db push

# 4. Commit migration file
git add supabase/migrations/
git commit -m "Add database migration"
git push origin main
```

### 3. Testing New Animations

```bash
# 1. Navigate to mobile directory
cd mobile

# 2. Run app with hot reload
flutter run

# 3. Make changes to animation files
# Changes will hot reload automatically!

# 4. Test on different screens:
#    - Home screen: Staggered lists
#    - Guide dashboard: Count-up stats
#    - Booking confirmation: Lottie success
```

---

## 🐛 Troubleshooting

### Flutter Issues

**Problem:** Package conflicts
```bash
flutter clean
flutter pub get
```

**Problem:** Build errors
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

**Problem:** Slow performance
```bash
# Run in release mode
flutter run --release
```

### Supabase Issues

**Problem:** Cannot connect
```bash
# Check if Supabase is running locally
supabase status

# Restart Supabase
supabase stop
supabase start
```

**Problem:** Migration errors
```bash
# Reset database (WARNING: deletes data)
supabase db reset
```

**Problem:** Authentication issues
```bash
# Check auth settings in Supabase dashboard
# Ensure user exists in auth.users AND users table
```

---

## 📦 Useful Scripts

### Check Everything is Working

```bash
# From gidyo/ directory

# 1. Check Flutter
cd mobile && flutter doctor

# 2. Check Supabase connection
supabase status

# 3. Run analyzer
flutter analyze

# 4. Run tests
flutter test
```

### Deploy to Production

```bash
# 1. Build release APK
cd mobile
flutter build apk --release

# 2. APK location:
# build/app/outputs/flutter-apk/app-release.apk

# 3. Build iOS (on Mac only)
flutter build ios --release
```

---

## 🎨 Key Features to Test

After setup, test these features:

### 1. Authentication
- Sign up as visitor
- Sign up as guide
- Login/logout
- Password reset

### 2. Visitor Features
- Browse guides (see staggered animations!)
- View guide profile
- Book a service
- View bookings
- Chat with guide

### 3. Guide Features
- Complete onboarding
- Set up services
- View dashboard (see count-up animations!)
- Manage availability
- Accept/decline bookings

### 4. Animations (NEW!)
- Home screen staggered guide cards
- Dashboard animated stat cards
- Booking confirmation Lottie animation
- Smooth page transitions

---

## 📚 Documentation

- **Full Supabase Setup**: See [SUPABASE_SETUP_GUIDE.md](./SUPABASE_SETUP_GUIDE.md)
- **Firebase FCM Setup**: See [docs/FIREBASE_CLOUD_MESSAGING_SETUP.md](./docs/FIREBASE_CLOUD_MESSAGING_SETUP.md)
- **Supabase README**: See [supabase/README.md](./supabase/README.md)

---

## 🆘 Getting Help

1. **Check the logs:**
   - Flutter: Check VS Code Debug Console
   - Supabase: Supabase Dashboard → Logs

2. **Common error solutions:**
   - See Troubleshooting section above
   - Check GitHub Issues

3. **Supabase Dashboard:**
   - [https://app.supabase.com](https://app.supabase.com)
   - View tables, run SQL queries, check logs

---

## ✅ Checklist for New Developers

- [ ] Flutter installed (`flutter doctor`)
- [ ] Supabase CLI installed (`supabase --version`)
- [ ] Supabase account created
- [ ] Supabase project created
- [ ] Project linked (`supabase link`)
- [ ] Migrations applied (`supabase db push`)
- [ ] `.env` file created and filled
- [ ] Dependencies installed (`flutter pub get`)
- [ ] App runs successfully (`flutter run`)
- [ ] Can sign up/login
- [ ] Can view guides
- [ ] Animations working (home screen, dashboard)

---

**You're ready to develop! 🎉**
