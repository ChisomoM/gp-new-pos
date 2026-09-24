# Geepay POS — New UI Design Spec

Reference doc for implementing the redesigned Geepay POS mobile agent app.
Companion to the live design canvas: https://claude.ai/artifact/TdDFgZBjQvcww55H8RaU6c

This is a **visual-only** redesign — it does not change existing app behavior,
API contracts, or fix known bugs in the current build. Treat everything below
as the target look and feel to implement in Flutter.

---

## 1. Design tokens

Source of truth: Geepay Design System (https://claude.ai/artifact/F8KbgtSFBkjTqQe5nV9b2f)

### Colors

| Token | Hex | Usage |
|---|---|---|
| `gp-cobalt` | `#383d92` | Primary brand color, icons, links, active states |
| `gp-sky` | `#00afeb` | Secondary brand color, gradient end stop |
| `gp-navy` | `#080c30` | Gradient start stop, splash/hero backgrounds |
| `surface-page` | `#f9fafb` | App background |
| Success | `#10b981` (icon/dot), `#065f46` (text), `#d1fae5` (fill) | Success states, badges |
| Warning | `#a15c00` (text), `#fff4d6` (fill) | Pending states |
| Danger | `#e11d2e` / `#991b1b` (text), `#fde8e8` / `#fee2e2` (fill) | Failed states, destructive actions |
| Info | `#383d92` on `#ececf8` | Info tiles, selected chips |
| Neutral text | `#141a34` (primary), `#272f4a` (secondary), `#70788f` (tertiary), `#9aa0b8` (muted) | Text hierarchy |
| Borders | `#eef0f5` / `#dde0eb` / `#f3f4f6` | Card and input borders, dividers |

**Primary gradient** (buttons, hero backgrounds):
```css
linear-gradient(115deg, #383d92 0%, #2b6fc2 48%, #00afeb 100%)
```

**Hero background gradient** (splash, dashboard, forced update):
```css
linear-gradient(160deg, #080c30 0%, #131850 48%, #383d92 100%)
```

### Typography

| Role | Font | Notes |
|---|---|---|
| Body / UI text | Inter (400/500/600/700) | Default for labels, body copy, buttons |
| Headings / display | DM Sans (500/600/700/800) | Screen titles, section headers, names |
| Numbers / monetary values | DM Sans + tabular figures | Custom `.gp-num` treatment — **not** JetBrains Mono (deviation from the design system's default; numbers looked "weird" in mono and were switched) |

`.gp-num` equivalent for Flutter text style: `fontFamily: 'DM Sans'`, `fontFeatures: [FontFeature.tabularFigures()]`, slight negative letter spacing (~-0.01em).

### Radii & shadows

- `radius-xl` = 12px — buttons, inputs
- `radius-2xl` = 16px — cards
- Card resting shadow: `0 1px 3px rgba(8,12,48,0.06), 0 4px 16px rgba(8,12,48,0.05)`
- Gradient button shadow: `0 4px 16px rgba(0,175,235,0.30), 0 1px 3px rgba(56,61,146,0.20)`

### Assets

- White wordmark (dark backgrounds): used on Login hero, Splash, Setup header
- Standalone "G" logomark: used as a subtle background watermark (10% opacity, white via filter, brightness(0) invert(1)) on Dashboard, Splash — never as a solid/opaque graphic in-flow
- Both assets are hosted on the canvas; export as PNG/SVG from the canvas for the app's `assets/` folder

---

## 2. Screen inventory

| Screen | Purpose | Key nav |
|---|---|---|
| Splash | App launch / branded loading state | → Setup (first run) or Login |
| Setup | First-run device registration (business name, email, phone, device ID) | → Dashboard on completion |
| Forced Update | Blocking screen when a mandatory update is required | No skip; single "Update now" CTA |
| Login | Merchant sign-in | → Dashboard |
| Dashboard | Home — today's collections summary, quick actions, recent transactions | → Collections, Cashier Summary, Transaction History, Settings |
| Collections | New collection request (phone, amount) | → Collection Status |
| Collection Status | Waiting-for-confirmation polling screen | → Collection Result |
| Collection Result | Success/failed outcome | → Dashboard or retry |
| Transaction History | Filterable list of past transactions | → Transaction Details, Cashier Summary |
| Transaction Details | Single transaction receipt view | Print/share actions |
| Cashier Summary | Totals for the day (successful/failed/total) | Print action |
| Settings | Company profile, printer settings, app updates, version, log out | → Printer Settings |
| Printer Settings | Built-in vs. Bluetooth printer, paired devices, test print | — |

Deprioritized (not built yet): Packages flow (lookup → confirm → purchase → result), Reset Password, Session Expired, Mode picker screen.

---

## 3. Component patterns

- **Back header**: 34×34px rounded-10 icon button (chevron-left) + DM Sans 16px/700 title, white background, bottom border `#f3f4f6`
- **Gradient CTA button**: full-width, radius-xl, primary gradient fill, white 15px/600 text, gradient button shadow
- **Grouped toolbar card**: single white radius-2xl card with internal 1px vertical dividers (not separate bordered tiles) — used for Dashboard quick actions
- **Transaction row**: circular initial avatar (colored by channel), phone number + channel/type caption, right-aligned `.gp-num` amount + solid pill status badge (SUCCESS/FAILED/PENDING)
- **Status badge pill**: `font-size:10px; font-weight:700; letter-spacing:0.03em; border-radius:999px; padding:2px 8px`, colored per status
- **Settings list row**: 36×36 rounded-10 icon tile (`#ececf8` bg, cobalt icon) + label + chevron-right, grouped in a bordered radius-2xl card with divider rows
- **Bottom nav**: Home / History / Settings, active item in cobalt, inactive in `#9aa0b8`

---

## 4. Implementation notes for Flutter

1. Map the tokens above into `ThemeData` (colorScheme, textTheme) and a `AppGradients` constants class for the two gradients.
2. Recreate `.gp-num` as a reusable `TextStyle` extension applied everywhere monetary/numeric values render.
3. Build shared widgets for: gradient button, back header, status badge pill, transaction row, settings list row — these repeat across nearly every screen.
4. Interactive behavior shown as static/demo state on the canvas (password show/hide, amount chips, status polling, success/failed toggle) should be wired to real state management, not literally ported from the markup.
5. This spec does not address existing app bugs noted separately (e.g. fake loading states, unwired session timeout) — those are out of scope for this visual pass.
