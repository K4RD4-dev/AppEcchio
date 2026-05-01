# APPecchio - UX Blueprint (Mobile-first)

## 1) Complete wireframe structure

- **Level 0 - Home Map (Primary Layer)**
  - Fullscreen living map
  - Top glass search bar
  - Quick chips: Today, Open Now, Nearby
  - Bottom contextual card: What's happening today
  - Center-bottom primary CTA: Explore
- **Level 1 - Radial Category Layer (Overlay)**
  - Dimmed map background (map stays visible)
  - Radial/semi-radial nodes (5 max): Explore, Events, Food & Drink, Culture, Services
  - Second-level contextual list for selected category
- **Level 2 - Detail Layer**
  - Hero image area
  - Title + key info (time, place, type)
  - Single primary CTA (Join / Call-Navigate / Access)

## 2) Component hierarchy

- `AppEcchioApp`
  - `HomeScreen`
    - `_LivingMapLayer`
      - `_MapPathPainter`
      - `_MapPin` x N
    - `_SearchGlassBar`
    - `_QuickFilterRow`
    - `_TodayContextCard`
    - `_RadialMenuOverlay` (stateful visibility)
      - `_RadialNode` x 5
      - `_SecondLevelArcList`
  - `DetailScreen`

## 3) Navigation flow diagram

```text
HOME MAP (idle)
  -> tap Explore
RADIAL MENU OVERLAY
  -> tap category
CATEGORY SECOND-LEVEL OPTIONS
  -> tap option
DETAIL SCREEN
  -> back
HOME MAP
```

## 4) Interaction states

- **Idle**
  - Map alive, subtle pin activity, quick actions always visible
- **Tap (Explore)**
  - Focus shifts to center CTA
  - Background dim increases
  - Radial nodes appear with short elevation/scale transition
- **Transition (Category -> Option)**
  - Selection context updates in-place (no hard page switch)
  - Arc-like directional feel through radial geometry
- **Transition (Option -> Detail)**
  - Slide + fade under 300ms
  - Keeps perceived continuity from map context

## 5) Suggested animations

- Map pin pulse: `1200-1800ms`, low amplitude, staggered
- Explore press feedback: `160-220ms` scale/elevation
- Radial reveal: `200-260ms` fade + position
- Category switch: `180-220ms` node emphasis change
- Detail open: `240-280ms` slide-right-to-left + fade
- All easing: `easeOutCubic`, no decorative loops

## 6) UI layout snapshots (by screen)

- **Home**
  - Top: glass search
  - Mid: animated map references
  - Bottom: contextual card + centered Explore FAB
- **Radial Menu**
  - Semi-radial category nodes around Explore center
  - Map always visible in dimmed state
  - Bottom sheet-like second-level action chips
- **Category Page (in-overlay state)**
  - Selected category highlighted
  - Up to 4 second-level options visible at once
  - One-tap progression to detail
- **Detail Page**
  - Hero visual header
  - Vertical information stack
  - Single primary CTA with high contrast
