# Extender / UDP / Steinhart Audit Report

Date: 2026-03-13  
Scope: `UDPReceiver`, `Extender`, calibration helpers, Steinhart integration,
settings persistence, sensor registry, property routing, and QML bindings.

## Executive Summary

This audit reviewed the full telemetry and calibration path from UDP ingest and
direct extender CAN input through C++ models, runtime calibration, persistence,
property routing, and QML consumption.

The codebase has a solid overall structure:

- UDP telemetry is centralized in `Utils/UDPReceiver.cpp`
- direct extender CAN handling is centralized in `Hardware/Extender.cpp`
- persistence is centralized in `Core/appsettings.cpp`
- dynamic QML access is centralized in `Core/PropertyRouter.cpp`
- extender configuration UI is centralized in `PowerTune/Core/ExBoardAnalog.qml`

However, the audit found multiple high-impact property-surface issues:

- some live derived extender properties exist but are not exposed cleanly through the selectable sensor flow
- calibrated extender properties are live but can be misclassified as inactive
- some UDP sensor keys can be marked active even when their model properties are never updated
- the main disconnect flow stops UDP but does not stop direct extender CAN updates
- linear sensor presets define real voltage spans, but runtime calibration ignores them
- digital speed input selection is persisted but hard-wired to EX Digital 1 at runtime

The Steinhart implementation itself appears broadly correct in static review,
but surrounding integration and persistence behavior is incomplete in several
important places.

## Audit Scope

Primary files reviewed:

- `Utils/UDPReceiver.cpp`
- `Hardware/Extender.cpp`
- `Utils/SteinhartCalculator.cpp`
- `Utils/CalibrationHelper.cpp`
- `Core/appsettings.cpp`
- `Core/connect.cpp`
- `Core/PropertyRouter.cpp`
- `Core/SensorRegistry.cpp`
- `Core/ExBoardConfigManager.cpp`
- `PowerTune/Core/ExBoardAnalog.qml`
- `PowerTune/Dashboard/RaceDash.qml`
- related model classes in `Core/Models/`

Audit focus:

- full runtime flow from UDP/CAN input to QML binding
- Steinhart NTC coefficient, divider, and runtime temperature calculation flow
- persistence and reload symmetry for all extender-related configuration
- sensor registry and property router integration
- performance risks in hot paths
- integration completeness and comment quality

## Method

This was a static code audit. It did not include:

- live CAN bus runtime capture
- device-side persistence round-trip testing
- QML interaction testing on hardware
- profiling with sampled runtime traces

The findings below are based on source inspection and code-path tracing.

## End-to-End Flow

### 1. UDP telemetry path

1. `Utils/UDPReceiver.cpp` receives datagrams on UDP port `45454`
2. packets are parsed into `ident,value`
3. `switch`/dispatch logic writes directly into data models such as:
   - `EngineData`
   - `VehicleData`
   - `DigitalInputs`
   - `ExpanderBoardData`
4. `SensorRegistry::markCanSensorActive()` marks mapped keys active
5. QML reads the live values either:
   - directly from context properties such as `Engine`, `Vehicle`, `Expander`
   - indirectly through `PropertyRouter.getValue(...)`

### 2. Direct extender CAN path

1. `Hardware/Extender.cpp` opens the CAN interface and listens for `framesReceived`
2. `readyToRead()` parses extender-related CAN frames
3. raw EX digital values are written into `DigitalInputs`
4. raw EX analog values are written into `ExpanderBoardData`
5. raw EX analog changes trigger `Extender::applyCalibration(...)`
6. calibrated values are written into `EXAnalogCalc0-7`
7. derived gear/speed logic updates `EXGear` and `EXSpeed`
8. QML reads these values directly or through `PropertyRouter`

### 3. Persistence / restore path

1. UI changes flow through `ExBoardAnalog.qml`
2. `ExBoardConfigManager` and `AppSettings` persist settings
3. `AppSettings::readandApplySettings()` restores:
   - EX linear calibration
   - NTC enable flags
   - Steinhart coefficients
   - divider jumper settings
   - gear sensor config
   - speed sensor config
4. restored values are reapplied to `Extender` and `SteinhartCalculator`

### 4. QML binding path

1. `Core/connect.cpp` exposes models/services to QML
2. `Core/PropertyRouter.cpp` maps model properties to runtime lookup keys
3. dashboards and widgets subscribe via direct bindings or router-based dynamic bindings
4. user-selectable dashboard inputs depend on the property surface exposed by
   `PropertyRouter` and `SensorRegistry`

## Findings

## High Severity

### 1. Live derived extender properties are not exposed cleanly through the selectable sensor flow

Files:

- `Hardware/Extender.cpp`
- `Core/Models/DigitalInputs.h`
- `Core/Models/ExpanderBoardData.h`
- `Core/SensorRegistry.cpp`
- `Core/PropertyRouter.cpp`
- `PowerTune/Settings/components/SensorPicker.qml`

Details:

- live derived properties exist and are updated:
  - `frequencyDIEX1`
  - `EXGear`
  - `EXSpeed`
- those properties are readable through their owning models and discoverable by
  `PropertyRouter`
- but `SensorPicker` depends on `SensorRegistry`, and `SensorRegistry` does not
  register those derived keys as selectable sensors

Impact:

- real translated/derived data exists but is not reliably available to
  user-selectable dashboards
- property exposure is incomplete even when runtime calculations are working

Assessment:

- property-surface integration bug
- high confidence

### 2. Calibrated extender channels are live properties but are not marked active correctly

Files:

- `Hardware/Extender.cpp`
- `Core/Models/ExpanderBoardData.h`
- `Core/SensorRegistry.cpp`
- `PowerTune/Settings/components/SensorPicker.qml`

Details:

- raw `EXAnalogInput0-7` updates trigger `Extender::applyCalibration()`
- `applyCalibration()` writes live translated values into `EXAnalogCalc0-7`
- `SensorRegistry` registers `EXAnalogCalc0-7`
- but only raw `EXAnalogInput*` keys are passed to `markCanSensorActive()`

Impact:

- translated/calibrated channels can be changing correctly while the active
  sensor flow treats them as inactive
- picker filtering and sensor-state visibility become misleading

Assessment:

- property activity classification bug
- high confidence

### 3. Some UDP GPS keys can be marked active even when no property is updated

Files:

- `Utils/UDPReceiver.cpp`
- `Core/Models/GPSData.h`
- `Core/SensorRegistry.cpp`

Details:

- GPS keys such as `gpsAltitude`, `gpsLatitude`, `gpsLongitude`, `gpsSpeed`, and
  `gpsbearing` are present in liveness mapping
- the reviewed dispatch path uses no-op handlers for those UDP identifiers in the
  current table
- `SensorRegistry` can therefore mark GPS keys active even though `GPSData`
  itself is not receiving the values from those packets

Impact:

- active-state metadata can claim live GPS data exists when the underlying
  property value is stale
- this is a direct correctness problem in the property surface

Assessment:

- property correctness bug
- high confidence

### 4. Main disconnect path does not stop extender CAN updates

Files:

- `Core/connect.cpp`
- `Hardware/Extender.cpp`

Details:

- `Connect::openConnection()` starts both:
  - `m_extender->openCAN(...)`
  - `m_udpreceiver->startreceiver()`
- `Connect::closeConnection()` stops only:
  - calculations
  - UDP receiver
- `Extender::closeConnection()` exists but is not called

Impact:

- extender-originated model updates can continue after the app reports disconnection
- diagnostics, UI state, and user assumptions can diverge from actual runtime behavior

Assessment:

- functional bug
- architecture/integration issue
- high confidence

### 5. Linear preset voltage ranges are ignored by runtime calibration

Files:

- `Utils/CalibrationHelper.cpp`
- `Core/ExBoardConfigManager.cpp`
- `Hardware/Extender.cpp`
- `PowerTune/Core/ExBoardAnalog.qml`

Details:

- `CalibrationHelper` defines presets with:
  - `val0v`
  - `val5v`
  - `minVoltage`
  - `maxVoltage`
- this implies support for sensors whose real electrical output is not `0-5V`
- `ExBoardConfigManager::applyLinearPreset()` persists only value endpoints
- `Extender::applyCalibration()` always uses:
  - `cal.val0v + (voltage / 5.0) * (cal.val5v - cal.val0v)`

Impact:

- sensors like `0.5-4.5V` pressure transducers calculate incorrectly
- preset UI suggests capability that runtime does not actually implement
- persisted preset behavior is mathematically inconsistent with its own metadata

Assessment:

- calibration correctness bug
- high risk for real sensor interpretation
- high confidence

### 6. EX-board speed configuration is not fully integrated into the app-wide speed source

Files:

- `Core/ExBoardConfigManager.cpp`
- `Core/appsettings.cpp`
- `Hardware/Extender.cpp`
- `Utils/UDPReceiver.cpp`
- `PowerTune/Settings/MainSettings.qml`

Details:

- EX-board speed settings are saved and restored
- runtime updates `Expander.EXSpeed`
- main app speed behavior is still controlled separately through startup/main speed settings
- EX-board speed config does not appear to own or automatically align the app's primary speed source

Impact:

- translated speed data can exist in `EXSpeed` without becoming the app's
  canonical speed property where users expect it
- persistence exists without complete property-surface integration

Assessment:

- integration bug
- high confidence

### 7. Saved digital speed input selection is ignored at runtime

Files:

- `PowerTune/Core/ExBoardAnalog.qml`
- `Core/appsettings.cpp`
- `Hardware/Extender.cpp`

Details:

- UI persists `digitalPort`
- `AppSettings` restores `digitalPort`
- runtime speed input still uses only `DigitalInputs::frequencyDIEX1Changed`
- `onSpeedSourceChanged()` reads only `frequencyDIEX1()`

Impact:

- EX Digital 2-8 are dead options for digital speed input
- saved configuration can look valid while doing nothing

Assessment:

- user-visible config integrity bug
- high confidence

## Medium Severity

### 8. UDP and direct CAN can both write the same extender model properties

Files:

- `Utils/UDPReceiver.cpp`
- `Hardware/Extender.cpp`
- `Core/connect.cpp`

Details:

- UDP idents `900-915` update EX digital/analog model fields
- direct extender CAN updates the same model fields
- both paths are enabled together by `Connect::openConnection()`

Impact:

- if daemons also emit extender-derived data, model state becomes last-writer-wins
- source ownership is ambiguous
- debugging and validation become difficult

Assessment:

- data ownership / arbitration issue
- medium-high confidence

### 9. ECU calculated analog channels are advertised but appear to have no live producer

Files:

- `Core/Models/AnalogInputs.h`
- `Core/Models/AnalogInputs.cpp`
- `Core/SensorRegistry.cpp`

Details:

- `AnalogCalc0-10` are exposed as model properties
- `SensorRegistry` registers them as selectable calculated analog channels
- no active runtime writer was found in the reviewed UDP/extender/calibration flow

Impact:

- user-selectable dashboards can be offered calculated analog properties that are
  effectively dead
- property exposure is broader than actual live translation support

Assessment:

- stale property-surface bug
- medium-high confidence

### 10. Sensor registry does not cleanly represent computed extender values

Files:

- `Core/SensorRegistry.cpp`
- `Hardware/Extender.cpp`
- `PowerTune/Settings/components/SensorPicker.qml`

Details:

- `EXAnalogCalc0-7` are registered
- raw EX analog/digital activity is tracked
- computed `EXGear` and `EXSpeed` are not integrated as clean selectable/live registry entries
- picker and overlay flows depend on `SensorRegistry`

Impact:

- live computed sensors are missing or misleading in selection UI
- configurable overlays cannot reliably discover the full active signal surface

Assessment:

- integration gap
- medium confidence

### 11. EX analog/digital enabled flags are saved but not enforced

Files:

- `Core/ExBoardConfigManager.cpp`
- `Core/SensorRegistry.cpp`
- `Hardware/Extender.cpp`

Details:

- channel enable keys such as `ui/exboard/ch*_enabled` and `di*_enabled` are persisted
- runtime still processes and registers all EX channels
- registry refresh does not hide disabled channels

Impact:

- disable toggles are metadata only
- users can believe a channel is disabled when it is still active and selectable

Assessment:

- config/runtime mismatch
- medium confidence

### 12. Some settings persist only on section save buttons

Files:

- `PowerTune/Core/ExBoardAnalog.qml`

Details:

- many analog calibration controls auto-save
- gear/speed sensor sections rely on `Save Gear Config` / `Save Speed Config`
- brightness input selectors do not consistently show direct save/apply hooks

Impact:

- persistence depends on user behavior and section-specific UX knowledge
- config changes can appear applied in the UI but not be committed yet

Assessment:

- UX/integration weakness
- medium confidence

### 13. EX-board brightness channel config is persisted but not clearly consumed at runtime

Files:

- `PowerTune/Core/ExBoardAnalog.qml`
- `Core/ExBoardConfigManager.cpp`
- `Core/ScreenControlService.cpp`

Details:

- brightness source/channel settings are persisted
- reviewed runtime behavior shows enable-state integration more clearly than actual selected channel usage

Impact:

- feature may be partially implemented or misleading in the current UI

Assessment:

- probable integration gap
- medium confidence

## Low Severity

### 14. UDP ingest path does avoidable parsing/allocation work

Files:

- `Utils/UDPReceiver.cpp`

Details:

- each packet becomes a `QString`
- packet parsing uses `split(",")` into a `QStringList`
- `toInt()` and `toFloat()` are done eagerly
- string handlers still pay numeric conversion cost

Impact:

- unnecessary per-packet overhead on a hot path
- likely acceptable at low rates, suboptimal at sustained telemetry rates

Assessment:

- performance issue
- high confidence

### 15. Extender CAN ingest path does avoidable per-frame string/meta work

Files:

- `Hardware/Extender.cpp`
- `Core/Models/CanFrameModel.cpp`
- `Core/Models/ConnectionData.cpp`

Details:

- hot path performs unnecessary string/debug work
- active sensor key names are built repeatedly with `QStringLiteral(...).arg(...)`
- frame updates fan into CAN monitor tracking and connection update paths

Impact:

- avoidable overhead on busy CAN buses

Assessment:

- performance issue
- medium-high confidence

### 16. PropertyRouter design is functionally broad but not performance-optimized

Files:

- `Core/PropertyRouter.cpp`
- `PowerTune/Gauges/RaceDash/*.qml`

Details:

- initialization scans many `Q_PROPERTY`s
- change forwarding uses sender/metaobject reflection
- emits a global `valueChanged(QString, QVariant)` relay
- multiple QML widgets filter those notifications in JS

Impact:

- higher runtime cost than more direct bindings
- duplicate-property ambiguity risk due to first-model-wins mapping

Assessment:

- architectural/performance concern
- medium confidence

- low-medium confidence

## Steinhart NTC Assessment

## Implementation Quality

Reviewed file:

- `Utils/SteinhartCalculator.cpp`

Observed strengths:

- channel bounds are checked consistently
- coefficients are computed from three calibration points
- Celsius/Kelvin conversion is explicit
- voltage divider resistance is computed through dedicated helper logic
- invalid or uncalibrated states return `nan` or safe fallback behavior
- runtime temperature path is clear:
  - voltage
  - resistance
  - Steinhart-Hart equation
  - Celsius output

## Integration Assessment

The Steinhart calculation logic is stronger than the surrounding integration.

What appears correct:

- coefficients are persisted through `AppSettings`
- coefficients are reloaded at startup
- NTC enable flags are persisted and restored
- divider jumper settings are persisted and restored
- `Extender::applyCalibration()` calls `voltageToTemperature()` when:
  - NTC is enabled
  - channel is enabled
  - channel is calibrated

What is still weak:

- channel enable/disable semantics are not enforced consistently across the wider EX-board feature set
- computed values are not represented cleanly in registry/selectable sensor flows
- comments and presets imply a more complete linear-calibration voltage-range system than runtime actually supports

## Conclusion

Steinhart itself does not appear to be the primary defect area. The main risks are:

- runtime integration completeness
- settings-to-runtime symmetry
- property-surface correctness and activity classification

## Persistence Assessment

## Working / Mostly Symmetric

The following persistence paths appear broadly implemented end-to-end:

- EX linear calibration values (`EXA00`-`EXA75`)
- Steinhart coefficients (`T*`, `R*`)
- NTC enable flags (`steinhartcalc*on`)
- divider jumper values (`AN*R3VAL`, `AN*R4VAL`)
- RPM divider settings
- gear sensor config map
- speed sensor config map

## Not Fully Reliable End-to-End

The following are persisted but not fully trustworthy in runtime behavior:

- speed `digitalPort`
- EX analog/digital enabled flags
- brightness source/channel settings
- EX-board speed becoming the main dashboard speed source

## Performance Assessment

## Main Hot-Path Concerns

Most likely hot-path overhead comes from:

- UDP packet parsing in `UDPReceiver`
- CAN frame processing and monitoring fan-out in `Extender`
- reflective `PropertyRouter` fan-out plus QML-side filtering

## Not Primary Bottlenecks

The audit did not identify Steinhart floating-point math itself as the dominant
runtime cost. The larger performance problem is surrounding string, QVariant,
reflection, and broad notification fan-out.

## Comments and Integration Quality

## Positive

- many calibration-related functions already have useful comments
- responsibilities are reasonably separated by file
- persistence is centralized instead of scattered

## Problems

- some comments/documented intent no longer match runtime behavior
- linear preset metadata implies voltage-range support that runtime does not honor
- several settings are represented as if complete features exist, but runtime integration is partial

## Overall Assessment

Code comments are acceptable, but integration accuracy is not yet at the same level.

## Recommended Remediation Order

### Phase 1: Correctness

1. Register and expose all intended live derived properties through the same
   selectable sensor flow used by dashboards
2. Fix GPS property correctness so active-state mapping only reflects data that
   is actually written to `GPSData`
3. Stop extender CAN in `Connect::closeConnection()`
4. Implement real voltage-span-aware linear calibration, or remove misleading preset metadata
5. Make EX-board speed configuration drive the app's main speed source consistently
6. Either implement `digitalPort` selection or constrain the UI to DI1 only

### Phase 2: Integration Completeness

1. Decide whether UDP or direct CAN owns extender data, then enforce that ownership
2. Register computed EX sensors cleanly in `SensorRegistry`
3. Mark translated/calibrated sensors active correctly
4. Remove or fix selectable dead properties such as `AnalogCalc0-10` if they are unsupported
5. Enforce EX enabled flags in runtime and picker visibility
6. Standardize save/apply behavior across all EX-board settings

### Phase 3: Performance

1. reduce UDP parsing allocations
2. remove avoidable per-frame string/debug work in extender processing
3. reduce broad PropertyRouter notification fan-out where possible
4. cache repeated sensor key strings in hot loops

## Verification Checklist

After fixes, verify all of the following:

- derived extender properties appear in the same selectable property flow as raw properties
- calibrated extender properties report active status when they are being updated
- GPS properties only report active when `GPSData` is actually being updated
- disconnecting stops both UDP and extender CAN updates
- a `0.5-4.5V` linear pressure preset produces correct scaled values
- NTC channels 0-5 restore coefficients and output stable temperatures after reboot
- divider jumper settings change runtime temperature calculation as expected
- EX speed on analog mode updates `EXSpeed` correctly
- EX speed on digital mode uses the selected digital channel
- enabling EX-board speed updates the app's main speed source where intended
- sensor picker shows computed extender signals that are intended to be selectable
- disabled EX channels disappear from selection flows or stop updating
- unsupported selectable properties such as dead `AnalogCalc*` channels are removed or implemented
- no duplicate-source race occurs between UDP and direct CAN extender writers

## Final Conclusion

The extender/UDP/calibration subsystem is structurally close to workable, but it
is not yet fully correct or complete.

The main problems are not the Steinhart formula itself. The primary defects are:

- incomplete or misleading property exposure
- incorrect activity/state translation in the selectable sensor flow
- incomplete disconnect behavior
- partial or misleading configuration integration
- calibration metadata not honored at runtime
- performance inefficiencies in the hottest ingest and routing paths

Until the high-severity items are fixed, this subsystem should not be considered
fully validated for production calibration-sensitive use.
