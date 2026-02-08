# PowerTune Architecture Improvement Backlog

This document tracks architectural improvements identified during the initial codebase cleanup.
These items should be addressed incrementally as development continues.

---

## HIGH PRIORITY

### TODO-001: Split DashBoard God Object

**Status:** Not Started  
**Effort:** Large  
**File:** `Core/dashboard.h` (3,205 lines, 535 Q_PROPERTY declarations)

**Problem:**
The `DashBoard` class is a "God Object" anti-pattern - it contains all sensor data,
vehicle data, GPS data, analog inputs, digital inputs, electric motor data, etc.
This violates the Single Responsibility Principle and makes the code hard to maintain.

**Target Architecture:**
Split into domain-specific data models:
- `EngineData` - RPM, boost, temps, pressures, injector duty, ignition
- `VehicleData` - speed, gear, odometer, trip data
- `GPSData` - position, lap times, track data
- `AnalogInputs` - custom sensor channels (AN1-AN8)
- `DigitalInputs` - switch states (DI1-DI8)
- `ElectricMotorData` - EV-specific data (if needed)

**Implementation Steps:**
1. Create new header files for each domain model in `Core/`
2. Move relevant Q_PROPERTY declarations to appropriate models
3. Update `Connect` class to instantiate all models
4. Update QML bindings to use new model paths (e.g., `EngineData.revs`)
5. Update daemons to populate correct models

---

### TODO-002: Extract Base Gauge Component

**Status:** Not Started  
**Effort:** Medium  
**Location:** `Gauges/`

**Problem:**
All gauge components (RoundGauge, SquareGauge, BarGauge, etc.) duplicate common
properties and menu systems. Changes must be made in multiple places.

**Target:**
Create `BaseGauge.qml` with common properties:
```qml
// Common properties
property string mainvaluename
property string unit
property int decimalpoints
property real warnvaluehigh
property real warnvaluelow
property color textcolor
property color backgroundColor
// Common menu component
```

**Implementation Steps:**
1. Create `Gauges/BaseGauge.qml` with common properties
2. Extract common menu into `Gauges/GaugeMenu.qml`
3. Refactor `RoundGauge.qml` to extend BaseGauge (largest file, ~2400 lines)
4. Refactor remaining gauge types
5. Update factory JS files to use new component hierarchy

---

### TODO-003: Consolidate RPM Bar Variants

**Status:** Not Started  
**Effort:** Small  
**Files:** `Gauges/RPMBar.qml`, `RPMBarStyle1.qml`, `RPMBarStyle2.qml`, `RPMBarStyle3.qml`

**Problem:**
Four separate files for RPM bar with minor visual differences.

**Target:**
Single `RPMBar.qml` with a `style` property (1, 2, 3, or "default").

**Implementation Steps:**
1. Analyze differences between the four variants
2. Create unified component with style switching logic
3. Update `Userdash1/2/3.qml` to use style property
4. Remove redundant files

---

## MEDIUM PRIORITY

### TODO-004: Extract Brightness Controller

**Status:** Not Started  
**Effort:** Small  
**File:** `QML/main.qml` (lines ~600-680)

**Problem:**
`digitalLoop()` and `ddcutilDigitalLoop()` functions are nearly identical,
and brightness logic is scattered throughout main.qml.

**Target:**
Create `QML/BrightnessController.qml` singleton that handles:
- Platform detection (DDCUTIL vs standard)
- Brightness level management
- Digital input triggering

---

### TODO-005: Refactor Connect Class

**Status:** Not Started  
**Effort:** Medium  
**File:** `Core/connect.h/cpp`

**Problem:**
`Connect` class has too many responsibilities:
- ECU connection management
- System commands (shutdown, reboot)
- Daemon management
- License validation
- File I/O for dashboards

**Target:**
Extract into focused classes:
- `SystemManager` - shutdown, reboot, daemon control
- `LicenseManager` - license validation
- `DashboardFileManager` - dashboard file I/O
- `Connect` - only ECU connection logic

---

### TODO-006: Split Settings/main.qml

**Status:** Not Started  
**Effort:** Medium  
**File:** `Settings/main.qml` (1,180 lines)

**Problem:**
Monolithic settings file with all configuration options.

**Target:**
Split into focused components:
- `Settings/ConnectionSettings.qml` - ECU selection, ports
- `Settings/DisplaySettings.qml` - brightness, themes
- `Settings/GPSSettings.qml` - GPS configuration
- `Settings/UnitSettings.qml` - metric/imperial
- `Settings/main.qml` - TabView container only

---

### TODO-007: Replace Magic Numbers

**Status:** Not Started  
**Effort:** Small  
**Location:** Throughout codebase

**Problem:**
Hardcoded values like brightness levels (25, 175, 235, 250),
screen breakpoints (800, 1600), timer intervals.

**Target:**
Create `QML/Constants.qml` singleton:
```qml
pragma Singleton

QtObject {
    // Brightness
    readonly property int brightnessMin: 25
    readonly property int brightnessDefault: 175
    readonly property int brightnessMax: 250
    
    // Screen breakpoints
    readonly property int screenSmall: 800
    readonly property int screenLarge: 1600
    
    // Timers
    readonly property int bootDelay: 1200
}
```

---

## LOW PRIORITY

### TODO-008: Daemon Registry System

**Status:** Not Started  
**Effort:** Medium  
**Location:** `Scripts/updatedaemons.sh`, `Settings/startup.qml`

**Problem:**
Daemon list is manually maintained in multiple places.
Adding a new daemon requires editing several files.

**Target:**
Create `daemons/daemons.json` registry:
```json
{
  "daemons": [
    {
      "id": "haltech_v2",
      "name": "Haltech V2",
      "binary": "HaltechV2",
      "category": "aftermarket",
      "canbus": true
    }
  ]
}
```
Auto-generate UI from registry.

---

### TODO-009: Add Unit Tests

**Status:** Not Started  
**Effort:** Large (ongoing)  
**Location:** New `tests/` directory

**Problem:**
No automated test coverage. Changes are risky.

**Target:**
Add Qt Test framework tests for:
- Core calculations (`Utils/Calculations.cpp`)
- ECU protocol parsing (`ECU/Apexi.cpp`, etc.)
- Data logger functionality
- SHCalc temperature calculations

---

### TODO-010: Standardize Error Handling

**Status:** Not Started  
**Effort:** Medium  
**Location:** Throughout codebase

**Problem:**
Inconsistent error handling. Some errors silently fail,
others crash. No consistent logging.

**Target:**
- Create `Utils/Logger.h` for consistent logging
- Add error codes/enums for common failures
- User-facing error messages in QML
- Crash reporting (optional)

---

## Notes

- Items should be tackled in priority order when time allows
- Each TODO should be a separate branch/PR
- Test thoroughly on target hardware after each change
- Update this document as items are completed or new issues found
