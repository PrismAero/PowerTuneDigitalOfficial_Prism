# Phase 03 - PowerTune.UI Module

## Scope

Create a centralized non-gauge UI module without duplicating component implementations.

## Changes Made

- Added `PowerTune.UI` singleton theme:
  - `PowerTune/UI/Theme.qml`
- Extended `CMakeLists.txt`:
  - Added `PowerTuneUiLib` module registration
  - Exported shared non-gauge components through `PowerTune.UI`
  - Added `PowerTune/UI` to `QML_IMPORT_PATH`
- Kept a single source of truth for settings UI components:
  - Real implementations stay in `PowerTune/Settings/components/*`
  - `PowerTune.UI` module references those same files directly

## Rationale

This avoids dual component hierarchies and wrapper indirection while still centralizing UI ownership in a dedicated module namespace.

## Validation

- No linter errors introduced by module wiring changes.
- Existing settings component files remain intact and continue to be used directly.

## Rollback

- Revert `CMakeLists.txt` `PowerTuneUiLib` additions and remove `PowerTune/UI/Theme.qml`.

## Follow-Up

- Gradually migrate imports in settings/menu pages to `PowerTune.UI` namespace where safe.
