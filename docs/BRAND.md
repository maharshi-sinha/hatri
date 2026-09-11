# Hatri — Brand + Design System

> The single source of truth for how Hatri looks, feels, and sounds.
> This applies to the **mobile app**, the **landing site** (`hatri.online`), and any future dashboard, deck, or asset.

Last updated: 2026-09-10 · v1.0

---

## 1. What Hatri is

**Hatri is the events OS for your city.** Open mics, gigs, markets, meetups, workshops, exhibitions, community events. One honest feed, sorted by what's near you and what your people saved.

**One-liner:** *Your city has a scene. Hatri finds it.*

**Positioning:**
- Not Instagram. Instagram is memory. Hatri is a plan.
- Not BookMyShow. BookMyShow sells tickets. Hatri surfaces the scene.
- Not a newsletter. It's a magazine that ships in the app every Monday.

**Audience:** Gen Z + young millennials (18-30) in Indian cities, starting Tier 2.

---

## 2. Tone of voice

### The voice, in one sentence

**Confident, playful, low ego. Written by someone who lives in the city, not a copywriter.**

### Rules

| Do | Don't |
| --- | --- |
| lowercase headlines (mostly) | Title Case Headlines Everywhere |
| short sentences. sharp. | "In today's fast-paced world…" |
| one-liners that land | multi-clause corporate speak |
| use "we" and "you" | "users" / "the platform" |
| show wit through structure, not emojis | 🎉 🚀 ✨ everywhere |
| leave room for silence | over-explain every feature |
| write like a text | write like a press release |
| specific > generic ("open mic tonight" > "events near you") | vague hype |

### Punctuation

- **Em dashes are banned.** Use periods or commas instead. They read as AI slop.
- Ellipsis `…` sparingly. Never trail-off for suspense.
- Sentence-case in body copy is fine when needed for readability. Just don't do Title Case in headlines.
- One-word or one-line paragraphs are welcome.

### Example headlines (do these)

- `your city has a scene.`
- `stop scrolling. show up.`
- `three moves. every week.`
- `your feed is lying to you about your city.`
- `alright. get in.`

### Example headlines (do not)

- `Discover Amazing Events Happening Around You!` (Title Case, exclaim, generic)
- `The Ultimate Way to Explore Your City` (corporate, over-promise)
- `🚀 Hatri — Your City, Reimagined` (emoji, buzzword)

---

## 3. Colors

Based on **Y2K acid-pop brutalism** on a near-black ground.

### Palette

| Role | Name | Hex | RGB | Where |
| --- | --- | --- | --- | --- |
| App background | **ground** | `#0E0E12` | 14 14 18 | Body of app + site |
| Cards, sheets, surfaces | **graphite** | `#1C1C1C` | 28 28 28 | Cards, panels |
| Raised chips, inputs | **surface** | `#24242C` | 36 36 44 | Input backgrounds |
| Divider, thin border | **border** | `#2E2E38` | 46 46 56 | Card borders, dividers |
| Primary CTA / accent | **fuchsia** | `#FF2E9A` | 255 46 154 | Primary buttons, alerts |
| Highlight / LIVE / numbers | **lime** | `#CFFF04` | 207 255 4 | Highlights, active dots, numbers |
| Category / secondary | **indigo** | `#5D00FF` | 93 0 255 | Category chips, secondary |
| Primary text | **paper** | `#F4F2FF` | 244 242 255 | All headline & body copy on dark |
| Secondary text | **muted** | `#89849C` | 137 132 156 | Sub-copy, meta, labels |
| On-neon text | **on-neon** | `#0E0E12` | 14 14 18 | Text on lime/fuchsia surfaces |

### Usage rules

- **80% of any screen** should be `ground` + `graphite` + `paper` + `muted`. That's the base.
- **Neon accents (fuchsia, lime, indigo)** are single-tap moments: one primary CTA per view, one section pop, one highlighted word. Never all three next to each other in copy.
- **Lime `#CFFF04`** is the Hatri signature. If you can only use one accent, use lime.
- **Fuchsia = urgent / primary action** (Save, Submit, primary CTA).
- **Indigo = category / secondary** (chips, category tags, secondary CTAs).
- **Never use hex literals in code.** Always reference the token (`AppColors.fuchsia`, `--color-fuchsia-hatri`, etc.).

### Semantic aliases

- `success` = lime
- `warning` = fuchsia (we don't have a separate warning; if you must, use `#FFD400`)
- `error` = fuchsia
- `live / online / active` = lime with a blink animation

---

## 4. Typography

### Fonts

| Family | Weight range | Use | Files |
| --- | --- | --- | --- |
| **Clash Display** | 500 / 600 / 700 | Display, headlines, big numbers, section labels | `ClashDisplay-Medium/Semibold/Bold.ttf` |
| **General Sans** | 400 / 500 / 600 / 700 | Body copy, buttons, chips, meta | `GeneralSans-*.ttf` |
| **Bonny** | 700 | Decorative flourish (magazine covers, "editor's letter"). Never body. | `Bonny-Bold.ttf` |

All three are self-hosted (not loaded from Google Fonts). Web loads them via `@font-face` from `/public/fonts/`. App loads them via `pubspec.yaml`.

### Type scale — app

| Style | Family | Size | Weight | Tracking | Line-height | Use |
| --- | --- | --- | --- | --- | --- | --- |
| `displayLarge` | Clash | 56sp | 700 | -1.6 | 0.95 | Hero moments |
| `displayMedium` | Clash | 40sp | 700 | -1.0 | 0.98 | Screen-level H1 |
| `displaySmall` | Clash | 28sp | 600 | -0.4 | 1.02 | Sub-hero |
| `headlineLarge` | Clash | 24sp | 700 | -0.2 | 1.1 | Section titles |
| `headlineMedium` | Clash | 20sp | 600 | 0 | 1.1 | Card headers |
| `titleLarge` | General | 20sp | 700 | 0 | 1.3 | Event titles |
| `titleMedium` | General | 16sp | 600 | 0 | 1.3 | Sub-titles |
| `labelLarge` | General | 15sp | 700 | 0.3 | 1.3 | Buttons |
| `labelMedium` | General | 12sp | 600 | 1.2 | 1.3 | Eyebrows, chips |
| `labelSmall` | General | 10sp | 600 | 1.4 | 1.3 | Meta labels |
| `bodyLarge` | General | 16sp | 400 | 0 | 1.4 | Primary body |
| `bodyMedium` | General | 14sp | 400 | 0 | 1.4 | Secondary body |
| `bodySmall` | General | 12sp | 500 | 0 | 1.35 | Meta |

### Type scale — web

Same families, sized by `text-*` Tailwind classes. Rough map:

| Web class | Approx px | App equivalent |
| --- | --- | --- |
| `text-8xl` (Clash) | 96 | Hero display (site only) |
| `text-6xl / text-7xl` (Clash) | 60 / 72 | Section headlines |
| `text-4xl / text-5xl` (Clash) | 36 / 48 | Card headers |
| `text-2xl / text-3xl` (Clash or General) | 24 / 30 | Card titles |
| `text-lg / text-xl` (General) | 18 / 20 | Body |
| `text-sm / text-base` (General) | 14 / 16 | Meta, chips |
| `text-xs` (General) | 12 | Eyebrows, tags |

### Type rules

- **Display type is uppercase-optional.** We prefer lowercase for Gen Z warmth, but ALL CAPS is fine for eyebrow chips and section labels.
- **Tight tracking** on big display (`-0.03em` to `-0.05em`). Bigger the type, tighter the tracking.
- **Line height 0.9 to 0.98** on display. Chunky, not airy.
- **Body line height 1.4-1.5**. Readable.
- Never mix Clash and General inside a single word or button. Big blocks of one, small blocks of the other.

---

## 5. Iconography + mascot

### Mascot: "the main character"

A clapperboard illustration that says **"YOU ARE THE MAIN CHARACTER"**. This is Hatri's face. Everywhere the user needs a moment of warmth, the mascot shows up.

- File: `assets/images/stickers/main_character.png`
- Animation: gentle wobble (rotate -3° ↔ +3° over 4s, ease-in-out) or float (Y ±8px)
- Never rotate beyond ±10° for the mascot itself.
- Never re-color the mascot. It's black on transparent, always.

### Sticker system

Illustrated stickers used as accent moments. Playful, hand-drawn, black-line on transparent.

| Sticker | Vibe | Use |
| --- | --- | --- |
| `main_character` | Cheerleader | Hero, empty states, celebrations |
| `disco_ball` | Party | Music / gig moments |
| `flame_heart` | Hot | Reactions, saves, "hot" chips |
| `lightning` | Energy | Live events, urgency |
| `camera` | Capture | Creators, event detail cover moments |
| `megaphone` | Announce | Maker CTA, "we're hiring" moments |
| `vinyl` | Music culture | Weekly Issue, curation |
| `arrows` | Direction | Sparingly — signage moments |

### Sticker usage rules

- **One or two stickers per screen** in most cases. Three max, and only in the hero. Never confetti of stickers.
- Stickers can rotate ±15° and animate wobble/float/spin.
- Stickers wear the Hatri drop-shadow: `filter: drop-shadow(0 8px 24px rgba(255,46,154,0.35))` on dark bg.
- Never stretch or crop. Preserve the transparent negative space.

### Utility illustrations

For empty / error / loading states. All in `assets/images/utility/`:

- `celebration.png` — success / confetti
- `empty.png` — nothing to show
- `error.png` — generic failure
- `maintenance.png` — coming soon / down
- `not_found.png` — 404
- `offline.png` — no connection
- `payment_failed.png` — checkout failure
- `pull_refresh.png` — refresh cue
- `session_expired.png` — auth expired
- `sold_out.png` — event full
- `update_required.png` — force upgrade

Always pair with a **one-line, on-brand copy**. No generic "Oops, something went wrong."

### Custom SVG icons

App uses a **custom SVG icon set** (not Material). Line-icon style, stroke-based, 22-24 px on the app. Every icon lives in `assets/icons/`. When we need a new icon, we draw one to match the set — never mix Material or Feather icons in.

---

## 6. Motion

### Duration tokens

| Token | ms | Use |
| --- | --- | --- |
| `Motion.fast` | 140 | Hover, tap feedback, toggles |
| `Motion.base` | 220 | Sheet open, card expand, tab switch |
| `Motion.slow` | 420 | Page transitions, editorial reveals |

### Easings

- **Default:** `ease-in-out` (or Flutter `Curves.easeInOut`)
- **Enter:** `ease-out` (things swoop in and settle)
- **Exit:** `ease-in` (things accelerate out)
- **Snappy micro-interactions:** `cubic-bezier(0.2, 0.9, 0.2, 1)`

### Signature motions

| Motion | Behavior | Where |
| --- | --- | --- |
| **Sticker wobble** | rotate ±3°, Y ±8px, 4s loop | Mascot + accent stickers |
| **Sticker spin** | 360° rotate, 12s linear | Disco ball, vinyl |
| **Sticker float** | Y ±16px, 6s ease-in-out | Lightning, flame heart |
| **LIVE blink** | opacity 100% → 25%, 1.4s steps(2) | Any "live" dot |
| **Marquee** | translateX 0 → -50%, 30-60s linear | Site marquees |
| **Shine** | background-position -200% → 200%, 6s linear | Reserved for hero text moments |
| **Hover lift** | `translateY(-2px)` + shadow gain, 200ms | Buttons, cards on web |

### Rules

- Reduced motion should always disable spin + marquee + shine. Wobble/float can stay.
- Never animate for the sake of animating. Every motion should point at something.
- Stagger children by 60-100ms on entry. Never more than 400ms total for a group.

---

## 7. Layout + spacing

### Spacing scale (4pt base)

Never use ad-hoc numbers. Always this scale:

| Token | Value | Use |
| --- | --- | --- |
| `xxs` | 4 | Icon-text tight gaps |
| `xs` | 8 | Chip padding, tight rows |
| `sm` | 12 | Small gaps, card inner padding |
| `md` | 16 | Standard row gap, card padding |
| `lg` | 20 | Section internal padding |
| `xl` | 24 | Section outer padding (mobile) |
| `xxl` | 32 | Section separations |
| `xxxl` | 48 | Hero padding, major dividers |

### Corners

| Token | Value | Use |
| --- | --- | --- |
| `xs` | 6 | Chips |
| `sm` | 10 | Small buttons, inline pills |
| `md` | 14 | Buttons, inputs, small cards |
| `lg` | 20 | Standard cards |
| `xl` | 28 | Sheets, big cards |
| `pill` | 999 | Fully rounded |

### Grid

- Site uses a **12-column** implicit grid via Tailwind (`grid grid-cols-12` or `grid-cols-[1fr_auto]`).
- Max content width: **`max-w-7xl` (1280px)** on site.
- Section padding: `py-24 sm:py-32` (mobile → desktop).
- Horizontal page padding: `px-4 sm:px-8`.

---

## 8. Component library — mobile app

### Buttons

- **Primary:** fuchsia bg, on-neon text, `Corners.md`, bold body font, uppercase-optional.
- **Secondary (outlined):** transparent bg, lime border + text.
- **Text:** lime text, no bg, no border.
- **Disabled:** `surfaceRaised` bg, `muted` text, no shadow, cursor-not-allowed.
- **Never gray primaries.** If it's the main action, it's fuchsia.

### Chips

- **Category chip:** indigo bg or graphite bg, `paper` text, `Corners.pill`, uppercase 10-12sp.
- **Live chip:** lime bg, `on-neon` text, blinking dot inside.
- **Filter chip:** `surface` bg, `paper` text; when selected, fuchsia bg + on-neon text.

### Cards

- **Event card:** graphite bg, 1px border in `border`, `Corners.lg`. Category chip top-left, save button top-right, image, title, meta.
- **Maker card:** same base, with colored top-strip in maker's accent color.
- **Brutal card (site only):** offset 5px shadow in accent color, thicker border. Used sparingly.

### Inputs

- `surface` bg, 1.5px `border` border.
- Focused: 1.5px `fuchsia` border + optional lime `4px 4px 0 lime` shadow (site only).
- Placeholder: `muted`.
- Label above input if not self-evident, all-caps 10-12sp `muted`.

### Bottom nav (app)

- Custom motor nav bar with liquid glass renderer.
- 4-5 items max. Icons + micro-labels.
- Active item: fuchsia icon + label. Inactive: muted.

---

## 9. Component library — web (landing site)

Same tokens, HTML/CSS/React implementation. Key components:

- `<Nav>` — sticky, transparent at top, blur + border on scroll
- `<Hero>` — big display + mascot + download buttons + proof row
- `<DownloadButtons>` — Android + iOS "Coming soon" + optional Join Waitlist pill
- `<SectionNumber num label accent>` — numbered eyebrow ("01 · The insight")
- `<Marquee>` — infinite scroll, lime or fuchsia bg
- `<Pillars>` — 3-card feature grid
- `<PhoneShowcase>` — horizontal-scroll phone frames
- `<MakersCTA>` — indigo brutal card
- `<CityCard>` — city chips + skyline mockup
- `<FAQ>` — accordion
- `<EndCTA>` — final waitlist push
- `<Footer>` — nav grid + giant faded wordmark

---

## 10. Motifs (site-specific)

- **Grid overlay:** faint 48×48 grid at ~4% opacity behind hero. Adds structure without noise.
- **Radial glows:** soft fuchsia/indigo blobs at 20-25% opacity, blurred to 3xl, positioned to lead the eye.
- **Brutal shadows:** cards get `5px 5px 0 accent` shadow with a matching-colored border. Used on 3 cards max per page.
- **Cityscape footer:** the `city_skyline.png` used in the city section + optionally in the footer as a faded #HATRI motif.
- **Editorial numbers:** big Clash bold numbers for stats (12, 1, 0) with tiny meta-labels underneath.
- **Highlighted word:** one word in the headline gets a lime underline squiggle SVG or lime background wash. Never more than one per headline.

---

## 11. Copy voice — Gen Z rules

### The voice cheatsheet

- **Feels like a text message.** Not a landing page.
- **Address the reader directly.** "you" not "users".
- **Confess.** "we hate ads." "we ship fast." Confessions build trust.
- **Use the specific.** "the sunday flea" beats "curated events."
- **One-word punchlines.** "promise." "finally." "loudly."
- **Contractions everywhere.** "you're", "we'll", "don't".

### Copy patterns to reuse

- **Structure:** [sharp claim]. [expansion]. [reveal].
  - e.g. `your feed is lying to you. instagram buries them. hatri collects them.`
- **Structure:** [do]. [do]. [do].
  - e.g. `see what's on. save what hits. show up.`
- **Structure:** [confession]. [conclusion].
  - e.g. `we live here. we love it.`

### Words to prefer

- "scene" over "events"
- "drop" over "release"  
- "hit" over "trend"
- "showed up" over "attended"
- "your people" over "your friends"
- "makers" over "vendors" or "businesses" (for consumers)
- "the group chat" as shorthand for community

### Words to avoid

- "curated" (overused)
- "seamless", "elevate", "revolutionize"
- "leverage", "utilize", "optimize"
- "amazing", "incredible", "life-changing"
- Anything a corporate blog post would say

---

## 12. Do & Don't quick sheet

| ✅ Do | ❌ Don't |
| --- | --- |
| Lowercase headlines | Title Case Everything |
| Periods and commas | Em dashes (`—`) |
| One primary CTA per view | Three primary CTAs competing |
| One accent per section | All three neons in one card |
| Stickers as moments | Stickers as confetti |
| Big Clash display | Tiny display type |
| Real specifics ("sunday flea") | Vague hype ("amazing events") |
| Dark ground everywhere | Light theme (no light theme, ever) |
| Consistent tokens | Ad-hoc hex colors |
| 4pt spacing scale | Random paddings |
| Sentence-case body | ALL CAPS PARAGRAPHS |

---

## 13. Where things live in code

### App (Flutter)

```
lib/core/theme/app_theme.dart       — All tokens (AppColors, Insets, Corners, Motion, AppTheme)
lib/core/widgets/                    — Shared widgets (buttons, chips, cards)
assets/images/stickers/              — Sticker PNGs
assets/images/utility/               — State illustrations
assets/images/city_skyline.png       — Skyline motif
assets/icons/                        — Custom SVG icon set
assets/fonts/                        — ClashDisplay, GeneralSans, Bonny, CabinetGrotesk
```

### Web (Next.js in `hatri-web/`)

```
src/app/globals.css                  — CSS tokens (@theme block) + keyframes + motifs
src/app/layout.tsx                   — Metadata, root layout
src/app/page.tsx                     — Section composition
src/components/                      — All landing components
public/stickers/                     — Copied sticker PNGs
public/fonts/                        — Copied font TTFs
public/icon.png                      — App icon (favicon + nav)
src/app/icon.png                     — Auto-registered as favicon (Next 15)
src/app/apple-icon.png               — Auto-registered as Apple touch icon
```

### Backend (`backend/` — coming Sprint 1)

Will follow the same tone in email templates, transactional messages, and admin dashboards. Same fonts, same palette, same rules.

---

## 14. When in doubt

Ask: **would this feel out of place in a text from a friend who runs a music venue?**

- If yes → it doesn't fit Hatri.
- If no → ship it.

---

*Everything above is version 1.0. Anything that contradicts this doc is wrong. Update this file, then update the code.*
