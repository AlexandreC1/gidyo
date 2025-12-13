# GIDYO

**Connecting International Visitors with Vetted Local Guides in Haiti**

GIDYO is a marketplace platform that bridges the gap between travelers seeking authentic experiences and trusted local guides in Haiti.

## 🚀 Project Status

**Foundation Complete** - All core infrastructure is set up and ready for development.

## 📁 Project Structure

```
gidyo/
├── web/                    # Next.js 14 marketing website (READY)
├── mobile/                 # Flutter mobile app - visitor + guide (READY)
├── supabase/              # Backend & database (READY)
│   └── migrations/        # Database schema & seed data
└── docs/                  # Documentation (READY)
    └── architecture/      # System design docs
```

## 🛠 Technology Stack

### Frontend
- **Web**: Next.js 14 + TypeScript + Tailwind CSS
- **Mobile**: Flutter + Dart (Clean Architecture)

### Backend
- **Database**: PostgreSQL (via Supabase)
- **Auth**: Supabase Auth
- **Storage**: Supabase Storage
- **Realtime**: Supabase Realtime
- **Payments**: Stripe + MonCash

## ✨ Features Implemented

### Landing Page (Web)
✅ Responsive navbar with language switcher
✅ Hero section with search functionality
✅ How It Works (tabbed for visitors/guides)
✅ Featured guides carousel
✅ Services grid (8 service types)
✅ Trust & Safety section
✅ Testimonials carousel
✅ Guide recruitment with earnings calculator
✅ Comprehensive footer

### Database Schema
✅ 13 tables with relationships
✅ Row Level Security (RLS) policies
✅ Automated triggers and functions
✅ Seed data for service types

### Mobile App Structure
✅ Clean architecture folder structure
✅ Feature-based organization
✅ Ready for development

## 🚦 Quick Start

### Prerequisites
- Node.js 18+
- Flutter SDK 3.0+
- Git

### 1. Set Up Web Landing Page

```bash
cd web
npm install
cp .env.example .env.local  # Add your Supabase credentials
npm run dev
```

Open [http://localhost:3000](http://localhost:3000)

### 2. Set Up Mobile App

```bash
cd mobile
flutter pub get
flutter run
```

### 3. Set Up Supabase

```bash
# Create a project at supabase.com
cd supabase
supabase link --project-ref <your-ref>
supabase db push
```

**Detailed setup instructions:** [docs/GETTING_STARTED.md](./docs/GETTING_STARTED.md)

## 📚 Documentation

- [Getting Started Guide](./docs/GETTING_STARTED.md) - Complete setup instructions
- [Architecture Overview](./docs/architecture/overview.md) - System design
- [Web README](./web/README.md) - Landing page details
- [Mobile README](./mobile/README.md) - Mobile app details
- [Supabase README](./supabase/README.md) - Backend details

## 🎨 Brand Colors

- **Primary Navy**: #1E3A5F
- **Teal Accent**: #0D9488
- **Golden**: #D97706
- **Light Gray**: #F3F4F6

## 🗺 Roadmap

### Phase 1: Foundation ✅ COMPLETE
- [x] Project structure
- [x] Database schema
- [x] Landing page
- [x] Mobile app scaffold

### Phase 2: Core Features (Next)
- [ ] Authentication (email, phone, OAuth)
- [ ] Guide profile creation
- [ ] Visitor profile creation
- [ ] Search & filtering
- [ ] Booking system
- [ ] Payment integration

### Phase 3: Communication
- [ ] Real-time chat
- [ ] Push notifications
- [ ] Email notifications
- [ ] SMS notifications

### Phase 4: Advanced Features
- [ ] Reviews & ratings
- [ ] Favorites
- [ ] Multi-day packages
- [ ] Admin dashboard
- [ ] Analytics

## 🌍 Multi-Language Support

The platform supports:
- 🇺🇸 English (EN) - Primary
- 🇫🇷 French (FR) - Secondary
- 🇭🇹 Haitian Creole (HT) - Local

## 🤝 Contributing

This is a private project. For team members:

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Commit changes: `git commit -m 'Add some feature'`
3. Push to branch: `git push origin feature/your-feature`
4. Open a Pull Request

## 📝 License

Proprietary - All rights reserved

## 🇭🇹 Made with ❤️ for Haiti

---

**Need help?** Check [GETTING_STARTED.md](./docs/GETTING_STARTED.md) or create an issue.
