# Dashboard Test Simulator (DashboardTestSim) -- Audit

**Date:** 2026-03-10
**File:** [`DashboardTestSim.qml`](PowerTune/Settings/DashboardTestSim.qml)
**Backing C++:** [`UdpTestSimulator`](Utils/UdpTestSimulator.h) / [`UdpTestSimulator.cpp`](Utils/UdpTestSimulator.cpp)

---

## 1. Purpose

The Dash Test tab is a **UDP test-data simulator** for exercising dashboard gauges
without a live ECU connection. It sends UDP datagrams on `localhost:45454` with
the format `ident,value` for each enabled channel at a configurable interval.

Key features:
- Manual per-channel sliders for RPM, Speed, Gear, Water Temp, Oil Pressure,
  TPS, AFR, Boost, Battery, Fuel Pressure, Intake Temp, Engine Load, and two
  boolean flags (Fuel Pump, Cool Fan).
- A "Sweep Test" mode that runs an automated multi-phase drive-cycle simulation
  (ramp RPM, shift gears, ramp temps, wind down) in a loop.
- Adjustable send interval (20--500 ms).

---

## 2. Integration and Context Properties

### C++ Registration

Registered in [`connect.cpp`](Core/connect.cpp:203) as a root context property:

```cpp
engine->rootContext()->setContextProperty("TestSim", m_testSimulator);
```

The `TestSim` context property is the **sole** external dependency of
[`DashboardTestSim.qml`](PowerTune/Settings/DashboardTestSim.qml). The component
does not reference `Engine`, `Vehicle`, `SensorRegistry`, `Settings`, `Translator`,
or any other context object.

### QML Module Registration

Registered in the `PowerTune.Settings` module at
[`CMakeLists.txt`](CMakeLists.txt:289):

```cmake
PowerTune/Settings/DashboardTestSim.qml
```

Loaded in [`SettingsManager.qml`](PowerTune/Core/SettingsManager.qml:103) at
StackLayout index 6.

### UdpTestSimulator API Surface

| Q_PROPERTY | Type | Notes |
|---|---|---|
| `running` | `bool` | Start/stop the send timer |
| `intervalMs` | `int` | Send interval, clamped 20--1000 |
| `sweepState` | `int` (read-only) | Current SweepPhase enum value |
| `sweepLooping` | `bool` (read-only) | Whether sweep is active |
| `channels` | `QVariantList` (read-only) | Full channel list as variant maps |

| Q_INVOKABLE | Signature |
|---|---|
| `channelCount()` | `int` |
| `channelName(int)` | `QString` |
| `channelUnit(int)` | `QString` |
| `channelMin(int)` | `qreal` |
| `channelMax(int)` | `qreal` |
| `channelStep(int)` | `qreal` |
| `channelValue(int)` | `qreal` |
| `channelEnabled(int)` | `bool` |
| `setChannelEnabled(int, bool)` | `void` |
| `setChannelValue(int, qreal)` | `void` |
| `startSweepTest()` | `void` |
| `stopSweepTest()` | `void` |

14 hardcoded channels initialized in [`initChannels()`](Utils/UdpTestSimulator.cpp:27).

---

## 3. Hardcoded Colors, Fonts, and Sizes (Theme Violations)

[`DashboardTestSim.qml`](PowerTune/Settings/DashboardTestSim.qml) defines **ten
local color properties** (lines 8--17) and uses **zero** `SettingsTheme` tokens.
It does not even `import PowerTune.UI 1.0`.

### 3.1 Color Mapping

Every color in the file is hardcoded. Below is the full inventory with the
`SettingsTheme` token each should map to:

| Local Property | Hex Value | Correct SettingsTheme Token | Notes |
|---|---|---|---|
| `bgDark` | `#111122` | `background` (`#161718`) | Blue-tinted; clashes with neutral gray theme |
| `panelBg` | `#1a1a36` | `surface` (`#1E1F21`) | Blue-tinted |
| `panelBorder` | `#2a2a50` | `border` (`#3A3B3E`) | Blue-tinted |
| `accent` | `#009688` | `accent` (`#009688`) | Same value, but should use token |
| `accentDim` | `#00695C` | `accentPressed` (`#00796B`) | Close but not identical |
| `txtPrimary` | `#FFFFFF` | `textPrimary` (`#ECEDEF`) | Pure white vs. off-white |
| `txtSecondary` | `#8888AA` | `textSecondary` (`#8B8D93`) | Blue-tinted |
| `greenOn` | `#00c853` | `success` (`#4CAF50`) | Different green entirely |
| `redOff` | `#ff1744` | `error` (`#F44336`) | Different red entirely |
| `sweepOrange` | `#FF6F00` | `warning` (`#FF9800`) | Different orange |
| (unset -- `"#444"`) | `#444444` | `textDisabled` (`#505258`) | Inline on line 45 |

### 3.2 Hardcoded Font Sizes

| Line(s) | Value | Should Be |
|---|---|---|
| 51 | `font.pixelSize: 20` | `SettingsTheme.fontSectionTitle` (20) -- same value but hardcoded |
| 61, 85 | `font.pixelSize: 13` | `SettingsTheme.fontCaption` (14) |
| 69, 84 | `font.pixelSize: 14` | `SettingsTheme.fontCaption` (14) |
| 103, 126 | `font.pixelSize: 15` | `SettingsTheme.fontStatus` (16) |
| 171 | `font.pixelSize: 14` | `SettingsTheme.fontCaption` (14) |
| 205 | `font.pixelSize: 16` | `SettingsTheme.fontStatus` (16) |
| 215 | `font.pixelSize: 12` | Below any theme tier; use `fontCaption` |

No `font.family` is set anywhere -- defaults to system font instead of
`SettingsTheme.fontFamily` ("Lato").

### 3.3 Hardcoded Sizes and Spacing

| Item | Hardcoded Value | SettingsTheme Equivalent |
|---|---|---|
| Header height | `56` | `tabBarHeight` (56) -- same but hardcoded |
| Header radius | `8` | `radiusLarge` (8) |
| Channel row height | `52` | None exact; closest is `controlHeight` (36) + padding |
| Channel row radius | `6` | `radiusSmall` (6) |
| Margins | `10` | `pageMargin` (16) |
| Spacing | `8`, `12` | `contentSpacing` (10), `controlGap` (16) |
| Button widths | `110`, `130` | `buttonMinWidth` (100) |
| Button height | `38` | `controlHeight` (36) |
| Border width | `1` | `borderWidth` (1) |
| Slider widths | `140`, specific `preferredWidth` values | Should use `Layout.fillWidth` |
| Switch `scale: 0.8` | Non-standard scaling | Should use `StyledSwitch` component |

---

## 4. Missing Imports

```qml
// Current imports:
import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
```

**Missing:**
- `import PowerTune.UI 1.0` -- needed for `SettingsTheme`
- `import PowerTune.Settings 1.0` -- needed if using `SettingsPage`, `SettingsSection`, `StyledButton`, `StyledSwitch`, etc.

---

## 5. Broken / Problematic Functionality

### 5.1 No SettingsPage Wrapper

Every other settings tab uses [`SettingsPage`](PowerTune/Settings/components/SettingsPage.qml)
as its root, which provides:
- `SettingsTheme.background` fill color
- ScrollView with `pageMargin` margins
- Consistent clipping

`DashboardTestSim` uses a bare `Item` root with a manual `Rectangle` fill, so it
does not scroll and will clip/overflow on small screens.

### 5.2 No Translation Support

The component hardcodes all English strings:
- "Dashboard Test Simulator"
- "SWEEP ACTIVE"
- "Interval:"
- "Stop" / "Start"
- "Stop Sweep" / "Sweep Test"

All other tabs use `Translator.translate(...)`. The `Translator` singleton is not
imported.

### 5.3 Unstyled Native Controls

The file uses raw Qt Quick Controls `Button`, `Slider`, and `Switch` instead of
the project's styled variants:
- `Button` -> should be `StyledButton`
- `Switch` -> should be `StyledSwitch`
- `Slider` -> no `StyledSlider` exists yet; needs custom styling or a new component

Raw controls inherit the platform/Material theme, which clashes with the dark
SettingsTheme.

### 5.4 GridLayout Overflow

The `GridLayout` with `columns: 2` for 14 channels produces 7 rows at 52px each
= 364px, plus the 56px header = 420px minimum. On a 480px display (common for
embedded dashboards), there is no scroll mechanism, so the bottom channels are
inaccessible.

### 5.5 Repeater with Q_INVOKABLE channelCount()

Line 142: `model: TestSim.channelCount()` -- This calls the invokable once and
creates a static integer model. If channels were ever added/removed dynamically,
the Repeater would not update. Currently this is not a runtime bug since channels
are fixed, but it is a fragile pattern. Using `TestSim.channels` (the
QVariantList property) as the model would be more robust and would auto-update.

### 5.6 Slider Value Update via Connections

Lines 189-194 connect every slider to `onChannelsChanged()`, which fires on
**any** channel change. With 14 channels and a 50ms sweep timer, this creates
14 signal handler invocations per tick (each slider re-reads its value). This is
a performance concern on embedded hardware.

---

## 6. Missing Features

### 6.1 Features Other Tabs Have That This Tab Lacks

| Feature | Status |
|---|---|
| `SettingsPage` / `SettingsSection` structure | Missing |
| `SettingsTheme` token usage | Missing (0 of ~20 tokens used) |
| Translation via `Translator.translate()` | Missing |
| Styled components (`StyledButton`, `StyledSwitch`) | Missing |
| ScrollView for overflow | Missing |
| Section collapsibility | Missing |
| `font.family: SettingsTheme.fontFamily` | Missing (all Text elements) |

### 6.2 Desirable Features for a Dashboard Test Utility

| Feature | Status |
|---|---|
| Channel presets (idle, cruising, redline, cold start) | Not implemented |
| Randomized noise/jitter per channel | Not implemented |
| Save/load test profiles | Not implemented |
| Visual feedback of current sweep phase name | Not shown (only "SWEEP ACTIVE" boolean) |
| Target/destination port configuration | Hardcoded to `45454` |
| Reset all channels to defaults button | Not implemented |
| Enable/disable all channels toggle | Not implemented |

---

## 7. Summary of Issues by Severity

### Critical (Breaks Visual Consistency)

1. **Zero SettingsTheme usage** -- 10 hardcoded colors with a blue/purple tint
   that clashes with the neutral gray palette used by all other tabs.
2. **No SettingsPage wrapper** -- No scroll, no margin consistency, no background
   match.
3. **Raw unstyled controls** -- `Button`, `Switch`, `Slider` inherit
   platform/Material styling instead of matching the custom dark theme.

### High (Functional Gaps)

4. **No translation support** -- All strings are hardcoded English.
5. **No scroll on overflow** -- Bottom channels inaccessible on embedded
   displays.

### Medium (Code Quality / Maintainability)

6. **No font.family set** -- Falls back to system default instead of "Lato".
7. **Performance: global channelsChanged signal** -- All 14 sliders update on
   every channel change during sweep.
8. **Fragile integer Repeater model** -- Should use `channels` QVariantList
   property.

### Low (Nice to Have)

9. No presets / profiles.
10. No sweep phase name display.
11. No reset-all or enable-all buttons.
12. Hardcoded UDP port.
