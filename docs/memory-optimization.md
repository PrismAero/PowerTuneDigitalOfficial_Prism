# PowerTune Memory Optimization Analysis

## Overview

PowerTune is a C++/Qt6 QML automotive dashboard application currently consuming ~7GB RAM on macOS dev builds. Target platform is Raspberry Pi where memory is limited to 1-4GB. This document captures the analysis findings and prioritized optimization plan.

## Architecture Summary

- Entry point: `main.cpp` creates QApplication + QQmlApplicationEngine
- Central coordinator: Connect class (`connect.cpp`/`connect.h`, ~50KB) - acts as god object managing 13 QObject data models, QML engine, ECU connections
- 13 domain model QObjects with ~567 total Q_PROPERTY declarations (each with NOTIFY signals)
- ECU daemons (external C binaries in `daemons/`) communicate via UDP to the main app
- QML UI: ~80 QML files with heavy use of dynamic object creation via JavaScript

## Memory Consumption Breakdown (Estimated)

| Component | Estimated Memory | Notes |
|---|---|---|
| Qt6 framework (debug symbols) | 2-3 GB | Debug libraries with full symbol tables |
| QFileSystemModel x2 (root "/") | 0.5-2 GB | Indexes entire macOS filesystem |
| QML engine + 567 properties + bindings | 200-500 MB | Meta-object system, JIT, binding expressions |
| Qt::Widgets framework overhead | 300-500 MB | Loaded but unused - app is pure QML |
| Qt::Charts + Qt::Multimedia | 200-400 MB | Heavy optional modules |
| Dynamic QML objects (gauges) | 50-200 MB | Depends on active gauge count |
| Embedded resources (decoded textures) | 20-50 MB | PNG to RGBA expansion |
| Application C++ objects | 10-20 MB | Actual data models and logic |

## Findings (Ranked by Severity)

### 1. CRITICAL: QFileSystemModel Indexing Root "/"

- Location: `connect.cpp`:217-222
- Two QFileSystemModel instances set to rootPath "/"
- On macOS this triggers full disk indexing consuming 0.5-2GB+
- Fix: Restrict to specific directories (e.g., user dashboard save paths)

### 2. CRITICAL: Qt::Widgets Linked Unnecessarily

- Location: `CMakeLists.txt`:233, `main.cpp`:25
- App uses QApplication instead of QGuiApplication
- Pulls in entire widget rendering subsystem for a pure QML app
- Fix: Switch to QGuiApplication, remove Qt::Widgets from CMake

### 3. CRITICAL: Debug Build Overhead

- Qt6 debug libraries are 3-5x larger than release
- The 7GB figure will likely drop to 1-2GB in release mode
- Fix: Always profile on release builds for accurate measurements

### 4. HIGH: Heavy Qt Modules Loaded at Startup

- Qt::Charts, Qt::Multimedia, Qt::Sensors, Qt::Positioning, Qt::Location, Qt::SerialBus all linked
- Many are only needed for specific features
- Fix: Lazy-load or conditionally compile modules

### 5. HIGH: 26+ Context Properties Registered at Startup

- Location: `connect.cpp`:227-262
- All 13 model objects + utilities registered as context properties before QML loads
- All 567 Q_PROPERTY declarations become introspectable immediately
- Fix: Consider using QML singletons or lazy registration

### 6. HIGH: Dynamic QML Object Creation via JavaScript

- Files: `createRoundGauge.js`, `createMaindash.js`, `createsquaregaugeUserDash.js`, etc.
- Each gauge is a complex QObject tree (50-100+ objects per gauge)
- A full dashboard could create 1000-3000 QObjects dynamically
- Fix: Use object pooling, limit max gauges, or pre-compile gauge types

### 7. MEDIUM: ExBoardAnalog.qml (60KB) Always Instantiated

- Location: `Main.qml`:116
- Instantiated with visible:false but fully constructed in memory
- Fix: Wrap in Loader, only load when needed

### 8. MEDIUM: Monolithic QML Files

- `ExBoardAnalog.qml` (60KB), `Cluster.qml` (40KB), `OBDPIDS.qml` (39KB), `AnalogInputs.qml` (37KB)
- Create hundreds of QML items each
- Fix: Break into smaller components, use Loaders for off-screen content

### 9. LOW: Duplicate Q_PROPERTY Registrations

- SensorData and AnalogInputs both declare sens1-sens8, auxcalc1-auxcalc4
- FlagsData declares SensorString1-8 overlapping with SensorData
- Fix: Consolidate into single source of truth

## Q_PROPERTY Count by Model

| Model | Properties | File Size |
|---|---|---|
| EngineData | ~198 | 59KB |
| VehicleData | ~81 | 26KB |
| FlagsData | 49 | 14KB |
| AnalogInputs | 46 | 13KB |
| ElectricMotorData | 32 | 11KB |
| SettingsData | 29 | 10KB |
| SensorData | 20 | 6KB |
| DigitalInputs | 18 | 7KB |
| TimingData | 18 | 7KB |
| ConnectionData | 18 | 7KB |
| ExpanderBoardData | 16 | 6KB |
| UIState | 13 | 5KB |
| GPSData | 10 | 3KB |
| **Total** | **~567** | |

## Optimization Priority Plan

### Phase 1 - Quick Wins (Expected savings: 1-4GB)

1. Fix QFileSystemModel root path from "/" to specific directories
2. Replace QApplication with QGuiApplication, remove Qt::Widgets
3. Profile on release build to get accurate baseline

### Phase 2 - Lazy Loading (Expected savings: 200-500MB)

4. Wrap ExBoardAnalog, OBDPIDS, AnalogInputs, ConsultRegs in Loaders
5. Conditionally compile/load Qt::Charts, Qt::Multimedia
6. Convert context properties to QML singletons for on-demand loading

### Phase 3 - Architecture Improvements (Expected savings: 100-300MB)

7. Consolidate duplicate properties across models
8. Implement gauge object pooling for dynamic creation
9. Break monolithic QML files into smaller components
10. Consider consolidating EngineData (198 props) into grouped sub-objects

### Phase 4 - RPi-Specific Optimizations

11. Use Qt Quick Compiler for ahead-of-time QML compilation
12. Enable texture compression for embedded images
13. Set QML_DISK_CACHE for compiled QML caching
14. Profile with valgrind/massif on ARM target
