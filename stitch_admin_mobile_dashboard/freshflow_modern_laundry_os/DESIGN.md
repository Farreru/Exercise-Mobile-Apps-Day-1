---
name: FreshFlow Modern Laundry OS
colors:
  surface: '#f9f9ff'
  surface-dim: '#cfdaf2'
  surface-bright: '#f9f9ff'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f0f3ff'
  surface-container: '#e7eeff'
  surface-container-high: '#dee8ff'
  surface-container-highest: '#d8e3fb'
  on-surface: '#111c2d'
  on-surface-variant: '#434655'
  inverse-surface: '#263143'
  inverse-on-surface: '#ecf1ff'
  outline: '#737686'
  outline-variant: '#c3c6d7'
  surface-tint: '#0053db'
  primary: '#004ac6'
  on-primary: '#ffffff'
  primary-container: '#2563eb'
  on-primary-container: '#eeefff'
  inverse-primary: '#b4c5ff'
  secondary: '#9d4300'
  on-secondary: '#ffffff'
  secondary-container: '#fd761a'
  on-secondary-container: '#5c2400'
  tertiary: '#006242'
  on-tertiary: '#ffffff'
  tertiary-container: '#007d55'
  on-tertiary-container: '#bdffdb'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#dbe1ff'
  primary-fixed-dim: '#b4c5ff'
  on-primary-fixed: '#00174b'
  on-primary-fixed-variant: '#003ea8'
  secondary-fixed: '#ffdbca'
  secondary-fixed-dim: '#ffb690'
  on-secondary-fixed: '#341100'
  on-secondary-fixed-variant: '#783200'
  tertiary-fixed: '#6ffbbe'
  tertiary-fixed-dim: '#4edea3'
  on-tertiary-fixed: '#002113'
  on-tertiary-fixed-variant: '#005236'
  background: '#f9f9ff'
  on-background: '#111c2d'
  surface-variant: '#d8e3fb'
typography:
  headline-xl:
    fontFamily: Plus Jakarta Sans
    fontSize: 36px
    fontWeight: '800'
    lineHeight: 44px
    letterSpacing: -0.03em
  headline-xl-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 30px
    fontWeight: '800'
    lineHeight: 38px
    letterSpacing: -0.025em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 34px
    letterSpacing: -0.02em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.015em
  headline-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 17px
    fontWeight: '600'
    lineHeight: 24px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  body-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 13px
    fontWeight: '400'
    lineHeight: 18px
  label-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: '600'
    lineHeight: 18px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: '600'
    lineHeight: 16px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 11px
    fontWeight: '700'
    lineHeight: 14px
    letterSpacing: 0.03em
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  gutter: 1rem
  margin: 1.25rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.875rem
  space-lg: 1.25rem
  space-xl: 1.75rem
---

## Brand & Style

This design system translates the complexity of commercial and on-demand laundry management into a friendly, airy, and hyper-legible mobile interface. Drawing visual inspiration from modern modular wellness dashboards, the aesthetic balances functional administrative rigor with soft, tactile approachability.

The visual style merges **Contemporary Minimalism** with **Soft Layered Tactility**:
- Crisp, rounded surfaces set against cool, ultra-light tinted backdrops evoke the hygiene, crisp folding, and cleanliness of fresh linens.
- Energetic color-coded accents bring instant situational awareness to multi-stage operational pipelines (e.g., washing, drying, folding, transit, completed).
- Micro-interactions, rounded pill badges, and circular progress rings provide continuous operational clarity without overwhelming operators, drivers, or facility managers during fast-paced shifts.

## Colors

The palette is engineered around high functional contrast and cleanliness:
- **Primary (`#2563EB` - Ocean Blue):** Represents fresh laundry cycles, core active states, primary CTA buttons, and critical operational navigation.
- **Secondary (`#F97316` - Energetic Amber):** Designates active machine cycles, pending pickups, urgent turnarounds, and express service alerts.
- **Tertiary (`#10B981` - Crisp Emerald):** Signifies completed batches, ready-for-pickup notifications, verified payments, and positive operational throughput metrics.
- **Neutral Accent (`#0284C7` - Sky Wash):** Dedicated to water efficiency tracking, detergent dosage monitoring, and wet-cycle phases.
- **Base Surfaces & Backgrounds:** The base canvas utilizes `#F8F9FA` transitioning to cool slate tints (`#F1F5F9`), while primary interactive cards sit on pure `#FFFFFF` to ensure high separation and clean contrast.
- **Typography & Structural Contrast:** Headlines and deep data values utilize `#0F172A` and `#1E293B`, while secondary metadata rests in softened slate `#64748B`.

## Typography

Typography relies entirely on **Plus Jakarta Sans** for its geometric balance, open counters, and contemporary feel. Large statistical values, batch numbers, and screen headers use heavy weights (`700` and `800`) with tighter letter spacing to maintain visual punch. Body and status copy stay strictly at medium and regular weights to preserve legibility when viewed in high-glare environments or active physical workspaces.

## Layout & Spacing

The interface employs a mobile-first fluid single-to-two-column modular layout:
- **Canvas Margins:** Fixed `1.25rem` (20px) horizontal outer margin creates a comfortable finger tap target safe zone and frame.
- **Card Internals:** Internal card padding scales between `1rem` and `1.25rem` to keep content breathing without excessive scrolling.
- **Modular Dashboard Grid:** Operational stats split into dual-column compact widgets separated by a consistent `0.875rem` (14px) gap, while critical orders and machine telemetry cards span full width.
- **Density Consideration:** Tap targets for interactive chips and row toggles maintain a minimum height of 44px to satisfy physical handheld ergonomics.

## Elevation & Depth

Visual depth is achieved through **ambient diffused shadows** and **tonal contrast** rather than structural borders:
- **Base Canvas:** Neutral off-white `#F8F9FA` acts as the recessed floor.
- **Level 1 (Cards & Modules):** Pure `#FFFFFF` surfaces paired with an ultra-soft ambient shadow: `box-shadow: 0 8px 24px -4px rgba(15, 23, 42, 0.04), 0 2px 6px -1px rgba(15, 23, 42, 0.02)`.
- **Level 2 (Active Overlays, Modals & Floating Bars):** Enhanced diffusion using `box-shadow: 0 16px 36px -6px rgba(37, 99, 235, 0.12), 0 4px 12px -2px rgba(15, 23, 42, 0.05)`.
- **Accent Tints:** Highlighted metric containers (e.g., Water Remainder or Dry Express widgets) apply a subtle 6% to 12% linear gradient tint of the associated functional color (e.g., `#E0F2FE` to `#BAE6FD` for water modules).

## Shapes

The design system adopts a **pill-shaped, generously curved geometry**:
- **Primary Content Cards:** Feature rounded corners between `20px` and `24px` (`rounded-lg` to `rounded-xl`), creating friendly, modular physical containers.
- **Tags, Filter Pills & Badges:** Utilize full 9999px pill shapes (`rounded-full`), providing strong contrast against rectangular data cards.
- **Internal Micro-elements:** Progress indicator bars, stat bar charts, and machine state chips inherit fully rounded caps for an organic, modern feel.

## Components

### Buttons & Call-to-Actions
- **Primary Buttons:** High-contrast pill-shaped (`rounded-full`) blocks in `#2563EB` with bold white text and a soft, matching blue ambient shadow.
- **Secondary / Action Icons:** Circular 40px buttons (`rounded-full`) in `#F1F5F9` featuring 18px icons in `#1E293B` for rapid navigation, close, and drawer toggles.

### Status Badges & Filter Pills
- **Filter Chips:** Capsule-style (`rounded-full`) horizontal scroller. Active state features high-contrast filled background (e.g., vibrant orange `#F97316` or ocean blue `#2563EB`) with a circular count bubble; inactive state rests on muted `#F1F5F9` with `#64748B` typography.
- **Batch State Indicators:** Pill badges utilizing 10% opacity color fills paired with heavy colored text (e.g., `bg-emerald-50 text-emerald-700` for "Cleaned & Ready").

### Dashboard Stat Rings & Progress Bars
- **Radial Rings:** Circular SVG gauges with a background track in `#F1F5F9` and stroke cap set to `round`. Accents use functional primary or alert tokens to display washer capacity and cycle completion percentages.
- **Segmented Bar Charts:** Rounded vertical pill bars with dynamic height fills, reflecting daily processed tonnage, customer drop-offs, and driver route completion.

### Cards & Order Modules
- **Order Queue Cards:** White elevated cards with customer avatar, delivery schedule pill, item tag breakdown, and a clean forward navigation affordance.
- **Environmental Tracking Card:** Soft pastel gradient card background (Sky `#E0F2FE` to `#BAE6FD`) incorporating droplet iconography, bold fluid volume counts, and cycle metrics.

### Inputs & Controls
- **Form Controls:** Generously rounded inputs (16px border-radius) with subtle border `#E2E8F0`, shifting to a crisp `2px #2563EB` focus ring with a faint glow.
- **Segmented Selectors:** Recessed pill container (`#F1F5F9`) housing sliding white pill tabs to switch between "In Wash", "Drying", and "Dispatched".