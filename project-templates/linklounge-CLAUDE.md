# Link Lounge - Project Instructions

## Project Overview

Link Lounge is a link-in-bio platform built with Next.js 15, React 19, and Supabase. It provides users with customizable profile pages to share links across social platforms.

## Personas (Select Based on Task)
- **Senior Frontend Engineer**: Profile editor, widgets, layouts, animations
- **Backend Engineer**: API routes, Supabase queries, caching, rate limiting
- **Payments Engineer**: Stripe integration, subscription management
- **Analytics Engineer**: Click tracking, engagement metrics, dashboards
- **Security Engineer**: Auth flows, CAPTCHA, rate limiting, input validation

## Key Principles
- Performance-first (Redis caching everywhere)
- Security-focused (rate limiting, Turnstile CAPTCHA, RLS)
- Accessibility (WCAG compliance)
- Mobile-responsive design
- SEO-optimized public profiles

## Tech Stack

- **Framework**: Next.js 15 (App Router)
- **React**: React 19 with Server Components
- **Database**: Supabase (PostgreSQL)
- **Cache**: Redis (Upstash)
- **Auth**: JWT + Supabase Auth + OAuth (Google, GitHub, Discord, Instagram)
- **Styling**: Tailwind CSS + Radix UI
- **Email**: SendGrid
- **Analytics**: Custom analytics with real-time tracking
- **Deployment**: Vercel

## File Organization

### `/src/lib/` - Core Libraries

#### Root Files (Shared Logic)
- `auth.ts` - JWT token generation/verification
- `cache.ts` - React native cache wrapper (request deduplication)
- `constants.ts` - App configuration and constants
- `validations.ts` - Zod schemas (single source of truth)
- `rate-limit.ts` - Rate limiting with Redis fallback
- `rbac.ts` - Role-based access control logic
- `rbac-server.ts` - Server-only RBAC wrapper
- `performance.ts` - Client-side performance utilities (debounce, throttle)
- `supabase.ts` - Supabase client initialization

#### `/src/lib/utils/` - Specialized Utilities
- `async-orchestration.ts` - Server-side async patterns (concurrency control, resource management)
- `react-concurrent.tsx` - React 18+ concurrent features (useTransition, Error boundaries)
- `api-cache.ts` - Redis cache re-exports for API routes
- `cache-revalidation.ts` - ISR revalidation utilities
- `animations.ts` - Animation helpers
- `debounce.ts` - Debounce utility (legacy, prefer `performance.ts`)
- `security.ts` - Security validation helpers
- `turnstile.ts` - Cloudflare Turnstile verification

#### `/src/lib/services/` - External Service Integrations
- `supabase-queries.ts` - Database query functions
- `sendgrid-email.ts` - Email service
- `totp-service.ts` - 2FA TOTP implementation
- `failed-attempts.ts` - Login attempt tracking
- `error-logging.ts` - Error logging service

#### `/src/lib/cache/` - Caching Infrastructure
- `redis.ts` - Redis cache implementation (Upstash)

#### `/src/lib/security/` - Security Modules
- `input-validation.ts` - Re-exports from validations.ts + sanitization utilities

### `/src/app/api/` - API Routes

#### Authentication (`/auth/`)
- `login/`, `register/`, `logout/` - Core auth
- `2fa/` - Two-factor authentication (setup, verify, enable, disable)
- `request-reset/`, `reset-password/` - Password recovery
- `delete-account/`, `request-reactivation/` - Account management
- `verify-email/`, `send-verification/` - Email verification

#### Data Routes
- `links/` - Link CRUD operations
- `pages/` - User pages management
- `widgets/` - Widget configuration
- `analytics/` - Analytics data
- `profile/` - Profile management

#### Cron Jobs (`/cron/`)
- `daily/`, `hourly/`, `weekly/` - Scheduled tasks (protected by CRON_SECRET)

### `/src/components/` - React Components

#### By Feature
- `auth/` - Authentication forms
- `profile/` - Profile display and editing
- `dashboard/` - Dashboard layouts
- `analytics/` - Analytics visualizations
- `settings/` - User settings
- `landing/` - Landing page components
- `support/` - Support features

#### Shared
- `ui/` - Base UI components (Radix-based)
- `shared/` - Reusable composite components

## Key Patterns

### Validation
All validation schemas are defined in `/src/lib/validations.ts`. The `/src/lib/security/input-validation.ts` re-exports these schemas and adds sanitization utilities. Never duplicate schemas.

### Rate Limiting
Rate limits are defined in `/src/lib/rate-limit.ts`. Auth routes skip rate limiting in development for easier testing. Key configs:
- `auth:login` - 5 attempts/15min
- `auth:register` - 3/hour
- `auth:password-reset` - 3/15min
- `auth:2fa` - 10/5min
- `auth:delete-account` - 3/hour

### Caching Strategy
- **React Cache** (`lib/cache.ts`): Request deduplication within a single request
- **Redis Cache** (`lib/cache/redis.ts`): Distributed caching across serverless instances
- **ISR Revalidation** (`lib/utils/cache-revalidation.ts`): Next.js static regeneration

### RBAC Separation
- `rbac.ts`: Core logic (shared)
- `rbac-server.ts`: Server-only wrapper with session handling

### 2FA Implementation
Full TOTP implementation using `otplib`:
- Setup: `/api/auth/2fa/setup` generates secret + QR code
- Verify: `/api/auth/2fa/verify-setup` confirms setup
- Login: Checks `twoFactorEnabled` flag and verifies TOTP code
- Dev bypass: Code `000000` accepted in development mode

## Development Notes

### Environment Variables
Required variables are documented in `.env.example`. Key ones:
- `NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `JWT_SECRET`
- `SENDGRID_API_KEY`
- `UPSTASH_REDIS_REST_URL`, `UPSTASH_REDIS_REST_TOKEN`
- `CRON_SECRET` (for cron job authentication)

### Testing
- Tests are in `/tests/` directory
- Run: `npm test` (579 tests total, 532 pass without server)
- Structure: api/, components/, integration/, security/, unit/
- Mobile tests: `cd mobile && npm test` (76 tests)

**Note**: Some integration tests require `npm run dev` to be running as they make HTTP requests to localhost:3000. These tests are in:
- `tests/api/links-crud.test.ts`
- `tests/api/profiles-crud.test.ts`
- `tests/api/widgets-crud.test.ts`
- `tests/api/reports-crud.test.ts`
- `tests/api/admin-support.test.ts`

### Database Migrations
Migrations are in `/src/lib/supabase-migrations/`. Apply via Supabase MCP or dashboard.

## Recent Changes (2025-12)

- Added rate limiting to all critical auth routes
- Added 2FA dev bypass (code 000000)
- Consolidated validation schemas
- Removed legacy Supabase client utilities
- Archived session documentation to `/docs/archive/`

## Recent Changes (2026-01)

- Added premium UI animations to landing page (beam sweep, glow hover, spotlight, blur reveal)
- Created React Native Expo iOS app in `/mobile` directory
- Added App Store screenshot automation with Playwright
- Fixed iPad responsive layouts in mobile app
- Fixed test suite issues:
  - RBAC tests now use `admins` table for admin role assignment
  - RLS tests properly handle both error and empty data responses
- Mobile app features: Supabase integration, link import, profile customization

### Architecture Improvements (January 2026)

**Validation & Schema Consolidation**:
- Centralized all Zod schemas in `validations.ts` (15+ new schemas)
- Removed duplicate validation functions from `auth.ts`
- API routes now use centralized schemas instead of inline definitions

**Supabase Client Factory**:
- Added `getSupabaseClientForRoute(role)` in `supabase.ts`
- Use 'anon' for public reads (respects RLS), 'service' for mutations

**Enhanced Error Logging** (`error-logging.ts`):
- Added severity levels: error, warning, info, critical
- Added error types: validation, auth, database, network, render, unknown
- Auto-detection: browser, OS, device type from user agent
- Error fingerprinting for deduplication
- Session tracking with sessionStorage
- Helper functions: `logCriticalError()`, `logWarning()`, `logApiError()`

**Enhanced Analytics Tracking** (`analytics-tracking.ts`):
- 40+ tracking fields for comprehensive metadata
- UTM parameter tracking (source, medium, campaign, term, content)
- Session tracking with unique session IDs
- Engagement metrics: scroll depth, time on page, bounce detection
- Click context: position, time to click, link position
- Connection info: type, mobile data detection
- Browser/OS version detection functions

**RLS Policy Optimization** (Migration 032):
- Fixed auth_rls_initplan issues with `(SELECT auth.uid())` wrapper
- Consolidated multiple permissive policies on pages table
- Created `get_analytics_totals()` RPC for efficient analytics sums

**Analytics Views** (Migration 033):
- `error_summary` - Aggregated errors by day/type/severity
- `traffic_summary` - Daily traffic with engagement metrics
- `geographic_summary` - Geographic distribution of views
- All views use `security_invoker = true` for proper RLS

**Supabase Performance Fixes**:
- Applied optimized RLS policies via Supabase MCP
- Fixed table references (link_analytics vs analytics)
- Fixed suggestions table columns (suggestion/category vs type/message)
