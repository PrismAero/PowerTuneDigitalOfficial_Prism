# Settings UI Audit

Audit of all settings-related QML files for the Prism project. This document catalogs every setting, control, layout value, and color used across the Settings UI to guide a future redesign.

---

## 1. SerialSettings.qml -- Tab Manager Analysis

**File:** [`SerialSettings.qml`](PowerTune/Core/SerialSettings.qml)

### Role

Purely a tab loader. Contains **no settings or user-editable controls** of its own. It defines a `TabBar` + `StackLayout` that loads each settings page as a child.

### How it is loaded

[`Main.qml`](PowerTune/Core/Main.qml:119) instantiates it inline: `SerialSettings {}` inside a `lastPage` item.

### Tab Model

A `ListModel` with 7 entries (note: task description shows 6 tabs, but there are actually 7):

| Index | Tab Title      | Component Loaded       |
|-------|----------------|------------------------|
| 0     | Main           | `MainSettings`         |
| 1     | Dash Sel.      | `DashSelector`         |
| 2     | Vehicle / RPM  | `VehicleRPMSettings`   |
| 3     | EX Board       | `ExBoardAnalog`        |
| 4     | Network        | `NetworkSettings`      |
| 5     | Diagnostics    | `DiagnosticsSettings`  |
| 6     | Dash Test      | `DashboardTestSim`     |

### TabBar Styling

| Property              | Value                              |
|-----------------------|------------------------------------|
| Tab bar height        | 56px                               |
| Tab button height     | 56px                               |
| Tab button width      | `tabView.width / tabModel.count`   |
| Font size             | 18px                               |
| Font family           | "Lato"                             |
| Font weight (active)  | `Font.DemiBold`                    |
| Font weight (inactive)| `Font.Normal`                      |
| Text color (active)   | `#FFFFFF` (colorTextPrimary)       |
| Text color (inactive) | `#B0B0B0` (colorTextSecondary)     |
| Bg color (active)     | `#009688` (colorAccent)            |
| Bg color (inactive)   | `#2D2D2D` (colorBackgroundTertiary)|
| Border (active)       | `#009688`, 1px                     |
| Border (inactive)     | `#3D3D3D` (colorDivider), 1px     |
| Radius                | 4px                                |

### Color Properties Defined

| Property                   | Value     |
|----------------------------|-----------|
| `colorBackground`          | `#121212` |
| `colorBackgroundSecondary` | `#1E1E1E` |
| `colorBackgroundTertiary`  | `#2D2D2D` |
| `colorAccent`              | `#009688` |
| `colorTextPrimary`         | `#FFFFFF` |
| `colorTextSecondary`       | `#B0B0B0` |
| `colorDivider`             | `#3D3D3D` |

### Other Contents

- `DLM` (downloadManager) instance -- not related to settings UI
- `lastdashamount` property -- not used in this file

---

## 2. Per-Page Setting Inventories

### 2.1 MainSettings.qml (Tab 0 -- "Main")

**File:** [`MainSettings.qml`](PowerTune/Settings/MainSettings.qml)  
**Root type:** `Rectangle`, color `#1a1a2e`  
**Layout:** 3-column `RowLayout`, margins 16, spacing 16  
**Uses shared components:** `SettingsSection`, `StyledButton`, `StyledComboBox`, `StyledTextField`, `StyledSwitch`, `ConnectionStatusIndicator`  
**Does NOT use:** `SettingsPage`, `SettingsRow`

#### Settings Inventory

| Setting Name            | Control Type              | AppSettings Key                 | Section           |
|-------------------------|---------------------------|---------------------------------|-------------------|
| Connect at Startup      | StyledButton enabled state| `ui/connectAtStartup`           | Connection        |
| CAN Status              | ConnectionStatusIndicator | (read-only, Diagnostics)        | Connection        |
| ECU Selection           | StyledComboBox            | via `AppSettings.setECU()`      | Connection        |
| Speed Units             | StyledComboBox            | `ui/unitSelector1`              | Units             |
| Temp Units              | StyledComboBox            | `ui/unitSelector`               | Units             |
| Pressure Units          | StyledComboBox            | `ui/unitSelector2`              | Units             |
| Vehicle Weight          | StyledTextField           | `ui/vehicleWeight`              | Vehicle           |
| Odometer                | StyledTextField           | `ui/odometer`                   | Vehicle           |
| Trip Meter              | StyledTextField (readOnly)| `ui/tripmeter`                  | Vehicle           |
| Trip Reset              | StyledButton              | (action only)                   | Vehicle           |
| CAN Bitrate             | StyledComboBox            | `ui/bitrateSelect`              | CAN Bus           |
| Apply Bitrate           | StyledButton              | (action only)                   | CAN Bus           |
| Daemon                  | StyledComboBox (disabled) | (none, always "Generic CAN")    | Daemon / Startup  |
| Speed Source            | StyledComboBox            | `ui/mainSpeedSource`            | Daemon / Startup  |
| Apply Startup           | StyledButton              | (action only)                   | Daemon / Startup  |
| Logfile Name            | StyledTextField           | (not persisted to AppSettings)  | Data Logging      |
| Data Logger Toggle      | StyledSwitch              | (not persisted to AppSettings)  | Data Logging      |
| Extender CAN Base Addr  | StyledTextField           | `ui/extenderCanBase`            | CAN Configuration |
| Shiftlight CAN Base Addr| StyledTextField           | `ui/shiftLightCanBase`          | CAN Configuration |
| Show Brightness Popup   | StyledButton              | (action only)                   | Display           |
| Language                | StyledComboBox            | `Language`                      | Language          |
| Quit                    | StyledButton              | (action only)                   | System            |
| Reboot                  | StyledButton              | (action only)                   | System            |
| Shutdown                | StyledButton              | (action only)                   | System            |

#### Inline Color Values (not from theme/component)

- Root background: `#1a1a2e`
- All label Text items: `color: "#FFFFFF"`, `font.pixelSize: 18`, `font.family: "Lato"`, `Layout.preferredWidth: 160`
- CAN section header text: `color: "#009688"`, `font.pixelSize: 18`, `font.weight: Font.DemiBold`
- Subtitle text: `color: "#B0B0B0"`, `font.pixelSize: 16`
- Version text: `color: "#B0B0B0"`, `font.pixelSize: 16`

#### Spacing Values

- Root margins: 16
- Root column spacing: 16
- Column widths: `(root.width - 64) / 3`
- Inner column spacing: 12
- Row spacing: 12
- Spacer items: `height: 8`, `height: 4`
- CAN address row spacing: 16

---

### 2.2 VehicleRPMSettings.qml (Tab 2 -- "Vehicle / RPM")

**File:** [`VehicleRPMSettings.qml`](PowerTune/Settings/VehicleRPMSettings.qml)  
**Root type:** `Rectangle`, color `#1a1a2e`  
**Layout:** 2-column `RowLayout`, margins 16, spacing 16  
**Uses shared components:** `SettingsSection`, `StyledTextField`, `StyledSwitch`  
**Does NOT use:** `SettingsPage`, `SettingsRow`

#### Settings Inventory

| Setting Name        | Control Type    | AppSettings Key         | Section              |
|---------------------|-----------------|-------------------------|----------------------|
| WaterTemp Warning   | StyledTextField | `waterwarn`             | Warning Thresholds   |
| Boost Warning       | StyledTextField | `boostwarn`             | Warning Thresholds   |
| RPM Warning         | StyledTextField | `rpmwarn`               | Warning Thresholds   |
| Knock Warning       | StyledTextField | `knockwarn`             | Warning Thresholds   |
| Lambda Multiply     | StyledTextField | `lambdamultiply`        | Warning Thresholds   |
| Speed Correction %  | StyledTextField | `Speedcorrection`       | SpeedCorrection      |
| Max RPM             | StyledTextField | `Max RPM`               | RPM / Shift Lights   |
| Shift Light Stage 1 | StyledTextField | `Shift Light1`          | RPM / Shift Lights   |
| Shift Light Stage 2 | StyledTextField | `Shift Light2`          | RPM / Shift Lights   |
| Shift Light Stage 3 | StyledTextField | `Shift Light3`          | RPM / Shift Lights   |
| Shift Light Stage 4 | StyledTextField | `Shift Light4`          | RPM / Shift Lights   |
| Gear Calc On/Off    | StyledSwitch    | `gercalactive`          | GearCalculation      |
| Gear 1 Ratio        | StyledTextField | `valgear1`              | GearCalculation      |
| Gear 2 Ratio        | StyledTextField | `valgear2`              | GearCalculation      |
| Gear 3 Ratio        | StyledTextField | `valgear3`              | GearCalculation      |
| Gear 4 Ratio        | StyledTextField | `valgear4`              | GearCalculation      |
| Gear 5 Ratio        | StyledTextField | `valgear5`              | GearCalculation      |
| Gear 6 Ratio        | StyledTextField | `valgear6`              | GearCalculation      |

*Persisted via batch methods:* `AppSettings.writeWarnGearSettings()`, `AppSettings.writeRPMSettings()`, `AppSettings.writeSpeedSettings()`

#### Inline Color Values

- Root background: `#1a1a2e`
- Label text: `color: "#FFFFFF"`, `font.pixelSize: 18`
- Shift stage card background: `#2D2D2D`, radius 8, border width 2
- Stage colors: `#4CAF50`, `#FFEB3B`, `#FF9800`, `#F44336`
- Subtitle text: `color: "#B0B0B0"`, `font.pixelSize: 16` or `font.pixelSize: 14`
- Hint text: `color: "#707070"`, `font.pixelSize: 16`, `font.italic: true`

#### Spacing Values

- Root margins: 16
- Root spacing: 16
- Column widths: `(root.width - 48) / 2`
- Inner column spacing: 12
- Shift light cards: spacing 12, inner margins 8, inner spacing 4
- Gear grid: columns 6, columnSpacing 8, rowSpacing 8, field width 90, height 40
- Left column label width: 160 (warnings), 200 (speed correction)
- Right column label width: 120 (MAX RPM)
- Shift stage card height: 100
- Shift stage field height: 36

#### Complexity Note

Uses a "Ref bridge" pattern with 10 hidden `StyledTextField` elements and 10 `Connections` blocks to sync Repeater delegate fields to named ids for `AppSettings` persistence. This is a significant architectural workaround.

---

### 2.3 DashSelector.qml (Tab 1 -- "Dash Sel.")

**File:** [`DashSelector.qml`](PowerTune/Settings/DashSelector.qml)  
**Root type:** `Rectangle`, color `#1a1a2e`  
**Layout:** `ColumnLayout`, margins 16, spacing 16, vertically centered with `Item { Layout.fillHeight: true }` spacers  
**Uses shared components:** `SettingsSection`, `StyledComboBox`, `DashSelectorWidget`  
**Does NOT use:** `SettingsPage`, `SettingsRow`

#### Settings Inventory

| Setting Name      | Control Type        | AppSettings Key      | Section              |
|-------------------|---------------------|----------------------|----------------------|
| Active Dashboards | StyledComboBox      | `ui/dashCount`       | ActiveDashboards     |
| Dashboard 1       | DashSelectorWidget  | `ui/dashSelect1`     | Dashboard Selection  |
| Dashboard 2       | DashSelectorWidget  | `ui/dashSelect2`     | Dashboard Selection  |
| Dashboard 3       | DashSelectorWidget  | `ui/dashSelect3`     | Dashboard Selection  |
| Dashboard 4       | DashSelectorWidget  | `ui/dashSelect4`     | Dashboard Selection  |

*Also calls:* `AppSettings.writeSelectedDashSettings()`

#### Inline Color Values

- Root background: `#1a1a2e`
- Label text: `color: "#FFFFFF"`, `font.pixelSize: 18`

#### Spacing Values

- Margins: 16
- Spacing: 16
- Section `Layout.maximumWidth`: 800 (horizontally centered)
- Label width: 200
- Inner row spacing: 16

---

### 2.4 ExBoardAnalog.qml (Tab 3 -- "EX Board")

**File:** [`ExBoardAnalog.qml`](PowerTune/Core/ExBoardAnalog.qml)  
**Root type:** `Rectangle`, color `#1a1a2e`  
**Layout:** `ScrollView` > `ColumnLayout`, margins 16, spacing 16  
**Uses shared components:** `SettingsSection`, `StyledComboBox`, `StyledTextField`, `StyledCheckBox`, `StyledSwitch`  
**Does NOT use:** `SettingsPage`, `SettingsRow`

This is by far the largest settings page (1219 lines).

#### Settings Inventory -- Linear Calibration (8 channels)

For each of EX AN 0-7:

| Setting           | Control Type    | AppSettings Key     |
|-------------------|-----------------|---------------------|
| Linear Preset     | StyledComboBox  | (not individually persisted) |
| Value at 0V       | StyledTextField | `EXA{n}0` (e.g. `EXA00`) |
| Value at 5V       | StyledTextField | `EXA{n}5` (e.g. `EXA05`) |

Total: 8 preset comboboxes + 16 text fields

#### Settings Inventory -- NTC Temperature (6 channels, AN 0-5)

For each of AN 0-5:

| Setting          | Control Type     | AppSettings Key           |
|------------------|------------------|---------------------------|
| NTC Enable       | StyledCheckBox   | `steinhartcalc{n}on`     |
| NTC Preset       | StyledComboBox   | (not individually persisted) |
| T1, R1, T2, R2, T3, R3 | StyledTextField (x6) | `T{n}1`, `R{n}1`, `T{n}2`, `R{n}2`, `T{n}3`, `R{n}3` |
| 100 Ohm Divider  | StyledCheckBox   | `AN{n}R3VAL`             |
| 1K Ohm Divider   | StyledCheckBox   | `AN{n}R4VAL`             |

Total: 6 NTC checkboxes + 6 preset comboboxes + 36 text fields + 12 divider checkboxes

#### Settings Inventory -- Board Configuration

| Setting             | Control Type    | AppSettings Key                    |
|---------------------|-----------------|------------------------------------|
| AN7 Damping         | StyledTextField | `AN7Damping`                       |
| RPM Source          | StyledComboBox  | `ui/exboard/rpmSource`             |
| CAN RPM Version     | StyledComboBox  | (via `setInputs`)                  |
| Cylinders (V1)      | StyledComboBox  | `ui/exboard/cylinderCombobox`      |
| Cylinders (V2)      | StyledComboBox  | `ui/exboard/cylinderComboboxV2`    |
| Cylinders (Di1)     | StyledComboBox  | `ui/exboard/cylinderComboboxDi1`   |
| Headlight Channel   | StyledComboBox  | `ui/exboard/selectedValue`         |
| CAN/IO Brightness   | StyledSwitch    | `ui/exboard/switchValue`           |
| RPM Checkbox        | StyledCheckBox  | `ui/exboard/rpmcheckbox` (hidden)  |

#### Settings Inventory -- Sensor Mapping (16 channels)

| Setting               | Control Type    | AppSettings Key                      |
|-----------------------|-----------------|--------------------------------------|
| EX AN 0-7 Name (x8)  | StyledTextField | `ui/exboard/exan{n}name`            |
| EX Digi 1-8 Name (x8)| StyledTextField | `ui/exboard/exdigi{n}name`          |

*Persisted via batch methods:* `AppSettings.writeEXBoardSettings()`, `AppSettings.writeSteinhartSettings()`, `AppSettings.writeExternalrpm()`, `AppSettings.writeEXAN7dampingSettings()`, `AppSettings.writeRPMFrequencySettings()`, `AppSettings.writeCylinderSettings()`

#### Total Control Count

- StyledComboBox: ~15
- StyledTextField: ~72 (visible) + 16 hidden bridge fields
- StyledCheckBox: ~19 (visible) + 1 hidden
- StyledSwitch: 1
- **Grand total: ~107+ controls**

#### Inline Color Values

- Root background: `#1a1a2e`
- Column headers: `font.pixelSize: 15`, `font.bold: true`, `color: "#a0a0a0"`
- Channel labels: `font.pixelSize: 15`, `color: "#FFFFFF"`
- Unit text: `color: "#a0a0a0"`
- Voltage range text: `color: "#808080"`
- Live value text (active): `color: "#4CAF50"`, (inactive): `color: "#606060"`
- Calibrated value text: `color: "#e0e0e0"`
- Status dot (active): `#4CAF50`, (inactive): `#555555`
- Section subheader: `color: "#009688"`, `font.pixelSize: 16`, `font.weight: Font.DemiBold`
- Board config labels: `font.pixelSize: 18`, `color: "#FFFFFF"`
- Hint text: `color: "#606080"`, `font.pixelSize: 12`, `font.italic: true`

#### Spacing Values

- Root margins: 16 (via `contentMargin` property)
- Column spacing: 16
- Row heights: 38 (linear), 38 (NTC), 28 (headers)
- Row spacing within sections: 6 (linear), 6 (NTC), 12 (board config), 6 (sensor mapping)
- Row left/right margin: 12
- Row inner spacing: 4 (linear/NTC), 12 (board config), 8 (sensor mapping), 24 (sensor mapping column gap)
- Field heights: 36 (throughout ExBoard)
- Column width constants: `chanColW: 70`, `linPresetColW: 145`, `val0vColW: 75`, `val5vColW: 75`, `unitColW: 50`, `vRangeColW: 48`, `liveVColW: 80`, `calibColW: 85`, `statusColW: 36`, `ntcCheckColW: 44`, `ntcPresetColW: 165`, `shFieldW: 60`, `divCheckColW: 42`
- Sensor name label width: 80
- Status dot: 10x10 radius 5

#### Complexity Note

Same "Ref bridge" pattern as VehicleRPMSettings: 16 hidden `StyledTextField` elements + 16 `Connections` blocks for sensor name mapping.

---

### 2.5 NetworkSettings.qml (Tab 4 -- "Network")

**File:** [`NetworkSettings.qml`](PowerTune/Settings/NetworkSettings.qml)  
**Root type:** `Rectangle`, color `#1a1a2e`  
**Layout:** 2-column `RowLayout` (settings left, console right), margins 16, spacing 16  
**Uses shared components:** `SettingsSection`, `StyledComboBox`, `StyledTextField`, `StyledButton`, `ConnectionStatusIndicator`  
**Does NOT use:** `SettingsPage`, `SettingsRow`

#### Settings Inventory

| Setting Name        | Control Type              | AppSettings Key         | Section           |
|---------------------|---------------------------|-------------------------|-------------------|
| WiFi Country        | StyledComboBox            | `ui/wifiCountryIndex`   | WIFI Configuration|
| WiFi SSID (WIFI 1)  | StyledComboBox            | (runtime scan results)  | WIFI Configuration|
| Password 1          | StyledTextField (password)| (not persisted)         | WIFI Configuration|
| Scan WIFI           | StyledButton              | (action only)           | WIFI Configuration|
| Connect WIFI        | StyledButton              | (action only)           | WIFI Configuration|
| Ethernet IP Address | ConnectionStatusIndicator | (read-only, Connection) | Network Status    |
| WLAN IP Address     | ConnectionStatusIndicator | (read-only, Connection) | Network Status    |
| Update              | StyledButton              | (action only)           | System Actions    |
| Restart Daemon      | StyledButton              | (action only)           | System Actions    |

#### Inline Color Values

- Root background: `#1a1a2e`
- Label text: `color: "#FFFFFF"`, `font.pixelSize: 18`
- Console panel background: `#0A0A0A`, radius 8, border `#3D3D3D` 1px
- Console title: `color: "#009688"`, `font.pixelSize: 20`, `font.weight: Font.Bold`
- Console divider: `#3D3D3D`
- Console text: `color: "#4CAF50"`, `font.pixelSize: 14`, `font.family: "Courier New"`

#### Spacing Values

- Root margins: 16
- Root spacing: 16
- Settings column: `Layout.preferredWidth: 480`, `Layout.maximumWidth: 520`
- Inner column spacing: 12
- Row spacing: 16
- Label width: 160
- Console inner margins: 12
- Console inner spacing: 8

---

### 2.6 DiagnosticsSettings.qml (Tab 5 -- "Diagnostics")

**File:** [`DiagnosticsSettings.qml`](PowerTune/Settings/DiagnosticsSettings.qml)  
**Root type:** `Item` (not Rectangle)  
**Layout:** Custom -- `ColumnLayout` with two `RowLayout` tiers (top: System+Connection panels, bottom: Sensor table+Log)  
**Uses shared components:** NONE -- fully custom layout  
**Does NOT use:** `SettingsPage`, `SettingsSection`, `SettingsRow`, or any Styled* components

#### Settings Inventory

This page is primarily **read-only diagnostics data**, not user-editable settings:

| Data Point       | Type      | Source                          |
|------------------|-----------|---------------------------------|
| CPU Temp         | Text      | `Diagnostics.cpuTemperature`    |
| CPU Load         | Text      | `Diagnostics.cpuLoadAverage`    |
| RAM              | Text      | `Diagnostics.memoryUsedMB` etc. |
| Disk             | Text      | `Diagnostics.diskUsagePercent`  |
| Uptime           | Text      | `Diagnostics.uptime`            |
| Platform         | Text      | `Connection.Platform`           |
| Sensors          | Text      | `Diagnostics.activeSensorCount` |
| CAN Status       | Dot+Text  | `Diagnostics.canStatusText`     |
| Daemon           | Text      | `Diagnostics.daemonName`        |
| CAN Rate         | Text      | `Diagnostics.canMessageRate`    |
| CAN Total        | Text      | `Diagnostics.canTotalMessages`  |
| Serial           | Dot+Text  | `Diagnostics.serialConnected`   |
| Connection Type  | Text      | `Diagnostics.connectionType`    |
| System Time      | Text      | `Diagnostics.systemTime`        |
| Live Sensor Data | ListView  | `Diagnostics.liveSensorEntries` |
| System Log       | ListView  | `Diagnostics.filteredLogMessages`|

**Interactive controls (not AppSettings):**

| Control         | Type        | Binding                          |
|-----------------|-------------|----------------------------------|
| Show All/Active | MouseArea   | `Diagnostics.showAllSensors`     |
| Log Level       | MouseArea   | `Diagnostics.logLevel` (0-3)     |
| Clear Log       | MouseArea   | `Diagnostics.clearLog()`         |

#### Inline Color Values (own color scheme, not matching other pages)

| Property             | Value     |
|----------------------|-----------|
| `panelBg`            | `#1e1e3a` |
| `panelBorder`        | `#2a2a4a` |
| `pageBg`             | `#1a1a2e` |
| `accentColor`        | `#009688` |
| `textPrimary`        | `#FFFFFF` |
| `textSecondary`      | `#B0B0B0` |
| `errorColor`         | `#ff1744` |
| `connectedColor`     | `#00c853` |
| `disconnectedColor`  | `#ff1744` |
| `consoleBg`          | `#0d0d1a` |
| `consoleText`        | `#00ff88` |
- Additional inline: `#FF9800` (warning CAN), `#3D3D3D` (dividers), `#2a2a4a` (button bg), `#666680` (debug log), `#606060` (inactive value)
- Toggle button: 100x28 radius 4
- Log level buttons: 50x26 radius 4

#### Spacing Values

- Root margins: 8
- Root spacing: 8
- Top row height: 230
- Panel inner margins: 10
- Panel inner spacing: 4
- Panel radius: 6
- Label width: 140
- Bottom row minimum height: 300
- Sensor table preferred width: 900
- Sensor list item height: 28
- Sensor list spacing: 1
- Log list inner margins: 6
- Log list spacing: 1

---

## 3. Overlapping / Duplicated Settings

### Settings that appear on MULTIPLE tabs

| Setting          | MainSettings                | VehicleRPMSettings | Notes |
|------------------|-----------------------------|--------------------|-------|
| (No direct key overlap found between active tabs) | | | |

**However, there is FUNCTIONAL overlap:**
- **Warning thresholds** (waterwarn, boostwarn, rpmwarn, knockwarn) are **set** on VehicleRPMSettings but **evaluated** (with warning triggers) on MainSettings via `Connections` blocks listening to `Engine.onWatertempChanged`, `Engine.onRpmChanged`, `Engine.onKnockChanged`.
- **Speed Source** appears only on MainSettings, but speed correction logic lives on VehicleRPMSettings.

### Settings across legacy files that may still be referenced

The legacy files (StartupSettings, WarnGearSettings, SpeedSettings, RPMSettings) contain the **same AppSettings keys** as now consolidated into MainSettings and VehicleRPMSettings; they are not loaded as tabs.

---

## 4. Spacing / Padding Inconsistencies Catalog

| Property                   | SerialSettings | MainSettings | VehicleRPM | DashSelector | ExBoard | Network | Diagnostics |
|----------------------------|:-:|:-:|:-:|:-:|:-:|:-:|:-:|
| Root margins               | 0 (anchors.fill) | 16 | 16 | 16 | 16 | 16 | 8 |
| Primary column spacing     | 0 | 16 | 16 | 16 | 16 | 16 | 8 |
| Inner section spacing      | -- | 12 | 12 | 16 | varies (6/12) | 12 | 4 |
| Row inner spacing          | -- | 12 | 12/16 | 16 | 4/2/8/12/24 | 16/12 | 4 |
| Label preferredWidth       | -- | 160 | 160/200/120 | 200 | 70-165 (varies) | 160 | 140 |
| Row left/right margins     | -- | 0 | 0 | 0 | 12 | 0 | 0 |

**Key inconsistencies:**
1. DiagnosticsSettings uses 8px margins while all others use 16px
2. ExBoardAnalog uses 12px row left/right margins while others use 0
3. Row spacing varies: 4, 6, 8, 12, 16, 24 across pages
4. Label widths range from 70px to 200px with no standard
5. ExBoardAnalog uses spacing 2 for NTC rows but 4 for linear rows and 12 for board config

---

## 5. Color Usage Catalog

### Background Colors

| Color   | Where Used |
|---------|------------|
| `#121212` | SerialSettings root, SettingsPage theme |
| `#1a1a2e` | MainSettings, VehicleRPMSettings, DashSelector, ExBoard, NetworkSettings, DiagnosticsSettings (pageBg) |
| `#1E1E1E` | SerialSettings colorBackgroundSecondary, SettingsPage theme, StyledComboBox popup bg |
| `#1E1E2E` | SettingsSection card bg |
| `#1e1e3a` | DiagnosticsSettings panelBg |
| `#2D2D2D` | SerialSettings colorBackgroundTertiary, VehicleRPM shift card bg, StyledTextField bg, StyledComboBox bg, StyledCheckBox bg, ConnectionStatusIndicator bg |
| `#2a2a4a` | DiagnosticsSettings (buttons, panelBorder) |
| `#0A0A0A` | NetworkSettings console bg |
| `#0d0d1a` | DiagnosticsSettings consoleBg |

**Issue:** The root background color `#1a1a2e` on 5 pages does NOT match:
- SerialSettings root `#121212`
- SettingsPage theme `#121212`
- SettingsSection card `#1E1E2E`
This creates a visible mismatch since SerialSettings wraps the pages.

### Accent Colors

| Color   | Where Used |
|---------|------------|
| `#009688` | Universal accent (SerialSettings, SettingsSection title, all Styled* components, MainSettings CAN header, ExBoard section subheader, DiagnosticsSettings, NetworkSettings console title) |
| `#00796B` | StyledButton pressed primary, StyledSwitch checked border, StyledCheckBox checked border |
| `#00897B` | StyledButton hovered primary, StyledButton hovered outline border |

### Text Colors

| Color   | Role |
|---------|------|
| `#FFFFFF` | Primary text everywhere |
| `#B0B0B0` | Secondary text (SerialSettings, SettingsRow description, StyledComboBox delegate idle, StyledCheckBox indicator border hovered, DiagnosticsSettings textSecondary) |
| `#a0a0a0` | ExBoard column headers / unit text (NOT matching `#B0B0B0` used elsewhere) |
| `#e0e0e0` | ExBoard calibrated values |
| `#707070` | StyledTextField placeholder, VehicleRPM hint text |
| `#808080` | ExBoard voltage range text |
| `#606060` | ExBoard/Diagnostics inactive value text |
| `#606080` | ExBoard hint text (different from `#707070` hints elsewhere) |
| `#666680` | DiagnosticsSettings debug log text |

### Status Colors

| Color   | Meaning |
|---------|---------|
| `#4CAF50` | Success / Connected / Active value (SettingsPage, ExBoard live, Diagnostics, NetworkSettings console) |
| `#00c853` | DiagnosticsSettings connectedColor (different green than `#4CAF50`) |
| `#00ff88` | DiagnosticsSettings system log text (yet another green) |
| `#F44336` | Error (SettingsPage, StyledButton danger, ConnectionStatusIndicator disconnected) |
| `#ff1744` | DiagnosticsSettings error (different red than `#F44336`) |
| `#FF9800` | Warning / Pending (SettingsPage, ConnectionStatusIndicator, DiagnosticsSettings CAN waiting) |
| `#FFEB3B` | VehicleRPM shift stage 2 color |

### Border / Divider Colors

| Color   | Where Used |
|---------|------------|
| `#3D3D3D` | SerialSettings colorDivider, SettingsSection divider, StyledTextField border, StyledComboBox border, StyledSwitch unchecked, Diagnostics dividers, NetworkSettings console border |
| `#2D2D4E` | SettingsSection border |
| `#2a2a4a` | DiagnosticsSettings panelBorder |
| `#505050` | StyledTextField hovered border, StyledCheckBox hovered border, StyledSwitch unchecked border |
| `#5a5a5a` | DashboardTheme panelBorder |

---

## 6. Touch Target Size Catalog

### Shared Components

| Component               | Height | Min Width | Notes |
|-------------------------|--------|-----------|-------|
| StyledButton            | 48px   | content+40 | Set via `implicitHeight: Math.max(48, ...)` |
| StyledComboBox          | 48px   | 100px     | `Math.max(48, fontMetrics.height + 24)` |
| StyledTextField         | 48px   | 120px     | `Math.max(48, font.pixelSize + topPadding + bottomPadding)` |
| StyledSwitch            | 48px   | --        | Track: 56x28, knob: 20x20 |
| StyledCheckBox          | 44px   | --        | Indicator: 28x28 |
| ConnectionStatusIndicator | 44px | 200px     | With 12px margins inside |
| SettingsRow             | auto   | --        | Label column: 280px preferred, control: 280x48 |

### Per-Page Overrides

ExBoardAnalog overrides most control sizes to 36px height and 15px font, making touch targets significantly smaller than the 48px standard defined by the shared components.

| Override Location                    | Height | Font Size |
|--------------------------------------|--------|-----------|
| ExBoard linear cal fields            | 36px   | 15px      |
| ExBoard NTC fields                   | 36px   | 15px      |
| ExBoard comboboxes                   | 36px   | 15px      |
| ExBoard checkboxes                   | 36px   | --        |
| ExBoard sensor mapping fields        | 36px   | 15px      |
| ExBoard board config fields          | 36px   | 15px      |
| VehicleRPM gear ratio fields         | 40px   | 16px      |
| VehicleRPM shift stage fields        | 36px   | 16px      |
| DiagnosticsSettings toggle button    | 28px   | 13px      |
| DiagnosticsSettings log level button | 26px   | 12px      |
| DiagnosticsSettings sensor rows      | 28px   | 14px      |

---

## 7. Shared Component Analysis

### SettingsPage.qml

**File:** [`SettingsPage.qml`](PowerTune/Settings/components/SettingsPage.qml)

Defines a complete theme object with design tokens but is **NOT USED by any settings page**. Every page uses its own root `Rectangle` with hardcoded colors instead.

| Token                 | Value   | Used by pages? |
|-----------------------|---------|:-:|
| colorBackground       | #121212 | No (pages use #1a1a2e) |
| colorBackgroundSecondary | #1E1E1E | No |
| colorBackgroundTertiary | #2D2D2D | No |
| colorAccent           | #009688 | Only via components |
| colorTextPrimary      | #FFFFFF | No (hardcoded inline) |
| colorTextSecondary    | #B0B0B0 | No (hardcoded inline) |
| colorDivider          | #3D3D3D | No (hardcoded inline) |
| colorSuccess          | #4CAF50 | No |
| colorWarning          | #FF9800 | No |
| colorError            | #F44336 | No |
| fontHeader            | 28      | No (pages use 18-22) |
| fontBody              | 22      | No (pages use 15-18) |
| fontCaption           | 16      | No |
| buttonHeight          | 48      | Matched by Styled* |
| controlHeight         | 44      | No |
| controlWidth          | 280     | No |
| sectionPadding        | 16      | No |
| rowSpacing            | 12      | Partially |
| sectionSpacing        | 20      | No |
| borderRadius          | 8       | Partially |

Also provides a `ScrollView` wrapper -- not used as pages handle their own scrolling.

### SettingsSection.qml

**File:** [`SettingsSection.qml`](PowerTune/Settings/components/SettingsSection.qml)

**Used by:** MainSettings, VehicleRPMSettings, DashSelector, ExBoardAnalog, NetworkSettings  
**NOT used by:** DiagnosticsSettings (uses custom panels)

| Hardcoded Value | Property |
|-----------------|----------|
| `#1E1E2E`       | Card background |
| `#2D2D4E`       | Card border |
| `#009688`       | Title color |
| `#B0B0B0`       | Collapse arrow color |
| `#3D3D3D`       | Divider & collapse button pressed bg |
| 8px              | Border radius |
| 1px              | Border width |
| 12px             | Inner margins |
| 8px              | Inner spacing |
| 20px             | Title font size |
| 32px             | Collapse button size |

### SettingsRow.qml

**File:** [`SettingsRow.qml`](PowerTune/Settings/components/SettingsRow.qml)

**NOT USED by any settings page.** All pages build their own `RowLayout` with inline Text labels.

| Hardcoded Value | Property |
|-----------------|----------|
| `#FFFFFF`       | Label text color |
| `#B0B0B0`       | Description text color |
| 22px             | Label font size |
| 16px             | Description font size |
| 280px            | Label column preferred width |
| 200px            | Label column minimum width |
| 280px            | Control container preferred width |
| 48px             | Control container preferred height |
| 20px             | Row spacing |

### StyledButton.qml

**File:** [`StyledButton.qml`](PowerTune/Settings/components/StyledButton.qml)

| Hardcoded Value | Property |
|-----------------|----------|
| 48px min        | Height (`Math.max(48, ...)`) |
| 22px             | Font size |
| 8px              | Border radius |
| `#009688`       | Primary bg, outline border |
| `#00897B`       | Primary hovered |
| `#00796B`       | Primary pressed |
| `#F44336`       | Danger bg |
| `#E53935`       | Danger hovered |
| `#C62828`       | Danger pressed |
| `#FFFFFF`       | Text color (primary/danger) |
| 2px              | Outline border width |

### StyledComboBox.qml

**File:** [`StyledComboBox.qml`](PowerTune/Settings/components/StyledComboBox.qml)

| Hardcoded Value | Property |
|-----------------|----------|
| 48px min        | Height |
| 22px             | Font size |
| 8px              | Border radius |
| `#2D2D2D`       | Background |
| `#3D3D3D`       | Border (idle), popup border |
| `#009688`       | Border (focused), indicator arrow pressed, highlight bg |
| `#1E1E1E`       | Popup background |
| `#FFFFFF`       | Display text, highlighted item text |
| `#B0B0B0`       | Idle item text, indicator arrow |
| `#252525`       | Odd delegate background |
| 16px             | Content left/right padding |
| 300px            | Max popup height |

### StyledTextField.qml

**File:** [`StyledTextField.qml`](PowerTune/Settings/components/StyledTextField.qml)

| Hardcoded Value | Property |
|-----------------|----------|
| 48px min        | Height |
| 120px min       | Width |
| 22px             | Font size |
| 8px              | Border radius |
| `#2D2D2D`       | Background |
| `#3D3D3D`       | Border (idle) |
| `#505050`       | Border (hovered) |
| `#009688`       | Border (focused), selection bg, cursor |
| `#FFFFFF`       | Text color, selected text |
| `#707070`       | Placeholder text color |
| 16px             | Left/right padding |
| 12px             | Top/bottom padding |
| 2px              | Cursor width |

### StyledSwitch.qml

**File:** [`StyledSwitch.qml`](PowerTune/Settings/components/StyledSwitch.qml)

| Hardcoded Value | Property |
|-----------------|----------|
| 48px             | Height |
| 56x28            | Track size |
| 20x20            | Knob size |
| 22px             | Font size |
| `#009688`       | Track checked |
| `#3D3D3D`       | Track unchecked |
| `#00796B`       | Border checked |
| `#505050`       | Border unchecked |
| `#FFFFFF`       | Knob color, text color |

### StyledCheckBox.qml

**File:** [`StyledCheckBox.qml`](PowerTune/Settings/components/StyledCheckBox.qml)

| Hardcoded Value | Property |
|-----------------|----------|
| 44px             | Height |
| 28x28            | Indicator size |
| 20px             | Font size |
| 6px              | Indicator radius |
| `#009688`       | Indicator checked bg |
| `#2D2D2D`       | Indicator unchecked bg |
| `#00796B`       | Border checked |
| `#3D3D3D`       | Border unchecked |
| `#505050`       | Border hovered |
| `#FFFFFF`       | Checkmark, text color |

### ConnectionStatusIndicator.qml

**File:** [`ConnectionStatusIndicator.qml`](PowerTune/Settings/components/ConnectionStatusIndicator.qml)

| Hardcoded Value | Property |
|-----------------|----------|
| 44px             | Height |
| 200px            | Width |
| 8px              | Border radius |
| 12x12            | Status dot |
| 18px             | Font size |
| `#2D2D2D`       | Background |
| `#4CAF50`       | Connected color |
| `#F44336`       | Disconnected color |
| `#FF9800`       | Pending color |
| `#3D3D3D`       | Unknown border |
| `#707070`       | Unknown dot |
| `#FFFFFF`       | Text color |

### Component Consistency Assessment

The Styled* components are **internally consistent** with each other -- they all use the same color palette:
- Accent: `#009688` / `#00897B` / `#00796B`
- Background: `#2D2D2D`
- Border: `#3D3D3D` -> `#505050` (hovered) -> `#009688` (focused)
- Text: `#FFFFFF`
- Secondary: `#B0B0B0`

**However**, there is NO design token system. Every component hardcodes its own copy of these values. A color change would require editing every component file individually.

### DashboardTheme.qml

**File:** [`DashboardTheme.qml`](PowerTune/Dashboard/DashboardTheme.qml)

A `pragma Singleton` `QtObject` with only 4 properties:
- `panelBackground: "#3a3a3a"`
- `panelBorder: "#5a5a5a"`
- `panelText: "#FFFFFF"`
- `panelRadius: 6`

Intentionally separate from Settings theme. Uses different grays that don't match the settings palette.

---

## 8. Legacy Stub Status

All legacy files **exist on disk** and are **listed in CMakeLists.txt** (lines 278-283). They are full implementations (not stubs) but are NOT loaded by any tab in SerialSettings.qml.

| File                                              | On Disk | In CMakeLists | Loaded as Tab | Status |
|---------------------------------------------------|:-------:|:-------------:|:-------------:|--------|
| [`StartupSettings.qml`](PowerTune/Settings/StartupSettings.qml) | Yes | Yes | No | Superseded by MainSettings Daemon/Startup section |
| [`WarnGearSettings.qml`](PowerTune/Settings/WarnGearSettings.qml) | Yes | Yes | No | Superseded by VehicleRPMSettings Warning/Gear sections |
| [`SpeedSettings.qml`](PowerTune/Settings/SpeedSettings.qml) | Yes | Yes | No | Superseded by VehicleRPMSettings SpeedCorrection section |
| [`RPMSettings.qml`](PowerTune/Settings/RPMSettings.qml) | Yes | Yes | No | Superseded by VehicleRPMSettings RPM/Shift Lights section |
| [`SenseHatSettings.qml`](PowerTune/Settings/SenseHatSettings.qml) | Yes | Yes | No | No replacement -- SenseHat feature appears removed |
| [`AnalogSettings.qml`](PowerTune/Settings/AnalogSettings.qml) | Yes | Yes | No | Loader wrapper for AnalogInputs; superseded by ExBoardAnalog |

---

## 9. Summary of Issues Found

### Architecture Issues

1. **SettingsPage component unused**: The `SettingsPage.qml` wrapper with its theme tokens is defined but never used by any page. All pages create their own root `Rectangle` with inline colors.

2. **SettingsRow component unused**: `SettingsRow.qml` provides consistent label+control layout but no page uses it. Each page builds its own `RowLayout` with inline Text+control pairs.

3. **No design token system**: Colors are hardcoded everywhere. The `SettingsPage.theme` object was an attempt at centralization but was never adopted. Even the Styled* components hardcode their own color copies.

4. **Ref bridge pattern**: Both `VehicleRPMSettings` (10 bridges + 10 Connections) and `ExBoardAnalog` (16 bridges + 16 Connections) use hidden `StyledTextField` elements to bridge Repeater delegate data to named ids for AppSettings persistence. This is fragile and verbose.

5. **6 legacy files in CMakeLists.txt**: `StartupSettings`, `WarnGearSettings`, `SpeedSettings`, `RPMSettings`, `SenseHatSettings`, and `AnalogSettings` are compiled into the binary but never loaded.

6. **DiagnosticsSettings uses no shared components**: It has its own complete custom layout with its own color scheme properties.

### Color Inconsistencies

7. **Root background mismatch**: Pages use `#1a1a2e`, SerialSettings uses `#121212`, SettingsPage defines `#121212`. The pages render inside SerialSettings, so there may be a visible seam.

8. **Multiple green colors for "connected/active"**: `#4CAF50`, `#00c853`, `#00ff88` are all used for success/connected/active states across different pages.

9. **Multiple red colors for "error/disconnected"**: `#F44336` (Styled* components) vs `#ff1744` (DiagnosticsSettings).

10. **Secondary text inconsistency**: `#B0B0B0` (most places) vs `#a0a0a0` (ExBoard headers) vs `#808080` (ExBoard voltage) vs `#707070` (hints) vs `#606060`/`#606080` (inactive values).

### Spacing Inconsistencies

11. **No standard row spacing**: Values of 2, 4, 6, 8, 12, 16, 24 px used across pages with no clear pattern.

12. **No standard label width**: 70, 80, 120, 140, 160, 200, 280 px used.

13. **DiagnosticsSettings uses 8px margins** while all other pages use 16px.

### Touch Target Issues

14. **ExBoard controls at 36px height**: Below the 48px minimum defined by Styled* components and well below the 44px Material Design minimum.

15. **Diagnostics buttons at 26-28px**: Toggle and log level buttons are extremely small touch targets.

16. **Font size inconsistency**: Styled* components use 22px, but pages override to 15-18px. The SettingsPage theme defines 28/22/16 but nobody uses it.