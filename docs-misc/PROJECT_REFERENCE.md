# PowerTune Prism Project Reference

Version: 2026-03-12
Maintainer: Kai Wyborny

This document is the current source-of-truth reference for the application
structure in `PowerTuneDigitalOfficial_Prism`. It replaces older project notes
that still described the earlier Qt 5 / qmake layout.

## 1. Project Identity

The project still uses several names in different layers of the stack:

| Name | Used For |
| --- | --- |
| `PowerTuneDigitalOfficial_Prism` | Repository and workspace folder |
| `PowerTuneQMLGui` | Root CMake project and executable target |
| `PowerTune` | Runtime app name and `QSettings` org/app identity |
| `PrismPT.Dashboard` | Dashboard QML module URI |
| `Prism.Keyboard` | On-screen keyboard QML module URI |

These names are all active. Do not assume the repository, executable, runtime
app, and QML namespaces are identical.

## 2. Audit Summary

This audit confirmed the following:

- The active build system is Qt 6 + CMake from the root `CMakeLists.txt`
- The app entry point is `main.cpp`, which loads `PowerTune/Core/Main.qml`
- The central C++ wiring point is `Core/connect.cpp`
- The dashboard stack is based on `RaceDash.qml`, `UserDashboard.qml`, overlay
  configs, and `PropertyRouter`
- The settings UI includes a dedicated `DisplaySettings.qml` page and new
  services such as `ScreenControlService` and `DashboardLockService`
- Older docs that referenced `Qt.labs.settings`, `DatasourceService.qml`,
  `DatasourcesList.qml`, `run-macos.sh`, or the old qmake workflow were stale

## 3. Authoritative Files

Use these files as the primary reference points:

| File | Why It Matters |
| --- | --- |
| `CMakeLists.txt` | Canonical build and module manifest |
| `main.cpp` | Runtime bootstrap and QML entry load |
| `Core/connect.cpp` | Backend object creation and QML context exposure |
| `PowerTune/Core/Main.qml` | Root application window and page flow |
| `PowerTune/Core/SettingsManager.qml` | Current settings tab structure |
| `PowerTune/Dashboard/RaceDash.qml` | Active race dashboard composition |
| `Core/appsettings.cpp` | Persistent settings and overlay config storage |

## 4. Top-Level Structure

```text
PowerTuneDigitalOfficial_Prism/
|-- CMakeLists.txt
|-- CMakePresets.json
|-- main.cpp
|-- Core/
|-- Hardware/
|-- Utils/
|-- PowerTune/
|-- Prism/
|-- Resources/
|-- Scripts/
|-- docs-misc/
|-- operating_platform/
|-- daemons/
|-- .github/
`-- .vscode/
```

### 4.1 C++ Source Areas

| Directory | Purpose |
| --- | --- |
| `Core/` | App orchestration, settings, diagnostics, dashboard lock, display control, models |
| `Hardware/` | Hardware-facing interfaces, currently `Extender` |
| `Utils/` | Supporting services such as UDP ingest, logging, downloads, calibration, WiFi scan |

### 4.2 QML Source Areas

| Directory | Purpose |
| --- | --- |
| `PowerTune/Core/` | Main app shell, intro page, settings manager, ex-board page, brightness popup |
| `PowerTune/Settings/` | Main, display, network, diagnostics, vehicle/RPM, dash selection pages |
| `PowerTune/Settings/components/` | Shared styled controls and layout primitives |
| `PowerTune/Dashboard/` | Dashboard pages and overlay configuration UI |
| `PowerTune/Gauges/Shared/` | Shared warning UI helpers |
| `PowerTune/Gauges/RaceDash/` | Reusable live race dash widgets |
| `Prism/Keyboard/` | Custom on-screen keyboard |

## 5. Build System

### 5.1 Active Build Path

The supported development path is:

- Qt 6
- CMake
- root `CMakeLists.txt`

The root build target is:

```text
PowerTuneQMLGui
```

### 5.2 Local macOS Build

Preferred local build flow:

```sh
cmake --preset macos-homebrew
cmake --build --preset macos-homebrew
```

Output:

```text
build/macos-homebrew/PowerTuneQMLGui.app
```

### 5.3 Historical Build Artifacts

These still exist but should not be treated as the current architecture:

- `operating_platform/deployment.pri`
- older docs that mention `PowerTuneQMLGui.pro`

## 6. Application Bootstrap

Startup flow:

1. `main.cpp` creates `QGuiApplication`
2. Runtime app identity is set to organization `PowerTune` and application `PowerTune`
3. Fonts from `:/Resources/fonts` are loaded
4. `QQmlApplicationEngine` adds import path `qrc:/qt/qml`
5. `DownloadManager` and `Connect` are registered/exposed
6. `Connect` constructs the backend graph and exposes context properties
7. `main.cpp` loads `qrc:/qt/qml/PowerTune/Core/PowerTune/Core/Main.qml`

## 7. QML Module Structure

The active QML modules declared in `CMakeLists.txt` are:

| URI | Library Target | Key Contents |
| --- | --- | --- |
| `PowerTune.Utils` | `PowerTuneUtilsLib` | `Translator.qml`, `MaterialIcon.qml` |
| `PowerTune.Core` | `PowerTuneCoreLib` | `Main.qml`, `Intro.qml`, `SettingsManager.qml`, `ExBoardAnalog.qml`, `BrightnessPopUp.qml` |
| `PowerTune.UI` | `PowerTuneUiLib` | themed settings components such as `StyledButton`, `StyledSpinBox`, `SensorPicker` |
| `PowerTune.Settings` | `PowerTuneSettingsLib` | `MainSettings.qml`, `DisplaySettings.qml`, `DashSelector.qml`, `VehicleRPMSettings.qml`, `NetworkSettings.qml`, `CanMonitor.qml`, `DiagnosticsSettings.qml`, `HelpPage.qml` |
| `PowerTune.Gauges.Shared` | `GaugesSharedLib` | `Warning.qml`, `WarningLoader.qml`, `WarningFlashTimer.qml` |
| `PowerTune.Gauges.RaceDash` | `GaugesRaceDashLib` | `ArcGauge.qml`, `GaugeReadout.qml`, `ShiftIndicator.qml`, `SensorCard.qml`, `StatusBox.qml`, `BrakeBiasBar.qml`, `BottomStatusBar.qml`, `GearIndicator.qml`, `TachCluster.qml`, `SpeedCluster.qml` |
| `PrismPT.Dashboard` | `PrismPTDashboardLib` | `DashboardTheme.qml`, `UserDashboard.qml`, `RaceDash.qml`, `DraggableOverlay.qml`, `OverlayConfigPopup.qml` |
| `Prism.Keyboard` | `PrismKeyboardLib` | `PrismKeyboard.qml`, `QwertyLayout.qml`, `NumericPad.qml`, `KeyButton.qml`, theme/icon helpers |

### 7.1 Embedded C++ in QML Modules

`RaceArcItem` is no longer a top-level `Core/` renderer. It is compiled from:

- `PowerTune/Gauges/RaceDash/geohelpers/RaceArcItem.cpp`
- `PowerTune/Gauges/RaceDash/geohelpers/RaceArcItem.h`

and linked into `GaugesRaceDashLib`.

## 8. Main UI Flow

`PowerTune/Core/Main.qml` is the root app window.

Current high-level page flow:

- `SwipeView`
- page 0: `Intro.qml`
- pages 1-3: additional dashboard loaders depending on `UI.Visibledashes`
- final page: `SettingsManager.qml`

Additional global UI behavior in `Main.qml`:

- boot brightness popup via `ScreenControl`
- swipe gating via `DashboardLock`
- unlock overlay with bottom-corner hold gesture
- on-screen keyboard overlay via `PrismKeyboard`

## 9. Backend Services Exposed To QML

`Core/connect.cpp` is the canonical list of context properties exposed to QML.

### 9.1 Core state and data models

- `Dashboard`
- `UI`
- `Engine`
- `Vehicle`
- `GPS`
- `Analog`
- `Digital`
- `Expander`
- `Motor`
- `Flags`
- `Timing`
- `Sensor`
- `Connection`
- `Settings`

### 9.2 Supporting services and helpers

- `PropertyRouter`
- `Extender2`
- `AppSettings`
- `Logger`
- `Calculations`
- `Dirmodel`
- `Filemodel`
- `Wifiscanner`
- `Calibration`
- `Steinhart`
- `SensorRegistry`
- `Diagnostics`
- `OverlayConfig`
- `ShiftHelper`
- `CanMonitorModel`
- `ExBoardConfig`
- `ScreenControl`
- `DashboardLock`
- `OverlayDefaults`

### 9.3 Notable newer services

| Service | Responsibility |
| --- | --- |
| `ExBoardConfigManager` | ex-board specific sensor/config persistence helpers |
| `ScreenControlService` | display brightness backend, presets, popup behavior |
| `DashboardLockService` | lock/unlock policy and swipe gating |
| `OverlayConfigDefaults` | default overlay config source for race dash widgets |

## 10. Data Flow

### 10.1 Telemetry ingest

There are two active data paths:

1. UDP telemetry via `Utils/UDPReceiver.cpp`
2. direct CAN access for the extender board via `Hardware/Extender.cpp`

### 10.2 UI binding

Live values reach QML through:

- direct context property bindings such as `Engine.rpm`
- dynamic lookup through `PropertyRouter.getValue(propertyName)`
- persistent config values through `AppSettings`

## 11. Settings and Persistence

The app uses:

```cpp
QSettings("PowerTune", "PowerTune")
```

Canonical runtime settings path on the target device:

```text
/home/root/.config/PowerTune/PowerTune.conf
```

### 11.1 `AppSettings` responsibilities

`Core/appsettings.cpp` currently handles:

- generic key/value storage
- RPM, speed, warning, and unit settings
- display brightness persistence
- dashboard background config
- overlay config save/load/remove
- dashboard lock persistence
- ex-board gear and speed sensor config
- extender calibration and Steinhart settings restore

### 11.2 Current settings tabs

`PowerTune/Core/SettingsManager.qml` defines these tabs:

| Index | Title | Component |
| --- | --- | --- |
| 0 | Main | `MainSettings.qml` |
| 1 | Display | `DisplaySettings.qml` |
| 2 | Dash Sel. | `DashSelector.qml` |
| 3 | Vehicle / RPM | `VehicleRPMSettings.qml` |
| 4 | EX Board | `ExBoardAnalog.qml` |
| 5 | Network | `NetworkSettings.qml` |
| 6 | Diagnostics | `DiagnosticsSettings.qml` |

## 12. Dashboard Architecture

### 12.1 Current active dashboard files

| File | Role |
| --- | --- |
| `UserDashboard.qml` | dashboard page with persisted background image/color |
| `RaceDash.qml` | primary race dashboard with draggable overlays |
| `DraggableOverlay.qml` | drag/edit shell |
| `OverlayConfigPopup.qml` | overlay editor |
| `DashboardTheme.qml` | dashboard theme singleton |

### 12.2 Overlay config flow

`RaceDash.qml`:

- defines default configs per overlay
- loads persisted config using `AppSettings.loadOverlayConfig()`
- merges legacy IDs where needed
- renders each overlay through `DraggableOverlay.qml`

Overlay positions are stored separately through `OverlayConfigManager`.

### 12.3 Current race dash overlays

The current race dash layout includes:

- `tachCluster`
- `speedCluster`
- `shiftIndicator`
- `waterTemp`
- `oilPressure`
- `statusRow0`
- `statusRow1`
- `brakeBias`
- `bottomBar`

### 12.4 Warning system

Warning UI is currently provided by the shared gauge module:

- `PowerTune/Gauges/Shared/Warning.qml`
- `PowerTune/Gauges/Shared/WarningLoader.qml`
- `PowerTune/Gauges/Shared/WarningFlashTimer.qml`

`UserDashboard.qml` hosts `WarningLoader`.

## 13. Resources

### 13.1 What is authoritative

Resource embedding is declared in `CMakeLists.txt` via `qt_add_resources()`.

### 13.2 Current drift

The committed `Resources/` tree in this repository is smaller than the current
resource manifest in `CMakeLists.txt`.

Observed committed assets include:

- font files under `Resources/fonts/`
- `Resources/graphics/Racedash_AiM.png`
- `Resources/graphics/needle.svg`

Treat the `qt_add_resources()` list as a manifest that still needs validation,
not as a guaranteed reflection of the current checked-in asset inventory.

## 14. Deployment Baseline

The intended target runtime remains:

- Raspberry Pi 4
- EGLFS / DRM / KMS
- `can0` on MCP2515
- SysVinit-based device images

See `BUILD.md` for the current Yocto-oriented build and deployment workflow.

## 15. Historical / Non-Authoritative Files

These files may still be useful, but they are not the current app structure
reference:

| File | Status |
| --- | --- |
| `docs-misc/device-audit/working-original-device-configuration.md` | historical deployed-device snapshot |
| `operating_platform/deployment.pri` | legacy deployment artifact |
| older revisions of `README.md` and dashboard docs | obsolete project structure |

## 16. Cross-Check Rules

When changing the codebase, verify the following:

| If you change... | Verify... |
| --- | --- |
| a QML file | it remains listed in the correct `qt_add_qml_module()` block |
| a C++ source/header | it remains listed in `CMakeLists.txt` |
| a context property name in `connect.cpp` | all QML call sites still match |
| a settings key in `AppSettings` | existing data compatibility is still acceptable |
| overlay config keys | `RaceDash.qml`, `OverlayConfigPopup.qml`, and saved state stay aligned |
| display or lock behavior | `DisplaySettings.qml`, `Main.qml`, `ScreenControlService`, and `DashboardLockService` stay aligned |
| resource paths | `CMakeLists.txt`, QML `qrc:` paths, and actual committed files all match |

## 17. Known Drift Still Present

This audit found remaining mismatches that are important to know about:

1. `.github/workflows/build.yml` still contained Qt 5 / qmake-era build logic and
   needed alignment with the Qt 6 CMake build.
2. The `Resources/` filesystem inventory does not currently match the larger
   `qt_add_resources()` list in `CMakeLists.txt`.
3. Naming remains mixed between `PowerTuneQMLGui`, `PowerTune`, and `PrismPT`.
   That is active behavior, not a documentation mistake.

## 18. Orientation Checklist

For anyone joining the project:

1. Read `CMakeLists.txt`
2. Read `main.cpp`
3. Read `Core/connect.cpp`
4. Read `PowerTune/Core/Main.qml`
5. Read `PowerTune/Core/SettingsManager.qml`
6. Read `PowerTune/Dashboard/RaceDash.qml`
7. Read `Core/appsettings.cpp`

These files describe the real app structure more reliably than older notes or
legacy scripts.
