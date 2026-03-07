# Phase 06 - QRC to Module-Based Loader Cutover

## Scope

Remove brittle `qrc:/qt/qml/...` load paths from active `PowerTune` runtime code and switch to module-relative URL resolution.

## Changes Made

- Converted dashboard and gauge loader paths to `Qt.resolvedUrl(...)`:
  - `PowerTune/Settings/DashSelector.qml`
  - `PowerTune/Dashboard/UserDashboard.qml`
  - `PowerTune/Dashboard/BackgroundSettingsPanel.qml`
  - `PowerTune/Gauges/Shared/GaugeFactory.qml`
  - `PowerTune/Gauges/Shared/WarningLoader.qml`
  - `PowerTune/Core/Main.qml`
  - `PowerTune/Gauges/Views/SpeedMeasurements.qml`
- Regenerated QRC analysis artifacts after cutover:
  - `docs/migration/qrc-inventory.json`
  - `docs/migration/qrc-inventory.md`
  - `docs/migration/qrc-usage-map.csv`
  - `docs/migration/qrc-disconnects-and-orphans.md`

## Validation

- `PowerTune/**/*.qml` no longer contains `qrc:/qt/qml/PowerTune` or `qrc:/qt/qml/PrismPT` references.
- Existing non-QML resource paths (`qrc:/Resources/...`) remain intentionally unchanged.

## Rollback

- Revert updated loader files and restore previous absolute qrc paths.

## Follow-Up

- Continue removing legacy qrc loader usage in archived/reference trees only if those trees are brought back into active build/runtime paths.
