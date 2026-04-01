# UI Orphans Archived (2026-03)

This folder stores QML files that were removed from the active runtime/build graph during the Linux/RPi4 UI remediation pass.

## Archived Files

- `PowerTune_Settings_CanMonitor.qml`
  - Original path: `PowerTune/Settings/CanMonitor.qml`
  - Reason: Not reachable from `SettingsManager.qml` tabs/routes.
- `PowerTune_Core_Intro.qml`
  - Original path: `PowerTune/Core/Intro.qml`
  - Reason: Not loaded by `Main.qml` runtime shell.
- `PowerTune_Dashboard_UserDashboard.qml`
  - Original path: `PowerTune/Dashboard/UserDashboard.qml`
  - Reason: No active runtime routing from shell/dashboard selection.

## Kept In Active Runtime

- `PowerTune/Core/SpeedSensorConfigPopup.qml`
  - Explicitly retained and wired as the primary speed sensor editor.

## Restore Notes

To restore any archived file:
1. Move it back to its original path.
2. Re-add it to `CMakeLists.txt` `qt_add_qml_module` `QML_FILES`.
3. Reconnect runtime navigation/loader references.
4. Validate reachability from `Main.qml` and `SettingsManager.qml`.
