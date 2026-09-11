# Hatri — Backend Spec

> Canonical backend architecture for Hatri.
> This document supersedes everything before it. When code disagrees with this doc, update this doc first, then fix the code.

**Version:** 0.5
**Last updated:** 2026-09-11
**Owner:** maharshi

---

## 0. What is Hatri

Hatri is the events OS for your city. Open mics, gigs, markets, meetups, workshops, exhibitions, community events. One honest feed sorted by what's near you and what your people saved.

**Distribution:** Flutter mobile app (iOS + Android) + landing site (`hatri.online`) + admin/business dashboards.
**Launch:** V1 rollout starts city by city. First city picked from waitlist demand.
**Users:** Gen Z + young millennials (18-30) in Indian cities, Tier 2 first.

---

## 1. Repository topology

```
flutter_projects/
├── hatri/              ← Flutter mobile app
├── hatri-web/          ← Landing site (Next.js). Lives at hatri.online
├── hatri-dashboard/    ← Admin + business owner dashboards. Coming Sprint 3
└── hatri-backend/      ← ONE Node backend serving every client
```

**Rule:** `hatri-backend` is the ONLY service that talks to Supabase. Neither the app nor the web nor the dashboard uses the Supabase client SDK directly. All persistence flows through the backend API.

**Exception:** the `hatri-web` waitlist route currently writes directly to Supabase's `waitlist` table using the service_role key. This stays local to the landing until backend is up, then may migrate to `hatri-backend/api/v1/waitlist`.

---

## 2. Scope of MVP (V1)

**In scope for launch:**
- Discovery feed (events sorted by proximity, save count, social signal)
- 12 event categories with text-only chips (no emoji): OPEN_MIC, FESTIVAL, WORKSHOP, MEETUP, MARKET, EXHIBITION, MUSIC, ACTIVITY, COLLEGE_EVENT, COMMUNITY_MEETUP, GAMING, WELLNESS
- Save + share + add-to-calendar per event
- 24-hour + 2-hour reminders for saved events (push)
- Maker profiles (cafés, collectives, crews) with follow + WhatsApp booking
- Weekly Issue: magazine drop every Monday, per city, community-authored
- Phone OTP auth (India-first, MSG91)
- City auto-detect via GPS on first launch, manual fallback
- Deep links on `hatri.online/e/{eventId}` with SSR preview pages
- Business owner portal (dashboard): create + moderate own events
- Admin portal: moderate everything, approve business owner claims

**Explicitly OUT of scope for V1:**
- **RSVP flow** (no `/events/:id/rsvp` endpoint, no `attendees` table). Users save, share, add to calendar, then register via the maker's external link.
- In-app ticketing (defer to external ticket providers)
- Payments (defer)
- User-to-user DMs (defer to Sprint 7+)
- iOS-first anything: Android + iOS ship together at V1

---

## 3. Tech stack (locked)

### Backend runtime
- **Node.js 20 LTS**
- **TypeScript 5.x (strict mode)**
- **NestJS 10** (framework)
- **Prisma 5.x** (ORM, code-first migrations)
- **OpenAPI 3 via `@nestjs/swagger`** (auto-generated docs at `/docs`)

### Persistence
- **Supabase Postgres** (managed, `ap-south-1` Mumbai region, currently `t3.nano`)
- **Upstash Redis** (BullMQ queue + rate limits + hot cache)
- **AWS S3** for media (event covers, maker logos, community uploads)

### External services

| Service | Purpose | Free tier | Overage |
|---|---|---|---|
| **Supabase** | Postgres + Storage | 500 MB DB, 1 GB storage | Pro ₹2,000/mo if we outgrow |
| **Upstash Redis** | Queue + cache | 10k commands/day | Pay-per-request after |
| **AWS S3** | Media storage | N/A | ~₹200/mo at MVP scale |
| **MSG91** | Phone OTP (SMS) | Pay per SMS | ~₹0.15/OTP after DLT approval |
| **Resend** | Transactional email | 3,000/month free | Pay after |
| **Firebase FCM** | Push notifications | Free forever | Free |
| **Firebase Crashlytics** | Mobile crash reporting | Free forever | Free |
| **BetterStack Logs** | Backend structured logs, infra observability | Generous free tier | Pay for retention |
| **BetterStack Uptime** | Uptime monitoring + alerts | 10 monitors free | Cheap after |
| **BetterStack Status Pages** | Public status page | Included | Included |
| **Mixpanel** | Product analytics (funnels, cohorts, retention) | 100k MTUs / 1M events / mo | Pay after |
| **AppsFlyer** | Mobile attribution (MMP), deep-link + install tracking | Free up to 12k conversions/mo | Pay after |
| **Google Cloud Vision** | Safe search + OCR on uploads | 1,000 requests/mo free | $1.50 per 1k after |
| **OpenStreetMap tiles** | Map view (native OSM tiles, no API key) | Free forever | N/A |
| **Shorebird** | Flutter OTA patches | Free tier for solo | Pay-per-patch after |
| **Cloudflare Pages** | SSR preview pages at hatri.online/e/{id} | Free forever | Free |

### Deployment
- **Vercel** for `hatri-web` (landing) and `hatri-dashboard` (admin/business)
- **Render** for `hatri-backend` (Node service + workers + cron)
- **Cloudflare Pages** for SSR share previews at `hatri.online/e/{id}`
- **GitHub Actions** for CI (test, typecheck, lint on every PR)

### Auth model
- **Phone OTP → JWT** (access token 15 min, refresh token 30 days with rotation)
- **OTP is 6 digits** (industry standard: Instagram, WhatsApp, banks). MSG91 DLT template must declare a 6-digit numeric variable slot.
- MSG91 for OTP delivery in India
- Refresh token stored in httpOnly cookie for web, secure storage for mobile
- Access token in Authorization header
- Refresh token rotates on every use, old token blacklisted in Redis 60 seconds to handle concurrent requests

### API design
- REST, JSON, versioned at `/api/v1`
- OpenAPI 3 auto-generated by NestJS Swagger
- Public docs at `hatri-backend.onrender.com/docs`
- Admin docs at `hatri-backend.onrender.com/docs/admin` (IP-restricted)
- All list endpoints paginated with cursor: `?cursor=...&limit=20`
- All timestamps ISO 8601 UTC
- All monetary values in paise (integer, no floats)

---

## 4. Repository structure — `hatri-backend/`

```
hatri-backend/
├── src/
│   ├── main.ts                       # NestJS bootstrap
│   ├── app.module.ts
│   ├── modules/
│   │   ├── auth/                     # Phone OTP + JWT
│   │   ├── users/                    # User profiles, preferences
│   │   ├── events/                   # Event CRUD, discovery
│   │   ├── makers/                   # Business owners + venues
│   │   ├── saves/                    # Save/unsave, reminder scheduling
│   │   ├── uploads/                  # S3 presign + Cloud Vision moderation
│   │   ├── weekly-issue/             # Magazine generation
│   │   ├── notifications/            # FCM + push token management
│   │   ├── admin/                    # Moderation queues, approvals
│   │   ├── analytics/                # Mixpanel + AppsFlyer server-side
│   │   ├── attribution/              # AppsFlyer S2S postbacks
│   │   └── cities/                   # City registry + gating
│   ├── shared/
│   │   ├── prisma/                   # Prisma service, extensions
│   │   ├── redis/                    # BullMQ + cache
│   │   ├── outbox/                   # Outbox pattern for domain events
│   │   ├── ratelimit/                # Redis-backed rate limiter
│   │   └── logging/                  # BetterStack transport
│   └── jobs/
│       ├── save-reminder.job.ts      # 24h + 2h before event
│       ├── weekly-issue.job.ts       # Monday 9am cron
│       ├── popularity-refresh.job.ts # Every 15 min
│       ├── moderation.job.ts         # Cloud Vision safe search
│       ├── ocr.job.ts                # Cloud Vision text detection
│       └── mixpanel-batch.job.ts     # Batch send to Mixpanel
├── prisma/
│   ├── schema.prisma
│   ├── migrations/
│   └── seed.ts
├── test/
│   ├── e2e/
│   └── integration/
├── docker-compose.dev.yml            # Local Postgres + Redis
├── Dockerfile                        # For Render deploy
├── .env.example
├── package.json
└── tsconfig.json
```

---

## 5. Data model

Full Prisma schema deferred to first commit. Key entities:

### Users + auth
- `User` (id, phone, city, homeCity, dob, displayName, avatarUrl, roles[], createdAt, deletedAt, deleteAt)
  - `deleteAt` — set to `now() + 30d` on account deletion request. Cron sweeps and hard-deletes after 30 days.
- `RefreshToken` (id, userId, hash, expiresAt, revokedAt, deviceFingerprint)
- `DeviceToken` (id, userId, fcmToken, platform, appflyerId, lastSeenAt)

### Cities
- `City` (id, slug, name, state, active, launchedAt, waitlistCount, timezone)

### Events
- `Event` (id, cityId, category, title, slug, description, coverS3Key, startAt, endAt, venueName, latitude, longitude, addressText, priceMin, priceMax, currency, externalRegisterUrl, ageMin, ageMax, makerId, organizerId, status, moderationStatus, publishedAt, createdAt, deletedAt)
  - `status`: DRAFT, PENDING_REVIEW, PUBLISHED, ARCHIVED
  - `moderationStatus`: PENDING, PASSED, FLAGGED_ADULT, FLAGGED_VIOLENCE, FLAGGED_OTHER
  - `category`: OPEN_MIC, FESTIVAL, WORKSHOP, MEETUP, MARKET, EXHIBITION, MUSIC, ACTIVITY, COLLEGE_EVENT, COMMUNITY_MEETUP, GAMING, WELLNESS
- `EventStat` (eventId, views, saves, shares, popularityScore, updatedAt)

### Makers
- `Maker` (id, cityId, name, slug, category, logoS3Key, description, whatsapp, instagram, latitude, longitude, addressText, verifiedAt, ownerUserId, tier)
  - `tier`: FREE, PRO (first 100 per city stay FREE forever)
- `MakerFollow` (id, userId, makerId, createdAt)

### Saves + reactions
- `Save` (id, userId, eventId, createdAt, reminderScheduledAt)
- `Reaction` (id, userId, targetType, targetId, reaction, createdAt)
  - `targetType`: EVENT, WEEKLY_ISSUE_SECTION, MAKER
  - `reaction`: HEART, FIRE, LAUGH, EYES (four reactions locked)

### Weekly Issue
- `WeeklyIssue` (id, cityId, volume, publishedAt, coverS3Key)
- `WeeklyIssueSection` (id, weeklyIssueId, kind, payloadJson, order)
  - `kind`: COVER, EDITORS_LETTER, STATS, FEATURE, GROUP_CHAT, ROLL_CALL, AWARDS, BACK_COVER
- `CommunityPost` (id, cityId, userId, kind, content, mediaS3Key, moderationStatus, createdAt)

### Outbox (domain events)
- `Outbox` (id, aggregate, aggregateId, eventName, payload, publishedAt, createdAt)

### Waitlist (Supabase, already live)
- `Waitlist` (id, email, audience, source, city, ip_hash, user_agent, resend_synced, created_at)

### Attribution (AppsFlyer)
- `AppsflyerInstall` (id, userId, appflyerId, mediaSource, campaign, agencyId, adId, siteId, subSiteId, installedAt, raw JSON)

---

## 6. API surface (v1, high-level)

Full OpenAPI spec at `/docs` post-launch. Sketch of route groups:

### Public + user (JWT required)
- `POST /api/v1/auth/otp/request` — send OTP to phone
- `POST /api/v1/auth/otp/verify` — verify, get JWT + refresh
- `POST /api/v1/auth/refresh` — rotate refresh token
- `POST /api/v1/auth/logout` — revoke refresh
- `GET  /api/v1/me` — current user
- `PATCH /api/v1/me` — update profile
- `DELETE /api/v1/me` — soft delete account (30-day tombstone)
- `POST /api/v1/me/devices` — register FCM token + AppsFlyer ID
- `GET  /api/v1/cities` — list active cities
- `GET  /api/v1/events` — discovery feed
- `GET  /api/v1/events/:id` — event detail
- `POST /api/v1/events/:id/save`
- `DELETE /api/v1/events/:id/save`
- `POST /api/v1/events/:id/share` — track share (analytics)
- `POST /api/v1/events/:id/react`
- `GET  /api/v1/makers` — list makers, filter by city/category
- `GET  /api/v1/makers/:id`
- `POST /api/v1/makers/:id/follow`
- `DELETE /api/v1/makers/:id/follow`
- `GET  /api/v1/weekly-issue/current`
- `GET  /api/v1/weekly-issue/:volume`
- `POST /api/v1/uploads/presign` — S3 upload URL + kick off moderation job
- `POST /api/v1/reports` — user reports on event/maker/post

### Business owner + organizer (elevated JWT)
- `POST /api/v1/business/events` — create event (auto PENDING_REVIEW → PUBLISHED after moderation)
- `POST /api/v1/business/events/from-flyer` — upload flyer, run OCR, return prefilled fields
- `PATCH /api/v1/business/events/:id`
- `DELETE /api/v1/business/events/:id`
- `POST /api/v1/business/makers/claim` — claim a maker profile
- `PATCH /api/v1/business/makers/:id`
- `GET  /api/v1/business/analytics` — my events stats

### Admin (MODERATOR + ADMIN JWT)
- `GET  /api/v1/admin/moderation/queue`
- `POST /api/v1/admin/moderation/:id/approve`
- `POST /api/v1/admin/moderation/:id/reject`
- `GET  /api/v1/admin/business/claims`
- `POST /api/v1/admin/business/claims/:id/approve`
- `GET  /api/v1/admin/cities`
- `POST /api/v1/admin/broadcast` — send FCM push to a city

### Attribution (AppsFlyer S2S)
- `POST /api/v1/attribution/appsflyer/postback` — signed S2S postback receiver

---

## 7. Roles + permissions

| Role | Consumer-facing name | Powers |
|---|---|---|
| **USER** | (implicit) | Save, share, react, follow, submit community posts |
| **BUSINESS_OWNER** | MAKER (in-app copy) | All USER powers + create events + edit own maker profile |
| **ORGANIZER** | ORGANIZER | Post pop-up events without a permanent venue |
| **SCENE_HOST** | SCENE HOST | Community moderators, curate the Weekly Issue |
| **MODERATOR** | (never shown to end users) | Moderate all cities' content |
| **ADMIN** | (never shown) | Everything + billing + city gating + broadcast |

**Consumer copy convention:** the app UI says **"MAKER"** for what the backend calls `BUSINESS_OWNER`. Never expose the internal enum in the UI.

---

## 8. Cross-cutting patterns

### Outbox pattern
Domain events (event published, save created, maker verified, etc.) get written to an `Outbox` table in the same transaction as the source of truth. A background worker reads the outbox, publishes to BullMQ, and marks published. Guarantees at-least-once delivery, no lost events on crashes.

### BullMQ jobs
- `save.reminder.24h` and `save.reminder.2h` — scheduled per save
- `event.published` — fan out to followers of the maker + city subscribers
- `weekly-issue.generate` — cron Monday 9 AM per active city
- `popularity.refresh` — cron every 15 minutes
- `moderation.image` — kicked off by upload
- `event.ocr` — kicked off by post-from-flyer
- `mixpanel.batch` — batch events every 30 seconds to Mixpanel
- `appsflyer.postback` — handle installs, purchases, custom events

All jobs are idempotent, retried with exponential backoff (10 retries max), and drop to a dead-letter queue after.

### Popularity scoring
```
score = views + (saves × 3) + (shares × 4)
```
Refreshed every 15 minutes via cron. Discovery feed sorts by `score DESC, startAt ASC` within the target city.

### Rate limits (Redis-backed)
- OTP request: 3 per phone per hour, 10 per IP per hour
- Waitlist: 5 per IP per minute
- Save/unsave: 30 per user per minute
- API generic: 60 per user per minute

### Idempotency keys
POST endpoints that mutate accept `Idempotency-Key` header. Response cached in Redis 24 hours. Prevents double-save on network retries.

### Age gating
Under-age users see no filtered content at all. Age-gated events are hidden from the feed and 404 on direct URL. Age check runs at query time; users edit DOB in settings, not on signup.

### City gating
Cities have `active: boolean` and a `launchedAt` date. Discovery API only returns events from active cities. Waitlist entries from inactive cities count toward the launch queue and get an email when their city goes live.

---

## 9. Uploads + Google Cloud Vision

**Flow:**
1. Client → `POST /api/v1/uploads/presign` with mime + intended use (event_cover, maker_logo, community_post, event_flyer)
2. Backend returns S3 presigned URL + upload ID
3. Client PUTs the file to S3 directly
4. Client → `POST /api/v1/uploads/:id/complete`
5. Backend kicks off `moderation.image` BullMQ job

**Moderation job (Cloud Vision `SAFE_SEARCH_DETECTION`):**
- Categories: adult, violence, racy, medical, spoof
- Rule: any `LIKELY` or `VERY_LIKELY` → auto-hide, queue for admin review
- `POSSIBLE` → publish but flag in moderator dashboard
- `UNLIKELY` or below → publish immediately

If Cloud Vision is unreachable: publish immediately with a "vision unreachable" flag; moderator dashboard shows the flag so mods can spot-check.

**OCR flow (post-from-flyer, Cloud Vision `TEXT_DETECTION`):**
1. Maker uploads flyer image
2. Backend calls `TEXT_DETECTION` on the S3 object
3. Backend parses raw text with regex heuristics:
   - **Title:** largest text block (top ~30% of image)
   - **Date:** matches `\d{1,2}[/-]\d{1,2}(?:[/-]\d{2,4})?` or day names
   - **Time:** matches `\d{1,2}\s*(?:AM|PM|:\d{2})`
   - **Venue:** line after "at" or largest bottom-third block
   - **Ticket URL:** `https?://\S+`
4. Returns `{ fields: {...prefilled}, moderation: {...} }`
5. Maker confirms/edits → publishes

**Cost estimate at MVP scale:**
- 500 uploads/day × 30 days = 15,000 requests/month
- Vision free tier: 1,000/month
- Overage: 14,000 × $0.0015 = ~$21/month (~₹1,800)

---

## 9.1 Media pipeline (CDN + compression)

### Delivery: CloudFront in front of S3

```
Client (Flutter/Web)
        ↓ read
cdn.hatri.online (CloudFront distribution)
        ↓ cache miss
hatri-media.s3.ap-south-1.amazonaws.com
```

**Setup:**
- CloudFront distribution with S3 as origin
- Custom domain `cdn.hatri.online` via Cloudflare DNS
- Public URLs for event covers + maker logos + community post images
- Signed URLs for private assets (business analytics screenshots, admin evidence uploads)
- Cache TTL: 1 year for immutable content-hashed keys, 60s for mutable keys

**Cost forecast at MVP scale:**
- CloudFront free tier: 1 TB/mo egress free for first 12 months
- After free tier: ~$0.017/GB. At 100 GB/mo = ~₹150/mo
- Alt: Cloudflare in front of S3 has unlimited free egress but adds Workers setup complexity. Deferred.

### Compression pipeline

Two-stage. Client shaves upload bandwidth; server owns authoritative sizes.

**Stage 1 — client-side (Flutter)** via `flutter_image_compress`:
- Compress to **quality 80** before upload
- Max dimensions **2048×2048** (preserve aspect ratio)
- Purpose: saves user bandwidth on slow India mobile networks

**Stage 2 — server-side (Node backend, Sharp)** — authoritative:

```js
sharp(buffer)
  .rotate()                             // auto-orient from EXIF
  .resize(maxWidth, maxWidth, {
    fit: 'inside',
    withoutEnlargement: true,
  })
  .webp({ quality: 70 })                // locked
  .toBuffer()
```

**Generates 3 variants per upload:**

| Variant | Max width | Use | Typical size |
|---|---|---|---|
| `thumb` | 400 px | List thumbnails, avatars | ~15 KB |
| `feed` | 1080 px | Card covers in the discovery feed | ~60 KB |
| `full` | 2048 px | Event detail hero, maker gallery | ~180 KB |

**All variants: WebP at quality 70**, with JPEG fallback for older Android. Storage cost per upload: original + 3 sizes = ~4x per asset. Still tiny at MVP scale (~5 GB total after 25k uploads).

### Bandwidth savings napkin math

- Raw phone camera photo: 3-5 MB
- Client-compressed (Q80, 2048): ~800 KB (5x reduction)
- Server-compressed (Q70 WebP, 1080 feed): ~60 KB (13x further reduction)
- **End-to-end: 20-30x reduction** vs original

Feed scrolls stay snappy on 3G.

### CDN URL scheme

```
cdn.hatri.online/{variant}/{s3Key}.webp

Examples:
cdn.hatri.online/thumb/events/e_abc.webp
cdn.hatri.online/feed/events/e_abc.webp
cdn.hatri.online/full/events/e_abc.webp
```

Content-hashed keys (`e_abc` includes a hash of the content) means we can cache forever; a new upload produces a new key.

### Moderation timing

Cloud Vision `SAFE_SEARCH_DETECTION` runs on the **original** before any variants are generated. If flagged LIKELY or VERY_LIKELY, no variants are produced and the asset is quarantined. Prevents wasted CPU on content that will never publish.

---

## 10. Analytics + observability

### The three-tool split

**Product analytics: Mixpanel**
The main tool for understanding users. Funnels, cohorts, retention, conversion. Every user-facing event goes here.

**Mobile attribution: AppsFlyer**
Where installs come from. Ad campaigns, deep links, referral chains. Attribution + fraud protection.

**Infra observability: BetterStack**
Logs, uptime, status page. Backend health, request traces, error alerting. Never product analytics.

**Mobile crashes: Firebase Crashlytics**
Native SDK for Flutter, free forever. Native crash reports with symbolication. Separate from BetterStack because BetterStack has no Flutter crash SDK.

### Locked event taxonomy (38 events, Mixpanel)

Every event fires client-side via Mixpanel SDK AND server-side batched via `mixpanel.batch` BullMQ job. Server-side is source of truth (client can be dropped, blocked, spoofed).

**Auth**
1. `auth_otp_requested`
2. `auth_otp_verified`
3. `auth_otp_failed`
4. `auth_logout`
5. `auth_deleted`

**Onboarding**
6. `onboarding_started`
7. `onboarding_city_detected`
8. `onboarding_city_manual`
9. `onboarding_interests_set`
10. `onboarding_completed`

**Discovery**
11. `feed_viewed`
12. `feed_scrolled`
13. `filter_applied`
14. `search_performed`

**Event**
15. `event_viewed`
16. `event_saved`
17. `event_unsaved`
18. `event_shared`
19. `event_reacted`
20. `event_external_register_clicked`
21. `event_calendar_added`
22. `event_directions_opened`

**Maker**
23. `maker_viewed`
24. `maker_followed`
25. `maker_unfollowed`
26. `maker_whatsapp_clicked`
27. `maker_instagram_clicked`

**Weekly Issue**
28. `weekly_issue_viewed`
29. `weekly_issue_spread_read`
30. `weekly_issue_shared`

**Community**
31. `community_post_created`
32. `community_post_reacted`
33. `report_submitted`

**Business owner**
34. `business_event_created`
35. `business_event_from_flyer_used`
36. `business_analytics_viewed`

**Notifications**
37. `push_permission_granted`
38. `push_opened`

Every event includes: `user_id`, `city_slug`, `app_version`, `platform`, `session_id`, and any context-specific props (e.g. `category` on `event_saved`).

### AppsFlyer setup

**SDK integration (Flutter):**
- `appsflyer_sdk` package
- Init on app launch with dev key + app ID
- Register FCM token to AppsFlyer for uninstall tracking
- Send `af_login` on auth success
- Send `af_purchase` when we add ticketing (post-MVP)

**S2S (server-to-server) postbacks:**
- Backend receives AppsFlyer postback at `POST /api/v1/attribution/appsflyer/postback`
- Signed with shared secret
- Persists to `AppsflyerInstall` table
- Feeds cohort analysis in Mixpanel via `user_properties` update

**Deep-link + install flow:**
- `hatri.online/e/{eventId}` uses AppsFlyer OneLink
- If user has app installed → opens event detail directly
- If not → App Store / Play Store with deferred deep link
- After install, AppsFlyer restores the deep link → app opens on that event

**Attribution windows:**
- Click-through: 7 days
- View-through: 24 hours
- Reattribution: 90 days

### BetterStack setup

**Backend Logs (structured JSON, sent via Winston/Pino transport):**
```json
{
  "level": "info",
  "service": "hatri-backend",
  "trace_id": "trc_abc",
  "user_id": "u_xyz",
  "route": "POST /api/v1/events/:id/save",
  "duration_ms": 42,
  "message": "event saved"
}
```

**Log levels:**
- `ERROR` — 90-day retention, alerts to Slack + phone
- `WARN` — 90-day retention, alerts on rate spike
- `INFO` — 30-day retention, request logs + business events
- `DEBUG` — 7-day retention, dev only

**Uptime monitors:**
- `hatri-backend.onrender.com/health` — 60s interval, alert on 2 consecutive failures
- `hatri-backend.onrender.com/ready` — 60s interval, checks Postgres + Redis
- `hatri.online` — 60s interval, checks landing site
- `hatri.online/e/test-slug` — 5 min interval, checks Cloudflare Pages SSR

**Public status page:** `status.hatri.online`. Auto-updates from uptime monitors. Component-level: API, Discovery, Waitlist, Push, Media, SSR previews.

**On-call routing:** ERROR-level alerts → Slack `#alerts` → after 5 min unacknowledged → SMS + phone call to on-call.

### Firebase Crashlytics

- Flutter SDK integrated at `main()` bootstrap
- Non-fatal errors also reported (for handled exceptions we want to track)
- User ID and app_version set on init
- Symbolication automatic via Fastlane on release builds

---

## 11. Push notifications (FCM)

### Permission timing
Ask AFTER first meaningful action, not at signup. Trigger: **first save + first scene join**.
Copy: `we'll ping you 2 hours before it starts. no spam, promise.`

### Push types

| Type | Trigger | Copy voice |
|---|---|---|
| `save.reminder.24h` | 24 hours before saved event | `tomorrow. did you forget?` |
| `save.reminder.2h` | 2 hours before | `2 hours to go. move.` |
| `weekly-issue.drop` | Monday 9 AM in user's city TZ | `vol X is out. read it.` |
| `maker.followed_event` | Followed maker publishes a new event | `hoot cafe posted something new` |
| `reengagement.day7` | User inactive 7+ days | Gen Z voice, rotated variants |

### Day-7 re-engagement pool (rotate randomly)
- `your city was busy this week.`
- `we missed you. so did the group chat.`
- `5 things happened. take a look.`
- `you're becoming a legend for missing this.`
- `open the app. change the city.`

Track opens via `push_opened` Mixpanel event with `type` field. Drop variants that underperform after 500 sends each.

---

## 12. Environments

Single-env deploy topology. Each PR to `hatri-backend` gets a Render preview environment auto-provisioned. `main` deploys to production.

- **Local** — Docker Compose (Postgres + Redis) + `hatri-backend` via `pnpm dev`
- **Preview** — Render preview per PR + shared Supabase project + in-memory Redis fallback if Upstash quota hit
- **Prod** — Render production + Supabase Mumbai + Upstash Mumbai + AWS S3 `ap-south-1`

Env vars managed via 1Password + Render dashboard. Committed `.env.example` shows the shape.

---

## 13. Third-party accounts checklist

Ordered by when you actually need each.

**Sprint 0 (this week, partly done)**
- [x] Supabase — Hatri project, Mumbai region, t3.nano
- [x] Domain — `hatri.online` on Hostinger
- [ ] Resend — API key + audiences + domain verification (in progress)
- [ ] BetterStack — logs + uptime + status page project

**Sprint 1 (backend scaffold)**
- [ ] GitHub — `hatri-backend`, `hatri-web` repos
- [ ] Vercel — `hatri-web` + future `hatri-dashboard` projects
- [ ] Render — `hatri-backend` service
- [ ] Upstash — Redis for BullMQ + rate limits
- [ ] AWS S3 — `hatri-media` bucket in `ap-south-1`
- [ ] Firebase — project `hatri-app` (FCM + Crashlytics)
- [ ] Google Cloud — project + Vision API enabled + service account JSON
- [ ] MSG91 — account + DLT template approval (2-3 day wait, start now)
- [ ] Cloudflare — DNS for `hatri.online` + Pages for SSR previews
- [ ] Mixpanel — project + SDK keys
- [ ] AppsFlyer — app registration + dev key + OneLink template

**Sprint 6 (launch prep)**
- [ ] Shorebird — Flutter OTA
- [ ] Google Play Console — ₹2,000 one-time
- [ ] Apple Developer Program — $99/year, 2-3 week verification

---

## 14. Security checklist

- [ ] Every DB write goes through backend with authz check; no direct Supabase writes from client
- [ ] `service_role` key never leaves server env
- [ ] JWT signed with rotating secret, `EXPIRES_IN` short (15 min)
- [ ] Refresh tokens rotate on every use, old tokens blacklisted in Redis
- [ ] All PII (phone, email) encrypted at rest via Supabase
- [ ] IPs hashed with a salt before storage
- [ ] Rate limits on every mutating endpoint
- [ ] Idempotency keys on POST endpoints
- [ ] S3 uploads via presigned URLs, never proxy through backend
- [ ] Cloud Vision moderation on every uploaded image
- [ ] Admin endpoints require `MODERATOR` or `ADMIN` role + IP allowlist
- [ ] OpenAPI `/docs` route disabled in prod, only Swagger JSON exposed at `/docs.json` behind admin auth
- [ ] CORS: only allowlisted origins (`hatri.online`, `dashboard.hatri.online`, dev localhost)
- [ ] No em dashes in error messages either. Small point, real point.
- [ ] Content moderation: any user report auto-hides after 3 reports on same target
- [ ] Under-age content gating enforced at query time, not just UI
- [ ] AppsFlyer S2S postback endpoint verifies HMAC signature before writing

---

## 15. Feature flags

Backend-driven feature flags stored in Postgres, cached in Redis 60s. Read at request time.

Locked flags for V1:
- `city.{slug}.launched` — per-city launch gate
- `weekly-issue.enabled` — kill switch
- `moderation.strict` — flip if bad content wave, drop threshold from LIKELY to POSSIBLE
- `push.day7-reengagement` — pause if open rate tanks
- `analytics.sample-rate` — 0.0 to 1.0, default 1.0
- `mixpanel.enabled` — kill switch if we need to stop sending

Feature flags are NOT for A/B tests. If we want A/B later, pick a proper experimentation tool or Mixpanel's own experiments.

---

## 16. Development workflow

### Local dev
```bash
cd hatri-backend
cp .env.example .env
docker compose -f docker-compose.dev.yml up -d
pnpm install
pnpm prisma migrate dev
pnpm dev
```

Backend runs on `localhost:3001`. Landing runs on `localhost:3000`. Flutter app points at `http://localhost:3001` in dev.

### Testing
- Unit: Vitest
- Integration: Vitest + testcontainers for Postgres
- E2E: Playwright hitting a preview env

### CI (GitHub Actions)
On every PR to `hatri-backend`:
1. Typecheck
2. Lint (ESLint + Prettier)
3. Unit tests
4. Integration tests
5. Prisma format check
6. OpenAPI spec diff (comment on PR)

### Commit style
Conventional commits (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`). Squash-merge to `main`.

---

## 17. Sprint plan (rough)

**Sprint 0** — Alignment (this week)
- Lock decisions in this doc
- Supabase, Resend, BetterStack accounts
- Deploy `hatri-web` (landing) to Vercel with waitlist wired
- Start MSG91 DLT approval

**Sprint 1** — Backend scaffold
- Create `hatri-backend/` with NestJS + Prisma
- Auth module (OTP + JWT)
- User module
- Migrations
- OpenAPI docs live at `/docs`
- BetterStack Logs wired
- Mixpanel + AppsFlyer S2S wired
- Deployed to Render preview per PR

**Sprint 2** — Content APIs
- Event CRUD + discovery feed
- Maker CRUD + follow
- Save + reactions
- Popularity scoring cron
- Uploads + S3 presign + Cloud Vision moderation

**Sprint 3** — Flutter integration
- App points at real backend
- Real auth flow
- Real feed
- Real saves
- Push notification registration (FCM)
- Firebase Crashlytics
- Mixpanel + AppsFlyer SDKs
- OneLink deep links

**Sprint 4** — Admin web dashboard
- `hatri-dashboard` Next.js scaffold
- Moderation queue
- Business owner claims approval
- City management

**Sprint 5** — Business owner web dashboard
- Same repo as admin, gated by role
- Create/edit events
- Post-from-flyer OCR flow
- Own analytics

**Sprint 6** — Weekly Issue + polish
- Weekly Issue generation cron
- Community posts
- Reactions on issue sections
- Push notification variants
- Store submission (Play + App Store)

---

## 18. Open questions (not decided yet)

1. **"Who's going" UI in Flutter app.** Currently implies RSVP. RSVP is removed. Options:
   - a) Remove the section entirely
   - b) Rename to "N people saved this" using save count (my rec)
   - c) Leave as-is and pretend the count is intent (dishonest)

2. **Waitlist API location.** Currently in `hatri-web`. Migrate to `hatri-backend/api/v1/waitlist` when backend is up, or leave at the edge?

3. **Session length.** JWT access token at 15 min → refresh at 30 days. Feels short for a weekly-use app. Consider 90-day refresh + longer access token?

4. **City TZ handling.** Weekly Issue drops "Monday 9 AM in user's city TZ". Assume `Asia/Kolkata` for now. When we go multi-country, need to actually use `City.timezone`.

5. **Vision API failover.** If Cloud Vision is down 6+ hours, queue images or fail the upload? Current plan: publish immediately with a flag. Trade-off: bad content might slip. Acceptable for MVP?

6. **Maker slug collisions.** Two Hoot Cafés in different cities. City-prefix like `raipur/hoot-cafe`? Or unique globally?

7. **Mixpanel + BetterStack overlap.** BetterStack log-analytics can query the same event stream. Do we double-send every event or pick one primary and use the other for backup? Recommend: Mixpanel primary for product events, BetterStack primary for infra/errors, no double-send.

---

## 19. Decision log

Chronological record of every locked decision.

| Date | Decision | Reason |
|---|---|---|
| 2026-09-02 | Modular monolith, not microservices | Solo dev, V1 speed |
| 2026-09-02 | Phone OTP via MSG91 | India-first, DLT-compliant |
| 2026-09-03 | 12 event categories, text-only chips | Locked for MVP |
| 2026-09-04 | Popularity: `views + saves*3 + shares*4`, cron 15 min | Simple, transparent |
| 2026-09-05 | 4 reactions: heart, fire, laugh, eyes | Locked |
| 2026-09-07 | GPS on first launch, no city switcher UI | Simplify onboarding |
| 2026-09-08 | Single-env deploy (main → prod + PR previews) | Solo, avoid staging overhead |
| 2026-09-08 | Push permission after first save + first scene join | Better opt-in rate |
| 2026-09-09 | 30-day soft delete for accounts | Reversible mistakes |
| 2026-09-09 | Age-gated content hidden entirely from under-age users | Safer default |
| 2026-09-09 | 24h + 2h save reminders | Balance signal + fatigue |
| 2026-09-09 | Day-7 re-engagement push, rotated Gen Z variants | Recover soft churn |
| 2026-09-10 | 38 telemetry events locked | Baseline analytics |
| 2026-09-10 | `hatri-backend/` is a sibling folder, NOT `hatri/backend/` | Cleaner separation, dashboards + app share it |
| 2026-09-10 | Node 20 + TypeScript + NestJS + Prisma + OpenAPI Swagger | Stack locked |
| 2026-09-10 | RSVP removed from V1 | Save + share + external register is enough |
| 2026-09-10 | Google Cloud Vision for safe search + OCR | Moderation + flyer upload flow |
| 2026-09-10 | BetterStack for logs + uptime + status page (replaces Sentry + UptimeRobot) | Unified observability |
| 2026-09-10 | Mixpanel BACK IN for product analytics (funnels, cohorts) | Log-based analytics too clunky for consumer analytics |
| 2026-09-10 | AppsFlyer for mobile attribution + install deep links | Standard MMP for paid acquisition |
| 2026-09-10 | Firebase Crashlytics for Flutter mobile crashes | Free, native SDK, we already use Firebase |
| 2026-09-10 | Landing waitlist stores in Supabase `waitlist` first, Resend second | Own the list |
| 2026-09-10 | CloudFront in front of S3 for media delivery, custom domain `cdn.hatri.online` | AWS-native, first-year free tier covers MVP |
| 2026-09-10 | Server-side image compression at quality 70 (WebP), 3 variants: thumb 400 / feed 1080 / full 2048 | Snappy feed on 3G, 20-30x reduction end to end |
| 2026-09-10 | Client-side pre-compression at quality 80, max 2048×2048 (Flutter `flutter_image_compress`) | Saves upload bandwidth for user |
| 2026-09-11 | OTP is 6 digits (not 4) | Industry standard, harder to brute force; DLT template must match |
| 2026-09-11 | Flutter app SDKs locked: dio + secure_storage + jwt_decoder + uuid + Firebase (core/messaging/crashlytics/performance) + mixpanel_flutter + appsflyer_sdk + flutter_image_compress + cached_network_image + geolocator + geocoding + app_links + flutter_local_notifications + add_2_calendar + shimmer + package_info_plus + path_provider + dio_smart_retry | Full 21-package aggressive install to unlock backend integration + push + analytics + attribution + image handling + location + deep links |

---

## 20. When in doubt

Ask: **what's the simplest thing that keeps the user's data safe and the API honest?** Ship that. Everything else is a Sprint 3 problem.

*Everything above is v0.3. Anything that contradicts this doc is wrong. Update the doc first, then update the code.*
