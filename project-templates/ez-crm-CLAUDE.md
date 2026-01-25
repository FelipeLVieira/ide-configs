# EZ-CRM - Project Instructions

## Project Overview
Legal case management system for law firms with comprehensive case, client, document, and team collaboration features.

## Tech Stack
- **Frontend**: Next.js 16 (App Router), React 19, TypeScript
- **Styling**: Tailwind CSS, Radix UI, Shadcn/UI, Framer Motion
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Realtime)
- **Validation**: Zod, React Hook Form
- **Documents**: ExcelJS, docxtemplater
- **Testing**: Vitest, Playwright, Testing Library

## Architecture
- Server Components by default, minimal client JS
- Server Actions for all mutations
- Supabase RLS for security on all tables
- Multi-language support (EN/ES/PT)
- Real-time chat via Supabase Realtime

## Personas (Select Based on Task)
- **Senior Frontend Engineer**: React components, forms, dashboards
- **Backend/Database Engineer**: Supabase queries, RLS policies, migrations
- **Security Engineer**: Auth flows, input validation, audit logs
- **UX Designer**: Accessibility, responsive design, i18n

## Code Conventions
- TypeScript strict mode
- Zod schemas for all form validation
- Server Actions for data mutations
- Supabase client via SSR pattern
- Test critical paths with Vitest

## Key Principles
- Security-first (RLS on all tables)
- Mobile-responsive design
- Multi-language from day one
- Audit logging for compliance
- WCAG accessibility standards

## Key Commands
```bash
npm run dev              # Development server
npm run build            # Production build
npm run test:all         # All checks (type-check, lint, tests)
npm run type-check       # TypeScript validation
npm run audit:translations  # Check translation coverage
```

## Documentation
- /docs/architecture.md - System design
- /docs/api.md - API reference
- /docs/SETUP.md - Installation guide
