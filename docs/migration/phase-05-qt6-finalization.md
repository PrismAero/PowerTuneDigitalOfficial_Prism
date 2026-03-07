# Phase 05 - Qt6 Finalization

## Scope

Finalize core Qt5-to-Qt6 migration cleanup items that are high-impact and low-risk.

## Changes Made

- Removed legacy/unused Qt5-era dialog import:
  - `PowerTune/Gauges/Views/Cluster.qml` no longer imports `QtQuick.Dialogs`.
- Added explicit UI and dashboard singleton registration in CMake:
  - `PowerTune/UI/Theme.qml`
  - `PowerTune/Dashboard/DashboardTheme.qml`
- Kept `Qt.labs.settings 1.0` in place for currently active persisted settings paths to avoid breaking storage behavior during this migration stage.

## Validation

- `QtQuick.Dialogs` import audit in `PowerTune` now returns no matches.
- Lint checks show no new blocking syntax/runtime registration issues from this phase.

## Rollback

- Re-add removed import or revert singleton registration changes in `CMakeLists.txt`.

## Follow-Up

- Replace `Qt.labs.settings 1.0` usages incrementally behind compatibility tests in a dedicated follow-up stream.
