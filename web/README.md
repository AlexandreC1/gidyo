# GIDYO Web - Marketing Landing Page

Next.js 14 marketing website for GIDYO marketplace platform.

## Tech Stack

- **Framework**: Next.js 14 (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS
- **Deployment**: Vercel (recommended)

## Getting Started

1. Install dependencies:
```bash
npm install
```

2. Create `.env.local` file:
```env
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

3. Run development server:
```bash
npm run dev
```

4. Open [http://localhost:3000](http://localhost:3000)

## Project Structure

```
web/
├── src/
│   ├── app/              # App router pages
│   ├── components/       # React components
│   ├── lib/             # Utilities and configurations
│   └── styles/          # Global styles
├── public/              # Static assets
└── package.json
```

## Features

- Responsive landing page
- Guide discovery interface
- Service browsing
- SEO optimized
- Multi-language support (EN/FR/HT)

## Build for Production

```bash
npm run build
npm start
```

## Environment Variables

- `NEXT_PUBLIC_SUPABASE_URL` - Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Supabase anonymous key
