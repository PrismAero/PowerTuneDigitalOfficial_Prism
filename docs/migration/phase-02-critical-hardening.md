# Phase 02 - Critical Hardening

## Scope

Address high-risk runtime failures found in the QRC audit and static review: dashboard loader disconnects, unsafe JSON parsing, keyboard focus guard logic, and inconsistent boost warning source handling.

## Changes Made

- Dashboard source pathing hardening:
  - Updated `PowerTune/Settings/DashSelector.qml` to use `Qt.resolvedUrl(...)` rather than mixed hardcoded qrc roots.
- JSON parse safety:
  - Added `try/catch` guards around stored dashboard parsing in:
    - `PowerTune/Dashboard/UserDashboard.qml`
    - `PowerTune/Gauges/Views/Cluster.qml`
    - `PowerTune/Gauges/Shared/GaugeFactory.qml`
- Dashboard sensor extra-loader path hardening:
  - Updated `PowerTune/Dashboard/UserDashboard.qml` PFCSensors loader to `Qt.resolvedUrl(...)`.
- Keyboard focus guard fix:
  - Corrected read-only gating logic in `PowerTune/Core/Main.qml` to avoid always-true `hasOwnProperty` condition.
- Boost warning consistency:
  - Updated `PowerTune/Gauges/Shared/WarningLoader.qml` to route both `onPimChanged` and `onBoostpresChanged` through one `updateBoostWarning()` function with fallback behavior.
  - Rewrote warning condition handlers to remove comma-expression style and improve behavior clarity.

## Validation

- Static validation:
  - Updated files pass parser/lint checks without introducing new blocking diagnostics.
- Behavioral expectations:
  - Invalid persisted dashboard JSON no longer aborts dashboard startup path.
  - Keyboard no longer auto-shows based on malformed read-only guard condition.
  - Boost warning logic now handles both historic and current signal/property naming paths.

## Rollback

- All changes are isolated to QML files in `PowerTune/*` and can be reverted by phase commit.
- No schema, data format, or display geometry changes were introduced.

## Follow-Up

- Phase 03 will separate non-gauge UI module concerns from dashboard theming and continue reducing cross-module coupling.
