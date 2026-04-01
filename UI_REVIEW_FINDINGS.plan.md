# Comprehensive UI Review Findings (Linux/RPi4)

## Review Scope

- Runtime shell and navigation rooted at `PowerTune/Core/Main.qml`
- Dashboard surfaces and overlay stack (`RaceDash`, `DraggableOverlay`, `OverlayConfigPopup`)
- Full settings hub (`SettingsManager` tabs and EX board popups)
- Persistence + application (`Core/appsettings.cpp`, `Core/connect.cpp`, `Utils/OverlayPositionManager.cpp`)
- Build/module wiring and deploy assumptions (`CMakeLists.txt`, Yocto launcher/config)

## Executive Risk Summary

- The app has multiple high-risk correctness gaps where user-visible settings are persisted but not actually applied at runtime.
- Linux/RPi4 deploy assumptions are split between `/home/root` (runtime/session) and `/home/pi` (content paths), creating operational fragility.
- Several shipped UI surfaces appear orphaned/unwired, increasing maintenance cost and feature ambiguity.
- Cross-page shell behavior has lock/swipe and startup-popup edge cases that can cause trapping or inconsistent UX.

## Severity-Ranked Findings

### Critical

1) Dash selection settings are not wired into runtime dashboard loading
- **Evidence**
  - `PowerTune/Core/Main.qml` hardcodes the active dashboard source to `RaceDash.qml` and leaves `secondPageLoader`, `thirdPageLoader`, and `fourthPageLoader` at `source: ""`.
  - `PowerTune/Settings/DashSelector.qml` persists `ui/dashCount` and `ui/dashSelect1..4`, and sets `UI.Visibledashes`, but this is not consumed by `Main.qml` loader sources.
  - `Core/appsettings.cpp` `readandApplySettings()` does not restore dash-selection keys into shell behavior.
- **Impact**
  - User can configure multi-dash state with no runtime effect; settings become misleading and non-functional.
- **Priority**
  - P0

### High

2) CAN bitrate default mismatch between UI and startup
- **Evidence**
  - `PowerTune/Settings/MainSettings.qml` loads `ui/bitrateSelect` default `0`.
  - `Core/connect.cpp` startup path (`startActiveCanModule`) reads `ui/bitrateSelect` with default `2`.
- **Impact**
  - Fresh installs can show one bitrate in UI while runtime connects at another until user edits/saves.
- **Priority**
  - P0

3) Language persistence is written but not restored through `readandApplySettings()`
- **Evidence**
  - `Core/appsettings.cpp` has `writeLanguage(...)` updating `Language` and `SettingsData`.
  - `readandApplySettings()` does not read `Language` or call `setlanguage(...)`.
  - `PowerTune/Settings/MainSettings.qml` loads combo from `Language`, but runtime `Settings.language` hydration depends on session interactions.
- **Impact**
  - Translation state may be inconsistent on restart until manual interaction.
- **Priority**
  - P1

4) `/home/root` runtime identity vs `/home/pi` hardcoded content paths
- **Evidence**
  - `yocto/.../powertune-launcher.c` sets `HOME=/home/root` and launches from `/opt/PowerTune`.
  - `Core/connect.cpp` uses `/home/pi/UserDashboards`, `/home/pi/Logo`, and command paths under `/home/pi`.
  - `PowerTune/Core/BootSplash.qml` uses `file:///home/pi/bootsplash.mp4`.
  - `Utils/downloadmanager.cpp` uses `/home/pi/KTracks`.
- **Impact**
  - Path ownership/existence assumptions can fail across images/deploy variants and maintenance operations.
- **Priority**
  - P1

5) Swipe/lock shell trap potential when interactivity is disabled via non-lock path
- **Evidence**
  - `PowerTune/Core/Main.qml` sets `SwipeView.interactive: UI.draggable === 0 && DashboardLock.swipeAllowed`.
  - Auto-return to index 0 is only handled in `onSwipeAllowedChanged`, not on `UI.draggable` changes.
- **Impact**
  - User can be stranded on settings when swipe is disabled by draggable state.
- **Priority**
  - P1

6) Brightness popup activation bound to C++ invokable (reactivity risk)
- **Evidence**
  - `PowerTune/Core/Main.qml` uses `active: ScreenControl.shouldShowPopupOnStartup()`.
  - `Core/ScreenControlService.cpp` can change readiness asynchronously during DDC detection.
- **Impact**
  - Startup popup may fail to appear when backend capabilities are resolved after initial binding evaluation.
- **Priority**
  - P1

### Medium

7) `VehicleRPMSettings.qml` has load-time writeback hazards
- **Evidence**
  - Multiple `Component.onCompleted` handlers call `applyWarnGear.start()` / `writeSpeedSettings(...)`.
  - Root page also hydrates from `AppSettings` in `Component.onCompleted`.
- **Impact**
  - Completion-order differences can overwrite persisted values with defaults during initialization.
- **Priority**
  - P2

8) Settings keys with no confirmed consumer
- **Evidence**
  - `PowerTune/Settings/NetworkSettings.qml` reads/writes `ui/wifiCountryIndex`; no other usage found.
  - `PowerTune/Settings/DiagnosticsSettings.qml` reads/writes `debug/arcFullSweep`; no other usage found.
  - `Core/appsettings.cpp` writes `"Number of Dashes"` (`writeSelectedDashSettings`) but runtime path uses `ui/dashCount`.
- **Impact**
  - Dead settings increase confusion, migration complexity, and test burden.
- **Priority**
  - P2

9) Orphaned/unreachable shipped QML surfaces
- **Evidence**
  - `PowerTune/Settings/CanMonitor.qml` included in `CMakeLists.txt`, `CanMonitorModel` context property exposed in `Core/connect.cpp`, but no route from `SettingsManager.qml`.
  - `PowerTune/Core/Intro.qml` included in `CMakeLists.txt` but not loaded from `Main.qml`.
  - `PowerTune/Core/SpeedSensorConfigPopup.qml` included in `CMakeLists.txt` with no runtime reference found.
  - `PowerTune/Dashboard/UserDashboard.qml` included in `CMakeLists.txt` with no active runtime route found from shell.
- **Impact**
  - Code/documentation drift and false confidence in untested features.
- **Priority**
  - P2

10) Architecture concentration in large single files
- **Evidence**
  - `PowerTune/Dashboard/OverlayConfigPopup.qml` (~2206 lines)
  - `Core/DiagnosticsProvider.cpp` (~1085 lines)
  - `Core/appsettings.cpp` (~1012 lines)
  - `Core/connect.cpp` (~692 lines)
- **Impact**
  - Elevated regression risk and reduced review/testability.
- **Priority**
  - P2

11) Build/deploy target mismatch risk in tooling
- **Evidence**
  - `CMakePresets.json` `raspberry-pi` preset uses `CMAKE_SYSTEM_PROCESSOR: aarch64`.
  - `yocto/conf/local.conf.template` documents target as Raspberry Pi 4 32-bit (`armv7l`).
- **Impact**
  - Confusing build defaults and accidental ABI mismatch during developer workflows.
- **Priority**
  - P2

### Low

12) Documentation drift around active page topology
- **Evidence**
  - `docs-misc/PROJECT_REFERENCE.md` still references `Intro.qml`/`HelpPage.qml` topology not reflected in current shell wiring.
- **Impact**
  - Onboarding and debugging friction.
- **Priority**
  - P3

## Reachability and Coverage Matrix

### Shell / Cross-Page
- `PowerTune/Core/Main.qml`: reviewed
- `PowerTune/Core/SettingsManager.qml`: reviewed
- `PowerTune/Core/BootSplash.qml`: reviewed
- `PowerTune/Core/BrightnessPopUp.qml`: reviewed
- `Prism/Keyboard/PrismKeyboard.qml`: reviewed

### Dashboard
- `PowerTune/Dashboard/RaceDash.qml`: reviewed
- `PowerTune/Dashboard/DraggableOverlay.qml`: reviewed
- `PowerTune/Dashboard/OverlayConfigPopup.qml`: reviewed
- `PowerTune/Dashboard/UserDashboard.qml`: reviewed for reachability

### Settings Surfaces
- `PowerTune/Settings/MainSettings.qml`: reviewed
- `PowerTune/Settings/DisplaySettings.qml`: reviewed
- `PowerTune/Settings/DashSelector.qml`: reviewed
- `PowerTune/Settings/VehicleRPMSettings.qml`: reviewed
- `PowerTune/Settings/NetworkSettings.qml`: reviewed
- `PowerTune/Settings/DiagnosticsSettings.qml`: reviewed
- `PowerTune/Settings/CanMonitor.qml`: reviewed for wiring status
- `PowerTune/Core/ExBoardAnalog.qml` and related `*ConfigPopup.qml`: reviewed

### Persistence / Apply Paths
- `Core/appsettings.cpp`: reviewed
- `Core/connect.cpp`: reviewed
- `Utils/OverlayPositionManager.cpp`: reviewed
- `Core/AppConstants.h`: reviewed

### Build / Deployment / Structure
- `CMakeLists.txt`: reviewed
- `CMakePresets.json`: reviewed
- `yocto/conf/local.conf.template`: reviewed
- `yocto/.../powertune-launcher.c`: reviewed
- `README.md`, `BUILD.md`: reviewed

## Prioritized Remediation Backlog

### Immediate (P0/P1)
- Wire dashboard selection persistence into runtime loader selection in `Main.qml` (or remove non-functional controls until implemented).
- Unify CAN bitrate default across UI and startup (`ui/bitrateSelect` single source of truth).
- Restore language in startup apply path (`readandApplySettings`) and make QML binding deterministic.
- Resolve `/home/root` vs `/home/pi` path strategy for RPi4 image and enforce one ownership model.
- Refactor brightness popup activation to a NOTIFY-backed property (instead of direct invokable binding).
- Add explicit fallback navigation control when swipe interactivity is disabled by `UI.draggable`.

### Next (P2)
- Remove or wire orphaned QML (`CanMonitor`, `Intro`, `SpeedSensorConfigPopup`, `UserDashboard`).
- Consolidate/deprecate stale keys (`Number of Dashes`, dual rpm source keys, legacy connect key fallbacks).
- Remove write-on-complete initialization side effects in `VehicleRPMSettings.qml`.
- Align CMake Raspberry Pi preset with Yocto target architecture.

### Hardening (P2/P3)
- Break up oversized files into smaller modules with ownership boundaries.
- Add regression checks for startup hydration, settings round-trip, and page reachability.
- Update docs to match active runtime topology.

## Known Unknowns / Validation Gaps

- No live runtime execution was performed in this pass (static audit only).
- Hardware-dependent behavior (DDC brightness, CAN module activation, Wi-Fi backend application) needs target-device confirmation.
- Some orphan candidates may be opened dynamically by paths not discovered via static references; dynamic tracing on device is recommended.

