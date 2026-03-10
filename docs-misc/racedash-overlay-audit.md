# RaceDash Overlay System -- Full Audit

**Date:** 2026-03-10
**Target:** 1600x720 ultrawide display
**Figma Reference:** https://www.figma.com/design/p6aIQVCeE37nwKpDEoImHG/Racedash_AiM?node-id=9-755

---

## Files Audited

| File | Path | Purpose |
|------|------|---------|
| [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml) | `PowerTune/Dashboard/` | Main RaceDash layout -- widget hierarchy, overlay wiring, edit toolbar |
| [`DashboardTheme.qml`](../PowerTune/Dashboard/DashboardTheme.qml) | `PowerTune/Dashboard/` | Per-dashboard theme singleton |
| [`UserDashboard.qml`](../PowerTune/Dashboard/UserDashboard.qml) | `PowerTune/Dashboard/` | Generic user-dashboard canvas with background and gauge container |
| [`DraggableOverlay.qml`](../PowerTune/Dashboard/DraggableOverlay.qml) | `PowerTune/Dashboard/` | Edit-mode chrome: drag, alignment guides, config button, close button |
| [`OverlayConfigPopup.qml`](../PowerTune/Dashboard/OverlayConfigPopup.qml) | `PowerTune/Dashboard/` | Popup for per-widget configuration -- sensor, arc colors, decimals, etc. |
| [`ArcFillOverlay.qml`](../PowerTune/Dashboard/ArcFillOverlay.qml) | `PowerTune/Dashboard/` | Canvas-based arc fill with conical gradient and animated tip cap |
| [`ArcGauge.qml`](../PowerTune/Dashboard/ArcGauge.qml) | `PowerTune/Dashboard/` | ShaderEffect-based arc gauge with chrome rings and fill indicator |
| [`BottomStatusBar.qml`](../PowerTune/Dashboard/BottomStatusBar.qml) | `PowerTune/Dashboard/` | Bottom bar: system status dot, team name, clock |
| [`BrakeBiasBar.qml`](../PowerTune/Dashboard/BrakeBiasBar.qml) | `PowerTune/Dashboard/` | Brake bias horizontal gradient bar with needle |
| [`GearIndicator.qml`](../PowerTune/Dashboard/GearIndicator.qml) | `PowerTune/Dashboard/` | Gear number display with ordinal suffix |
| [`SensorCard.qml`](../PowerTune/Dashboard/SensorCard.qml) | `PowerTune/Dashboard/` | Standalone sensor card with label, value, unit, and angular divider |
| [`ShiftIndicator.qml`](../PowerTune/Dashboard/ShiftIndicator.qml) | `PowerTune/Dashboard/` | Shift-light pill row driven by `ShiftHelper` C++ helper |
| [`StatusBox.qml`](../PowerTune/Dashboard/StatusBox.qml) | `PowerTune/Dashboard/` | Two-row status box with ON/OFF indicators and chrome dividers |
| [`DatasourceService.qml`](../PowerTune/Gauges/Shared/DatasourceService.qml) | `PowerTune/Gauges/Shared/` | Singleton datasource registry with search/filter |
| [`DatasourcesList.qml`](../PowerTune/Gauges/Shared/DatasourcesList.qml) | `PowerTune/Gauges/Shared/` | Static ListModel of all available sensor channels |
| [`PropertyRouter.cpp`](../Core/PropertyRouter.cpp) | `Core/` | C++ implementation -- routes `getValue()` to data model properties |
| [`PropertyRouter.h`](../Core/PropertyRouter.h) | `Core/` | C++ header -- 13 model types, QHash-based property map |

---

## 1. Widget Placement and Layout Engine

### 1.1 Positioning Method

All overlays in [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml) use **absolute pixel coordinates** via explicit `x` and `y` properties on each [`DraggableOverlay`](../PowerTune/Dashboard/DraggableOverlay.qml) instance. There is no layout manager (Row/Column/Grid) governing the top-level arrangement. Each widget's position is hardcoded at instantiation time, matching target positions from the Figma design.

Current overlay positions:

| Overlay ID | x | y | Width | Height | Description |
|------------|---|---|-------|--------|-------------|
| `tachGroup` (shift) | 337 | 30 | dynamic | dynamic | Shift light pills |
| `waterTemp` | 58 | 60 | 250 | 113 | Water temp sensor card |
| `oilPressure` | 58 | 201 | 250 | 113 | Oil pressure sensor card |
| `statusBox` (parent) | 58 | 379 | 250 | dynamic | Status box container |
| `statusRow0` | 0 | 0 | 250 | 32 | Digital input 1 status row |
| `statusRow1` | 0 | 0 | 250 | 32 | Digital input 2 status row |
| `biasNeedle` | 274 | 603 | 12 | 28 | Brake bias needle indicator |
| `tachGroup` (arc) | 498 | 80 | 595 | 595 | Tach arc gauge |
| `tachGroup` (text) | 660 | 238 | dynamic | dynamic | Tach value + gear + unit |
| `speedGroup` (arc) | 1058 | 154 | 521 | 521 | Speed arc gauge |
| `speedGroup` (text) | 1229 | 374 | dynamic | dynamic | Speed value + unit |
| `bottomBar` | 0 | 680 | 1600 | 40 | Bottom status bar |

### 1.2 Snap-to-Grid / Auto-Guide Alignment

[`DraggableOverlay.qml`](../PowerTune/Dashboard/DraggableOverlay.qml:50) provides visual alignment guides during drag:

- **Crosshair guides** (lines 51-67): Horizontal and vertical lines through the widget center, full-canvas extent (1600x720), shown only while `_isDragging`
- **Center crosshair** (lines 70-87): Fixed lines at canvas center (800, 360), shown as a lighter secondary guide during drag
- **Coordinate label** (lines 90-100): Shows `x, y` below the widget during drag

**No snap-to-grid logic exists.** Widgets can be dragged to any pixel position. There is no magnetic snapping, edge alignment, or grid quantization.

### 1.3 Lock Mechanism

The lock mechanism is implemented via [`OverlayConfig.positionsLocked`](../PowerTune/Dashboard/DraggableOverlay.qml:19):

- [`DragHandler`](../PowerTune/Dashboard/DraggableOverlay.qml:204) is `enabled: root.editMode && !root._locked`
- The edit toolbar in [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml:578) provides a Lock/Unlock button that toggles `OverlayConfig.positionsLocked`
- A "Reset Positions" button calls `OverlayConfig.resetAllPositions()` which triggers `onPositionsReset` in each overlay

**Edit mode activation:** Double-tap (2 taps within 400ms) toggles `editMode`. Triple-tap opens the config popup if `configType !== ""`.

### 1.4 Figma Layout Comparison

Comparing the static background image [`Racedash_AiM.png`](../Racedash_AiM.png) against overlay positions:

| Element | Figma Approximate Position | Code Position | Status |
|---------|---------------------------|---------------|--------|
| Shift lights | top-center above tach | x:337, y:30 | Appears aligned |
| Water temp card | upper-left zone | x:58, y:60 | Appears aligned with left sensor area |
| Oil pressure card | below water temp | x:58, y:201 | Aligned, ~28px gap from water temp bottom |
| Status rows | left-side below oil | x:58, y:379 | Positioned in left zone near Figma status area |
| Brake bias needle | bottom-left | x:274, y:603 | Near brake bias bar in background |
| Tach arc | center | x:498, y:80, 595x595 | Matches the large center arc ring in background |
| Tach text | center of tach | x:660, y:238 | Centered within tach arc area |
| Speed arc | right | x:1058, y:154, 521x521 | Matches the smaller right arc ring |
| Speed text | center of speed arc | x:1229, y:374 | Centered within speed arc area |
| Bottom bar | full-width bottom | x:0, y:680, 1600x40 | Matches bottom bar zone |

**Missing from current implementation vs Figma background:**

1. **`BrakeBiasBar.qml`** -- The brake bias gradient bar (RWD/FWD) visible in the Figma background is NOT instantiated in `RaceDash.qml`. Only a standalone `biasNeedle` overlay exists, but the actual [`BrakeBiasBar`](../PowerTune/Dashboard/BrakeBiasBar.qml) component is never used
2. **`SensorCard.qml`** -- The standalone [`SensorCard`](../PowerTune/Dashboard/SensorCard.qml) component with drop shadows is not used; sensor cards are inlined directly in `RaceDash.qml` without the divider Canvas and DropShadow effects
3. **`StatusBox.qml`** -- The chrome-bordered [`StatusBox`](../PowerTune/Dashboard/StatusBox.qml) component is not used; status rows are inlined directly
4. **`ArcGauge.qml`** -- The ShaderEffect-based [`ArcGauge`](../PowerTune/Dashboard/ArcGauge.qml) is NOT used. Instead, [`ArcFillOverlay`](../PowerTune/Dashboard/ArcFillOverlay.qml) (Canvas-based) is used for both tach and speed arcs

---

## 2. Settings / Configuration Menu Binding

### 2.1 PropertyRouter Channel Assignment

All live data bindings flow through [`PropertyRouter.getValue(sensorKey)`](../Core/PropertyRouter.h:75). The `PropertyRouter` C++ class:

- Accepts 13 data model pointers at construction (Engine, Vehicle, GPS, Analog, Digital, Expander, Motor, Flags, Sensor, Connection, Settings, Timing, UI)
- Scans each model's `QMetaObject` properties via introspection at [`initializePropertyMappings()`](../Core/PropertyRouter.cpp:59)
- Routes `getValue(propertyName)` calls to the appropriate model's `QObject::property()` at runtime
- Returns `QVariant(0)` for unknown properties (with a `qWarning`)

The binding pattern in QML is:
```qml
var v = PropertyRouter.getValue(raceDash.tachSensorKey);
return v !== undefined ? Number(v) : 0;
```

This is a **polling/expression-reevaluation** pattern, NOT a direct QML property binding. The value is re-evaluated whenever the JS expression is reevaluated, which happens on QML engine repaint cycles. There is no explicit `Connections` or signal-based notification from `PropertyRouter` when a value changes.

**ISSUE:** `PropertyRouter.getValue()` is a `Q_INVOKABLE` method that returns a snapshot. QML has no way to know when the underlying model property changes, since `PropertyRouter` does not emit signals per-property. The binding relies on QML's implicit reevaluation, which may miss intermediate updates or cause stale display values.

### 2.2 Widget-to-Sensor Mapping

| Widget | Sensor Key Property | Default Key | Config Type |
|--------|-------------------|-------------|-------------|
| Tach arc + text | `tachSensorKey` | `"rpm"` | `tachGroup` |
| Gear indicator | `tachGearKey` | `"Gear"` | (part of tachGroup) |
| Shift lights | `tachSensorKey` | `"rpm"` | (part of tachGroup) |
| Speed arc + text | `speedSensorKey` | `"speed"` | `speedGroup` |
| Water temp | `wtSensorKey` | `"Watertemp"` | `sensorCard` |
| Oil pressure | `opSensorKey` | `"oilpres"` | `sensorCard` |
| Status row 0 | `sr0SensorKey` | `"DigitalInput1"` | `statusRow` |
| Status row 1 | `sr1SensorKey` | `"DigitalInput2"` | `statusRow` |
| Bottom bar | (static text) | `"Cardinal Racing"` | `staticText` |

### 2.3 Multi-Instrument Compound Widgets

The **tachGroup** is a compound instrument spanning multiple overlays:

1. `shiftOverlay` -- Shift lights (uses `tachSensorKey` for RPM, `tachShiftPoint`, `tachShiftCount`, `tachShiftPattern`)
2. `tachArcOverlay` -- Arc fill (uses `tachSensorKey`, `tachMin`, `tachMax`, `tachArcColorStart`, `tachArcColorEnd`)
3. `tachTextOverlay` -- Gear display (uses `tachGearKey`) + RPM text (uses `tachSensorKey`) + unit label

All three share the same `overlayId: "tachGroup"` and `configType: "tachGroup"`, meaning configuration changes apply to all three simultaneously via [`applyOverlayProps("tachGroup")`](../PowerTune/Dashboard/RaceDash.qml:72).

Similarly, **speedGroup** spans:
1. `speedArcOverlay` -- Arc fill
2. `speedTextOverlay` -- Speed value + unit

Both share `overlayId: "speedGroup"`.

**Each sub-gauge within a group CANNOT independently bind to different PropertyRouter parameters** -- they are all driven by the same root-level property (e.g., `tachSensorKey`). The gear indicator is the exception: it uses a separate property `tachGearKey` that is independently configurable within the tachGroup config.

### 2.4 Binding Issues

| Issue | Severity | Details |
|-------|----------|---------|
| **`oilpres` not in DatasourcesList** | Medium | The default sensor key `"oilpres"` for oil pressure is not present in [`DatasourcesList.qml`](../PowerTune/Gauges/Shared/DatasourcesList.qml). The list only has ESP/ECT/MAP/RPM/Speed/Gear as core channels. Oil pressure must be resolved from one of the C++ data models directly. |
| **`DigitalInput1`/`DigitalInput2` not in DatasourcesList** | Medium | Status row defaults reference `DigitalInput1` and `DigitalInput2`, but the DatasourcesList only contains EX Digital Inputs (EXDigitalInput1-8). The non-prefixed names must be resolved from the `DigitalInputs` C++ model. |
| **No reactive binding from PropertyRouter** | High | `PropertyRouter.getValue()` is a snapshot function. QML expression bindings relying on it will only update when the QML engine happens to reevaluate the expression. There is no signal propagation from the C++ model through PropertyRouter to QML. |
| **Brake bias has no sensor binding** | Medium | The `biasNeedle` overlay has no `configType` and no sensor binding. It is a static Canvas drawing. |

---

## 3. Specific Widget Verification

### 3.1 RPM Arc Gauge

**Component used:** [`ArcFillOverlay`](../PowerTune/Dashboard/ArcFillOverlay.qml) (Canvas-based, NOT the ShaderEffect-based `ArcGauge.qml`)

| Parameter | Value | Figma Reference |
|-----------|-------|-----------------|
| `startAngleDeg` | 135 | Matches -- arc starts at lower-left (135 degrees from 3-o'clock) |
| `sweepAngleDeg` | 270 | Matches -- 270-degree sweep (3/4 circle) |
| `arcOuterRadius` | 0.434 | Proportional to 595x595 container = ~258px radius |
| `arcInnerRadius` | 0.225 | Proportional = ~134px radius |
| `minValue` | 0 (default) | Correct |
| `maxValue` | 10000 (default) | Correct for typical RPM range |
| Colors | `#E88A1A` to `#C45A00` | Orange gradient -- matches Figma warm-tone arc |

**NOTE:** The background image provides the chrome ring appearance. `ArcFillOverlay` only draws the colored fill. The unused [`ArcGauge.qml`](../PowerTune/Dashboard/ArcGauge.qml) has a full ShaderEffect with chrome rings built-in, but it is not active.

### 3.2 Speed Arc Gauge

**Component used:** [`ArcFillOverlay`](../PowerTune/Dashboard/ArcFillOverlay.qml)

| Parameter | Value | Figma Reference |
|-----------|-------|-----------------|
| `startAngleDeg` | 135 | Same as tach |
| `sweepAngleDeg` | 270 | Same as tach |
| `arcOuterRadius` | 0.434 | Proportional to 521x521 container = ~226px radius |
| `arcInnerRadius` | 0.225 | Proportional = ~117px radius |
| `minValue` | 0 | Correct |
| `maxValue` | 200 | Default MPH range |
| Colors | `#AA1111` to `#880000` | Red gradient |

### 3.3 Gear Indicator

[`GearIndicator.qml`](../PowerTune/Dashboard/GearIndicator.qml):

- Bound to `PropertyRouter.getValue(raceDash.tachGearKey)` (default: `"Gear"`)
- Displays: N for 0, R for negative, "1st", "2nd", "3rd", "4th+" with ordinal suffixes
- Font: HyperspaceRaceVariable, 140px bold for number, 52px bold for suffix
- Color: hardcoded `#FFFFFF`
- `dividerLine` present but `visible: false` -- the horizontal divider below gear is hidden

### 3.4 Shift Indicator

[`ShiftIndicator.qml`](../PowerTune/Dashboard/ShiftIndicator.qml):

- 11 pills (default), 75px wide, 10px gap, 40px radius = 925px total width
- Driven by `ShiftHelper` C++ helper for pill colors, activation order, and active light count
- Supports patterns: "center-out", "left-to-right", "right-to-left", "alternating"
- Color animation: 60ms `ColorAnimation` on each pill

### 3.5 Sensor Cards (Water Temp / Oil Pressure)

Inlined directly in [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml:148) rather than using the [`SensorCard.qml`](../PowerTune/Dashboard/SensorCard.qml) component:

- Label: 40px, Font.Light, italic, right-aligned
- Value: 68px, normal weight, italic, -2.72 letter spacing
- Unit: 32px, normal weight, italic, right-aligned at bottom of value

**Difference from `SensorCard.qml`:** The inline versions lack the DropShadow effect on value and unit text, and lack the angular Canvas divider line.

### 3.6 Status Rows

Inlined in [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml:263) rather than using [`StatusBox.qml`](../PowerTune/Dashboard/StatusBox.qml):

- Threshold-based ON/OFF display with color coding: green `#1ED033` for ON, red `#FF0909` for OFF
- Nested `DraggableOverlay` inside a parent `DraggableOverlay` for the status box container

### 3.7 Bottom Status Bar

[`BottomStatusBar.qml`](../PowerTune/Dashboard/BottomStatusBar.qml):

- Left: "System" label + green/red status dot (16x16 circle)
- Center: team name (configurable, default "Cardinal Racing")
- Right: Clock from `Diagnostics.displayTime`
- All text: 24px, normal weight, italic, -0.96 letter spacing

### 3.8 Brake Bias

**ISSUE:** Only a bare needle Canvas exists in `RaceDash.qml` at position (274, 603). The actual [`BrakeBiasBar.qml`](../PowerTune/Dashboard/BrakeBiasBar.qml) component (containing the title, labels, gradient bar, and needle) is never instantiated. The background image shows the "BRAKE BIAS" label and RWD/FWD gradient, but these are baked into the static PNG. The needle overlay has no sensor binding and no config type.

---

## 4. Arc Gauge Shader and Rendering Quality

### 4.1 Active Renderer: ArcFillOverlay (Canvas-based)

[`ArcFillOverlay.qml`](../PowerTune/Dashboard/ArcFillOverlay.qml) is the actively used arc renderer. It uses `Canvas` (HTML5 Canvas 2D API via Qt Quick):

**Rendering pipeline:**
1. **Main fill arc** (lines 64-93): Conical gradient from `arcColorStart` to `arcColorEnd`, drawn as two concentric `ctx.arc()` calls (outer clockwise, inner counter-clockwise) creating an annular sector
2. **Tip cap** (lines 95-120): Linear gradient quad at the fill endpoint, creating a glowing leading-edge effect

**Anti-aliasing:** Canvas 2D provides browser-level AA on arc strokes. This is generally acceptable but can show sub-pixel artifacts at:
- Arc start/end boundaries (no explicit round caps -- sharp start, gradient tip)
- Inner/outer radius transitions

**Arc thickness:** Determined by `arcOuterRadius - arcInnerRadius`. For the tach: `0.434 - 0.225 = 0.209` of container width. At 595px, this is ~124px thick.

**Gradient:** Conical gradient parameters in [`fillCanvas.onPaint`](../PowerTune/Dashboard/ArcFillOverlay.qml:82):
- Stop 0.0: `arcColorStart`
- Stop at sweepDeg/360: `arcColorEnd`
- Stop 1.0: `arcColorEnd` (wraps the remainder)

**ISSUE:** The conical gradient origin angle calculation `(-startRad * 180 / Math.PI + 90)` may produce visible gradient discontinuities if `sweepAngleDeg` does not evenly divide 360. For a 270-degree sweep, the gradient maps 0.0-0.75 of the conical range, which is acceptable.

### 4.2 Inactive Renderer: ArcGauge (ShaderEffect-based)

[`ArcGauge.qml`](../PowerTune/Dashboard/ArcGauge.qml) exists but is **not used** in `RaceDash.qml`:

- Uses `ShaderEffect` with compiled shaders at `qrc:/shaders/arcgauge.frag.qsb` and `qrc:/shaders/arcgauge.vert.qsb`
- Provides chrome rings (outer and inner), bevel effects, and GPU-accelerated anti-aliasing via the `antiAlias: 1.5 / root.gaugeSize` uniform
- Has a Canvas overlay for the tip indicator wedge

**NOTE:** The shader files (`arcgauge.frag.qsb`, `arcgauge.vert.qsb`) were not directly audited as they are pre-compiled binary shaders. The uniforms suggest support for:
- `progress`, `startAngle`, `sweepAngle` -- arc fill control
- `outerRadius`, `innerRadius` -- fill band
- `chromeOuterRadius`, `chromeInnerRadius` -- decorative chrome rings
- `colorStart`, `colorEnd` -- fill gradient
- `chromeDark` (#282828), `chromeLight` (#6A6A6A) -- chrome ring colors
- `backgroundColor` (#151518)
- `bevelStrength` (0.9)
- `antiAlias` -- edge smoothing factor

### 4.3 Rendering at 1600x720

- The tach arc at 595x595 renders entirely within the 720px height. Canvas at this resolution should produce clean arcs
- The speed arc at 521x521 also fits within bounds
- Both arcs have startup animations (sweep to 100% then back to 0%) with `SequentialAnimation`
- Live value updates use `Behavior on _animatedProgress` with 150ms `OutQuad` easing (ArcFillOverlay) or 120ms (ArcGauge)
- `Canvas.requestPaint()` is called on every progress change, which is performant for 2D Canvas but may show frame drops under high refresh rates

**Potential issues at 1600x720:**
- Canvas 2D anti-aliasing quality depends on the platform's Canvas implementation (GPU vs CPU)
- No explicit `antialiasing: true` flag on the Canvas item (Qt Quick 2 Canvas uses platform default)
- The tip cap gradient quad may show slight banding at large arc sizes

---

## 5. Dynamic Graphics Pipeline

### 5.1 Live Property Bindings

All dynamic visuals are driven by QML expression bindings that call `PropertyRouter.getValue()`:

| Visual | Binding Source | Update Mechanism |
|--------|---------------|------------------|
| Tach arc fill | `PropertyRouter.getValue(tachSensorKey)` | Expression reevaluation -> `_dataProgress` -> `_animatedProgress` -> `Canvas.requestPaint()` |
| Speed arc fill | `PropertyRouter.getValue(speedSensorKey)` | Same pipeline |
| Gear glyph | `PropertyRouter.getValue(tachGearKey)` | Expression reevaluation -> `_gearText` / `_suffix` computed properties |
| Shift lights | `PropertyRouter.getValue(tachSensorKey)` -> `ShiftHelper.activeLightCount()` | Expression reevaluation -> pill color toggle |
| Water temp value | `PropertyRouter.getValue(wtSensorKey)` | Expression reevaluation -> `text` update |
| Oil pressure value | `PropertyRouter.getValue(opSensorKey)` | Expression reevaluation -> `text` update |
| Status ON/OFF | `PropertyRouter.getValue(sr0SensorKey)` vs `threshold` | Expression reevaluation -> text + color change |
| System dot | `systemOk` property | Direct property binding (hardcoded `true`) |
| Clock | `Diagnostics.displayTime` | Direct property binding to C++ signal |

### 5.2 Animation Transitions

| Animation | Component | Duration | Easing |
|-----------|-----------|----------|--------|
| Arc fill progress | `ArcFillOverlay._animatedProgress` | 150ms | OutQuad |
| Arc fill progress (ArcGauge) | `ArcGauge._animatedProgress` | 120ms | OutQuad |
| Startup sweep up | Both arc components | 800ms | InOutCubic |
| Startup sweep down | Both arc components | 600ms | InOutCubic |
| Shift light color | `ShiftIndicator` pill color | 60ms | ColorAnimation (linear) |

### 5.3 Warning System

Both [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml:637) and [`UserDashboard.qml`](../PowerTune/Dashboard/UserDashboard.qml:44) include a `WarningLoader` at z:300 in a transparent full-screen Rectangle. This suggests a warning overlay system exists but was not included in the audit scope.

---

## 6. Theme Architecture Assessment

### 6.1 Current DashboardTheme Token Structure

[`DashboardTheme.qml`](../PowerTune/Dashboard/DashboardTheme.qml) is a `pragma Singleton` in the `PrismPT.Dashboard` module:

```qml
pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property color panelBackground: "#3a3a3a"
    readonly property color panelBorder: "#5a5a5a"
    readonly property color panelText: "#FFFFFF"
    readonly property int panelRadius: 6
}
```

**CRITICAL FINDING: `DashboardTheme` is defined but NEVER USED.** Zero references to `DashboardTheme` exist in any dashboard QML file.

### 6.2 SettingsTheme Misuse in Dashboard Files

**`SettingsTheme` is a settings-page-only singleton.** Per the design constraint, dashboard colors should be per-dashboard, not sourced from the settings theme. The following dashboard files incorrectly use `SettingsTheme`:

#### [`DraggableOverlay.qml`](../PowerTune/Dashboard/DraggableOverlay.qml) -- 24 references

| Line | Token Used | Purpose |
|------|-----------|---------|
| 2 | `import PowerTune.UI 1.0` | Imports the SettingsTheme module |
| 55 | `SettingsTheme.accent` | Horizontal alignment guide color |
| 64 | `SettingsTheme.accent` | Vertical alignment guide color |
| 74 | `SettingsTheme.textPrimary` | Center crosshair horizontal color |
| 83 | `SettingsTheme.textPrimary` | Center crosshair vertical color |
| 93 | `SettingsTheme.fontCaption` | Coordinate label font size |
| 94 | `SettingsTheme.fontFamily` | Coordinate label font family |
| 95 | `SettingsTheme.accent` | Coordinate label text color |
| 107 | `SettingsTheme.accent` | Edit border color |
| 116 | `SettingsTheme.surface` | Close button background |
| 117 | `SettingsTheme.textPrimary` | Close button border |
| 125 | `SettingsTheme.fontCaption` | Close button "X" font size |
| 127 | `SettingsTheme.fontFamily` | Close button "X" font family |
| 128 | `SettingsTheme.textPrimary` | Close button "X" color |
| 141 | `SettingsTheme.surface` | Config button background |
| 142 | `SettingsTheme.accent` | Config button border |
| 151 | `SettingsTheme.fontCaption` | Config button "C" font size |
| 153 | `SettingsTheme.fontFamily` | Config button "C" font family |
| 154 | `SettingsTheme.accent` | Config button "C" color |
| 166 | `SettingsTheme.fontFamily` | Overlay ID label font |
| 167 | `SettingsTheme.textPrimary` | Overlay ID label color |
| 176 | `SettingsTheme.fontFamily` | Position label font |
| 177 | `SettingsTheme.textPrimary` | Position label color |

#### [`OverlayConfigPopup.qml`](../PowerTune/Dashboard/OverlayConfigPopup.qml) -- 50+ references

Every UI element in the config popup uses `SettingsTheme` tokens:
- Background: `SettingsTheme.surfaceElevated`
- Border: `SettingsTheme.border`
- Radius: `SettingsTheme.radiusLarge`
- Text colors: `SettingsTheme.textPrimary`, `SettingsTheme.textSecondary`
- Font: `SettingsTheme.fontCaption`, `SettingsTheme.fontLabel`, `SettingsTheme.fontFamily`
- Control heights: `SettingsTheme.controlHeight`
- Button styling via `StyledButton`, `StyledTextField`, `StyledComboBox`, `StyledSpinBox`, `StyledColorPicker` -- all from `PowerTune.UI`

### 6.3 Analysis of SettingsTheme Usage Context

The `SettingsTheme` usage falls into two categories:

1. **Edit-mode chrome in `DraggableOverlay.qml`** -- These are control/UI elements (alignment guides, buttons, labels) that appear during edit mode. They are NOT part of the dashboard's visual display. A case could be made that edit-mode UI should use a consistent app-wide theme. However, per the design constraint, these should still use `DashboardTheme` or local dashboard-specific colors.

2. **Config popup in `OverlayConfigPopup.qml`** -- This is a modal configuration dialog. It uses `StyledButton`, `StyledComboBox`, etc., which are `PowerTune.UI` components that inherently depend on `SettingsTheme`. Migrating the popup away from `SettingsTheme` would require either duplicating the styled components or creating dashboard-specific variants.

### 6.4 Recommendations for Per-Dashboard Theming

1. **Expand `DashboardTheme.qml`** to include tokens for edit-mode chrome (accent, surface, text colors, font settings) at minimum
2. **Replace all `SettingsTheme` references in `DraggableOverlay.qml`** with `DashboardTheme` tokens
3. **For `OverlayConfigPopup.qml`**, either:
   - Accept that config popups use the global UI theme (since they are modal overlays, not part of the dashboard display)
   - Or create dashboard-aware styled components that read from `DashboardTheme`
4. **Make `DashboardTheme` properties writable** (remove `readonly`) to support per-dashboard color schemes loaded from configuration
5. **Add arc color tokens** to `DashboardTheme` rather than hardcoding them in `RaceDash.qml` properties

### 6.5 Hardcoded Colors in Dashboard Files

Colors that should be tokenized via `DashboardTheme`:

| File | Color | Usage |
|------|-------|-------|
| [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml:22) | `#E88A1A`, `#C45A00` | Tach arc gradient |
| [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml:35) | `#AA1111`, `#880000` | Speed arc gradient |
| [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml:159) | `#FFFFFF` | All text colors |
| [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml:300) | `#1ED033`, `#FF0909` | Status ON/OFF colors |
| [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml:562) | `#DD1a1a36`, `#3a3a60` | Edit toolbar background/border |
| [`RaceDash.qml`](../PowerTune/Dashboard/RaceDash.qml:580) | `#663333`, `#336633` | Lock button colors |
| [`ArcFillOverlay.qml`](../PowerTune/Dashboard/ArcFillOverlay.qml:16) | `#E88A1A`, `#C45A00` | Default arc colors |
| [`ArcGauge.qml`](../PowerTune/Dashboard/ArcGauge.qml:85) | `#151518` | Arc background |
| [`ArcGauge.qml`](../PowerTune/Dashboard/ArcGauge.qml:111) | `#282828`, `#6A6A6A` | Chrome ring colors |
| [`GearIndicator.qml`](../PowerTune/Dashboard/GearIndicator.qml:38) | `#FFFFFF` | Gear text color |
| [`ShiftIndicator.qml`](../PowerTune/Dashboard/ShiftIndicator.qml:35) | `#222222` | Inactive pill color |
| [`BottomStatusBar.qml`](../PowerTune/Dashboard/BottomStatusBar.qml:41) | `#1ED033`, `#FF0909` | System status dot colors |
| [`BrakeBiasBar.qml`](../PowerTune/Dashboard/BrakeBiasBar.qml:65) | `#CC0000`, `#CCCC00`, `#00CC00` | Bias bar gradient |
| [`SensorCard.qml`](../PowerTune/Dashboard/SensorCard.qml:88) | `#3A3A3A` | Divider stroke color |
| [`StatusBox.qml`](../PowerTune/Dashboard/StatusBox.qml:30) | `#3A3A3A`, `#4A4A4A` | Chrome divider colors |

---

## Summary of Key Findings

### Critical Issues

1. **`DashboardTheme` is defined but never used** -- 4 tokens defined, 0 consumed. All dashboard chrome uses `SettingsTheme` instead.
2. **`SettingsTheme` incorrectly used in dashboard files** -- `DraggableOverlay.qml` (24 refs) and `OverlayConfigPopup.qml` (50+ refs) both import and use `SettingsTheme` for dashboard overlay elements.
3. **`PropertyRouter.getValue()` lacks reactive signaling** -- QML bindings to `PropertyRouter.getValue()` are snapshot-based, not signal-driven. This can cause missed or delayed value updates.

### High-Priority Issues

4. **`ArcGauge.qml` (ShaderEffect) is unused** -- The GPU-accelerated arc gauge with chrome rings sits idle while the Canvas-based `ArcFillOverlay` handles all rendering. This may be intentional (background image provides chrome) or an oversight.
5. **`BrakeBiasBar.qml` is never instantiated** -- Only the needle exists; the full component with labels and gradient bar is not used. The background static image shows the brake bias area but the interactive component is missing.
6. **Multiple reusable components unused** -- `SensorCard.qml`, `StatusBox.qml`, and `ArcGauge.qml` are defined but bypassed in favor of inline implementations in `RaceDash.qml`.

### Medium-Priority Issues

7. **Missing datasource entries** -- `oilpres`, `DigitalInput1`, `DigitalInput2` are used as default sensor keys but do not appear in `DatasourcesList.qml`. They presumably resolve via the C++ model property scan.
8. **No snap-to-grid** -- Drag positioning is free-form with visual guides only.
9. **All text colors hardcoded** -- `#FFFFFF` used throughout with no theme token.
10. **Brake bias needle has no sensor binding or config type** -- It is purely decorative.

### Architectural Notes

11. **Overlay config persistence** via `OverlayConfig` singleton (C++ backend, not audited) handles save/load/reset of positions and widget configurations.
12. **Edit mode** is per-overlay (double-tap) with a shared toolbar that appears when any overlay is in edit mode.
13. **Static background** `Racedash_AiM.png` provides the chrome rings, brake bias area, and sensor card decorations. Dynamic widgets overlay on top.
