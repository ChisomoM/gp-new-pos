# Geepay POS: UI/UX Polish Plan

Status: proposal, not yet implemented.
Scope: the Flutter app in `lib/` (visual layer only; no API or behavior changes unless called out).
Companion to `geepay-pos-design-spec.md`, which defines brand tokens. This plan extends that spec into a full design system and a prioritised rollout.

Contents

1. Audit findings
2. Design system (visual language)
3. Component rules
4. Motion and micro-interactions
5. Screen-by-screen plan
6. Prioritised implementation roadmap
7. Guardrails so it stays consistent

---

## 1. Audit findings

All numbers below come from a scan of `lib/**/*.dart` (excluding generated l10n).

### 1.1 Summary scorecard

| Area | What exists today | Target |
|---|---|---|
| Spacing values | 26 distinct values; 92 of ~260 literals are off a 4pt grid (6, 10, 14, 18, 22, 26, 34...) | 11 tokens on a 4pt grid |
| Font sizes | 21 distinct sizes, 31 uses of half-pixel sizes (10.5, 11.5, 12.5, 13.5, 14.5, 16.5) | 10 named text styles |
| Font weights | w400, w600, w700, w900, `bold`, `normal` | 400 / 500 / 600 / 700 only |
| Font families | Inter, DM Sans, plus leftover Poppins, Lato, Manrope, Ubuntu | Inter + DM Sans only |
| Corner radii | 13 distinct values (2, 6, 8, 10, 12, 13, 14, 16, 18, 24, 28, 30, 999) | 6 tokens |
| Icon sizes | 12 distinct sizes (10, 12, 13, 14, 16, 17, 18, 19, 20, 22, 34, 40) | 4 tokens |
| Icon libraries | Iconsax mixed with Material `Icons.*` in 6 files | Iconsax only, via `AppIcons` |
| Raw colors | 26 raw `Color(0x...)` literals outside `app/theme`, plus `Colors.red/green/blue/grey/amber` | Tokens only |
| Button implementations | `GradientButton`, `AppButton` (unused), `PrimaryButton` (unused), 4+ inline `OutlinedButton.styleFrom` variants | One `AppButton` with variants |
| Text inputs | `AppTextField`, `AppPasswordField`, 2 inline fields in Collections, `kTextFieldDecoration`, 2 more legacy password fields | One field family |
| Loading states | 10 `CircularProgressIndicator`s; `shimmer` is a dependency but unused | Skeletons for content, spinners only for actions |
| Animations | Only 2 spinning controllers; `AnimatedPage`, `FadeSlideListItem`, `FadeSlideAnimation` exist but are never used | Motion tokens + a small set of patterns |
| Empty / error states | Plain centered text, errors in red text with no retry | `EmptyState` / `ErrorState` components |

### 1.2 Spacing

Histogram of `EdgeInsets` / `SizedBox` / `spacing` literals:

```
on-grid : 4(7) 8(28) 12(13) 16(28) 20(34) 24(15) 32(4) 48(2)
off-grid: 1(5) 2(5) 3(4) 5(1) 6(10) 7(2) 9(3) 10(8) 13(1) 14(20) 15(2)
          18(9) 22(16) 26(3) 28(1) 34(1) 44(1)
```

Patterns worth calling out:

- **22 is the de facto section gap** (Settings, Collections) while other screens use 24. Pick 24.
- **14 is the de facto row padding** (settings tiles, detail rows, bottom bars `fromLTRB(20, 14, 20, 22)`). Pick 12 or 16 depending on density.
- **6 appears as label-to-field gap** in `AppPasswordField` but `AppTextField` uses 8. Two fields that sit next to each other on Login are misaligned by 2px.
- **Dashboard hack**: `SliverPadding(top: 48)` combined with `Transform.translate(offset: -20)` to fake an overlap. Replace with an explicit overlap value from tokens.
- **1, 2, 3px** are used between title/subtitle text lines. These should become line-height driven (text styles with proper `height`) instead of spacers.
- Offending files, most first: `printer_settings_page.dart`, `settings_body.dart`, `setup_body.dart`, `collections_body.dart`, `login_body.dart`, `collection_result_body.dart`, `home_body.dart`, `transaction_details_body.dart`.

### 1.3 Typography

- 21 sizes in use. Examples of near-duplicates doing the same job: row titles are 13.5 in `TransactionRow` and `_SettingsTile` but 13 in detail rows; form labels are 14 in `AppTextField` and 13 in Collections.
- Headings are inconsistent: screen titles 16 (`BackHeader`), result headline 21, status headline 19, dashboard name 21, settings name 16.5, login title 24.
- Hero amount uses `FontWeight.w900` (DM Sans is only loaded up to 800 in the spec) and `toStringAsFixed(2)` with no thousands separator: `ZMW 12450.00`.
- Currency formatting is inconsistent: `ZMW 20.00` in fields, `K20` on amount chips, `utils/currency_formater.dart` has its own 18px styles.
- `textTheme` is set in `AppTheme` but almost no widget reads from it. Every widget builds `TextStyle(...)` by hand.

### 1.4 Colour

- Tokens exist in `AppColors` and are used well in most places, but there are 26 raw hex values, some off-brand: `#2E3192` in dialogs (a different cobalt), `#141644` / `#3D4560` in chips, `#0C1040`, `#F7F8FA`, `#F0F1F5`, `#B9BDD6`.
- Snackbars use Material `Colors.green / red / blue` and their `shade900`s, which do not match the semantic palette at all.
- **Channel avatars reuse semantic colours**: Airtel rows use `dangerIcon/dangerFill` and MTN rows use `warningText/warningFill`. Every Airtel transaction therefore looks like an error, and every MTN row looks pending, before the user reads the status badge.
- **Contrast**: `textMuted #9AA0B8` on white is about 2.6:1 and is used for subtitles and metadata at 11.5px (fails WCAG AA). `textTertiary #70788F` is about 4.4:1 (just under AA).
- `AppDarkTheme` exists but uses Manrope and every widget hardcodes light `AppColors`, so dark mode would be broken if enabled.

### 1.5 Iconography

- Iconsax is the main set (good, modern, consistent 1.5 stroke) but Material icons leak in: `printer_settings_page.dart` (`arrow_back_ios_new`, `bluetooth`, `print_outlined`, `check`), `app_alerts.dart` (`check_circle`, `error`, `info`), password fields (`visibility`), `app_button.dart` (`arrow_forward`), `custom_nav_bar.dart`.
- **Directional arrows where chevrons belong**: settings rows and the Login / Setup CTAs use `Iconsax.arrow_right_3` (a full arrow). Row affordances should be a small chevron; primary CTAs like "Continue" do not need an icon at all.
- Two different back glyphs: `Iconsax.arrow_left_2` in `BackHeader`, Material `arrow_back_ios_new` in Printer settings.
- **Semantic mismatches**: "Collections" (receiving money) and "Request payment" use `Iconsax.send_2`, which reads as sending money. Dashboard bell icon has no action. "Updates" uses a refresh icon tinted success green.
- Bottom nav uses the same outline icon for active and inactive; only colour changes.
- `AppIcons` exists but is mostly legacy (Zicta, Zed money, master card assets) and not used by the new screens, which import `Iconsax` directly.

### 1.6 Components

- **Ripples are invisible on most tappable surfaces.** `TransactionRow`, `_AmountChip`, `_FilterChip` and the `BackHeader` back button all put an `InkWell` outside an opaque `Container` with a `BoxDecoration` colour. The ink is painted underneath the decoration, so there is no press feedback. `GroupedToolbarItem` has no clipping, so its ripple spills past the card's rounded corners.
- Headers: `BackHeader` is 66px tall with a 16px title and a 34px back target (below the 44-48px touch minimum). Printer settings has its own `_Header` copy. Root tabs use `BackHeader` as a plain title bar.
- Cards: some use a border (`TransactionRow`, detail cards), some a shadow (`GroupedToolbarCard`, settings cards), with radii 14, 16 and 18 side by side.
- Key/value rows are implemented three times (details, result, printer settings) with slightly different padding and sizes.
- Status pill (10px, 2px vertical padding) is fine in spirit but too small to scan; `UP TO DATE` badge in Settings duplicates it with different padding (9/3) and size (10.5).
- Dialog (`showAppDialog`) uses Poppins and Lato, 8px radius, asymmetric button radii (6 top, other bottom).
- Bottom navigation is the stock `BottomNavigationBar` with 10px labels and no active indicator.
- Tab switching rebuilds the body each time (`_buildBody` in `main_body.dart`), so the History cubit is recreated, refetches, and loses filter and scroll position on every visit.
- Dead components to remove: `AppButton`, `PrimaryButton`, `CustomBottomAppBar`, `kTextFieldDecoration`, `utils/password_field.dart`, `widgets/password_field.dart`, `buttonShape`, `buttonSize`, unused `reviews.dart`, `coming_soon*.dart` (verify before deleting).

### 1.7 Widgets that feel generic

| Widget | Why it feels basic |
|---|---|
| Dashboard hero stats | One big number, raw `toStringAsFixed`, dots with counts, a spinner while loading. No breakdown, no sense of proportion, no pending count. |
| Quick actions card | Two items stretched across the full width, 19px icons with no container, 11.5px labels. Feels empty. |
| Recent transactions | Stacked bordered cards with 8px gaps: visually noisy, no grouping, no time shown. |
| Transaction history | Flat list, no date grouping, no pull-to-refresh, no result count, filter chips with no animation. |
| Result screen | Static icon, no moment of confirmation for the single most important event in the app (money received). |
| Empty / error states | One line of grey or red text. |
| Settings profile card | Gradient card with gradient-button shadow: heavy glow that competes with the page. |

### 1.8 Missing interaction states

- Pressed: missing on rows, chips, header button (see ripple bug).
- Focus: inputs have a focus border, nothing else does (no keyboard / accessibility focus ring).
- Disabled: `GradientButton` uses `#B9BDD6`; outlined buttons have no disabled style; chips have none.
- Loading: CTA swaps label for spinner without keeping width stable or animating.
- Selected: chips change colour instantly.
- Error: inputs show red border but error text pops in; no field-level validation on Collections.
- Success: only a snackbar.

### 1.9 Screens that need the most attention

1. **Dashboard** (`home_body.dart`): first screen every shift; hero, stats and list are all generic.
2. **Collection flow** (`collections_body.dart`, `collection_status_body.dart`, `collection_result_body.dart`): the core money moment, needs confidence and feedback.
3. **Transaction history** (`transaction_history_body.dart`): high-frequency, flat, no grouping, state lost on tab switch.
4. **Printer settings** (`printer_settings_page.dart`): most divergent screen (own header, Material icons, 11 font sizes, most off-grid spacing).
5. **Transaction details** (`transaction_details_body.dart`): should feel like a receipt.
6. **Settings** (`settings_body.dart`): mostly good structure; needs token alignment and a calmer profile card.
7. **Login / Setup / Splash**: solid base; mostly token alignment and input unification.

---

## 2. Design system

All tokens live in `lib/app/theme/` and are the only allowed source of these values.

### 2.1 Spacing scale (4pt grid)

| Token | Value | Typical use |
|---|---|---|
| `AppSpace.x0` | 0 | |
| `AppSpace.x1` | 4 | icon to text in tight badges, title to subtitle |
| `AppSpace.x2` | 8 | label to control, chip gaps, icon to label |
| `AppSpace.x3` | 12 | row internal gaps, avatar to text, list row gap |
| `AppSpace.x4` | 16 | card padding, field to field, bottom bar padding |
| `AppSpace.x5` | 20 | page gutter (horizontal) |
| `AppSpace.x6` | 24 | section to section |
| `AppSpace.x8` | 32 | major block separation, empty state padding |
| `AppSpace.x10` | 40 | hero internal spacing |
| `AppSpace.x12` | 48 | top of auth screens |
| `AppSpace.x16` | 64 | splash / illustration spacing |

Rules:

- Page gutter is always 20. Card padding is always 16. Section gap is always 24.
- Label to control: 8. Field to field: 16. Heading to its content: 12.
- Hairlines (1px borders, dividers) are the only allowed non-token values. Vertical gaps between stacked text lines come from line height, not spacers.
- Migration map for existing values: `2,3 → 4 or remove`, `6 → 8 (or 4)`, `10 → 8 or 12`, `14 → 12 or 16`, `18 → 16 or 20`, `22,26 → 24`, `28 → 24 or 32`, `34 → 32` (or a size token).

### 2.2 Typography scale

Inter for UI text, DM Sans for headings and numbers (per existing spec). Sizes are whole numbers; line heights on a 4pt rhythm.

| Style | Font | Size / line | Weight | Tracking | Use |
|---|---|---|---|---|---|
| `display` | DM Sans, tabular | 32 / 40 | 700 | -0.02em | hero amount |
| `title1` | DM Sans | 24 / 32 | 700 | -0.01em | auth screen titles, result headline |
| `title2` | DM Sans | 20 / 28 | 700 | -0.01em | page titles in large headers, greeting name |
| `title3` | DM Sans | 18 / 24 | 700 | 0 | app bar titles |
| `headline` | DM Sans | 16 / 24 | 700 | 0 | section and widget titles |
| `bodyLg` | Inter | 16 / 24 | 400 | 0 | input text, primary copy |
| `body` | Inter | 14 / 20 | 400 | 0 | body copy, descriptions |
| `bodyStrong` | Inter | 14 / 20 | 600 | 0 | list row titles, values in key/value rows |
| `label` | Inter | 13 / 16 | 600 | 0 | form labels, chip text, button sm |
| `caption` | Inter | 12 / 16 | 400 | 0 | metadata, helper text, timestamps |
| `overline` | Inter | 11 / 16 | 700 | +0.06em, uppercase | section labels, status pills |
| `button` | Inter | 15 / 20 | 600 | 0 | lg and md buttons |

Numbers: `num(size)` variants of DM Sans with tabular figures at 32, 24, 18, 16, 14. Money is always rendered by one `MoneyText` widget:

- Thousands separators via `NumberFormat` (`ZMW 12,450.00`).
- Currency code in the same family, one step smaller and in `textTertiary`.
- Optional muted decimals for large figures (hero, result).
- One notation everywhere. Recommendation: `ZMW` in data, `K` only for compact chips if product agrees; never mix on the same screen.

Weights: 400, 500, 600, 700 only. Remove `w900` and `FontWeight.bold`.
Wire these into `ThemeData.textTheme` and expose as `context.text.bodyStrong` etc. so widgets stop constructing `TextStyle`.

### 2.3 Colour usage

Keep the existing palette in `AppColors`. Changes:

- **Adjust for contrast**: darken `textTertiary` to about `#646C84` (AA on white). Restrict `textMuted` to placeholders, disabled text and decorative icons, never to information the user needs to read.
- **Add missing tokens** so raw hex can go: `surfaceSubtle #F7F8FA` (icon buttons, pressed fills), `borderSubtle #F0F1F5`, `disabledFill #B9BDD6`, `onBrandHigh/Mid/Low` (white at 100 / 76 / 60% for text on gradients), `selectedText` (replaces `#141644`), `unselectedText` (replaces `#3D4560`).
- **Channel colours are not semantic colours**. Add `channelMtn`, `channelAirtel`, `channelZamtel` (fg + fill) that are visually distinct from warning / danger. Better still, show operator logos in the avatar.
- Semantic colour is reserved for status. A screen should not show red unless something failed.
- Brand gradient only on: primary CTA, hero surfaces. Not on cards (settings profile card becomes a white card with a cobalt avatar, or a subtle tinted card without the glow shadow).
- Dark mode: out of scope. Remove `AppDarkTheme` (or leave it disabled and documented) so it does not look supported.

### 2.4 Border radius

| Token | Value | Use |
|---|---|---|
| `AppRadius.xs` | 6 | small badges inside rows, tooltips |
| `AppRadius.sm` | 8 | checkboxes, small icon buttons (32) |
| `AppRadius.md` | 12 | buttons, inputs, chips (non-pill), icon tiles, snackbars |
| `AppRadius.lg` | 16 | cards, list groups, dialogs content blocks |
| `AppRadius.xl` | 24 | bottom sheets (top corners), dialogs, hero bottom edge |
| `AppRadius.full` | 999 | pills, avatars, filter chips |

Rule: nested radius = outer radius minus padding (a 12px tile inside a 16px card with 4px inset). Migration: `10 → 12`, `13, 14 → 12 or 16`, `18 → 16`, `28, 30 → 24`.

### 2.5 Elevation and shadows

| Level | Token | Definition | Use |
|---|---|---|---|
| 0 | `flat` | 1px `borderLight`, no shadow | cards on white, inputs, list groups on page |
| 1 | `card` | existing `AppGradients.card` | cards on `surfacePage` |
| 2 | `raised` | `0 2 8 rgba(8,12,48,.06), 0 8 24 rgba(8,12,48,.08)` | sticky bottom action bar, floating quick actions over hero |
| 3 | `overlay` | `0 8 24 rgba(8,12,48,.10), 0 24 48 rgba(8,12,48,.14)` | dialogs, sheets, toasts, menus |
| brand | `brandGlow` | existing `gradientButton` | primary CTA only |

Rules: a surface gets a border or a shadow, not both. Shadows are always tinted navy, never black. Move shadows out of `AppGradients` into `AppShadows`.

### 2.6 Icon system

- **Library**: Iconsax only, `Linear` style by default, `Bold` style for active / selected states (nav bar, selected chips). Remove Material icons from UI code.
- **Access**: every icon goes through `AppIcons` with semantic names (`AppIcons.back`, `AppIcons.chevronRight`, `AppIcons.receive`, `AppIcons.printer`). Screens never import `iconsax_flutter` directly. Legacy asset constants move to `AppAssets`.
- **Sizes**: `AppIconSize.sm 16` (inline with caption/label text), `md 20` (controls, list rows, buttons), `lg 24` (nav bar, app bar actions), `xl 32` (feature icons inside 56 to 64px circles for empty/result states).
- **Containers**: icon tiles are 40x40, radius 12, `infoFill` background with `gpCobalt` icon at 20. Avatars are 40x40 circles.
- **Navigation**: back uses a left chevron, row affordance uses a right chevron at 16 in `textMuted`, forward CTAs have no trailing arrow. Choose one chevron pair from Iconsax (the `arrow_left_2` family already used by `BackHeader`) and verify on device that left and right glyphs match in weight.
- **Semantics** (proposed mapping):

| Meaning | Icon |
|---|---|
| Collect / request payment | `Iconsax.money_recive` (or `receive_square`) instead of `send_2` |
| Summary / reports | `Iconsax.chart_2` |
| History | `Iconsax.clock` / `Iconsax.receipt_2` |
| Success / failed / pending | `tick_circle` / `close_circle` / `timer_1` |
| Printer | `Iconsax.printer` |
| Bluetooth | `Iconsax.bluetooth` |
| Share receipt | `Iconsax.export_1` |
| Show / hide password | `eye` / `eye_slash` |

Remove the dashboard bell until notifications exist, or wire it.

### 2.7 Component sizing

| Element | Size |
|---|---|
| Minimum touch target | 48x48 (visual can be smaller, hit area cannot) |
| Button lg / md / sm | 52 / 44 / 36 height |
| Input | 52 height, 16 horizontal padding |
| Chip | 36 height, 12 horizontal padding (filter chips 16) |
| Icon button | 40 visual in 48 hit area |
| List row | min 64 (two lines), 56 (one line) |
| Avatar / icon tile | 40 |
| App bar | 56 + safe area |
| Bottom nav | 64 + safe area |
| Bottom action bar | 16 top, 16 + safe area bottom, 20 gutter |

### 2.8 Grid and layout

- Single column, 20px gutters, 4pt vertical rhythm.
- Max content width 560, centred, for tablets and landscape POS terminals.
- Screen anatomy: app bar, scroll body, optional sticky bottom action bar (primary action always bottom-anchored on task screens: Collections, Details, Result, Printer test).
- Sections: `SectionHeader` (headline + optional trailing text action) then 12 gap then content; 24 between sections.
- Grouped lists: one card per group with inset dividers (start at text, not at the icon) rather than one bordered card per row.

### 2.9 Interaction states

| State | Visual rule |
|---|---|
| Default | tokens as defined |
| Pressed | ripple clipped to shape (cobalt at 8%) plus scale 0.98 on buttons and cards, 100ms |
| Hover (web / desktop only) | background to `surfaceSubtle` or cobalt at 4%, 150ms |
| Focus | 2px cobalt ring at 40% offset 2px, for keyboard / accessibility navigation |
| Selected | `infoFill` background, cobalt 1.5px border, `selectedText`, Bold icon variant |
| Disabled | 40% opacity on content, no shadow, no ripple |
| Loading | label cross-fades to spinner, button keeps its width, taps ignored |
| Error | danger border, helper text slides in (150ms), `dangerText` |
| Success | inline check / toast, light haptic |

Implementation pattern for every tappable decorated surface: `Material(color, shape, clipBehavior: Clip.antiAlias) > InkWell > content`, or `Ink(decoration:)`. Never `InkWell > Container(color)`.

---

## 3. Component rules

Each item below becomes one shared widget in `lib/widgets/` (or `lib/ui/`), with a golden test.

| Component | Rule |
|---|---|
| `AppButton` | Variants: `primary` (gradient + brandGlow), `secondary` (white, `borderMedium`, cobalt text), `tertiary` (text only), `destructive` (dangerFill, dangerText), `icon`. Sizes lg / md / sm. Optional leading icon only when it adds meaning (print, share). Replaces `GradientButton`, legacy `AppButton`, `PrimaryButton` and all inline `OutlinedButton.styleFrom`. |
| `AppTextField` | One family: text, phone, amount, password (with `eye` icon toggle or keep the Show/Hide text, but the same everywhere). Label 8 above, helper / error 4 below, 52 height, radius md, 1.5px border, animated border colour. Supports prefix icon and prefix text. Replaces inline Collections fields and legacy fields. |
| `AppChoiceChip` | Used by amount chips and history filters. Height 36, pill for filters, radius md for amount chips. Animated selection. |
| `AppCard` | Radius lg, padding 16, elevation `flat` or `card`. Optional header slot. |
| `ListGroup` + `AppListTile` | Grouped card with inset dividers. Tile: leading 40 icon tile or avatar, title `bodyStrong`, subtitle `caption`, trailing value / badge / chevron. Replaces `_SettingsTile`, printer device rows, and informs `TransactionRow`. |
| `KeyValueList` | Label `body` in `textTertiary`, value `bodyStrong` right-aligned, 14 vertical padding becomes 12, copy-to-clipboard on IDs. Replaces three copies. |
| `StatusBadge` | Overline style (11/700), 4 x 8 padding, pill, optional 6px leading dot. One component for transaction status and settings badges. |
| `AppHeader` | 56 tall, title3, 40px back button in a 48 hit area with left chevron, optional trailing actions. Variant `large` for root tabs (title2, no back). Replaces `BackHeader` and Printer `_Header`. |
| `SectionHeader` | headline + optional "View all" tertiary button with chevron. |
| `AppNavBar` | 64 tall, Linear / Bold icon swap, 12px label, animated pill indicator behind the active icon, selection haptic. |
| `AppDialog` | Radius xl, padding 24, title1 or title3, body, buttons stacked full width (primary on top) or side by side; destructive variant. Inter / DM Sans only. |
| `AppSheet` | Radius xl top corners, 4x36 drag handle, 20 gutter, overlay shadow. |
| `AppToast` | Replaces snackbars: white surface, overlay shadow, 20 icon in semantic colour, title + message, radius md, floating 16 from edges, swipe to dismiss. |
| `EmptyState` | 64 circle in `infoFill` with xl icon, headline, body in `textTertiary`, optional secondary button. |
| `ErrorState` | Same shape, danger tint, message, "Try again" button wired to the cubit's reload. |
| `Skeleton` | Built on `shimmer` (already a dependency). Shapes mirror the real layout: `SkeletonRow`, `SkeletonStat`, `SkeletonText`. Base `#EEF0F5`, highlight `#F7F8FA`. |
| `MoneyText` | Single source of truth for amount formatting and styling (see 2.2). |
| `Tooltip` | Dark navy surface, caption white, radius xs, 150ms fade, long press on mobile. Used for info icons on stats. |

---

## 4. Motion and micro-interactions

### 4.1 Principles

1. **Purposeful**: motion explains a change (where something came from, what changed, that an action worked). Never decoration.
2. **Fast**: most transitions are 150 to 250ms. Nothing blocks input.
3. **Subtle**: small distances (8 to 16px), small scales (0.96 to 1.0), opacity. No bounces except the success moment.
4. **Consistent**: every animation uses a token, never a literal duration or curve.
5. **Respectful**: if `MediaQuery.disableAnimationsOf(context)` is true, durations collapse to zero (cross-fades only).

### 4.2 Tokens (`AppMotion`)

| Token | Duration | Curve | Use |
|---|---|---|---|
| `instant` | 100ms | `easeOut` | press scale, ripple start |
| `fast` | 150ms | `easeOutCubic` | colour / border changes, chip selection, focus |
| `base` | 200ms | `easeOutCubic` (enter), `easeInCubic` (exit) | tab cross-fade, dropdowns, expand / collapse, toasts |
| `slow` | 300ms | `easeInOutCubic` / `Curves.fastOutSlowIn` | page transitions, sheets, dialogs |
| `emphasis` | 500ms | `easeOutBack` (subtle overshoot) | success check, hero number count-up |
| `stagger` | 30ms per item, max 8 items | | list entrance on first load |

### 4.3 Where to use motion

| Moment | Treatment |
|---|---|
| Button press | scale to 0.98 over `instant`, ripple clipped to shape, light haptic on primary CTA |
| Button loading | `AnimatedSwitcher` label to spinner with fixed width, `fast` |
| Card / row press | clipped ripple + scale 0.99 |
| Page transitions | `pageTransitionsTheme` with a single builder (e.g. `FadeForwardsPageTransitionsBuilder` on Android, Cupertino on iOS), `slow` |
| Tab switch | `IndexedStack` (preserves state) with a `base` fade-through; nav pill indicator slides |
| Chip selection | `AnimatedContainer` fill / border, `fast` |
| Filter change | list content `AnimatedSwitcher` fade, `base` |
| Dropdown / menu | fade + scale from 0.96 at anchor, `base` |
| Dialog | fade + scale 0.96 to 1, `slow` enter, `base` exit |
| Bottom sheet | slide up with `slow`, scrim fade |
| Toast | slide 16px + fade in, `base`; auto dismiss with swipe |
| Loading | skeleton shimmer at 1.2s loop; skeleton to content cross-fade `base` |
| List first load | rows fade + rise 8px, `stagger` (use existing `FadeSlideListItem`, then delete the unused variants) |
| Expand / collapse | `AnimatedSize` + chevron rotation 180 degrees, `base` |
| Hero amount | count-up from previous value with `TweenAnimationBuilder`, `emphasis` duration, `easeOutCubic` |
| Pull to refresh | brand-coloured indicator, success haptic when data changes |
| Collection waiting | calm pulsing ring around the phone icon (1.6s loop, opacity only) and a progress bar for the 5 minute window |
| Payment success | circle scales in, check draws, success haptic, amount fades up (total under 700ms, once) |
| Payment failed | icon scales in, single 4px horizontal shake, error haptic |
| Input error | helper text slide / fade in `fast`, border colour `fast` |
| Copy to clipboard | inline "Copied" swap on the value, `fast`, light haptic |

---

## 5. Screen-by-screen plan

### 5.1 Dashboard (`home/widgets/home_body.dart`)
- Hero: greeting (`caption`, onBrandMid) and name (`title2`). Remove non-functional bell or wire it.
- Stats: `MoneyText` display with count-up, currency and decimals muted. Below it, a thin segmented bar (successful / pending / failed proportions from existing `statusCounts`) and a three-column stat row (count + label per status) instead of dots. Tap opens History pre-filtered.
- Quick actions: floating `raised` card overlapping the hero by a token value (remove the `Transform.translate` hack). Each action gets a 40px icon tile + label; fix clipped ripple; correct icons (receive, chart).
- Recent transactions: `SectionHeader` with "View all" chevron; rows inside one `ListGroup` card; time in subtitle.
- Loading: hero `SkeletonStat` and 3 `SkeletonRow`s instead of spinners. Empty: `EmptyState` with "New collection" action. Error: `ErrorState` with retry.

### 5.2 Collection flow
- **New collection**: switch to `AppTextField` (phone, amount); consistent label sizes; amount chips via `AppChoiceChip` with the same currency notation as the field; summary card uses `MoneyText` with animated value; inline validation for phone and amount; bottom action bar with `raised` elevation when content scrolls under it. Replace `send_2` with a receive icon.
- **Waiting**: pulsing ring, elapsed / remaining time progress, "Cancel request" as `secondary` button.
- **Result**: animated success / failure moment, `KeyValueList`, "Print receipt" as primary when successful, "Done" as secondary; "Try again" primary on failure.

### 5.3 Transaction history
- `IndexedStack` in `MainBody` so state and scroll survive tab switches.
- Large header variant, filter chips with animated selection and counts ("Failed 3").
- Group by day with sticky headers ("Today", "Yesterday", "Mon 22 Sep") and a per-day total on the right.
- Pull to refresh, skeleton rows, `EmptyState` per filter ("No failed transactions today").
- Staggered entrance on first load only.

### 5.4 Transaction details
- Receipt feel: status header card (icon, `MoneyText` display, status badge, date), then `KeyValueList` with copyable transaction ID, then a subtle dashed divider and the Geepay mark as a footer.
- Bottom bar: Share (secondary icon button, `export_1`) + Print (primary). Replace "coming soon" snackbars with toasts or hide the actions until wired.

### 5.5 Settings
- Profile card: white `AppCard` (or light tint) with gradient avatar ring; drop the brand glow shadow.
- `SectionHeader`s at 24 gaps, `ListGroup` tiles, chevron icons, `StatusBadge` for "Up to date".
- Log out as `destructive` button; dialog via `AppDialog`.

### 5.6 Printer settings
- Replace `_Header` with `AppHeader`; replace all Material icons; convert mode choice to radio-style selectable cards (animated selection); device rows as `AppListTile` with connection `StatusBadge`; Scan button shows inline spinner; "Run test print" as bottom-anchored primary. Largest spacing / type cleanup of any screen.

### 5.7 Login, Setup, Splash
- Unify field components and label gaps (fixes the 6px vs 8px mismatch). Remove trailing arrow from "Continue". Error messages as inline field errors or `AppToast`.
- Splash: keep the brand gradient; replace the rotating spinner with a subtle logo fade / progress bar; hold a minimum 600ms to avoid flash.
- Placeholder screens ("Cashier summary", "Company profile"): use `EmptyState` with a "Coming soon" badge rather than a blank page, or hide the entry points.

### 5.8 Global
- Bottom navigation: `AppNavBar`.
- Toasts replace all snackbars (`app_alerts.dart`, `print_helper.dart`, `bluetooth_printer_helper.dart`, `functions.dart`, details screen).
- Dialog restyle.

---

## 6. Prioritised implementation roadmap

Each phase is a separate PR, reviewable on its own. Earlier phases carry no screen redesign, only foundations, so they are low risk.

| Phase | Scope | Deliverables | Size |
|---|---|---|---|
| **0. Foundations** | Tokens only | `AppSpace`, `AppRadius`, `AppShadows`, `AppMotion`, `AppIconSize`, text styles wired into `ThemeData.textTheme` + `context.text` extension, colour token additions and contrast fix, `AppIcons` semantic map, `MoneyText`. Remove stray fonts (Poppins, Lato, Manrope, Ubuntu) and dead widgets. | S |
| **1. Core components** | Shared widgets | `AppButton`, `AppTextField` family, `AppChoiceChip`, `AppCard`, `ListGroup` / `AppListTile`, `KeyValueList`, `StatusBadge`, `AppHeader`, `SectionHeader`, `EmptyState`, `ErrorState`, `Skeleton*`. Fixes the ripple bug everywhere at once. Golden tests for each. | M |
| **2. Shell and feedback** | App-wide | `AppNavBar`, `IndexedStack` tabs, page transitions theme, `AppToast`, `AppDialog`, `AppSheet`. | M |
| **3. Dashboard** | Highest traffic | Hero stats, quick actions, recent list, skeleton / empty / error. | M |
| **4. Collection flow** | Core task | New collection, waiting, result (success moment). | M |
| **5. History + Details** | High frequency | Grouping, filters, refresh, receipt layout. | M |
| **6. Settings + Printer** | Utility screens | Token alignment, printer rebuild on components. | M |
| **7. Auth + Splash + placeholders** | First impression | Field unification, CTA cleanup, splash motion. | S |
| **8. Polish pass** | Whole app | On-device review at 360dp and a large POS screen, reduce-motion check, contrast check, haptics review, remove any remaining lint violations. | S |

Recommended order rationale: phases 0 to 2 remove most inconsistencies automatically because screens already share `BackHeader`, `TransactionRow`, `GradientButton` and `AppTextField`. Screen phases then only handle layout and data presentation.

Definition of done for every phase:
- No new literals for spacing, radius, font size, colour, duration, or icon size outside `lib/app/theme`.
- Golden tests updated; widget tests green; `very_good_analysis` clean.
- Checked on a small Android phone (360x640) and the target POS terminal.

---

## 7. Guardrails

- **Design lint script** (`tool/design_lint.sh`, run in CI) that fails on:
  - `fontSize:` with a `.5` value or any literal outside `lib/app/theme`
  - `Color(0x` outside `lib/app/theme`
  - `Icons.` in `lib/` (Material icons)
  - `import 'package:iconsax_flutter` outside `app_icons.dart`
  - `EdgeInsets` / `SizedBox` numeric literals not in the spacing scale
  - `Duration(milliseconds:` outside `AppMotion` (animation code only)
  - `GoogleFonts.` outside the theme
- **Golden tests** for every shared component in default, pressed, disabled, loading, selected and error states.
- **Component catalogue**: a debug-only "Design system" screen (reachable from Settings in dev flavour) listing tokens and components, so drift is visible.
- Update `geepay-pos-design-spec.md` to point at this document for anything beyond brand colours.

### Open decisions for product / design

1. Currency notation: `ZMW 20.00` everywhere, or `K20` allowed in compact chips?
2. Channel avatars: operator logos or neutral initials with non-semantic channel colours?
3. Keep "Coming soon" entry points (Cashier summary, Company profile, Share, Print on details) visible or hide them until built?
4. Dark mode: confirm out of scope so `AppDarkTheme` can be removed.
5. Dashboard bell: remove or build notifications?
