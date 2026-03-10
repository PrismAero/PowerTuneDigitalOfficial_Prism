# Dashboard Component Config Menus -- Hardcoded Style Audit

Date: 2026-03-10

## Scope

All QML files in `PowerTune/Dashboard/` and `PowerTune/Gauges/` that contain
configuration UI (popups, dialogs, property editors, datasource selectors) or
hardcoded colors/fonts that should use theme tokens.

The primary config menu is `OverlayConfigPopup.qml`. In addition, the
`DraggableOverlay.qml` component renders an edit-mode chrome overlay with its
own hardcoded styling. A lightweight `DashboardTheme.qml` singleton exists but
is barely used and contains only four tokens.

---

## 1. OverlayConfigPopup.qml

**Path:** `PowerTune/Dashboard/OverlayConfigPopup.qml`
**Purpose:** Modal popup that opens when configuring any dashboard overlay item
(sensor cards, status rows, gauge groups, static text). Contains category/sensor
pickers, label/unit text fields, min/max fields, arc color fields, threshold
field, decimal spinner, shift-light settings, and action buttons.

### 1.1 Hardcoded Colors

| Line(s) | Value | Usage |
|---------|-------|-------|
| 39 | `#1a1a36` | Popup background fill |
| 40 | `#3a3a60` | Popup border |
| 96 | `#009688` | `accent` property alias |
| 97 | `#FFFFFF` | `txtP` (primary text) property alias |
| 98 | `#8888AA` | `txtS` (secondary text) property alias |
| 99 | `#111122` | `fieldBg` (field background) property alias |
| 100 | `#2a2a50` | `fieldBorder` property alias |
| 135 | `#333` | Close button background |
| 642 | `#663333` | Reset button background |
| 660 | `#333355` | Cancel button background |

Total: **10 unique hardcoded color values**

### 1.2 Hardcoded Font Sizes

| Line(s) | Value | Usage |
|---------|-------|-------|
| 124 | `18px` | Title text |
| 140 | `14px` | Close button "X" |
| 162, 189, 269, 296, 329, 359, 393, 419, 445, 474, 500, 528, 544, 589 | `13px` | Section labels (repeated) |
| 182, 224, 249, 276, 309, 345, 371, 404, 428, 484, 508, 516, 572 | `14px` | ComboBox/TextField content text (repeated) |
| 629, 648, 666 | `15px` | Action button text |

Total: 4 distinct pixel sizes (13, 14, 15, 18), none referencing a theme token.

### 1.3 Hardcoded Font Weights

`Font.DemiBold` (line 125), `Font.Bold` (lines 141, 631, 649, 667) -- no theme
reference.

### 1.4 Hardcoded Dimensions

- Popup `width: 460` (line 30)
- Popup `radius: 10` (line 42)
- Button sizes `32x32`, `42` height
- Field radius `6` used throughout
- Separator `height: 1`

### 1.5 Styled Components Used

None. Every control is manually styled with raw `Rectangle` backgrounds and
`Text` content items. No `StyledTextField`, `StyledComboBox`, `StyledButton`,
or `SettingsSection` wrappers.

### 1.6 Recommended SettingsTheme Token Mapping

| Current Hardcoded | SettingsTheme Token | Notes |
|------------------|-------------------|-------|
| `#1a1a36` (popup bg) | `surfaceElevated` (`#272829`) | Or new `popupBg` token |
| `#3a3a60` (popup border) | `border` (`#3A3B3E`) | Close match |
| `#009688` (accent) | `accent` (`#009688`) | Exact match -- use token |
| `#FFFFFF` (primary text) | `textPrimary` (`#ECEDEF`) | Slight difference |
| `#8888AA` (secondary text) | `textSecondary` (`#8B8D93`) | Close match |
| `#111122` (field bg) | `controlBg` (`#2F3032`) | Or new `popupFieldBg` |
| `#2a2a50` (field border) | `border` (`#3A3B3E`) | Close match |
| `#333` (close btn bg) | `surfacePressed` (`#2A2B2E`) | Close match |
| `#663333` (reset btn bg) | `error` (`#F44336`) | Semantic mismatch -- review |
| `#333355` (cancel btn bg) | `controlBg` (`#2F3032`) | Close match |
| `font 18px` | `fontSectionTitle` (20) or `fontLabel` (18) | 18 matches `fontLabel` |
| `font 15px` | `fontStatus` (16) | Close, round up |
| `font 14px` | `fontCaption` (14) | Exact match |
| `font 13px` | `fontCaption` (14) | Round up, or add new |
| `radius: 6` | `radiusSmall` (6) | Exact match -- use token |
| `radius: 10` | `radiusLarge` (8) | Close, or add `radiusPopup` |

---

## 2. DraggableOverlay.qml

**Path:** `PowerTune/Dashboard/DraggableOverlay.qml`
**Purpose:** Wraps every dashboard component, providing drag-to-reposition and
edit-mode chrome (close button, config button, alignment guides, position readout).

### 2.1 Hardcoded Colors

| Line(s) | Value | Usage |
|---------|-------|-------|
| 54 | `#40009688` | Horizontal alignment guide (40% opacity teal) |
| 63 | `#40009688` | Vertical alignment guide |
| 73 | `#20FFFFFF` | Center crosshair H (20% white) |
| 83 | `#20FFFFFF` | Center crosshair V |
| 93 | `#80009688` | Snap coordinate text |
| 104 | `"transparent"` | Edit border fill (OK) |
| 105 | `#60009688` | Edit border stroke |
| 114 | `#CC333333` | Close button bg (dimmed dark) |
| 115 | `#80FFFFFF` | Close button border |
| 125 | `#FFFFFF` | Close button "X" text |
| 138 | `#CC333333` | Config button bg |
| 139 | `#80009688` | Config button border |
| 150 | `#009688` | Config button "C" text |
| 162 | `#80FFFFFF` | Overlay ID label text |
| 172 | `#80FFFFFF` | Position label text |

Total: **11 unique hardcoded color values** (some repeated)

### 2.2 Hardcoded Font Sizes

| Line(s) | Value | Usage |
|---------|-------|-------|
| 92 | `12px` | Snap coordinate text |
| 123 | `14px` | Close button "X" |
| 149 | `14px` | Config button "C" |
| 161 | `10px` | Overlay ID label |
| 170 | `10px` | Position label |

### 2.3 Hardcoded Dimensions

- Button size `28x28`, radius `14`
- Guide widths `1600`, `720` (absolute to 1600x720 display)

### 2.4 Styled Components Used

None. Entirely custom rectangles and text items.

### 2.5 Recommended SettingsTheme Token Mapping

| Current Hardcoded | SettingsTheme Token | Notes |
|------------------|-------------------|-------|
| `#009688` variants | `accent` | Use with Qt.rgba for alpha variants |
| `#FFFFFF` / `#80FFFFFF` | `textPrimary` | Use with alpha for dimmed variants |
| `#CC333333` | `surfacePressed` | Close enough |
| `12px`, `14px` | `fontCaption` (14) | Normalize to 14 |
| `10px` | No match | Add `fontMicro` token or use `fontCaption` |
| `28x28` buttons | New `overlayButtonSize` or compute from `controlHeight` | |

---

## 3. DashboardTheme.qml

**Path:** `PowerTune/Dashboard/DashboardTheme.qml`
**Purpose:** Singleton intended to centralize dashboard panel styling. Currently
only 4 tokens:

| Token | Value | Used By |
|-------|-------|---------|
| `panelBackground` | `#3a3a3a` | Not referenced in any Dashboard file |
| `panelBorder` | `#5a5a5a` | Not referenced in any Dashboard file |
| `panelText` | `#FFFFFF` | Not referenced in any Dashboard file |
| `panelRadius` | `6` | Not referenced in any Dashboard file |

**Status:** Completely unused. Either expand with overlay/config tokens or
remove in favor of using `SettingsTheme` for config menus and keeping
`DashboardTheme` for runtime gauge chrome only.

---

## 4. Other Dashboard Components with Hardcoded Colors

These are NOT config menus, but gauge display components on the dashboard that
also contain hardcoded values. Included for completeness since they may render
inside the config popup preview or need consistency.

### 4.1 SensorCard.qml

| Line(s) | Value | Usage |
|---------|-------|-------|
| 24, 40, 62 | `#FFFFFF` | Label, value, unit text color |
| 51, 74 | `#40000000` | Drop shadow color (40% black) |
| 88 | `#3A3A3A` | Divider line stroke |

Font sizes: 40px (label), 68px (value), 32px (unit) -- these are gauge display
sizes, not config sizes. Font weight `Font.Light`, `Font.Normal`, font style
`italic`.

### 4.2 StatusBox.qml

| Line(s) | Value | Usage |
|---------|-------|-------|
| 30, 80-83 | `#3A3A3A`, `#4A4A4A` | Border/divider strokes |
| 53, 106 | `#FFFFFF` | Label text |
| 62, 115 | `#1ED033` | "ON" status green |
| 62, 115 | `#FF0909` | "OFF" status red |

Font sizes: 32px. Font style: italic.

### 4.3 BottomStatusBar.qml

| Line(s) | Value | Usage |
|---------|-------|-------|
| 33, 54, 66 | `#FFFFFF` | Text color |
| 41 | `#1ED033` | System OK green |
| 41 | `#FF0909` | System error red |

Font sizes: 24px.

### 4.4 ArcGauge.qml

| Line(s) | Value | Usage |
|---------|-------|-------|
| 11 | `#E88A1A` | Default arc color start (property default) |
| 12 | `#C45A00` | Default arc color end (property default) |
| 85 | `#151518` | Arc background fill |
| 111 | `#282828` | Shader chrome dark |
| 112 | `#6A6A6A` | Shader chrome light |
| 113 | `#151518` | Shader background |

### 4.5 ArcFillOverlay.qml

| Line(s) | Value | Usage |
|---------|-------|-------|
| 16 | `#E88A1A` | Default arc color start |
| 17 | `#C45A00` | Default arc color end |

### 4.6 GearIndicator.qml

| Line(s) | Value | Usage |
|---------|-------|-------|
| 38, 48 | `#FFFFFF` | Gear number, suffix text |

Font sizes: 140px, 52px.

### 4.7 ShiftIndicator.qml

| Line(s) | Value | Usage |
|---------|-------|-------|
| 35 | `#222222` | Unlit pill background |

Pill colors are computed by `ShiftHelper.pillColors()`.

### 4.8 BrakeBiasBar.qml

| Line(s) | Value | Usage |
|---------|-------|-------|
| 19, 31, 43 | `#FFFFFF` | Text colors |
| 65 | `#CC0000` | Gradient red |
| 66 | `#CCCC00` | Gradient yellow |
| 67 | `#00CC00` | Gradient green |
| 80 | `#FFFFFF` | Needle fill |

### 4.9 RaceDash.qml

| Line(s) | Value | Usage |
|---------|-------|-------|
| 22 | `#E88A1A` | Tach arc color start default |
| 23 | `#C45A00` | Tach arc color end default |
| 35 | `#AA1111` | Speed arc color start default |
| 36 | `#880000` | Speed arc color end default |

---

## 5. Gauges/Shared Components

### 5.1 Warning.qml

| Line(s) | Value | Usage |
|---------|-------|-------|
| 14 | `"red"` | Warning rectangle fill |
| 18 | `"red"` to `"orange"` animation | Flash colors |
| 31, 43 | `"black"` | Warning text color |

Font: 30px from `font.family: "Lato"`, `font.bold: true`.

### 5.2 DatasourcesList.qml / DatasourceService.qml / WarningLoader.qml

No hardcoded colors (data models and logic only).

---

## 6. Summary: Files Requiring Config Menu Theme Migration

**Primary targets (config/edit UI):**

| File | Hardcoded Colors | Hardcoded Font Sizes | Uses Styled Components | Priority |
|------|-----------------|---------------------|----------------------|----------|
| `OverlayConfigPopup.qml` | 10 | 4 distinct sizes | None | HIGH |
| `DraggableOverlay.qml` | 11 | 3 distinct sizes | None | HIGH |
| `DashboardTheme.qml` | 4 (unused) | 0 | N/A (is a theme) | MEDIUM |

**Secondary targets (gauge display -- not config menus):**

| File | Hardcoded Colors | Notes |
|------|-----------------|-------|
| `SensorCard.qml` | 3 | Display only |
| `StatusBox.qml` | 4 | Display only |
| `BottomStatusBar.qml` | 3 | Display only |
| `ArcGauge.qml` | 6 | Shader + canvas |
| `ArcFillOverlay.qml` | 2 | Defaults only |
| `GearIndicator.qml` | 1 | Display only |
| `ShiftIndicator.qml` | 1 | Display only |
| `BrakeBiasBar.qml` | 5 | Gradient + needle |
| `RaceDash.qml` | 4 | Property defaults |
| `Warning.qml` | 3 | Alert overlay |

---

## 7. Recommended Approach

1. **OverlayConfigPopup.qml** -- Replace all local color/font aliases with
   `SettingsTheme` token references. Replace manual `Rectangle`+`Text` button
   styling with `StyledButton`. Replace raw `TextField` with `StyledTextField`.
   Replace raw `ComboBox` with `StyledComboBox`. This makes the config popup
   visually consistent with the Settings module.

2. **DraggableOverlay.qml** -- For the edit-mode chrome, create a small set of
   overlay-specific tokens in `DashboardTheme.qml` (or extend `SettingsTheme`
   with an overlay section). The alignment guides and edit chrome have unique
   alpha transparency needs.

3. **DashboardTheme.qml** -- Either:
   - (a) Expand it with proper tokens for runtime gauge display and edit chrome, or
   - (b) Deprecate it and merge dashboard chrome tokens into `SettingsTheme`.

4. **Gauge display components** (SensorCard, StatusBox, etc.) -- These are
   runtime dashboard visuals, not config menus. Their styling is intentionally
   separate from the Settings theme. However, status colors like `#1ED033` and
   `#FF0909` should still reference semantic tokens (consider adding
   `DashboardTheme.statusOn` / `DashboardTheme.statusOff`).
