# Phase 04 - Dashboard Theme Separation

## Scope

Separate dashboard panel theming from settings/menu theming to preserve creative dashboard freedom while enabling centralized non-gauge UI design.

## Changes Made

- Added dashboard-specific singleton theme:
  - `PowerTune/Dashboard/DashboardTheme.qml`
- Updated dashboard panel components to use dashboard-only tokens:
  - `PowerTune/Dashboard/GaugeCreationMenu.qml`
  - `PowerTune/Dashboard/BackgroundSettingsPanel.qml`
  - `PowerTune/Dashboard/ColorSelectionPanel.qml`
- Updated `CMakeLists.txt`:
  - Registered `DashboardTheme.qml` as singleton
  - Included it in `PrismPT.Dashboard` QML module

## Separation Rule Enforced

- Settings/menu reusable UI tokens are in `PowerTune.UI`.
- Dashboard panel styling uses `PrismPT.Dashboard` theme (`DashboardTheme`) and does not consume `PowerTune.UI` theme directly.

## Validation

- Dashboard panel files compile with theme references in-module.
- No display geometry policy changes were introduced.

## Rollback

- Revert the three dashboard panel files, remove `DashboardTheme.qml`, and undo `CMakeLists.txt` entries.

## Follow-Up

- Expand dashboard theme token usage beyond panel container colors as part of styling consistency work.
