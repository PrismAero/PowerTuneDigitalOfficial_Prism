# Settings Theme Design Specification

Design specification for `SettingsTheme.qml` -- a `pragma Singleton` QML `QtObject` that provides all design tokens for the PowerTune Settings UI and dashboard widget menus.

---

## 1. Scope and Constraints

| Constraint | Value |
|---|---|
| Display | 1600 x 720 px, fixed, touchscreen |
| Runtime | EGLFS -- no window chrome, no mouse cursor |
| Input | Touch only -- **no hover states** (idle, pressed, focused only) |
| Framework | Qt Quick / QML, `pragma Singleton` `QtObject` pattern |
| Singleton location | `PowerTune/Settings/SettingsTheme.qml` |
| Registration | CMake `set_source_files_properties(... PROPERTIES QT_QML_SINGLETON_TYPE TRUE)` |
| Consumers | All Settings pages, all `Styled*` components, `SettingsSection`, `SettingsRow`, `SettingsPage`, `SerialSettings` TabBar, dashboard widget configuration menus |
| Not covered | Individual dashboard rendering themes (each dashboard has its own per-dashboard theme) |

---

## 2. Dark Stone Color Palette

A warm-neutral dark palette that eliminates the current purple-tinted backgrounds (`#1a1a2e`, `#1E1E2E`, `#1e1e3a`). All colors are near-neutral grays without blue or purple undertones -- grounded, automotive-premium, reminiscent of dark carbon/graphite.

### 2.1 Background Hierarchy

Four levels of surface elevation, progressing from darkest (page root) to lightest (control interiors).

| Token | Hex | Role |
|---|---|---|
| `background` | `#161718` | Page root background, deepest layer |
| `surface` | `#1E1F21` | Section cards, panels, tab bar background |
| `surfaceElevated` | `#272829` | Popups, dropdown panels, overlays, tooltips |
| `surfacePressed` | `#2A2B2E` | Momentary pressed state on interactive surfaces (tabs, collapse headers) |
| `controlBg` | `#2F3032` | Interior of text fields, combo boxes, checkboxes, switch tracks (unchecked) |

```
Visual hierarchy (dark to light):

  #161718  background -------- deepest, page root
  #1E1F21  surface ----------- section cards
  #272829  surfaceElevated --- popups, dropdowns
  #2F3032  controlBg --------- input field interiors
```

### 2.2 Text Colors

| Token | Hex | Role | Min contrast on darkest bg |
|---|---|---|---|
| `textPrimary` | `#ECEDEF` | Primary labels, control text, headings | 15.7:1 on `background` |
| `textSecondary` | `#8B8D93` | Descriptions, secondary labels, inactive tab text | 5.5:1 on `background` |
| `textPlaceholder` | `#787A82` | Placeholder text inside input controls | 3.1:1 on `controlBg` |
| `textDisabled` | `#505258` | Disabled control text, inactive elements | (decorative, no min required) |

### 2.3 Border Colors

| Token | Hex | Role |
|---|---|---|
| `border` | `#3A3B3E` | Default borders on controls, section card borders, divider lines, scrollbar handles |
| `borderFocused` | -- | Uses `accent` (`#009688`); not a separate token. Focused controls switch border to accent. |

### 2.4 Accent Colors

Retains the existing teal accent family from the `Styled*` components. This color is well-established across the codebase and provides good contrast on dark backgrounds.

| Token | Hex | Role |
|---|---|---|
| `accent` | `#009688` | Primary accent -- focus borders, active tab bg, section titles, button bg, switch track (checked) |
| `accentPressed` | `#00796B` | Pressed state of accent-colored buttons |

### 2.5 Semantic Status Colors

One canonical color per semantic meaning. Eliminates the current inconsistency of 3 different greens and 2 different reds.

| Token | Hex | Replaces | Role |
|---|---|---|---|
| `success` | `#4CAF50` | `#4CAF50`, `#00c853`, `#00ff88` | Connected, active, success states |
| `warning` | `#FF9800` | `#FF9800` | Warnings, pending/connecting states |
| `error` | `#F44336` | `#F44336`, `#ff1744` | Errors, disconnected, danger button bg |
| `errorPressed` | `#C62828` | `#C62828` | Pressed state of danger/error buttons |

### 2.6 Special Purpose Colors

| Token | Hex | Role |
|---|---|---|
| `consoleBg` | `#111213` | Terminal/log output panel background (darker than page) |
| `consoleText` | `#4CAF50` | Terminal/log text (matches `success` for classic terminal look) |

### 2.7 Complete Palette Summary

```
BACKGROUNDS                    TEXT
#161718  background            #ECEDEF  textPrimary
#1E1F21  surface               #8B8D93  textSecondary
#272829  surfaceElevated       #787A82  textPlaceholder
#2A2B2E  surfacePressed        #505258  textDisabled
#2F3032  controlBg

BORDERS                        ACCENT
#3A3B3E  border                #009688  accent
                               #00796B  accentPressed

SEMANTIC                       SPECIAL
#4CAF50  success               #111213  consoleBg
#FF9800  warning               #4CAF50  consoleText
#F44336  error
#C62828  errorPressed
```

Total: 19 color tokens.

---

## 3. Spacing Token System

All values are fixed pixels. No responsive scaling -- single 1600x720 target.

| Token | Value | Role |
|---|---|---|
| `pageMargin` | 16 px | Outer margin of settings page content area |
| `sectionSpacing` | 16 px | Vertical gap between `SettingsSection` cards |
| `sectionPadding` | 12 px | Inner padding of section cards (all sides) |
| `contentSpacing` | 10 px | Vertical spacing between rows inside a section |
| `controlGap` | 16 px | Horizontal gap between label column and control column in a row |
| `labelWidth` | 180 px | Default label column preferred width (pages with special layouts may override) |
| `tabBarHeight` | 56 px | Height of the tab bar |
| `tabPaddingH` | 16 px | Horizontal padding inside each tab button |

### Spacing Diagram

```
+--[pageMargin: 16]---------------------------------------+
|                                                          |
|  +--SettingsSection--[sectionPadding: 12]-----------+   |
|  |  Section Title (accent color, 20px bold)          |   |
|  |  ─────────── divider (1px border color) ──────── |   |
|  |                                                    |   |
|  |  [labelWidth: 180]  <-controlGap: 16->  [control] |   |
|  |           <-- contentSpacing: 10 -->               |   |
|  |  [labelWidth: 180]  <-controlGap: 16->  [control] |   |
|  |                                                    |   |
|  +----------------------------------------------------+   |
|                  <-- sectionSpacing: 16 -->               |
|  +--SettingsSection------------------------------------+   |
|  | ...                                                  |   |
|  +------------------------------------------------------+   |
+----------------------------------------------------------+
```

---

## 4. Typography Scale

Font family: **Lato** (consistent with existing codebase).

| Token | Size | Weight | Role |
|---|---|---|---|
| `fontSectionTitle` | 20 px | `Font.Bold` | Section card headings |
| `fontLabel` | 18 px | `Font.Normal` | Row labels, setting names |
| `fontControl` | 18 px | `Font.Normal` | Text inside controls (fields, combo boxes, buttons, switches, checkboxes) |
| `fontTab` | 18 px | `Font.DemiBold` (active), `Font.Normal` (inactive) | Tab bar labels |
| `fontStatus` | 16 px | `Font.Normal` | Status text, descriptions, version info, subtitles |
| `fontCaption` | 14 px | `Font.Normal` | Captions, hints, unit labels (use sparingly -- minimum legible size at arm's length) |

### Font token (string type)

| Token | Value |
|---|---|
| `fontFamily` | `"Lato"` |

### Legibility Notes

- At ~182 DPI (estimated for 1600x720 automotive display), 18px text is approximately 2.5mm tall -- readable at 60-80cm arm's length.
- 14px (`fontCaption`) is approximately 1.95mm -- use only for supplementary info, never for primary labels or interactive text.
- All interactive control text uses 18px minimum to ensure readability while operating a vehicle.

---

## 5. Control Size Specifications

All interactive controls must meet the 48px minimum touch target height. This addresses the audit finding that ExBoard uses 36px and Diagnostics uses 26-28px controls.

### Primary Controls

| Token | Value | Role |
|---|---|---|
| `controlHeight` | 48 px | Universal minimum height for all interactive controls |
| `buttonMinWidth` | 100 px | Minimum width for `StyledButton` |
| `textFieldMinWidth` | 120 px | Minimum width for `StyledTextField` |
| `comboBoxMinWidth` | 100 px | Minimum width for `StyledComboBox` |

### Switch Dimensions

| Token | Value | Role |
|---|---|---|
| `switchTrackWidth` | 52 px | Switch track total width |
| `switchTrackHeight` | 28 px | Switch track total height |
| `switchKnobSize` | 22 px | Switch knob diameter |

Overall switch component height remains `controlHeight` (48px) -- the track is vertically centered within the touch target.

### CheckBox Dimensions

| Token | Value | Role |
|---|---|---|
| `checkBoxSize` | 28 px | Indicator square size (width and height) |

Overall checkbox component height remains `controlHeight` (48px) -- the indicator is vertically centered within the touch target.

### Status Indicator

| Token | Value | Role |
|---|---|---|
| `statusDotSize` | 12 px | Connection/status dot diameter |

### Dense Layout Note

Pages with many controls (notably ExBoard with 107+ controls) should use `ScrollView` with collapsible `SettingsSection` cards to manage density. Controls must not be resized below `controlHeight` (48px). Collapsible sections allow the user to focus on one section at a time while maintaining proper touch targets.

---

## 6. Border and Radius Tokens

| Token | Value | Role |
|---|---|---|
| `radiusSmall` | 6 px | Buttons, text fields, combo boxes, checkboxes, tabs, status indicators |
| `radiusLarge` | 8 px | Section cards, popup panels |
| `borderWidth` | 1 px | Standard border width for all elements |

### Rationale

Two radius values reduce visual noise while providing appropriate rounding:
- 6px on 48px-tall controls produces a clean, modern look (12.5% corner ratio)
- 8px on taller section cards provides a softer container feel
- Both values are close enough to appear cohesive

---

## 7. TabBar Design Specification

The settings UI uses a tab bar at the top with 7 tabs across the full 1600px width.

### Layout

| Property | Value |
|---|---|
| Tab count | 7 (Main, Dash Sel., Vehicle / RPM, EX Board, Network, Diagnostics, Dash Test) |
| Tab bar height | `tabBarHeight` = 56 px |
| Tab width | `tabBarWidth / tabCount` = ~228 px each (fills available width) |
| Tab horizontal padding | `tabPaddingH` = 16 px |
| Tab radius | `radiusSmall` = 6 px |
| Tab border | `borderWidth` = 1 px |

### Tab States (touch-only, no hover)

| State | Background | Text Color | Text Weight | Border Color |
|---|---|---|---|---|
| Inactive (idle) | `surface` | `textSecondary` | `Font.Normal` | `border` |
| Inactive (pressed) | `surfacePressed` | `textSecondary` | `Font.Normal` | `border` |
| Active (selected) | `accent` | `textPrimary` | `Font.DemiBold` | `accent` |

### Tab Bar Diagram

```
+----[228px]----+----[228px]----+----[228px]----+----[228px]----+----[228px]----+----[228px]----+----[228px]----+
| [56px]        |               |               |               |               |               |               |
|    Main       |  Dash Sel.    | Vehicle / RPM |   EX Board    |   Network     | Diagnostics   |  Dash Test    |
|  (active)     |  (inactive)   |  (inactive)   |  (inactive)   |  (inactive)   |  (inactive)   |  (inactive)   |
|  accent bg    |  surface bg   |  surface bg   |  surface bg   |  surface bg   |  surface bg   |  surface bg   |
+---------------+---------------+---------------+---------------+---------------+---------------+---------------+
```

---

## 8. Scrollbar Design

For pages with `ScrollView` (notably ExBoard, potentially others with collapsed sections).

| Property | Value | Source Token |
|---|---|---|
| Width | 6 px | (hardcoded in implementation) |
| Handle color | `#3A3B3E` | `border` |
| Track | Transparent | -- |
| Policy | `ScrollBar.AsNeeded` | -- |
| Horizontal | `ScrollBar.AlwaysOff` | -- |

---

## 9. Contrast Ratio Reference

All ratios calculated against WCAG 2.1 formulas. Minimum requirements: 4.5:1 for normal text (AA), 3:1 for large text (AA).

### Text on Backgrounds

| Text Token | Background Token | Ratio | Passes |
|---|---|---|---|
| `textPrimary` (#ECEDEF) | `background` (#161718) | 15.7:1 | AAA |
| `textPrimary` (#ECEDEF) | `surface` (#1E1F21) | 13.9:1 | AAA |
| `textPrimary` (#ECEDEF) | `surfaceElevated` (#272829) | 11.4:1 | AAA |
| `textPrimary` (#ECEDEF) | `controlBg` (#2F3032) | 9.7:1 | AAA |
| `textSecondary` (#8B8D93) | `background` (#161718) | 5.5:1 | AA |
| `textSecondary` (#8B8D93) | `surface` (#1E1F21) | 5.3:1 | AA |
| `textPlaceholder` (#787A82) | `controlBg` (#2F3032) | 3.1:1 | AA-large (placeholder text exempt from WCAG but still legible) |

### Accent on Backgrounds

| Foreground | Background | Ratio | Passes |
|---|---|---|---|
| `accent` (#009688) text | `background` (#161718) | 5.0:1 | AA |
| `accent` (#009688) text | `surface` (#1E1F21) | 4.7:1 | AA |
| `textPrimary` (#ECEDEF) | `accent` (#009688) button bg | 3.2:1 | AA-large (button text at 18px qualifies as large text) |
| `textPrimary` (#ECEDEF) | `error` (#F44336) button bg | 3.2:1 | AA-large |

### Semantic Colors on Backgrounds

| Semantic Color | Background | Ratio | Passes |
|---|---|---|---|
| `success` (#4CAF50) | `background` (#161718) | 5.8:1 | AA |
| `success` (#4CAF50) | `surface` (#1E1F21) | 5.4:1 | AA |
| `warning` (#FF9800) | `background` (#161718) | 7.3:1 | AAA |
| `error` (#F44336) | `background` (#161718) | 4.6:1 | AA |

---

## 10. QML Singleton Property Structure

File: `PowerTune/Settings/SettingsTheme.qml`

Follows the same pattern as [`DashboardTheme.qml`](PowerTune/Dashboard/DashboardTheme.qml) -- a `pragma Singleton` `QtObject` with `readonly property` declarations.

```qml
pragma Singleton
import QtQuick 2.15

QtObject {
    // -- Background hierarchy --
    readonly property color background: "#161718"
    readonly property color surface: "#1E1F21"
    readonly property color surfaceElevated: "#272829"
    readonly property color surfacePressed: "#2A2B2E"
    readonly property color controlBg: "#2F3032"

    // -- Text --
    readonly property color textPrimary: "#ECEDEF"
    readonly property color textSecondary: "#8B8D93"
    readonly property color textPlaceholder: "#787A82"
    readonly property color textDisabled: "#505258"

    // -- Borders --
    readonly property color border: "#3A3B3E"

    // -- Accent --
    readonly property color accent: "#009688"
    readonly property color accentPressed: "#00796B"

    // -- Semantic status --
    readonly property color success: "#4CAF50"
    readonly property color warning: "#FF9800"
    readonly property color error: "#F44336"
    readonly property color errorPressed: "#C62828"

    // -- Special purpose --
    readonly property color consoleBg: "#111213"
    readonly property color consoleText: "#4CAF50"

    // -- Spacing --
    readonly property int pageMargin: 16
    readonly property int sectionSpacing: 16
    readonly property int sectionPadding: 12
    readonly property int contentSpacing: 10
    readonly property int controlGap: 16
    readonly property int labelWidth: 180
    readonly property int tabBarHeight: 56
    readonly property int tabPaddingH: 16

    // -- Typography --
    readonly property string fontFamily: "Lato"
    readonly property int fontSectionTitle: 20
    readonly property int fontLabel: 18
    readonly property int fontControl: 18
    readonly property int fontTab: 18
    readonly property int fontStatus: 16
    readonly property int fontCaption: 14

    // -- Control sizes --
    readonly property int controlHeight: 48
    readonly property int buttonMinWidth: 100
    readonly property int textFieldMinWidth: 120
    readonly property int comboBoxMinWidth: 100
    readonly property int switchTrackWidth: 52
    readonly property int switchTrackHeight: 28
    readonly property int switchKnobSize: 22
    readonly property int checkBoxSize: 28
    readonly property int statusDotSize: 12

    // -- Border and radius --
    readonly property int radiusSmall: 6
    readonly property int radiusLarge: 8
    readonly property int borderWidth: 1
}
```

Total properties: 19 colors + 8 spacing + 7 typography + 9 control sizes + 3 border/radius = **46 tokens**.

---

## 11. Token-to-Component Mapping

How each existing component should consume the theme tokens. Components reference `SettingsTheme.<token>` directly.

### SerialSettings.qml (Tab Manager)

| Element | Token(s) |
|---|---|
| Root background | `background` |
| Tab bar height | `tabBarHeight` |
| Tab button width | computed: `width / tabCount` |
| Tab active bg | `accent` |
| Tab inactive bg | `surface` |
| Tab pressed bg | `surfacePressed` |
| Tab active text | `textPrimary`, `fontTab`, `Font.DemiBold` |
| Tab inactive text | `textSecondary`, `fontTab`, `Font.Normal` |
| Tab border (active) | `accent`, `borderWidth` |
| Tab border (inactive) | `border`, `borderWidth` |
| Tab radius | `radiusSmall` |

### SettingsSection.qml

| Element | Token(s) |
|---|---|
| Card background | `surface` |
| Card border | `border`, `borderWidth` |
| Card radius | `radiusLarge` |
| Inner padding | `sectionPadding` |
| Content spacing | `contentSpacing` |
| Title text | `accent`, `fontSectionTitle`, `Font.Bold`, `fontFamily` |
| Divider | `border`, 1px height |
| Collapse button pressed bg | `surfacePressed` |
| Collapse arrow color | `textSecondary` |

### SettingsRow.qml

| Element | Token(s) |
|---|---|
| Row spacing | `controlGap` |
| Label text | `textPrimary`, `fontLabel`, `fontFamily` |
| Label column width | `labelWidth` |
| Description text | `textSecondary`, `fontStatus`, `fontFamily` |
| Control container height | `controlHeight` |

### StyledButton.qml

| Element | Token(s) |
|---|---|
| Height | `controlHeight` |
| Min width | `buttonMinWidth` |
| Radius | `radiusSmall` |
| Font | `fontControl`, `fontFamily` |
| Primary bg (idle) | `accent` |
| Primary bg (pressed) | `accentPressed` |
| Primary text | `textPrimary` |
| Danger bg (idle) | `error` |
| Danger bg (pressed) | `errorPressed` |
| Danger text | `textPrimary` |
| Outline border (idle) | `accent`, `borderWidth` |
| Outline bg (pressed) | `surfacePressed` |
| Outline text | `accent` |

### StyledTextField.qml

| Element | Token(s) |
|---|---|
| Height | `controlHeight` |
| Min width | `textFieldMinWidth` |
| Radius | `radiusSmall` |
| Background | `controlBg` |
| Border (idle) | `border`, `borderWidth` |
| Border (focused) | `accent`, `borderWidth` |
| Text color | `textPrimary` |
| Placeholder color | `textPlaceholder` |
| Selection bg | `accent` |
| Cursor color | `accent` |
| Font | `fontControl`, `fontFamily` |

### StyledComboBox.qml

| Element | Token(s) |
|---|---|
| Height | `controlHeight` |
| Min width | `comboBoxMinWidth` |
| Radius | `radiusSmall` |
| Background | `controlBg` |
| Border (idle) | `border`, `borderWidth` |
| Border (focused) | `accent`, `borderWidth` |
| Display text | `textPrimary`, `fontControl` |
| Indicator arrow | `textSecondary` (idle), `accent` (pressed) |
| Popup background | `surfaceElevated` |
| Popup border | `border` |
| Popup radius | `radiusLarge` |
| Delegate text (idle) | `textSecondary` |
| Delegate text (highlighted) | `textPrimary` |
| Delegate highlight bg | `accent` |

### StyledSwitch.qml

| Element | Token(s) |
|---|---|
| Component height | `controlHeight` |
| Track size | `switchTrackWidth` x `switchTrackHeight` |
| Knob size | `switchKnobSize` |
| Track (checked) | `accent` |
| Track (unchecked) | `controlBg` |
| Track border (checked) | `accentPressed` |
| Track border (unchecked) | `border` |
| Knob color | `textPrimary` |
| Label | `textPrimary`, `fontControl`, `fontFamily` |

### StyledCheckBox.qml

| Element | Token(s) |
|---|---|
| Component height | `controlHeight` |
| Indicator size | `checkBoxSize` |
| Indicator radius | `radiusSmall` |
| Indicator bg (checked) | `accent` |
| Indicator bg (unchecked) | `controlBg` |
| Indicator border (checked) | `accentPressed` |
| Indicator border (unchecked) | `border` |
| Checkmark color | `textPrimary` |
| Label | `textPrimary`, `fontControl`, `fontFamily` |

### ConnectionStatusIndicator.qml

| Element | Token(s) |
|---|---|
| Height | `controlHeight` |
| Radius | `radiusSmall` |
| Background | `controlBg` |
| Dot size | `statusDotSize` |
| Connected color | `success` |
| Disconnected color | `error` |
| Pending color | `warning` |
| Unknown border | `border` |
| Unknown dot | `textPlaceholder` |
| Text | `textPrimary`, `fontControl`, `fontFamily` |

### Settings Pages (MainSettings, VehicleRPMSettings, DashSelector, ExBoardAnalog, NetworkSettings, DiagnosticsSettings)

| Element | Token(s) |
|---|---|
| Root background | `background` |
| Label text | `textPrimary`, `fontLabel`, `fontFamily` |
| Section subheader text | `accent`, `fontLabel`, `Font.DemiBold` |
| Subtitle/description text | `textSecondary`, `fontStatus` |
| Hint text | `textPlaceholder`, `fontCaption`, italic |
| Console panel bg | `consoleBg` |
| Console panel text | `consoleText` |
| Console panel border | `border` |

---

## 12. Migration from Current Values

Summary of key color changes from the audit findings:

| Current Value | Current Role | New Token | New Value |
|---|---|---|---|
| `#1a1a2e` | Page root bg (purple-tinted) | `background` | `#161718` |
| `#121212` | SerialSettings root | `background` | `#161718` |
| `#1E1E2E` | SettingsSection card bg | `surface` | `#1E1F21` |
| `#1E1E1E` | Secondary bg | `surface` | `#1E1F21` |
| `#2D2D2D` | Control backgrounds | `controlBg` | `#2F3032` |
| `#2D2D4E` | Section border (purple) | `border` | `#3A3B3E` |
| `#3D3D3D` | Dividers, borders | `border` | `#3A3B3E` |
| `#505050` | Hovered border | -- | Removed (no hover on touch device) |
| `#FFFFFF` | Primary text | `textPrimary` | `#ECEDEF` |
| `#B0B0B0` | Secondary text | `textSecondary` | `#8B8D93` |
| `#a0a0a0` | ExBoard headers | `textSecondary` | `#8B8D93` |
| `#707070` | Placeholder text | `textPlaceholder` | `#787A82` |
| `#808080` | ExBoard voltage text | `textSecondary` | `#8B8D93` |
| `#606060`, `#606080` | Inactive values | `textDisabled` | `#505258` |
| `#00c853` | DiagnosticsSettings connected | `success` | `#4CAF50` |
| `#00ff88` | DiagnosticsSettings log text | `consoleText` | `#4CAF50` |
| `#ff1744` | DiagnosticsSettings error | `error` | `#F44336` |
| `#1e1e3a` | DiagnosticsSettings panelBg | `surface` | `#1E1F21` |
| `#2a2a4a` | DiagnosticsSettings border | `border` | `#3A3B3E` |
| `#0A0A0A` | NetworkSettings console bg | `consoleBg` | `#111213` |
| `#0d0d1a` | DiagnosticsSettings console bg | `consoleBg` | `#111213` |
| `#666680` | DiagnosticsSettings debug text | `textDisabled` | `#505258` |
