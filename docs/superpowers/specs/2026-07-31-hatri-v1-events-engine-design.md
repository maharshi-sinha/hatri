# Hatri v1 — "The Events Engine" · Design Spec

**Date:** 2026-07-31
**Status:** Draft for review
**Owner:** Rishabh (with Claude Code)

## 1. Product thesis

Hatri is **Raipur's digital haat**. A *haat* is the weekly open-air market where the whole town gathers to trade, discover, and socialise — the historic *Turi Hatri* in Purani Basti, Raipur, was known as "the parent of the barter system of exchange." Hatri is that gathering, digitised: a place where locals discover what's happening, and where micro-creators and small businesses get seen and hired.

The full vision spans four "stalls": event discovery, a creator/small-business marketplace, event-services, and community. **v1 focuses on the wedge that can be seeded without a cold-start problem — local event discovery** (the audience engine) — with a lightweight **creator seed** embedded: every event surfaces the people behind it, so marketplace supply accumulates *through* events.

**Build strategy:** UI prototype first on mock data; real backend later. The app already uses the repository pattern (`lib/core/repositories/`), so swapping mock data for a backend is a swap, not a rewrite.

## 2. Goals & non-goals

**Goals (v1 prototype):**
- A polished, clickable Gen-Z event-discovery experience for Raipur, on mock data.
- Discovery that feels alive: filter by *Tonight / This Weekend / Free / Near Me* + categories, a map, and a weekly "drop".
- Frictionless event posting (under a minute).
- The signature RSVP → ticket-reveal delight + a shareable "I'm going" flex card (growth loop).
- The creator seed: tappable public profiles for organizers & performers.
- Trust & social scaffolding as UI: verified badge, ratings, "safe venue" tags, "who's going", group plans.

**Non-goals (out of v1):** real accounts/backend, gig-board apply-flow, real verification, real two-way ratings, QR check-in, share-my-location, post-event photo drops, stories, AI poster generator, Hatri Wrapped, push notifications, reels, hiring/payments, IG import, multi-city.

## 3. Target user & context

- **Hero user:** a Gen-Z Raipur local hunting for plans (consumer-first). Organizers/creators are the supply side, seeded behind the scenes.
- **Aesthetic:** the existing neon/pop dark theme — `AppColors` palette, ClashDisplay/GeneralSans fonts, card + ticker + blinking-dot patterns. New screens must feel native to it.

## 4. Architecture approach

- Extend the existing Flutter app; keep **BLoC + go_router + get_it + repository pattern**.
- All data flows through **mock repositories**; a backend later swaps in behind the same interfaces.
- **Enrich the `Event` model** and add new models (creator profile, plan, attendee) + matching mock data.
- New feature-first folders under `lib/features/` (e.g. `creators/`, `plans/`, plus discovery widgets) and shared widgets under `lib/shared/widgets/`.
- **Maps:** use `flutter_map` (OpenStreetMap tiles) for the prototype — no API key or billing, works immediately; can swap to Google Maps later. **[Confirmed]**

## 5. v1 feature set (🟢)

| Feature | What it does | Touches |
|---|---|---|
| Discovery filters | Filter bar on Events: Tonight · This Weekend · Free · Near Me + category chips | refine `events_screen.dart`, extend `EventsBloc` |
| Home retune | Sections: Tonight in Raipur · This Weekend · Trending · Newly Added | refine `home_screen.dart` |
| Map view | Events pinned on a Raipur map; tap a pin → event | new `discovery/map_screen.dart` + `flutter_map` |
| 30-sec Post-an-Event | Streamlined create flow + a "who's performing" lineup field | refine `host_event_screen.dart` |
| RSVP + reveal + flex card | Existing ticket reveal + a shareable "I'm going" card | refine `event_details_screen.dart`, `ticket_reveal_screen.dart`; `share_plus` |
| Who's going + FOMO | Attendee faces + live RSVP counters | `event_details_screen.dart`, ticker / blinking-dot widgets |
| Creator/organizer profiles | Public profile: bio, upcoming/past events, Follow, dormant Hire/Contact button | new `creators/creator_profile_screen.dart` |
| This Week in Hatri | Weekly digest surface of the week's events | new `discovery/this_week_screen.dart` |
| Group plans | Start a plan, invite, "who's in" (UI shell) | new `plans/` |
| Trust UI | Verified badge, star-rating display, "safe venue" tag chip | new shared widgets |

## 6. Data model changes

- **`Event`** (enrich): add `tags` (hot / trending / weekend), `interestedCount`, `lat` / `lng`, `category` (enum), `lineup` (`List<creatorId>`), `isSafeVenue`. Source values already exist in `design_raw.js`.
- **`CreatorProfile`** (new): id, name, avatar, bio, category, isVerified, rating, eventIds.
- **`Plan`** (new): id, eventId, hostId, inviteeIds, whosInIds.
- **`Attendee`** (new, lightweight): id, name, avatar — for "who's going".
- Extend `MockRepository` with creators, plans, attendees, and richer events. Add `CreatorRepository` (+ mock); add `PlanRepository` if plans need shared state.

## 7. Success criteria (prototype)

A first-time user can, on mock data: browse & filter events, see them on a map, open an event, RSVP with the reveal and share a flex card, tap into a creator/organizer profile, view "This Week in Hatri", start a group plan, and see trust cues — and it all feels like one cohesive, polished, distinctly-Hatri Gen-Z app.

## 8. Roadmap (post-v1)

**🟠 Next, once the backend lands (in this order):**
1. Gig-board apply-flow *(marquee)*
2. Real verification + real two-way ratings & reviews
3. QR door check-in → attendance → reputation
4. Women's-safety share-my-location
5. Hatri Wrapped + push notifications

**🔵 Later:** Reels, real hiring/booking + payments, IG/WhatsApp import at scale, monetization (boosted events, promoted profiles, ticketing fee), multi-city expansion.

## 9. Confirmed decisions (2026-07-31)

1. **Maps:** `flutter_map` / OpenStreetMap for the prototype.
2. **Design:** new screens designed fresh in the existing Hatri style.
3. **Dropped (not needed):** post-event photo drops, stories, and the AI poster generator — removed from scope and roadmap.
