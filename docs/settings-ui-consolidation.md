# PowerTune Settings UI - Consolidation and Polish Plan

## Current State Analysis

The settings UI currently has 11 tabs in the tab bar: Main, Dash Sel., Sensehat, Warn/Gear, Speed, Analog, RPM, EX Board, Startup, Network, Diagnostics. This analysis covers the first 7 tabs based on screenshot review.

### Per-Page Analysis

#### 1. Main Page
- **Layout:** 3-column grid with 8 grouped sections
- **Left column:** Connection (Connect/Disconnect, GPS Connect/Disconnect, GPS Port dropdown, Serial Status indicator), ECU Configuration (ECU Selection dropdown), Units (Speed/Temp/Pressure dropdowns)
- **Center column:** Vehicle (Weight kg, Odo, Trip with Trip Reset), Data Logging (Logfile name, Data Logger toggle, NMEA Logger toggle), GoPro (Variant dropdown, Password field, GoPro rec toggle)
- **Right column:** CAN Configuration (CAN Extender base address, Shiftlight CAN base address), Language (English dropdown), System (version, Quit/Reboot/Shutdown buttons)
- **Issues:**
  - Dense but well-organized overall
  - Serial Status indicator (red dot in a rectangle) looks unpolished - needs better visual treatment
  - GroupBox borders are inconsistent - some are tighter than others
  - Connect/Disconnect button pairs have inconsistent styling (filled vs outline)
  - "GPS Port:" label has trailing colon while other labels don't - inconsistent
  - Some labels have colons, others don't (Weight kg vs GPS Port:)
  - CAN "base adress" has a typo - should be "base address"
  - The HEX display (HEX: 0x000) is right-aligned and looks disconnected from the input

#### 2. Dash Sel. Page
- **Layout:** Single centered column with 2 small groups
- **Content:** Active Dashboards (count dropdown), Dashboard Selection (a card showing "Dash 1" with a "User Dash 1" dropdown)
- **Issues:**
  - EXTREMELY sparse - ~90% of the screen is empty
  - Only 2 controls on the entire page
  - The "Active Dashboards" label is redundant (label and group title say the same thing)
  - Dashboard card styling (gray border rectangle) is inconsistent with other pages
  - STRONG candidate for merging into Main page

#### 3. Sensehat Page
- **Layout:** Single full-width group with 2-column grid of sensor cards
- **Content:** 5 sensor toggle cards (Accelerometer, Gyro Sensor, Compass, Pressure Sensor, Temperature Sensor), each with icon + name + description + toggle
- **Issues:**
  - Very sparse - bottom 60% of the page is empty
  - The card-based design with icons is actually well-done and could be a pattern for other pages
  - Temperature Sensor card is alone in its row (odd number of items)
  - Only relevant when running on Raspberry Pi with Sensehat - not applicable on all deployments
  - STRONG candidate for merging or making conditional

#### 4. Warn/Gear Page
- **Layout:** 2-column layout
- **Left:** Warning Thresholds (Coolant, Boost, Max RPM, Knock, Lambda multiply - all numeric inputs)
- **Right:** Gear Calculation (enable toggle showing "Gear Calculation Off", 6 gear ratio inputs, help text)
- **Issues:**
  - Moderate density, reasonable grouping
  - "Max RPM" value (10000) DUPLICATED here and on Warn/Gear page AND on RPM page - this is a data inconsistency risk
  - Label alignment: labels are left-aligned, inputs are positioned differently between the two sections
  - Gear ratio inputs lack column headers (no "RPM/Speed Ratio" header)
  - Help text at bottom of Gear section is good practice but inconsistent with other pages that lack help text
  - The two columns have different heights, creating visual imbalance

#### 5. Speed Page
- **Layout:** Single left-aligned column with 2 tiny groups
- **Content:** Speed Correction % (single numeric input with hint text "(100 = no correction)"), USB VR Speed Sensor (single toggle)
- **Issues:**
  - EXTREMELY sparse - ~95% of the screen is empty
  - Only 2 controls total
  - Label reads "Speed Correction % %" - the % symbol appears TWICE (once in group title, once in label)
  - Groups only span about half the width, leaving right side completely empty
  - STRONGEST candidate for merging - this should NOT be its own page

#### 6. Analog Page
- **Layout:** Full-width table/grid layout
- **Content:** 11 rows (Analog 0-10), columns: Input, Sensor Preset (dropdown), Val @ 0V, Val @ 5V, Unit, Min V, Max V
- **Issues:**
  - Good tabular layout for repetitive data
  - NO GroupBox wrapper - inconsistent with other pages that use GroupBox styling
  - No section title/header explaining what this configures
  - The "Unit", "Min V", "Max V" columns appear to have empty/disabled inputs - unclear if they're read-only or just empty
  - Column header alignment: headers don't perfectly align above their respective columns
  - Analog 0 and Analog 1 rows have different Val @ 5V handling (Analog 0 shows just "5" while Analog 1 shows no value in the visible area)
  - Could benefit from a "reset all to defaults" button

#### 7. RPM Page
- **Layout:** 2 full-width groups stacked vertically
- **Content:** RPM Configuration (MAX RPM input), Shift Light (4 color-coded stage cards - green/stage 1, yellow/stage 2, orange/stage 3, red/stage 4, each with RPM threshold)
- **Issues:**
  - Moderate density, bottom 40% unused
  - "MAX RPM" is DUPLICATED from Warn/Gear page (both show 10000) - data inconsistency risk
  - The shift light stage cards are visually well-designed with color coding
  - The 4 stage cards have inconsistent widths - stage 4 (red) box appears wider than stage 1 (green)
  - Stage cards are left-aligned with empty space on the right
  - Could be merged with Speed and/or Warn/Gear for a "Vehicle Dynamics" page

## Global Issues

### Consistency Problems
1. **Label formatting:** Some labels have colons (GPS Port:, Trip:), others don't (Weight kg, Coolant, Boost)
2. **GroupBox usage:** Most pages use teal-titled GroupBoxes, but Analog page has no GroupBox
3. **Spacing:** Margins and padding vary between pages and between groups on the same page
4. **Button styling:** Three different button styles seen: filled teal (Connect, GPS Connect), outlined teal (Disconnect, Trip Reset, Quit, Reboot), filled red (Shutdown)
5. **Input field widths:** Vary widely even for similar data types
6. **Typos:** "base adress" should be "base address" on Main page

### Content Duplication
- "Max RPM" appears on BOTH Warn/Gear page AND RPM page
- This creates a risk where changing it in one place doesn't update the other

### Wasted Space
- Dash Sel., Sensehat, Speed, and RPM pages are all severely under-utilized
- Each has less than 10 controls but occupies an entire tab

## Consolidation Plan

### Proposed Tab Structure (7 tabs instead of 11+)

| Current Tabs | Proposed Tab | Rationale |
|---|---|---|
| Main | **General** | Rename for clarity. Keep Connection, ECU, Units, Vehicle, Language, System sections |
| Dash Sel. | **General** (merge) | Move Active Dashboards and Dashboard Selection into General page as a new section |
| Sensehat | **Sensors** (merge) | Combine into a new "Sensors" page with Analog inputs |
| Warn/Gear | **Engine** (merge) | Combine warning thresholds, gear calc, RPM config, shift light, speed correction |
| Speed | **Engine** (merge) | Speed correction and USB VR sensor move into Engine page |
| Analog | **Sensors** (merge) | Analog inputs become the primary content of the Sensors page |
| RPM | **Engine** (merge) | RPM config and shift light settings merge into Engine page |
| EX Board | **EX Board** (keep) | Keep as-is (not analyzed yet) |
| Startup | **Startup** (keep) | Keep as-is (not analyzed yet) |
| Network | **Network** (keep) | Keep as-is (not analyzed yet) |
| Diagnostics | **Diagnostics** (keep) | Keep as-is (not analyzed yet) |

**Result: 7 tabs** - General, Sensors, Engine, EX Board, Startup, Network, Diagnostics

### Proposed Page Layouts

#### General Page (merged Main + Dash Sel.)
```
+--[Connection]--------+--[Vehicle]----------+--[System]-----------+
| Connect  Disconnect  | Weight kg  [____]   | CAN Extender        |
| GPS Conn GPS Disconn | Odo        [____]   |   base addr [____]  |
| GPS Port [dropdown]  | Trip  [__] [Reset]  | Shiftlight CAN      |
| Serial   [status]    |                     |   base addr [____]  |
+--[ECU Config]--------+--[Data Logging]-----+--[Language]---------+
| ECU Sel  [dropdown]  | Logfile    [______] | [English dropdown]  |
|                      | [x] Data Logger     +--[Dashboard]--------+
+--[Units]-------------| [x] NMEA Logger     | Active Dash [1 v]   |
| Speed    [dropdown]  +--[GoPro]------------| Dash 1 [User Dash v]|
| Temp     [dropdown]  | Variant   [dropdown]+--[System]----------+
| Pressure [dropdown]  | Password  [______]  | V 1.99F             |
+----------------------| [x] GoPro rec      | [Quit][Reboot][Stop]|
                       +---------------------+---------------------+
```

#### Sensors Page (merged Sensehat + Analog)
```
+--[Sensehat Sensors]----------------------------------------------+
| Enable or disable individual sensors from the Raspberry Pi       |
| [icon] Accelerometer [x]    [icon] Gyro Sensor     [x]          |
| [icon] Compass       [x]    [icon] Pressure Sensor [x]          |
| [icon] Temperature   [x]                                        |
+--[Analog Inputs]--------------------------------------------------+
| Input    | Sensor Preset | Val@0V | Val@5V | Unit | Min V | MaxV |
| Analog 0 | [Custom v]    | [0]    | [5]    | [__] | [__]  | [__] |
| ...      |               |        |        |      |       |      |
| Analog10 | [Custom v]    | [0]    | [5]    | [__] | [__]  | [__] |
+-------------------------------------------------------------------+
```

#### Engine Page (merged Warn/Gear + Speed + RPM)
```
+--[RPM & Speed]------+--[Warning Thresholds]--+--[Gear Calculation]-+
| Max RPM    [10000]  | Coolant      [110]     | [x] Enable          |
| Speed Corr [100] %  | Boost        [0.9]     | Gear 1  [120]       |
| (100=no correction) | Knock        [80]      | Gear 2  [74]        |
| [x] USB VR Speed    | Lambda mult  [14.7]    | Gear 3  [54]        |
+--[Shift Light]------+                        | Gear 4  [37]        |
| [stg1][stg2]        +------------------------| Gear 5  [28]        |
| [stg3][stg4]        |                        | Gear 6  [__]        |
+---------------------+------------------------+---------------------+
```

### Polish Items Checklist

1. Fix "base adress" typo to "base address" on CAN Configuration section
2. Fix "Speed Correction % %" double percent - should be "Speed Correction (%)"
3. Standardize label formatting - remove all trailing colons (GPS Port: -> GPS Port)
4. Standardize input field widths for similar data types (all numeric inputs same width)
5. Add GroupBox wrapper to Analog inputs section with teal header
6. Remove "Max RPM" duplication - single source on Engine page
7. Standardize GroupBox padding/margins across all sections
8. Improve Serial Status indicator - use a proper status LED component
9. Add column headers to Gear ratio section
10. Ensure shift light stage cards have consistent widths
11. Center the Sensehat cards grid properly (handle odd item count)
12. Add help text consistently where inputs are non-obvious

### Memory Impact

This consolidation also helps with RPi memory optimization (Phase 2 from memory-optimization.md):
- Fewer tab pages = fewer QML components instantiated at startup
- Merged pages can share components and reduce total QObject count
- Using Loader for Sensehat section (only relevant on RPi hardware) saves memory on non-RPi builds
