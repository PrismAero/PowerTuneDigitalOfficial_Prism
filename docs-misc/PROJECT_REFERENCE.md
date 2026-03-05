# PowerTune Digital Dashboard -- Project Reference

Version: 2026-03-04
Maintainer: Kai Wyborny

This document provides a complete technical reference for the PowerTune Digital
Dashboard application. It is intended as the single source of truth for any
developer or AI agent joining the project. It covers architecture, data flow,
build system, deployment, file locations, and cross-check rules.

---

## Table of Contents

1. [Project Identity](#1-project-identity)
2. [High-Level Architecture](#2-high-level-architecture)
3. [Directory Structure](#3-directory-structure)
4. [Build System](#4-build-system)
5. [Application Bootstrap](#5-application-bootstrap)
6. [QML Module Structure](#6-qml-module-structure)
7. [C++ Backend Classes](#7-c-backend-classes)
8. [Data Models](#8-data-models)
9. [Data Flow: CAN Bus to QML Gauges](#9-data-flow-can-bus-to-qml-gauges)
10. [Settings and Persistence](#10-settings-and-persistence)
11. [Gauge System and Dashboard Architecture](#11-gauge-system-and-dashboard-architecture)
12. [Extender Board (CAN Expansion)](#12-extender-board-can-expansion)
13. [Sensor System](#13-sensor-system)
14. [Diagnostics System](#14-diagnostics-system)
15. [Settings UI Structure](#15-settings-ui-structure)
16. [Deployment and Target Device](#16-deployment-and-target-device)
17. [Resource Locations](#17-resource-locations)
18. [Legacy and Dead Code](#18-legacy-and-dead-code)
19. [Cross-Check Rules](#19-cross-check-rules)
20. [Known Issues](#20-known-issues)
21. [Onboarding Checklist](#21-onboarding-checklist)

---

## 1. Project Identity

| Field             | Value                                                 |
|-------------------|-------------------------------------------------------|
| Name              | PowerTuneQMLGui                                       |
| Description       | Automotive digital dashboard for ECU monitoring        |
| Primary Language  | C++17 / QML (Qt Quick)                                |
| Qt Version (dev)  | Qt 6.x (CMake build)                                  |
| Qt Version (device)| Qt 5.15.7 (qmake build on Yocto)                    |
| Target Hardware   | Raspberry Pi 4 (ARMv7, 32-bit Poky/Yocto)            |
| Display           | EGLFS (no X11), touchscreen, 800x480 or 1024x600     |
| Repository        | PowerTuneDigitalOfficial/Prism                        |
| Git Branch Model  | main -> release/* -> staging -> dev -> feature/*, bug/*|

---

## 2. High-Level Architecture

```
+----------------------------+     UDP (port 45454)     +-----------------+
|   External ECU Daemon      | -----------------------> |  PowerTuneQMLGui |
|   (e.g. Generic, Haltechd) |   "ident,value" packets  |                 |
+----------------------------+                           |  +----------+  |
                                                         |  |UDPReceiver|  |
+----------------------------+     SocketCAN (can0)      |  +----+-----+  |
|   CAN Extender Board       | -----------------------> |       |         |
|   (MCP2515 via SPI)        |   CAN frames             |  +----v-----+  |
+----------------------------+                           |  | Extender |  |
                                                         |  +----+-----+  |
                                                         |       |         |
                                                         |  +----v-----------+
                                                         |  | Domain Models   |
                                                         |  | (EngineData,    |
                                                         |  |  VehicleData,   |
                                                         |  |  Expander, ...) |
                                                         |  +----+-----------+
                                                         |       |           |
                                                         |       | Q_PROPERTY
                                                         |       | bindings  |
                                                         |  +----v-----------+
                                                         |  | QML UI          |
                                                         |  | (Gauges,        |
                                                         |  |  Settings,      |
                                                         |  |  Dashboards)    |
                                                         |  +----------------+
                                                         +-----------------+
```

The application has two data ingest paths:

1. **UDP path**: External ECU daemons read CAN data and send parsed telemetry
   as UDP packets (port 45454) in the format `"ident,value"`. The `UDPReceiver`
   class routes each identifier to the correct domain model setter via a large
   `switch(ident)` block (~1000 cases).

2. **CAN path**: The `Extender` class reads raw CAN frames from the Extender
   board hardware via SocketCAN and writes directly into `ExpanderBoardData`
   and `DigitalInputs` models.

Both paths populate QObject-based domain models with `Q_PROPERTY` declarations.
QML binds to these properties reactively via `setContextProperty()`.

---

## 3. Directory Structure

```
PowerTuneDigitalOfficial_Prism/
|-- main.cpp                    # Application entry point
|-- CMakeLists.txt              # Primary build system (Qt6)
|-- qml.qrc                    # Non-module QML resources (graphics, fonts, tracks)
|-- deployment.pri             # Install target: /opt/PowerTune/
|
|-- Core/                       # Central C++ backend
|   |-- connect.cpp/.h          # Main orchestrator (creates all objects, registers with QML)
|   |-- dashboard.cpp/.h        # Legacy coordination shell (mostly empty now)
|   |-- appsettings.cpp/.h      # QSettings read/write for app configuration
|   |-- PropertyRouter.cpp/.h   # Dynamic property access router for gauges
|   |-- SensorRegistry.cpp/.h   # Runtime sensor availability tracker
|   |-- DiagnosticsProvider.cpp/.h  # System health and CAN status
|   |-- serialport.cpp/.h       # Serial port utility (legacy, not in CMake)
|   |-- Models/                 # Domain data model classes (all QObject-based)
|       |-- DataModels.h        # Convenience header including all models
|       |-- EngineData.h/.cpp   # Engine metrics (~170 Q_PROPERTY declarations)
|       |-- VehicleData.h/.cpp  # Vehicle speed, gear, odometer, etc.
|       |-- ExpanderBoardData.h/.cpp  # EX Analog 0-7 raw + calc
|       |-- DigitalInputs.h/.cpp     # Digital inputs 1-8 + EX Digital 1-8
|       |-- AnalogInputs.h/.cpp      # ECU-reported analog channels 0-10
|       |-- GPSData.h/.cpp           # GPS coordinates, speed, altitude
|       |-- FlagsData.h/.cpp         # ECU status flags
|       |-- ElectricMotorData.h/.cpp # EV motor metrics
|       |-- TimingData.h/.cpp        # Timing advance data
|       |-- SensorData.h/.cpp        # SenseHat sensors
|       |-- ConnectionData.h/.cpp    # Connection status flags
|       |-- SettingsData.h/.cpp      # Runtime settings state
|       |-- UIState.h/.cpp           # UI mode, current page, brightness
|
|-- Hardware/
|   |-- Extender.cpp/.h         # CAN Extender board communication
|   |-- gps.cpp/.h              # GPS serial/NMEA (legacy, not in CMake)
|   |-- gopro.cpp/.h            # GoPro integration (legacy)
|   |-- sensors.cpp/.h          # SenseHat sensors (legacy)
|
|-- Utils/
|   |-- UDPReceiver.cpp/.h      # UDP socket listener, parses daemon packets
|   |-- Calculations.cpp/.h     # Derived computations (boost, fuel economy)
|   |-- CalibrationHelper.cpp/.h # Linear calibration (0V/5V mapping)
|   |-- SteinhartCalculator.cpp/.h # NTC thermistor calibration
|   |-- SignalSmoother.cpp/.h   # Signal damping/smoothing
|   |-- DataLogger.cpp/.h       # CSV data logging
|   |-- downloadmanager.cpp/.h  # HTTP downloads (firmware updates)
|   |-- ParseGithubData.cpp/.h  # GitHub release parsing
|   |-- wifiscanner.cpp/.h      # WiFi network scanner
|   |-- shcalc.cpp/.h           # Steinhart-Hart coefficient solver
|   |-- textprogressbar.cpp/.h  # Console progress bar
|   |-- iomapdata.cpp/.h        # IO map parsing (legacy, not in CMake)
|   |-- Speedo.cpp/.h           # Speed calculations (legacy, not in CMake)
|
|-- ECU/                        # ECU protocol implementations (legacy, not in CMake)
|   |-- AdaptronicSelect.cpp/.h
|   |-- Apexi.cpp/.h
|   |-- arduino.cpp/.h
|   |-- obd.cpp/.h
|
|-- PowerTune/                  # QML source organized by module
|   |-- Core/                   # PowerTune.Core QML module
|   |   |-- Main.qml            # Root window, SwipeView, dashboard loader
|   |   |-- SerialSettings.qml  # Settings tab bar + StackLayout
|   |   |-- ExBoardAnalog.qml   # Extender board calibration page
|   |   |-- Intro.qml           # Splash/intro screen
|   |   |-- BrightnessPopUp.qml # Brightness control popup
|   |   |-- AnalogInputs.qml    # ECU analog input display
|   |   |-- ConsultRegs.qml     # Nissan Consult registers
|   |   |-- OBDPIDS.qml         # OBD-II PID display
|   |   |-- Laptimecontainer.qml # Lap timer container
|   |
|   |-- Gauges/                 # PowerTune.Gauges QML module
|   |   |-- Userdash1.qml       # User dashboard 1 (editable)
|   |   |-- Userdash2.qml       # User dashboard 2 (editable)
|   |   |-- Userdash3.qml       # User dashboard 3 (editable)
|   |   |-- RoundGauge.qml      # Circular analog gauge
|   |   |-- SquareGauge.qml     # Rectangular gauge
|   |   |-- VerticalBarGauge.qml # Vertical bar gauge
|   |   |-- MyTextLabel.qml     # Text/numeric display
|   |   |-- StatePicture.qml    # State-driven image
|   |   |-- StateGIF.qml        # Animated state indicator
|   |   |-- Picture.qml         # Static image/logo
|   |   |-- RPMBar.qml          # Horizontal RPM bar
|   |   |-- DatasourcesList.qml # Sensor selection list (legacy, ~400 entries)
|   |   |-- Datasources.qml     # Sensor metadata definitions
|   |   |-- Warning.qml         # Warning popup logic
|   |   |-- WarningLoader.qml   # Warning trigger loader
|   |   |-- ShiftLights.qml     # RPM shift light indicators
|   |   |-- CircularGauge.qml   # Qt6 circular gauge base
|   |   |-- create*.js          # Factory scripts for gauge instantiation
|   |   |-- (35+ more gauge and style files)
|   |
|   |-- Settings/               # PowerTune.Settings QML module
|   |   |-- MainSettings.qml    # ECU, CAN, connection, startup config
|   |   |-- VehicleRPMSettings.qml # Combined speed/gear/RPM/warning settings
|   |   |-- NetworkSettings.qml # WiFi, network config
|   |   |-- DiagnosticsSettings.qml # System health, CAN status, sensor data
|   |   |-- DashSelector.qml    # Dashboard selection/management
|   |   |-- DashSelectorWidget.qml # Dashboard dropdown widget
|   |   |-- CanMonitor.qml      # Raw CAN frame monitor
|   |   |-- AnalogSettings.qml  # Analog input calibration
|   |   |-- HelpPage.qml        # QR codes and contact info
|   |   |-- components/         # Shared styled components
|   |       |-- StyledButton.qml
|   |       |-- StyledComboBox.qml
|   |       |-- StyledTextField.qml
|   |       |-- StyledSwitch.qml
|   |       |-- StyledCheckBox.qml
|   |       |-- SettingsSection.qml
|   |       |-- SettingsRow.qml
|   |       |-- SettingsPage.qml
|   |       |-- ConnectionStatusIndicator.qml
|   |
|   |-- Utils/                  # PowerTune.Utils QML module
|       |-- Translator.qml      # Internationalization singleton
|       |-- MaterialIcon.qml    # Material Design icon component
|       |-- Translator.js       # Translation lookup script
|
|-- Prism/
|   |-- Keyboard/               # Prism.Keyboard QML module
|       |-- PrismKeyboard.qml   # On-screen keyboard
|       |-- QwertyLayout.qml    # QWERTY key layout
|       |-- NumericPad.qml      # Numeric keypad
|       |-- KeyButton.qml       # Individual key button
|
|-- Resources/                  # Static assets
|   |-- graphics/               # PNG/SVG gauge graphics, LEDs, backgrounds
|   |-- fonts/                  # MaterialSymbolsOutlined.ttf
|   |-- Logo/                   # Logo images
|   |-- Sounds/                 # Audio files
|   |-- KTracks/                # GPS track coordinate files by country
|   |-- exampleDash/            # Example dashboard configs + logos
|
|-- Scripts/                    # Build and deployment scripts
|   |-- build-macos.sh          # Local macOS CMake build
|   |-- run-macos.sh            # Run on macOS (builds if needed)
|   |-- updatePowerTune.sh      # On-device build and install
|   |-- updatedaemons.sh        # Daemon update on Yocto
|   |-- updatepi4.sh            # Pi 4 system setup
|   |-- updateUserDashboards.sh # Sync example dashboards to device
|
|-- CAN_Configs/                # CAN configuration files (LINK ECU, etc.)
|-- daemons/                    # Daemon binaries (not committed)
|-- GPSTracks/                  # Lap timer QML + track data
|-- Documents/                  # Project documentation
|-- docs/                       # Technical docs
|   |-- device-audit/           # Device configuration audit
|   |-- boot-splash-video-spec.md
|   |-- settings-ui-consolidation.md
|-- reference_sourcecode/       # Old Qt5 reference (gitignored)
|-- device-backup/              # Device backup files (gitignored)
```

---

## 4. Build System

### 4.1 CMake (Primary, Qt6)

**File**: `CMakeLists.txt`

- Project: PowerTuneQMLGui, version 1.0.0, C++17
- Qt modules: Core, Gui, Qml, Quick, QuickControls2, Network, SerialBus
- Qt6-only: Core5Compat (for GraphicalEffects)
- Optional: ddcutil (DDC/CI brightness, Linux only)
- Generates 5 QML modules as static libraries linked to the main executable
- `RESOURCE_PREFIX /qt/qml` for all QML modules
- `CMAKE_EXPORT_COMPILE_COMMANDS ON` for clangd

**macOS local build**:
```
Scripts/build-macos.sh    # Output: build/macos-dev/PowerTuneQMLGui.app
Scripts/run-macos.sh      # Build + run
```

### 4.2 qmake (Legacy, Qt5 device builds)

**File**: `PowertuneQMLGui.pro`

- Still used by `updatePowerTune.sh` for on-device Yocto builds
- Uses `qml.qrc` for resources
- Missing newer source files (PropertyRouter, SensorRegistry, DiagnosticsProvider, etc.)
- `deployment.pri` sets install target to `/opt/PowerTune/`
- C++11 standard (vs C++17 in CMake)

**On-device build** (via `updatePowerTune.sh`):
```
ssh root@<device>
cd /home/pi/src && git pull
qmake && make -j4
make install  # -> /opt/PowerTune/
```

### 4.3 Adding New Files

When adding a new C++ source file:
1. Add `.cpp` and `.h` to `SOURCES` in `CMakeLists.txt`
2. Add to `PowertuneQMLGui.pro` SOURCES/HEADERS (if maintaining qmake compat)

When adding a new QML file:
1. Add to the appropriate `qt_add_qml_module(QML_FILES ...)` in `CMakeLists.txt`
2. The `qmldir` file is auto-generated by CMake

When adding a new JS file to Gauges:
1. Add to `RESOURCES` in the `PowerTuneGaugesLib` module block

---

## 5. Application Bootstrap

**File**: `main.cpp`

Sequence:
1. Set `QT_QUICK_CONTROLS_STYLE=Basic`
2. Create `QGuiApplication`
3. Set org: `Power-Tune`, domain: `power-tune.org`, app: `PowerTune`
4. Create `QQmlApplicationEngine`
5. Add import path: `qrc:/qt/qml`
6. Register C++ types:
   - `DownloadManager` as `DLM 1.0`
   - `Connect` as `com.powertune.ConnectObject 1.0`
7. Set initial context properties: `DLM`, `Connect`, `Extender2`, `HAVE_DDCUTIL`
8. Load: `qrc:/qt/qml/PowerTune/Core/PowerTune/Core/Main.qml`
9. `app.exec()`

The doubled path `PowerTune/Core/PowerTune/Core/` is an artifact of
`qt_add_qml_module` with `RESOURCE_PREFIX /qt/qml` and `OUTPUT_DIRECTORY`.

---

## 6. QML Module Structure

### 6.1 Modules

| Module URI        | Library Target         | Key Files                              |
|-------------------|------------------------|----------------------------------------|
| PowerTune.Utils   | PowerTuneUtilsLib      | Translator.qml (singleton), MaterialIcon.qml |
| PowerTune.Core    | PowerTuneCoreLib       | Main.qml, SerialSettings.qml, ExBoardAnalog.qml |
| PowerTune.Settings| PowerTuneSettingsLib   | MainSettings.qml, DiagnosticsSettings.qml, components/* |
| PowerTune.Gauges  | PowerTuneGaugesLib     | Userdash1-3, RoundGauge, SquareGauge, create*.js |
| Prism.Keyboard    | PrismKeyboardLib       | PrismKeyboard.qml, NumericPad.qml |

### 6.2 Module Dependencies

```
                com.powertune (C++ registered types)
                         |
                         v
    PowerTune.Core <-- PowerTune.Utils
         |                ^
         |                |
         v                |
    PowerTune.Settings ---+
         |
         v (via Loader)
    PowerTune.Gauges ---- PowerTune.Utils

    Prism.Keyboard (used by Core)
```

Core imports Settings and Utils. Settings imports Utils. Gauges imports Utils.
Settings loads Gauges dashboards via `Loader.source` with `qrc:` paths.
No explicit `DEPENDENCIES` in CMake; all modules are linked at build time.

### 6.3 QML Resource Paths

QML files are loaded from:
- `qrc:/qt/qml/PowerTune/Core/PowerTune/Core/<file>.qml`
- `qrc:/qt/qml/PowerTune/Gauges/PowerTune/Gauges/<file>.qml`
- `qrc:/qt/qml/PowerTune/Settings/PowerTune/Settings/<file>.qml`

Static resources (graphics, fonts, tracks) are in `qml.qrc` under prefix `/`:
- `qrc:/Resources/graphics/<file>.png`
- `qrc:/Resources/fonts/MaterialSymbolsOutlined.ttf`
- `qrc:/Resources/KTracks/<country>/<track>.txt`

### 6.4 QML Files NOT in Any Module

These exist on disk but are not in `CMakeLists.txt` QML_FILES:
- `PowerTune/Gauges/Camera.qml` (GoPro camera)
- `PowerTune/Gauges/Charts.qml` (data charting)
- `PowerTune/Gauges/ConsultTest.qml` (Consult debug)
- `PowerTune/Gauges/Dyno.qml` (dyno mode)
- `PowerTune/Gauges/GPS.qml` (GPS map view)
- `PowerTune/Gauges/Mediaplayer.qml` (media playback)
- `PowerTune/Gauges/PFCSensors.qml` (PowerFC sensors)
- `PowerTune/Gauges/SensorTest.qml` (sensor testing)
- `PowerTune/Gauges/VirtualDyno.qml` (virtual dyno)

These are legacy or optional features that may still be listed in `qmldir` but
are not compiled into the Qt6 CMake build.

---

## 7. C++ Backend Classes

### 7.1 Connect (Core/connect.h)

The central orchestrator. Created once in `main.cpp`. Responsibilities:
- Creates ALL domain models and utility objects
- Registers everything with `QQmlApplicationEngine` via `setContextProperty()`
- Manages connection lifecycle: `openConnection()`, `closeConnection()`
- System actions: `reboot()`, `shutdown()`, `restartDaemon()`, `update()`

**Object creation order** (constructor, lines ~63-239):
1. DashBoard, UIState
2. Domain models: EngineData, VehicleData, GPSData, AnalogInputs, DigitalInputs,
   ExpanderBoardData, ElectricMotorData, FlagsData, TimingData, SensorData,
   ConnectionData, SettingsData
3. AppSettings
4. PropertyRouter (receives pointers to all models)
5. UDPReceiver (receives pointers to all models)
6. DataLogger, Calculations, WifiScanner
7. Extender (CAN hardware)
8. SteinhartCalculator, CalibrationHelper, SensorRegistry, DiagnosticsProvider
9. QFileSystemModel instances

**QML context property names** (the names QML uses to access C++ objects):

| QML Name         | C++ Class                | Description                          |
|------------------|--------------------------|--------------------------------------|
| Dashboard        | DashBoard                | Legacy coordination shell            |
| UI               | UIState                  | UI mode, page, brightness            |
| Engine           | EngineData               | ~170 engine properties               |
| Vehicle          | VehicleData              | Speed, gear, odometer                |
| GPS              | GPSData                  | Position, altitude, satellites       |
| Analog           | AnalogInputs             | ECU analog channels 0-10             |
| Digital          | DigitalInputs            | Digital inputs + EX digital 1-8      |
| Expander         | ExpanderBoardData        | EX analog raw/calc 0-7               |
| Motor            | ElectricMotorData        | EV motor metrics                     |
| Flags            | FlagsData                | ECU status flags                     |
| Timing           | TimingData               | Timing advance data                  |
| Sensor           | SensorData               | SenseHat sensors                     |
| Connection       | ConnectionData           | Connection status                    |
| Settings         | SettingsData             | Runtime settings                     |
| PropertyRouter   | PropertyRouter           | Dynamic property lookup              |
| Extender2        | Extender                 | CAN hardware interface               |
| AppSettings      | AppSettings              | QSettings read/write                 |
| Logger           | DataLogger               | CSV logging                          |
| Calculations     | Calculations             | Derived values                       |
| Calibration      | CalibrationHelper        | Linear calibration                   |
| Steinhart        | SteinhartCalculator      | NTC thermistor calibration           |
| SensorRegistry   | SensorRegistry           | Runtime sensor availability          |
| Diagnostics      | DiagnosticsProvider      | System diagnostics                   |
| Wifiscanner      | WifiScanner              | WiFi network scanning                |
| Dirmodel         | QFileSystemModel         | File browser (directories)           |
| Filemodel        | QFileSystemModel         | File browser (files)                 |
| DLM              | DownloadManager          | HTTP downloads                       |
| Connect          | Connect                  | Main orchestrator                    |

### 7.2 PropertyRouter (Core/PropertyRouter.h)

Routes dynamic property access to the correct domain model. This exists because
gauges historically used `Dashboard[propertyName]` for dynamic sensor binding.
Now gauges should use `PropertyRouter.getValue("rpm")` instead.

Key methods:
- `Q_INVOKABLE QVariant getValue(const QString &propertyName)` -- primary lookup
- `Q_INVOKABLE QString getModelName(const QString &propertyName)` -- find owner model
- `Q_INVOKABLE bool hasProperty(const QString &propertyName)` -- existence check

Internally maintains `QHash<QString, ModelType> m_propertyModelMap` populated by
`initializePropertyMappings()` which maps every known property name to its model.

### 7.3 AppSettings (Core/appsettings.h)

Wraps `QSettings("PowerTuneQML", "PowerTuneDash")` for persistent app config.

Key methods:
- `setValue(key, value)` -- write to QSettings
- `getValue(key)` -- read from QSettings
- `readandApplySettings()` -- load all settings into domain models on startup

Settings file on device: `/home/root/.config/PowerTuneQML/PowerTuneDash.conf`

Key settings keys: `Max RPM`, `Shift Light1-4`, `waterwarn`, `boostwarn`,
`rpmwarn`, `valgear1-6`, `Cylinders`, `ExternalSpeed`, `ExternalRPM`,
`DI1RPMEnabled`, `RPMFrequencyDivider`, `Speedcorrection`, `Pulsespermile`,
`DaemonLicenseKey`, `Country`, `Track`, `Brightness`

---

## 8. Data Models

All data models follow the same pattern:
- Inherit from `QObject`
- Declare properties with `Q_PROPERTY(type name READ getter WRITE setter NOTIFY signal)`
- All properties default to 0
- Setters emit change signals for QML reactive binding
- Created in `Connect` constructor, registered via `setContextProperty()`

### 8.1 Model Reference

| Model              | QML Name   | Property Count | Key Properties                     |
|--------------------|------------|----------------|------------------------------------|
| EngineData         | Engine     | ~170           | rpm, Intakepress, MAP, TPS, BatteryV, Watertemp, egt1-12, AFR, InjDuty, Ign, Knock, Power, Torque |
| VehicleData        | Vehicle    | ~25            | speed, Gear, Odo, WheelSpeedFL/FR/RL/RR, lateralg, drag, altitude |
| ExpanderBoardData  | Expander   | 16             | EXAnalogInput0-7 (raw V), EXAnalogCalc0-7 (calibrated) |
| DigitalInputs      | Digital    | 16             | DigitalInput1-7 (ECU), EXDigitalInput1-8 (Extender) |
| AnalogInputs       | Analog     | 22             | Analog0-10 (raw V), AnalogCalc0-10 (calibrated) |
| GPSData            | GPS        | ~15            | gpsLatitude, gpsLongitude, gpsSpeed, gpsAltitude, gpsSatellites |
| FlagsData          | Flags      | ~20            | Flag1-12 (ECU status bits)         |
| ElectricMotorData  | Motor      | ~20            | motorRPM, motorTemp, batterySOC, motorTorque |
| TimingData         | Timing     | ~8             | timing advance, base timing        |
| SensorData         | Sensor     | ~12            | SenseHat: accelX/Y/Z, gyroX/Y/Z, compassX/Y/Z, ambientTemp, ambientPress |
| ConnectionData     | Connection | ~8             | connected, serialConnected, port, baudRate |
| SettingsData       | Settings   | ~15            | Runtime setting values             |
| UIState            | UI         | ~10            | currentPage, editMode, brightness, fullscreen |

### 8.2 Convenience Header

`Core/Models/DataModels.h` includes all model headers. Use this when you need
access to multiple models from a single translation unit.

---

## 9. Data Flow: CAN Bus to QML Gauges

### 9.1 UDP Path (Primary)

```
ECU -> External Daemon -> UDP packet "ident,value" (port 45454)
                              |
                              v
                 UDPReceiver::processPendingDatagrams()
                  (Utils/UDPReceiver.cpp, lines 85-1100)
                              |
                   switch(ident) routes to model:
                     179 -> m_engine->setrpm(Value)
                     199 -> m_vehicle->setSpeed(Value)
                     908-915 -> m_expander->setEXAnalogInput0-7(Value/1000)
                     ... (~1000 cases total)
                              |
                              v
                   EngineData::setrpm(qreal rpm)
                   {  m_rpm = rpm; emit rpmChanged(rpm);  }
                              |
                              v
                   QML binding: Engine.rpm -> gauge updates
```

**The `ident` values are protocol-specific.** Each daemon translates its ECU
protocol into these standard identifiers. The Generic daemon handles standard
CAN frames.

### 9.2 CAN Path (Extender Board)

```
Extender Board -> CAN frames on can0
                        |
                        v
              Extender::readyToRead()
              (Hardware/Extender.cpp, lines 250-320)
                        |
              Decodes CAN payload by frame ID:
                adress2 -> EXAnalogInput0-3
                adress3 -> EXAnalogInput4-7
                adress4 -> EXDigitalInput1-8
                        |
                        v
              ExpanderBoardData / DigitalInputs updated
                        |
                        v
              QML binding: Expander.EXAnalogInput0 -> gauge
```

### 9.3 How QML Binds to Data

**Direct binding** (explicit model reference in QML):
```qml
Text { text: Engine.rpm.toFixed(0) }
```

**Dynamic binding via PropertyRouter** (used by configurable gauges):
```qml
property string datasource: "rpm"
Text { text: PropertyRouter.getValue(datasource).toFixed(0) }
```

**Legacy pattern** (deprecated, still exists in some gauges):
```qml
Text { text: Dashboard[datasource] }
```

The migration from `Dashboard[x]` to `PropertyRouter.getValue(x)` is an
ongoing refactoring effort (Phase 2b in the gauge system overhaul plan).

---

## 10. Settings and Persistence

### 10.1 C++ QSettings (AppSettings)

- Backend: `QSettings("PowerTuneQML", "PowerTuneDash")`
- File: `/home/root/.config/PowerTuneQML/PowerTuneDash.conf` (INI format)
- Used for: RPM limits, warning thresholds, gear ratios, speed correction,
  daemon license key, startup behavior, input configuration
- Loaded at startup by `AppSettings::readandApplySettings()`
- Written by `AppSettings::setValue()` when user changes settings

### 10.2 QML Qt.labs.settings

- Backend: `QSettings` using `QCoreApplication` org/app name
- File: `/home/root/.config/Power-Tune/PowerTune.conf`
- Used for: QML-side persistent state (selected tabs, dashboard positions,
  gauge configurations, toggle states)
- Each `Settings {}` block in QML can use a `category` to scope keys
- These two config files are DIFFERENT -- `AppSettings` writes to
  `PowerTuneQML/PowerTuneDash.conf`, while `Qt.labs.settings` writes to
  `Power-Tune/PowerTune.conf` (based on org name set in `main.cpp`)

### 10.3 Dashboard Configs

User dashboard layouts (gauge positions, sizes, sensor bindings) are persisted
via `Qt.labs.settings` within each `Userdash*.qml` file using the `Settings`
component with unique categories per gauge instance.

Example dashboard config files on device:
- `/home/pi/UserDashboards/` -- exported/imported dashboard configs
- `/home/pi/Logo/` -- custom logo images for dashboards

---

## 11. Gauge System and Dashboard Architecture

### 11.1 Gauge Types

| Gauge Component      | File                          | Purpose                      |
|----------------------|-------------------------------|------------------------------|
| RoundGauge           | PowerTune/Gauges/RoundGauge.qml | Circular analog gauge       |
| SquareGauge          | PowerTune/Gauges/SquareGauge.qml | Rectangular numeric gauge  |
| VerticalBarGauge     | PowerTune/Gauges/VerticalBarGauge.qml | Vertical bar       |
| MyTextLabel          | PowerTune/Gauges/MyTextLabel.qml | Text/numeric readout      |
| StatePicture         | PowerTune/Gauges/StatePicture.qml | State-driven image       |
| StateGIF             | PowerTune/Gauges/StateGIF.qml | Animated state indicator     |
| Picture              | PowerTune/Gauges/Picture.qml  | Static image/logo            |
| RPMBar               | PowerTune/Gauges/RPMBar.qml   | Horizontal RPM bar           |
| CircularGauge        | PowerTune/Gauges/CircularGauge.qml | Qt6 circular base       |
| ShiftLights          | PowerTune/Gauges/ShiftLights.qml | RPM shift indicators      |
| BarGauge             | PowerTune/Gauges/BarGauge.qml | General bar gauge            |

### 11.2 Gauge Creation Flow

Each gauge type has a corresponding JavaScript factory file:
- `createRoundGauge.js`
- `createsquaregaugeUserDash.js`
- `createText.js`
- `createverticalbargauge.js`
- `createPicture.js`
- `createStatePicture.js`
- `createStateGIF.js`
- `createMaindash.js`

These are imported by `Userdash*.qml` and called when the user adds a gauge
in edit mode. Each script uses `Qt.createComponent()` + `createObject()` to
instantiate gauges dynamically onto the dashboard canvas.

### 11.3 Dashboard Edit Mode

Currently, each `Userdash*.qml` contains:
- A canvas `Item` that holds gauge instances
- A hidden `squaregaugemenu` triggered by double-tap
- Edit mode toggled by finding the hidden menu area
- Gauges are draggable in edit mode
- Configuration menus are per-gauge (bespoke popups)

### 11.4 Sensor Selection (DatasourcesList)

`DatasourcesList.qml` contains a static `ListModel` with ~400 entries mapping
display names to property keys. This is used by gauge configuration menus to
let users pick which sensor a gauge displays.

Each entry has: `titlename`, `sourcename` (property key), `symbol` (unit),
`maxvalue`, `decimalpoints`.

This is being replaced by `SensorRegistry` + `SensorListModel` (see Section 13).

---

## 12. Extender Board (CAN Expansion)

### 12.1 Hardware

The CAN Extender Board connects via CAN bus (MCP2515 on the Pi via SPI) and
provides:
- **8 Analog inputs** (0-5V range): EXAnalogInput0-7
  - Channels 0-5 support non-linear NTC temperature sensors
  - All 8 support linear voltage sensors
  - Each broadcasts raw voltage and calibrated value
- **8 Digital inputs** (3.5V-12V threshold): EXDigitalInput1-8
  - Positively switched only (not ground-switched)
  - EXDigitalInput1 can be configured as tachometer/RPM input

### 12.2 CAN Frame Structure

The Extender uses 3 CAN frame IDs (configurable base address):
- `base + 0` (adress2): Analog channels 0-3 (4x uint16, *0.001 for voltage)
- `base + 1` (adress3): Analog channels 4-7 (4x uint16, *0.001 for voltage)
- `base + 2` (adress4): Digital inputs 1-8 (8x uint8, 0=OFF, 1=ON)

RPM from CAN uses a separate base address (`RPMCANBaseID`).

### 12.3 Calibration

**Linear calibration** (`CalibrationHelper`):
- Maps 0V and 5V to user-defined values (e.g., 0V=0psi, 5V=100psi)
- Formula: `calibrated = val0v + (raw_voltage / 5.0) * (val5v - val0v)`

**NTC thermistor calibration** (`SteinhartCalculator`):
- Uses Steinhart-Hart equation with 3 resistance/temperature reference points
- Only for EX Analog channels 0-5

### 12.4 RPM from Digital Input

When `DI1RPMEnabled` is true, EXDigitalInput1 acts as a tachometer input.
The `RPMFrequencyDivider` setting configures the pulses-per-revolution ratio
(depends on cylinder count and ignition type).

---

## 13. Sensor System

### 13.1 SensorRegistry (Core/SensorRegistry.h)

Runtime registry tracking which sensors are actually available. Sensors come from:
- ECU data via daemon UDP (`SensorSource::DaemonUDP`)
- Extender board analog (`SensorSource::ExtenderAnalog`)
- Extender board digital (`SensorSource::ExtenderDigital`)
- GPS hardware (`SensorSource::GPS`)
- SenseHat sensors (`SensorSource::SenseHat`)
- Computed values (`SensorSource::Computed`)

Each sensor entry contains: `key`, `displayName`, `category`, `unit`, `source`,
`active` (bool), `lastActiveTimestamp`.

CAN sensors start as `active=false` and become active when data arrives
(`markCanSensorActive()`). A 10-second timeout timer marks them inactive again.

### 13.2 Sensor Categories

Sensors are grouped into categories for filtering:
- Engine, Boost/Turbo, Temperatures, Pressures, Fuel System, Injectors,
  Ignition, O2/Lambda/AFR, Knock, EGT, Analog Inputs, Digital Inputs,
  Extender Analog, Extender Digital, GPS, Vehicle, Traction/Launch, ECU State

### 13.3 Planned: SensorListModel

A `QAbstractListModel` wrapper around `SensorRegistry` to provide:
- Searchable, filterable sensor list for QML
- Category tabs
- Active/inactive visual distinction
- Pagination for large sensor lists
- Will replace the static `DatasourcesList.qml` ComboBox pattern

---

## 14. Diagnostics System

### 14.1 DiagnosticsProvider (Core/DiagnosticsProvider.h)

Provides system health data to the Diagnostics settings page:
- **System info** (2s poll): CPU temp, memory %, RAM MB, CPU load, disk usage, uptime
- **CAN status** (1s poll): connected, message rate, error count, total messages
- **CAN status text**: 3-state logic:
  - "Disconnected" if `!m_canConnected`
  - "Active" if `m_lastCanMsgTime.elapsed() <= 5000`
  - "Waiting" if connected but no recent messages
- **Log buffer**: Circular buffer of 200 entries with level/message/timestamp
- **Sensor summary**: active count, total count

### 14.2 System Metrics Sources

| Metric        | Linux Source                              | macOS       |
|---------------|------------------------------------------|-------------|
| CPU temp      | `/sys/class/thermal/thermal_zone0/temp`  | N/A (0.0)   |
| Memory        | `/proc/meminfo` (MemTotal, MemAvailable) | `vm_stat`   |
| CPU load      | `/proc/loadavg`                          | `sysctl`    |
| Disk usage    | `statvfs("/")`                           | `statvfs`   |
| Uptime        | `QElapsedTimer` (app uptime, not system) | Same        |

---

## 15. Settings UI Structure

### 15.1 Tab Layout

`SerialSettings.qml` defines the main settings tab bar with a `TabBar` +
`StackLayout`. Current tabs:

| Index | Tab Name     | Component                 |
|-------|--------------|---------------------------|
| 0     | Settings     | MainSettings.qml          |
| 1     | RPM/Vehicle  | VehicleRPMSettings.qml    |
| 2     | Dashboards   | DashSelector.qml          |
| 3     | EX Board     | ExBoardAnalog.qml         |
| 4     | Network      | NetworkSettings.qml       |
| 5     | Diagnostics  | DiagnosticsSettings.qml   |

TabButton width is `tabView.width / tabModel.count` for responsive fill.

### 15.2 Styled Components

All Settings pages use shared components from `Settings/components/`:
- `SettingsPage` -- page wrapper with consistent padding
- `SettingsSection` -- card-style section with title
- `SettingsRow` -- label + control row layout
- `StyledButton`, `StyledComboBox`, `StyledTextField`, `StyledSwitch`,
  `StyledCheckBox` -- all use content-aware implicit sizing
- `ConnectionStatusIndicator` -- 3-state LED (connected/warning/disconnected)

### 15.3 MainSettings Sections

MainSettings.qml contains these sections:
- **ECU Configuration**: ECU type, daemon selection, license key
- **CAN Configuration**: CAN base address (hex), RPM base address (hex)
- **Connection**: Connect/disconnect buttons, CAN status indicator
- **Startup / CAN**: Auto-connect, startup delay, daemon auto-start

---

## 16. Deployment and Target Device

### 16.1 Target Device

| Property          | Value                                         |
|-------------------|-----------------------------------------------|
| Board             | Raspberry Pi 4 Model B (BCM2711)              |
| OS                | Poky (Yocto) 4.0.17, kernel 6.1.61-v7l       |
| Init System       | SysVinit (NOT systemd)                        |
| Qt on device      | Qt 5.15.7                                     |
| Display           | EGLFS (QT_QPA_PLATFORM=eglfs), no X11        |
| CAN               | MCP2515 via SPI (can0, 1Mbps)                 |
| IP (dev default)  | 192.168.15.129                                |
| SSH               | root@192.168.15.129 (passwordless root login) |

### 16.2 Device File Locations

| Path                                              | Contents                        |
|---------------------------------------------------|---------------------------------|
| `/opt/PowerTune/PowertuneQMLGui`                  | Main application binary         |
| `/home/pi/daemons/`                               | ECU daemons (67 total)          |
| `/home/pi/daemons/Generic`                        | Currently active daemon         |
| `/home/pi/daemons/Key.lic`, `Licence.lic`         | Daemon license files            |
| `/home/pi/UserDashboards/`                        | User dashboard configs          |
| `/home/pi/Logo/`                                  | Custom logo images              |
| `/home/pi/src/`                                   | Git source repo (older clone)   |
| `/home/pi/Recovery/`                              | Recovery app (fallback)         |
| `/home/root/.config/PowerTuneQML/PowerTuneDash.conf` | C++ app settings            |
| `/home/root/.config/Power-Tune/PowerTune.conf`    | QML settings persistence        |
| `/etc/init.d/powertune`                           | SysVinit startup script         |
| `/home/pi/startdaemon.sh`                         | Daemon startup (ifdown/ifup can0, run Generic) |
| `/home/pi/powertune-update.sh`                    | Auto-update script              |
| `/home/pi/bootsplash.mp4`                         | Boot splash video               |

### 16.3 Boot Sequence on Device

1. SysVinit starts `/etc/init.d/powertune` at priority S010 (before networking)
2. Script runs `powertune-update.sh` (auto-update check)
3. Script runs `startdaemon.sh` in background (brings up CAN, starts Generic daemon)
4. Script launches `PowertuneQMLGui -platform eglfs` in background
5. Monitor loop: if PowertuneQMLGui crashes, launch Recovery app

### 16.4 Deployment Methods

**Method A: On-device build (Yocto qmake)**
```bash
ssh root@192.168.15.129
cd /home/pi/src && git pull
/home/pi/src/Scripts/updatePowerTune.sh
```

**Method B: Cross-compile + scp**
```bash
# Build on dev machine (or CI)
cmake --build build/ --target PowerTuneQMLGui
# Transfer binary
scp build/PowerTuneQMLGui root@192.168.15.129:/opt/PowerTune/
# Restart
ssh root@192.168.15.129 "kill \$(pidof PowertuneQMLGui); /opt/PowerTune/PowertuneQMLGui -platform eglfs &"
```

**Method C: Package transfer (Yocto .deb-like)**
```bash
scp PowerTuneQMLGui.tar.zst root@192.168.15.129:/tmp/
ssh root@192.168.15.129 "cd /tmp && zstd -df PowerTuneQMLGui.tar.zst && tar xf PowerTuneQMLGui.tar -C /opt/PowerTune/"
```

---

## 17. Resource Locations

### 17.1 Graphics and Images

| Resource                    | Path                                    |
|-----------------------------|-----------------------------------------|
| Gauge background images     | `Resources/graphics/`                   |
| LED indicators              | `Resources/graphics/led*.png`           |
| RPM bar fill/empty          | `Resources/graphics/RPM_*.png`          |
| Needle SVG                  | `Resources/graphics/needle.svg`         |
| QR codes (help page)        | `Resources/graphics/*QR.png`            |
| Country flags               | `Resources/graphics/Flags/*.png`        |
| Logos                       | `Resources/Logo/`                       |
| Example dashboards          | `Resources/exampleDash/`                |

### 17.2 Fonts

- `Resources/fonts/MaterialSymbolsOutlined.ttf` -- Material Design icons
- On device: system fonts installed via `updatedaemons.sh`

### 17.3 Track Data

- `Resources/KTracks/Countries.txt` -- list of countries
- `Resources/KTracks/<Country>/<Track>.txt` -- GPS coordinates for lap timing

### 17.4 CAN Configuration Files

- `CAN_Configs/LINK ECU/` -- CAN address configuration for Link ECUs

---

## 18. Legacy and Dead Code

### 18.1 Dead QML Files (content moved or deprecated)

| File                               | Status                                    |
|------------------------------------|-------------------------------------------|
| Settings/StartupSettings.qml       | Content moved to MainSettings             |
| Settings/WarnGearSettings.qml      | Content moved to VehicleRPMSettings       |
| Settings/SpeedSettings.qml         | Content moved to VehicleRPMSettings       |
| Settings/RPMSettings.qml           | Content moved to VehicleRPMSettings       |
| Settings/SenseHatSettings.qml      | Removed from active use                   |
| Core/ConsultRegs.qml               | Nissan-specific, not needed for Generic   |
| Core/OBDPIDS.qml                   | OBD-specific, not needed for Generic      |
| Core/AnalogInputs.qml              | Honda ECU-specific                        |

These files still exist in CMakeLists.txt QML_FILES but are not loaded in the
active tab configuration. They should be cleaned up eventually.

### 18.2 Legacy C++ (not in CMake build)

| File                    | Status                                          |
|-------------------------|-------------------------------------------------|
| Core/serialport.cpp/.h  | Legacy serial port, replaced by daemon approach |
| ECU/*.cpp/*.h            | ECU protocol implementations (live in daemons)  |
| Hardware/gps.cpp/.h     | GPS serial, may be re-enabled later             |
| Hardware/gopro.cpp/.h   | GoPro integration, low priority                 |
| Hardware/sensors.cpp/.h | SenseHat, may be re-enabled                     |
| Utils/iomapdata.cpp/.h  | IO map parsing, legacy                          |
| Utils/Speedo.cpp/.h     | Speed calculations, merged into Calculations    |

### 18.3 DashBoard God Object

`Core/dashboard.h/.cpp` was the original monolithic class holding ALL data.
It has been refactored into the domain models in `Core/Models/`. The `DashBoard`
class now exists as a thin shell:
- Still registered as `"Dashboard"` for backward compatibility
- Holds `UIState*` and stubs for `SteinhartCalculator*`, `SignalSmoother*`
- No longer holds or forwards data properties
- Will be fully removed when all QML references are migrated

### 18.4 PowertuneQMLGui.pro Drift

The qmake `.pro` file is missing several newer C++ classes:
`PropertyRouter`, `SensorRegistry`, `DiagnosticsProvider`, `UIState`,
`ConnectionData`, `SettingsData`, `CalibrationHelper`, `SignalSmoother`,
`SteinhartCalculator`. If qmake builds are still needed, these must be added.

---

## 19. Cross-Check Rules

These are critical "if you change X, verify Y" relationships. Follow these
whenever making changes to avoid breaking the application.

### 19.1 C++ Changes

| If you change...                          | Verify...                                              |
|-------------------------------------------|--------------------------------------------------------|
| A `Q_PROPERTY` name in any model          | All QML files binding to that property name             |
| A `Q_PROPERTY` name in any model          | `PropertyRouter::initializePropertyMappings()` maps it  |
| A `Q_PROPERTY` name in any model          | `SensorRegistry::registerCommonCanSensors()` uses new name |
| `UDPReceiver::processPendingDatagrams()`  | The `ident` matches what the external daemon sends      |
| `Extender::readyToRead()` frame parsing   | CAN base address config in MainSettings matches         |
| `AppSettings::readandApplySettings()`     | Keys match what MainSettings QML writes with `setValue` |
| `Connect` constructor object creation     | All `setContextProperty()` calls follow creation        |
| Context property name in `connect.cpp`    | ALL QML files that reference that context property      |
| `DiagnosticsProvider` properties          | `DiagnosticsSettings.qml` bindings                     |
| `SensorRegistry` sensor keys             | `PropertyRouter` property names match                   |
| Any `Q_INVOKABLE` method signature        | All QML `callsite.method()` invocations                 |

### 19.2 QML Changes

| If you change...                          | Verify...                                              |
|-------------------------------------------|--------------------------------------------------------|
| A QML file name                           | `CMakeLists.txt` QML_FILES entry                       |
| A QML file name                           | Any `Loader.source` or `Component` references           |
| A QML file name                           | The `qml.qrc` file (if a non-module resource)          |
| Tab order in `SerialSettings.qml`         | `StackLayout` indices match new tab order               |
| `StyledComboBox` model items              | All `onCurrentIndexChanged` handlers                    |
| Dashboard page in `DashSelector.qml`      | `Main.qml` SwipeView page indices                       |
| Gauge component API (properties)          | All `create*.js` factory scripts that set those props   |
| Gauge `datasource` property handling      | `DatasourcesList.qml` sourcename keys match model props |
| A `Settings {}` category name             | User data will be lost (category is the storage key)    |
| `SettingsSection` or component styling    | Test on target resolution (800x480 or 1024x600)        |

### 19.3 Build System Changes

| If you change...                          | Verify...                                              |
|-------------------------------------------|--------------------------------------------------------|
| CMakeLists.txt SOURCES                    | PowertuneQMLGui.pro SOURCES/HEADERS (if maintaining)   |
| CMakeLists.txt QML_FILES                  | Module builds correctly (`cmake --build`)               |
| New Qt module dependency                  | Yocto image includes that Qt module                    |
| New C++ class registered in connect.cpp   | Both CMakeLists.txt and .pro updated                   |
| qml.qrc resources                         | Files exist at the paths listed                         |
| RESOURCE_PREFIX in CMake                  | Main.qml load path in main.cpp                        |

### 19.4 Deployment Changes

| If you change...                          | Verify...                                              |
|-------------------------------------------|--------------------------------------------------------|
| Application binary name                   | `/etc/init.d/powertune` script references              |
| Install path (deployment.pri)             | Init script looks in `/opt/PowerTune/`                 |
| Daemon communication protocol             | `UDPReceiver` ident mappings still match               |
| CAN bitrate                               | `/etc/network/interfaces` can0 bitrate matches         |
| Boot splash file                          | `bootsplash.service` references correct path            |
| Qt version on device                      | Rebuild all QML modules for that Qt version            |

---

## 20. Known Issues

### 20.1 Active Issues

1. **Generic daemon 97% CPU**: The `/home/pi/daemons/Generic` daemon uses a
   busy-wait loop. This is an upstream daemon issue, not app code.

2. **CAN ERROR-PASSIVE state**: Device CAN interface reports ERROR-PASSIVE,
   likely because no ECU is connected during development.

3. **QML lint warnings**: IDE reports "Failed to import QtQuick" and
   "unqualified access" warnings. These are IDE configuration issues for
   cross-compiled Qt6, not actual code errors.

4. **Qt version mismatch**: Development uses Qt6 (CMake), device runs Qt5.15.7
   (qmake). QML imports use `2.15` versioned imports for backward compat, but
   some Qt6-only features (like `QtQuick.Shapes`) may not work on the device
   without updating the Yocto Qt layer.

5. **Two config file locations**: `AppSettings` writes to
   `PowerTuneQML/PowerTuneDash.conf` while `Qt.labs.settings` writes to
   `Power-Tune/PowerTune.conf`. This split is intentional but confusing.

6. **.pro file drift**: The qmake .pro file is missing ~10 newer source files.
   On-device builds with qmake will fail unless updated.

### 20.2 Historical Fixes (Reference)

- **Reboot button freeze**: Fixed by changing `QProcess::start()` +
  `waitForFinished()` to `QProcess::startDetached()`. Never use blocking
  process calls from the UI thread.

- **Diagnostics layout collapse**: Fixed by using fixed `preferredWidth` values
  instead of `root.width * factor` (which evaluates to 0 during early layout).

- **CAN status always "Connected"**: Fixed by implementing 3-state logic in
  `DiagnosticsProvider::canStatusText()` using `QElapsedTimer` to track actual
  message flow, not just daemon connection status.

---

## 21. Onboarding Checklist

For any new developer or AI agent joining this project:

1. **Read this document first** (you are here).

2. **Understand the data flow** (Section 9). Trace a single value (e.g., RPM)
   from external daemon through UDPReceiver through EngineData to QML.

3. **Know the two build systems** (Section 4). CMake is primary for development,
   qmake is still used for on-device builds.

4. **Know the QML module structure** (Section 6). Every QML file must be listed
   in the correct `qt_add_qml_module()` block in CMakeLists.txt.

5. **Check the cross-check rules** (Section 19) before every change. The most
   common breakages are: renamed properties without updating QML, new files not
   added to CMakeLists.txt, and settings key mismatches.

6. **Know where settings are persisted** (Section 10). There are TWO config
   files. Changing a `Settings {}` category in QML will lose user data.

7. **Know the device** (Section 16). The target is a Pi 4 running 32-bit Yocto
   with SysVinit (not systemd), EGLFS (no X11), and Qt 5.15.7.

8. **Read the existing plan** if continuing gauge system work:
   `.cursor/plans/gauge_system_overhaul_5f5a62a5.plan.md`

9. **Key files to read for orientation**:
   - `Core/connect.cpp` -- how everything is wired together
   - `PowerTune/Core/Main.qml` -- the application root
   - `PowerTune/Core/SerialSettings.qml` -- settings tab structure
   - `Core/Models/EngineData.h` -- example of the Q_PROPERTY pattern
   - `Utils/UDPReceiver.cpp` -- the data intake pipeline

10. **Test changes on the target device** when possible. EGLFS rendering and
    touch input behave differently than desktop. Use `scp` to deploy and SSH
    to restart.

11. **Commit frequently** with detailed messages. Use
    `git commit -F .git-commit-msg.txt && rm .git-commit-msg.txt` for large
    messages. Update `.gitignore` before committing new file types.

12. **Never commit**: `device-backup/`, `reference_sourcecode/`, `*.log`,
    `build/`, `.cursor/`, daemon binaries, license files, or the `.memory/`
    database files.

---

## Appendix A: QML Context Property Quick Reference

For quick lookup, here is every context property name and what it accesses:

```
Dashboard       -> DashBoard       (legacy shell, avoid using)
UI              -> UIState         (currentPage, editMode, brightness)
Engine          -> EngineData      (rpm, MAP, TPS, Watertemp, BatteryV, ...)
Vehicle         -> VehicleData     (speed, Gear, Odo, ...)
GPS             -> GPSData         (gpsLatitude, gpsLongitude, gpsSpeed, ...)
Analog          -> AnalogInputs    (Analog0-10, AnalogCalc0-10)
Digital         -> DigitalInputs   (DigitalInput1-7, EXDigitalInput1-8)
Expander        -> ExpanderBoardData (EXAnalogInput0-7, EXAnalogCalc0-7)
Motor           -> ElectricMotorData (motorRPM, motorTemp, batterySOC, ...)
Flags           -> FlagsData       (Flag1-12)
Timing          -> TimingData      (timing advance values)
Sensor          -> SensorData      (SenseHat accel/gyro/compass/temp/press)
Connection      -> ConnectionData  (connected, serialConnected, port, ...)
Settings        -> SettingsData    (runtime settings)
PropertyRouter  -> PropertyRouter  (getValue(), hasProperty(), getModelName())
Extender2       -> Extender        (openCAN(), closeConnection())
AppSettings     -> AppSettings     (setValue(), getValue())
Logger          -> DataLogger      (start/stop logging)
Calculations    -> Calculations    (derived computations)
Calibration     -> CalibrationHelper (linearCalibrate())
Steinhart       -> SteinhartCalculator (steinhartCalc())
SensorRegistry  -> SensorRegistry  (availableSensors, getSensorsByCategory())
Diagnostics     -> DiagnosticsProvider (cpuTemp, canStatusText, logMessages)
Wifiscanner     -> WifiScanner     (scan(), networks)
Dirmodel        -> QFileSystemModel (directory listing)
Filemodel       -> QFileSystemModel (file listing)
DLM             -> DownloadManager  (download())
Connect         -> Connect          (openConnection(), reboot(), shutdown())
```

---

## Appendix B: UDPReceiver Ident Ranges

For reference when debugging data flow. Key ident ranges used by daemons:

| Ident Range   | Data Category            | Target Model       |
|---------------|--------------------------|--------------------|
| 100-199       | Core engine metrics      | EngineData         |
| 200-299       | Vehicle/speed data       | VehicleData        |
| 300-399       | Fuel system              | EngineData         |
| 400-499       | Temperatures             | EngineData         |
| 500-599       | Boost/turbo              | EngineData         |
| 600-699       | Ignition/timing          | EngineData         |
| 700-799       | O2/Lambda/AFR            | EngineData         |
| 800-899       | Flags/status             | FlagsData          |
| 900-919       | Analog inputs (ECU)      | AnalogInputs       |
| 908-915       | EX Analog inputs         | ExpanderBoardData  |
| 920-939       | Digital inputs           | DigitalInputs      |
| 1000-1099     | GPS data                 | GPSData            |
| 1100-1199     | EV motor data            | ElectricMotorData  |
| 1200-1299     | EGT 1-12                 | EngineData         |
| 1300-1399     | Knock data               | EngineData         |
| 1400-1499     | Traction/launch control  | EngineData         |

Note: Exact mappings are in `Utils/UDPReceiver.cpp` lines 107-1100. Always
verify against the actual switch statement, as daemon-specific idents may vary.

---

## Appendix C: Extender Board CAN Frame IDs

| Frame ID           | Payload                                     |
|--------------------|---------------------------------------------|
| base + 0 (adress2) | Analog CH0-3: 4x uint16 (millivolts)       |
| base + 1 (adress3) | Analog CH4-7: 4x uint16 (millivolts)       |
| base + 2 (adress4) | Digital DI1-8: 8x uint8 (0=OFF, 1=ON)      |
| rpmBase (separate)  | RPM data from CAN ECU                       |

Default base address is configurable in MainSettings.qml (CAN Configuration
section, hex input). Stored via `AppSettings::setValue("CANBaseAddress", ...)`.

---

End of document.
