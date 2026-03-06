# PowerTune Gauges: Architecture Analysis and Modernization Plan

---

## Table of Contents

1. [Gauge Folder Catalog](#1-gauge-folder-catalog)
2. [Cross-Usage and Dependency Map](#2-cross-usage-and-dependency-map)
3. [Dashboard System Architecture](#3-dashboard-system-architecture)
4. [Property Binding and Data Flow](#4-property-binding-and-data-flow)
5. [Current Rendering Analysis](#5-current-rendering-analysis)
6. [Modernization: Toward AiM-Style Design](#6-modernization-toward-aim-style-design)
7. [High Contrast and Accessibility Implementation](#7-high-contrast-and-accessibility-implementation)
8. [Recommended Implementation Phases](#8-recommended-implementation-phases)

---

## 1. Gauge Folder Catalog

**Path:** `PowerTune/Gauges/` -- 61 files total.

### 1.1 Core Base Components

These are the Qt6-ported replacements for the deprecated `QtQuick.Extras`
gauge types. They form the foundation that all other gauges build on.

| File                     | Type                    | Replaces                                     | Rendering             |
| ------------------------ | ----------------------- | -------------------------------------------- | --------------------- |
| `Gauge.qml`              | Linear bar gauge        | `QtQuick.Extras.Gauge`                       | Rectangle + Loader    |
| `GaugeStyle.qml`         | Style for Gauge         | `QtQuick.Controls.Styles.GaugeStyle`         | QtObject (no visuals) |
| `CircularGauge.qml`      | Circular gauge          | `QtQuick.Extras.CircularGauge`               | Repeater + Loader     |
| `CircularGaugeStyle.qml` | Style for CircularGauge | `QtQuick.Controls.Styles.CircularGaugeStyle` | QtObject (no visuals) |

These are registered as `PowerTune.Gauges 1.0` via the `qmldir` file.

### 1.2 User-Facing Gauge Widgets

| File                      | Type                     | Visual Style            | Canvas Count                       | Key Feature                                                                  |
| ------------------------- | ------------------------ | ----------------------- | ---------------------------------- | ---------------------------------------------------------------------------- |
| `RoundGauge.qml`          | Circular w/ needle       | Configurable colors     | 3 (needle, red zone, needle trail) | Most configurable; 90+ properties; intro animation; context menu for editing |
| `BarGauge.qml`            | Linear bar               | Horizontal/vertical     | 0                                  | Color changes by value threshold                                             |
| `VerticalBarGauge.qml`    | Horizontal bar + numeric | Bar with readout        | 0                                  | Settings-backed scale/offset math                                            |
| `SquareGauge.qml`         | Numeric + bar combo      | Title bar + value + bar | 0                                  | Warning flash animation; dual value display; scale/offset                    |
| `SquareGaugeMain.qml`     | Square variant           | Same as SquareGauge     | 0                                  | Simplified color config                                                      |
| `SquareGaugeRaceDash.qml` | Race dash variant        | `lightsteelblue` bar    | 0                                  | Fixed race dash colors                                                       |
| `RPMBar.qml`              | RPM bar strip            | Image-based fill        | 0                                  | Pre-rendered PNG bars (empty.png/fill.png); ShiftLights                      |
| `RPMBarStyle1.qml`        | RPM bar variant 1        | Gauge + image bg        | 0                                  | Racedash.png background                                                      |
| `RPMBarStyle2.qml`        | RPM bar variant 2        | Image fill + path       | 0                                  | RPM_BG.png / RPM_Fill.png                                                    |
| `RPMBarStyle3.qml`        | RPM bar variant 3        | FuelTech-style          | 0                                  | fueltechempty.png / fueltechfill.png                                         |
| `ForceMeter.qml`          | G-force display          | Concentric circles      | 0                                  | Rectangle-only; reads Vehicle.accelx/y                                       |
| `ShiftLights.qml`         | 8-LED shift strip        | Image-based LEDs        | 0                                  | ledoff/green/yellow/red.png                                                  |

### 1.3 Style Components

| File                      | Extends             | Canvas Usage               | Key Feature                                                                   |
| ------------------------- | ------------------- | -------------------------- | ----------------------------------------------------------------------------- |
| `DashboardGaugeStyle.qml` | CircularGaugeStyle  | Canvas needle              | Half-gauge option                                                             |
| `NormalGaugeStyle.qml`    | CircularGaugeStyle  | Canvas background + needle | Radial gradient background; `paintBackground()` draws ellipse, arcs, gradient |
| `TachometerStyle.qml`     | DashboardGaugeStyle | Canvas red warning arc     | Red labels/ticks for indices 8-10                                             |

### 1.4 Needle Components

| File                           | Angle Range | Canvas Usage     | Key Feature                                              |
| ------------------------------ | ----------- | ---------------- | -------------------------------------------------------- |
| `GaugeNeedle_minus90to180.qml` | -90 to 270  | Canvas trail arc | Radial gradient trail; Behavior animation (5ms, OutCirc) |
| `GaugeNeedle_minus180to90.qml` | -180 to 90  | Canvas trail arc | Same pattern, different angle range                      |

### 1.5 Dashboard Views (Pre-Built Layouts)

| File            | Layout Type   | Gauge Components Used                                             |
| --------------- | ------------- | ----------------------------------------------------------------- |
| `Dashboard.qml` | Fixed cluster | CircularGauge, GaugeNeedle_minus180to90, GaugeNeedle_minus90to180 |
| `Cluster.qml`   | Alt cluster   | CircularGauge with styles                                         |
| `SportDash.qml` | Sport layout  | Direct Engine/Vehicle bindings                                    |
| `Advanced.qml`  | Advanced view | Extended parameter display                                        |

### 1.6 User-Configurable Dashboards

| File            | Dynamic Creation                          | Persistence                      | Gauge Types Supported                                                            |
| --------------- | ----------------------------------------- | -------------------------------- | -------------------------------------------------------------------------------- |
| `Userdash1.qml` | `Component.createObject` via JS factories | `Qt.labs.settings` + file export | RoundGauge, SquareGauge, VerticalBarGauge, Text, Picture, StatePicture, StateGIF |
| `Userdash2.qml` | Same                                      | Same                             | Same                                                                             |
| `Userdash3.qml` | Same                                      | Same                             | Same                                                                             |

### 1.7 JS Factory Scripts

| Script                         | Creates          | Parent Target |
| ------------------------------ | ---------------- | ------------- |
| `createRoundGauge.js`          | RoundGauge       | `userDash`    |
| `createverticalbargauge.js`    | VerticalBarGauge | `userDash`    |
| `createsquaregaugeUserDash.js` | SquareGauge      | `userDash`    |
| `createText.js`                | MyTextLabel      | `userDash`    |
| `createPicture.js`             | Picture          | `userDash`    |
| `createStatePicture.js`        | StatePicture     | `userDash`    |
| `createStateGIF.js`            | StateGIF         | `userDash`    |
| `createMaindash.js`            | Main dash layout | `userDash`    |

### 1.8 Data Source Helpers

| File                      | Purpose                                                                                                                       |
| ------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `DatasourcesList.qml`     | ListModel with 4000+ lines defining all available data sources (`sourcename`, `titlename`, `maxvalue`, `decimalpoints`, etc.) |
| `Datasources.qml`         | Data source selection UI                                                                                                      |
| `ColorList.qml`           | ListModel of color names for gauge configuration ComboBoxes                                                                   |
| `ColorpickerCombobox.qml` | Color picker combo box widget                                                                                                 |

---

## 2. Cross-Usage and Dependency Map

### 2.1 Import Dependencies

```
PowerTune.Gauges 1.0
    ├── Gauge.qml
    ├── GaugeStyle.qml
    ├── CircularGauge.qml
    └── CircularGaugeStyle.qml

PowerTune.Utils 1.0
    └── (Utility functions shared across gauges)

Qt5Compat.GraphicalEffects
    └── Imported by: RoundGauge, BarGauge, VerticalBarGauge, SquareGauge,
        SquareGaugeMain, SquareGaugeRaceDash, GaugeNeedle_*, RPMBar,
        RPMBarStyle1, RPMBarStyle2
    └── ACTUALLY USED BY: None (imported but no Glow/DropShadow/etc. instantiated)

com.powertune 1.0
    └── Imported by: RPMBar, RPMBarStyle1, RPMBarStyle2
    └── Provides: ConnectObject
```

### 2.2 Component Nesting

```
Userdash1/2/3.qml
    ├── RoundGauge.qml
    │   ├── DatasourcesList.qml (instance per gauge)
    │   ├── CircularGauge.qml
    │   │   └── CircularGaugeStyle.qml (inline override)
    │   │       ├── Canvas (needle)
    │   │       ├── Canvas (red zone)
    │   │       └── Canvas (needle trail)
    │   └── ColorList.qml (for config menus)
    │
    ├── SquareGauge.qml
    │   ├── DatasourcesList.qml
    │   ├── Gauge.qml (vertical)
    │   │   └── GaugeStyle.qml (inline override)
    │   ├── Gauge.qml (horizontal)
    │   │   └── GaugeStyle.qml (inline override)
    │   └── ColorList.qml
    │
    ├── VerticalBarGauge.qml
    │   ├── DatasourcesList.qml
    │   ├── Gauge.qml
    │   │   └── GaugeStyle.qml (inline override)
    │   └── ColorList.qml
    │
    ├── MyTextLabel.qml
    ├── Picture.qml
    ├── StatePicture.qml
    └── StateGIF.qml

Dashboard.qml (pre-built)
    ├── CircularGauge.qml (speed)
    │   └── NormalGaugeStyle.qml
    │       └── Canvas (background + needle)
    ├── CircularGauge.qml (RPM)
    │   └── TachometerStyle.qml
    │       └── DashboardGaugeStyle.qml
    │           └── Canvas (needle)
    ├── GaugeNeedle_minus180to90.qml (water temp)
    │   └── Canvas (trail arc)
    └── GaugeNeedle_minus90to180.qml (intake temp)
        └── Canvas (trail arc)
```

### 2.3 DatasourcesList Duplication Issue

Every `RoundGauge`, `SquareGauge`, `VerticalBarGauge`, and `MyTextLabel`
instantiates its own `DatasourcesList` (a ListModel with 4000+ lines). On a
dashboard with 10 gauges, this means 10 copies of the same 4000-line ListModel
in memory. This is a significant memory and creation-time cost.

**Recommendation:** Move `DatasourcesList` to a singleton or create it once
at the dashboard level and pass it by reference.

---

## 3. Dashboard System Architecture

### 3.1 Page Structure

```
Main.qml (ApplicationWindow)
└── SwipeView (dashView)
    ├── firstPageLoader  (Loader) ─── Userdash1/2/3.qml or CanMonitor.qml
    ├── secondPageLoader (Loader) ─── (active if Visibledashes > 1)
    ├── thirdPageLoader  (Loader) ─── (active if Visibledashes > 2)
    ├── fourthPageLoader (Loader) ─── (active if Visibledashes > 3)
    └── lastPage (Item)           ─── SerialSettings.qml
```

- SwipeView navigates between 1-4 user dashboards + settings page
- `interactive: UI.draggable === 0` -- swiping disabled in edit mode
- `PageIndicator` at the bottom shows current page

### 3.2 Dashboard Configuration Flow

```
DashSelector.qml (Settings tab)
    ├── Number of dashboards (1-4)
    ├── DashSelectorWidget.qml (per slot)
    │   ├── ComboBox: User Dash 1 / 2 / 3 / CAN Monitor
    │   └── Sets linkedLoader.source on change
    └── AppSettings.writeSelectedDashSettings()
```

### 3.3 Gauge Creation Flow (User Dashboards)

```
User double-taps dashboard background
    → UI.draggable toggles to 1 (edit mode)
    → Add gauge menu appears
    → User selects gauge type
    → JS factory script runs:
        Qt.createComponent("RoundGauge.qml")
        component.createObject(userDash, { properties... })
    → Gauge appears with default properties
    → User configures via context menu (right-click/double-tap on gauge)
```

### 3.4 Dashboard Persistence

```
Save: Userdash.qml serializes userDash.children → CSV string
    → Connect.saveDashtoFile("Dash1Export", csvString)
    → Written to /home/pi/UserDashboards/Dash1Export.txt

Load: Connect.readdashsetup1() → parses CSV → UI.dashsetup1 (QStringList)
    → Userdash1.qml listens to Dashboard.onDashsetup1Changed
    → Recreates gauges from parsed data via JS factories

Format (CSV per gauge, one line each):
    "Round gauge",x,y,width,mainvaluename,maxvalue,minvalue,...
    "Square gauge",x,y,width,mainvaluename,maxvalue,...
    "Bar gauge",x,y,width,mainvaluename,maxvalue,...
```

---

## 4. Property Binding and Data Flow

### 4.1 Data Source Architecture

```
ECU / OBD / CAN Daemon (external process on Pi)
         |
    UDP port 45454  or  SocketCAN
         |
    UDPReceiver.cpp / Extender.cpp
         |
    switch(ident) → model.setProperty(value)
         |
    ┌────┴──────────────────────────────────────┐
    │  C++ Models (QObject with Q_PROPERTY)      │
    │  EngineData    (~170 properties)           │
    │  VehicleData   (~90 properties)            │
    │  AnalogInputs  (Analog0-10, sens1-8, etc.) │
    │  SensorData    (sens1-8, auxcalc1-4)       │
    │  GPSData, DigitalInputs, FlagsData, etc.  │
    └────┬──────────────────────────────────────┘
         |
    setContextProperty() in Connect::Connect()
         |
    ┌────┴──────────────────────────────────────┐
    │  QML Context Properties                    │
    │  Engine, Vehicle, Analog, Digital, GPS,    │
    │  Sensor, Flags, Timing, Expander, Motor,   │
    │  UI, Dashboard, PropertyRouter, etc.       │
    └────┬──────────────────────────────────────┘
         |
    Two binding patterns in QML:
         |
    ├── Direct: value: Engine.rpm
    │           text: Vehicle.speed.toFixed(0)
    │
    └── Dynamic: PropertyRouter.getValue(mainvaluename)
                 (resolved at runtime from string property name)
```

### 4.2 PropertyRouter

`Core/PropertyRouter.h/.cpp` provides dynamic property resolution:

- `initializePropertyMappings()` -- scans all models via `QMetaObject`, builds
  `QHash<QString, ModelType>` mapping property names to their parent model
- `getValue(propertyName)` -- looks up the model, reads the property via
  `QMetaObject::property()`, returns the value
- Used by configurable gauges where the user picks a data source from
  `DatasourcesList`

### 4.3 Binding Patterns in Gauges

**Pre-built dashboards** (Dashboard.qml, SportDash.qml):

```qml
value: Engine.rpm
value: Engine.Watertemp
value: Vehicle.speed
text: (Analog.auxcalc1).toFixed(1)
```

**User-configurable gauges** (RoundGauge.qml, SquareGauge.qml):

```qml
// After intro animation completes:
gauge.value = Qt.binding(function() {
    return PropertyRouter.getValue(mainvaluename);
});
```

The `mainvaluename` is set by the user through the gauge's context menu,
which presents a ComboBox bound to `DatasourcesList`. The selected
`sourcename` (e.g., `"rpm"`, `"Watertemp"`, `"speed"`) becomes the
`mainvaluename` and is passed to `PropertyRouter.getValue()`.

### 4.4 DatasourcesList Structure

Each entry in the ListModel:

```qml
ListElement {
    titlename: "Engine RPM"          // Display name in ComboBox
    sourcename: "rpm"                // Property name for PropertyRouter
    decimalpoints: "0"               // Display precision
    maxvalue: "10000"                // Default maximum for gauge scale
    stepsize: "1000"                 // Tick mark step
    divisor: "1"                     // Value divisor
    supportedECUs: ""                // ECU compatibility filter
}
```

---

## 5. Current Rendering Analysis

### 5.1 Canvas Usage Audit

| Component                  | Canvas Count | What It Draws                                | Repaint Trigger                  | RPi Impact                                                                                                  |
| -------------------------- | ------------ | -------------------------------------------- | -------------------------------- | ----------------------------------------------------------------------------------------------------------- |
| `RoundGauge.qml`           | 3            | Needle, red zone, needle trail               | `onValueChanged`, color changes  | **Critical** -- 3 Canvas repaints per value update per gauge. 5 RoundGauges = 15 Canvas repaints per frame. |
| `NormalGaugeStyle.qml`     | 2            | Background (ellipse, arcs, gradient), needle | `Component.onCompleted` (static) | Moderate -- only on creation                                                                                |
| `DashboardGaugeStyle.qml`  | 1            | Needle                                       | Per value update                 | Moderate                                                                                                    |
| `TachometerStyle.qml`      | 1            | Red warning arc                              | `Component.onCompleted` (static) | Low                                                                                                         |
| `GaugeNeedle_minus90to180` | 1            | Trail arc with radial gradient               | Per value update                 | **High**                                                                                                    |
| `GaugeNeedle_minus180to90` | 1            | Trail arc with radial gradient               | Per value update                 | **High**                                                                                                    |

**Total Canvas elements on a typical user dashboard with 4 RoundGauges:**
12 Canvas elements, of which 8 repaint on every value change.

### 5.2 Qt5Compat.GraphicalEffects Audit

`Qt5Compat.GraphicalEffects` is imported in 10+ gauge files but **never
actually instantiated**. No `Glow {}`, `DropShadow {}`, or other effect
elements exist in the code. The import can be safely removed from all files.

### 5.3 Rendering Primitives Summary

| Primitive       | Usage Count (approx) | Batches Well?    | Notes                                         |
| --------------- | -------------------- | ---------------- | --------------------------------------------- |
| Rectangle       | Very high            | Yes              | Tick marks, backgrounds, bars, needles        |
| Text            | High                 | Yes (atlas)      | Labels, values, titles                        |
| Image           | Medium               | Yes (shared tex) | RPM bars, shift lights, backgrounds           |
| Canvas          | 10+                  | No (CPU)         | Needles, trails, red zones, style backgrounds |
| Shape/ShapePath | 0                    | N/A              | Imported in CircularGauge.qml but unused      |

### 5.4 Performance Bottlenecks (Ranked)

| Rank | Issue                                        | Affected Components                                    | Impact                                           |
| ---- | -------------------------------------------- | ------------------------------------------------------ | ------------------------------------------------ |
| 1    | Canvas needle repaints on every value update | RoundGauge, DashboardGaugeStyle, GaugeNeedle\_\*       | Each 400x400 Canvas repaint costs 4-8ms on RPi 4 |
| 2    | Canvas needle trail with radial gradient     | RoundGauge, GaugeNeedle\_\*                            | Expensive gradient computation per frame         |
| 3    | DatasourcesList duplicated per gauge         | RoundGauge, SquareGauge, VerticalBarGauge, MyTextLabel | Memory: 4000-line ListModel x N gauges           |
| 4    | `Qt.binding(function(){...})` pattern        | RoundGauge, SquareGauge, MyTextLabel                   | JS evaluation per frame; blocks GUI thread       |
| 5    | Dynamic gauge creation via JS factories      | Userdash1/2/3                                          | Creation latency; consider Loader caching        |

---

## 6. Modernization: Toward AiM-Style Design

### 6.1 Design Comparison: Current vs AiM

| Aspect             | Current PowerTune              | AiM MXT Target                                   |
| ------------------ | ------------------------------ | ------------------------------------------------ |
| Arc rendering      | Canvas with JS paint functions | Pre-rasterized PNG or ShaderEffect               |
| Needle             | Canvas-drawn polygon           | Pre-rasterized PNG with baked glow, or Rectangle |
| Needle trail       | Canvas with radial gradient    | Not present (arc-fill replaces it)               |
| Color bands        | Per-tick conditional coloring  | Solid-color arc fill (yellow-green)              |
| Value display      | Small text on gauge face       | Large central readout, dominant hierarchy        |
| Labels             | Full numeric labels around arc | Clean labels outside arc, or hidden              |
| Grid/layout        | Free-position drag-and-drop    | Structured grid cells (name/value/unit)          |
| Warning indication | Background color flash         | Arc color change or border flash                 |
| Background         | Per-gauge colored circles      | Pure black, maximum contrast                     |
| Typography         | Mixed fonts and sizes          | Consistent hierarchy: value > unit > label       |

### 6.2 Modernization Strategy

The modernization should be layered so existing functionality is preserved
while new rendering paths are introduced alongside.

#### Phase 1: Eliminate Canvas from Dynamic Elements

Replace the three Canvas elements in `RoundGauge.qml`:

**Canvas needle** -> Pre-rasterized PNG needle or `Rectangle`:

```qml
needle: Item {
    y: outerRadius * (needleinset * 0.01)
    implicitWidth: outerRadius * (needleBaseWidth * 0.01)
    implicitHeight: outerRadius * (needleLength * 0.01)

    // Fake 3D needle with two half-Rectangles
    Rectangle {
        width: parent.width / 2
        height: parent.height
        anchors.right: parent.horizontalCenter
        color: needlecolor2
        antialiasing: true
    }
    Rectangle {
        width: parent.width / 2
        height: parent.height
        anchors.left: parent.horizontalCenter
        color: needlecolor
        antialiasing: true
    }
}
```

**Canvas red zone** -> Static `Shape` with `PathAngleArc` (paint once):

```qml
Shape {
    anchors.fill: parent
    ShapePath {
        strokeColor: "red"
        strokeWidth: redareawidth
        fillColor: "transparent"
        capStyle: ShapePath.FlatCap
        PathAngleArc {
            centerX: outerRadius; centerY: outerRadius
            radiusX: outerRadius - redareainset
            radiusY: outerRadius - redareainset
            startAngle: valueToAngle(redareastart) - 90
            sweepAngle: endangle - valueToAngle(redareastart)
        }
    }
}
```

**Canvas needle trail** -> Remove entirely for AiM-style, or replace with
ShaderEffect arc (see GAUGE_STYLE_DESIGN_GUIDE.md Section 5B).

#### Phase 2: Introduce AiM-Style Gauge Components

Create new gauge components alongside existing ones:

| New Component          | Replaces              | AiM Feature                                            |
| ---------------------- | --------------------- | ------------------------------------------------------ |
| `ArcFillGauge.qml`     | RoundGauge (optional) | No needle, arc-fill only, large central readout        |
| `NumericCell.qml`      | SquareGauge           | Clean name/value/unit cell with consistent grid sizing |
| `GearIndicator.qml`    | (new)                 | Oversized single-character gear display                |
| `TimingPanel.qml`      | (new)                 | Best/gain/lap time display                             |
| `ModernRoundGauge.qml` | RoundGauge            | Pre-rasterized assets, no Canvas, ShaderEffect arc     |

These would be registered in `qmldir` alongside existing components and
selectable in `DatasourcesList` or the gauge creation menu.

#### Phase 3: Theme System

Introduce a `GaugeTheme` singleton that all gauges read from:

```qml
// GaugeTheme.qml (singleton)
pragma Singleton
import QtQuick 2.15

QtObject {
    // Background
    readonly property color bgPrimary: "#000000"
    readonly property color bgSecondary: "#1A1A1A"

    // Arc
    readonly property color arcTrack: "#222222"
    readonly property color arcFill: "#88FF00"
    readonly property color arcDanger: "#FF0000"

    // Text
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#888888"
    readonly property color textAccent: "#01E6DE"

    // Needle
    readonly property color needlePrimary: "#FF6600"
    readonly property color needleGlow: "#40FF6600"

    // Warning
    readonly property color warningColor: "#FF0000"
    readonly property real warningFlashDuration: 250

    // Sizing
    readonly property real labelFontFactor: 0.06
    readonly property real valueFontFactor: 0.35
    readonly property real unitFontFactor: 0.09

    // Font
    readonly property string fontFamily: "Inter"
}
```

Register as singleton in `qmldir`:

```
singleton GaugeTheme 1.0 GaugeTheme.qml
```

All gauge colors then bind to `GaugeTheme.textPrimary` etc., enabling
theme switching by swapping the singleton or updating its properties.

---

## 7. High Contrast and Accessibility Implementation

### 7.1 Qt 6.10 High Contrast Mode

Qt 6.10 introduced built-in high contrast mode detection. The system
automatically detects when:

- macOS: "Increase contrast" is enabled in Accessibility settings
- Linux/RPi: "High Contrast" setting in Gnome desktop
- Windows 11: A Contrast theme is applied

For PowerTune (running on RPi with EGLFS, not a desktop compositor), the
detection must be manual since EGLFS bypasses the desktop environment.

### 7.2 Implementation Strategy

**Add a `highContrast` property to the GaugeTheme singleton:**

```qml
pragma Singleton
import QtQuick 2.15

QtObject {
    property bool highContrast: false

    // Colors adapt based on highContrast
    readonly property color bgPrimary: "#000000"
    readonly property color bgSecondary: highContrast ? "#000000" : "#1A1A1A"

    readonly property color arcTrack: highContrast ? "#333333" : "#222222"
    readonly property color arcFill: highContrast ? "#FFFF00" : "#88FF00"
    readonly property color arcDanger: "#FF0000"

    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: highContrast ? "#CCCCCC" : "#888888"
    readonly property color textAccent: highContrast ? "#FFFFFF" : "#01E6DE"

    readonly property color needlePrimary: highContrast ? "#FFFFFF" : "#FF6600"

    // Borders become more visible
    readonly property int borderWidth: highContrast ? 2 : 1
    readonly property color borderColor: highContrast ? "#FFFFFF" : "#333333"

    // Text becomes larger
    readonly property real fontSizeMultiplier: highContrast ? 1.15 : 1.0

    // Warning becomes more aggressive
    readonly property real warningFlashDuration: highContrast ? 150 : 250
}
```

**High contrast toggle in settings:**

Add a toggle in `MainSettings.qml` (or `DashSelector.qml`) that sets
`GaugeTheme.highContrast = true`. Persist via `Qt.labs.settings`.

### 7.3 What Changes in High Contrast Mode

| Element               | Normal                   | High Contrast                             |
| --------------------- | ------------------------ | ----------------------------------------- |
| Arc fill color        | `#88FF00` (yellow-green) | `#FFFF00` (pure yellow, higher luminance) |
| Inactive text         | `#888888` (gray)         | `#CCCCCC` (light gray, 4.5:1 ratio)       |
| Gauge borders         | 1px `#333333`            | 2px `#FFFFFF`                             |
| Accent text           | `#01E6DE` (cyan)         | `#FFFFFF` (white, maximum contrast)       |
| Tick marks (inactive) | `#444444`                | `#666666`                                 |
| Background            | `#1A1A1A` (dark gray)    | `#000000` (pure black)                    |
| Font size             | 1.0x                     | 1.15x (15% larger)                        |

### 7.4 Accessibility Properties

Add `Accessible` metadata to gauge components for screen reader support
(future-proofing, even if RPi EGLFS does not use a screen reader today):

```qml
CircularGauge {
    Accessible.role: Accessible.ProgressBar
    Accessible.name: mainvaluename + " gauge"
    Accessible.value: gauge.value.toFixed(decimalpoints) + " " + mainunit
    Accessible.description: mainvaluename + ": " + gauge.value.toFixed(decimalpoints)
}
```

---

## 8. Recommended Implementation Phases

### Phase 1: Quick Wins (No Visual Changes)

| Task                                                                                            | Impact                                      | Effort  |
| ----------------------------------------------------------------------------------------------- | ------------------------------------------- | ------- |
| Remove unused `Qt5Compat.GraphicalEffects` imports from all gauge files                         | Reduces load time, eliminates unused module | Low     |
| Remove duplicate `PowerTune.Gauges 1.0` import lines (present in RoundGauge, SquareGauge, etc.) | Code cleanup                                | Trivial |
| Singleton `DatasourcesList` instead of per-gauge instances                                      | Saves ~40MB memory on 10-gauge dashboard    | Medium  |
| Replace Canvas needle in `RoundGauge.qml` with dual-Rectangle approach                          | Eliminates 1 Canvas per RoundGauge          | Medium  |
| Replace Canvas red zone in `RoundGauge.qml` with static `Shape`                                 | Eliminates 1 Canvas per RoundGauge          | Medium  |

### Phase 2: GaugeTheme Singleton

| Task                                                                 | Impact                                    | Effort      |
| -------------------------------------------------------------------- | ----------------------------------------- | ----------- |
| Create `GaugeTheme.qml` singleton                                    | Enables theme switching and high contrast | Medium      |
| Migrate hardcoded colors in existing gauges to `GaugeTheme` bindings | Consistency                               | Medium-High |
| Add high contrast toggle in settings                                 | Accessibility                             | Low         |

### Phase 3: New AiM-Style Components

| Task                                                      | Impact                       | Effort |
| --------------------------------------------------------- | ---------------------------- | ------ |
| Create `ArcFillGauge.qml` (ShaderEffect-based, no Canvas) | Modern arc-fill gauge        | High   |
| Create `NumericCell.qml` (structured name/value/unit)     | Clean data readout           | Medium |
| Create `GearIndicator.qml`                                | Oversized gear display       | Low    |
| Create `ModernRoundGauge.qml` (pre-rasterized assets)     | RPi-optimized circular gauge | High   |
| Update gauge creation menu to offer old + new styles      | User choice                  | Medium |
| Update `DashSelectorWidget` with new gauge types          | Integration                  | Medium |

### Phase 4: Dashboard Layout System

| Task                                                      | Impact                       | Effort |
| --------------------------------------------------------- | ---------------------------- | ------ |
| Grid-based layout option (alongside free-position)        | AiM-style structured layouts | High   |
| Dashboard templates (AiM-style, classic cluster, minimal) | Quick start for users        | Medium |
| Per-gauge theme override (allow mixing styles)            | Flexibility                  | Medium |

### Priority Order

```
Phase 1 ──────> Phase 2 ──────> Phase 3 ──────> Phase 4
(cleanup)       (theming)       (new gauges)    (layouts)
   |               |                |               |
   Quick,          Enables          User-visible    Full AiM
   invisible       Phase 3+4       modernization   experience
   improvement     and HC mode
```

---

## Appendix: File Quick Reference

### Files to Modify (Phase 1)

```
PowerTune/Gauges/RoundGauge.qml          -- Remove Canvas needle/red zone
PowerTune/Gauges/BarGauge.qml            -- Remove Qt5Compat import
PowerTune/Gauges/VerticalBarGauge.qml    -- Remove Qt5Compat import
PowerTune/Gauges/SquareGauge.qml         -- Remove Qt5Compat import; deduplicate imports
PowerTune/Gauges/SquareGaugeMain.qml     -- Remove Qt5Compat import
PowerTune/Gauges/SquareGaugeRaceDash.qml -- Remove Qt5Compat import
PowerTune/Gauges/RPMBar.qml             -- Remove Qt5Compat import
PowerTune/Gauges/RPMBarStyle1.qml        -- Remove Qt5Compat import
PowerTune/Gauges/RPMBarStyle2.qml        -- Remove Qt5Compat import
PowerTune/Gauges/DatasourcesList.qml     -- Convert to singleton
```

### Files to Create (Phase 2+)

```
PowerTune/Gauges/GaugeTheme.qml          -- Theme singleton
PowerTune/Gauges/ArcFillGauge.qml        -- AiM-style arc-fill gauge
PowerTune/Gauges/NumericCell.qml          -- Structured value cell
PowerTune/Gauges/GearIndicator.qml       -- Large gear display
PowerTune/Gauges/ModernRoundGauge.qml    -- RPi-optimized round gauge
```

### Key C++ Files

```
Core/connect.cpp (line 204-234)           -- QML context property registration
Core/PropertyRouter.h/.cpp                -- Dynamic property resolution
Core/Models/EngineData.h                  -- ~170 Q_PROPERTY (rpm, temps, pressures)
Core/Models/VehicleData.h                 -- ~90 Q_PROPERTY (speed, gear, accel)
Core/Models/AnalogInputs.h               -- Analog channels and calculations
Core/Models/UIState.h                     -- Dashboard state and configuration
Core/appsettings.h/.cpp                   -- Persistent settings management
```
