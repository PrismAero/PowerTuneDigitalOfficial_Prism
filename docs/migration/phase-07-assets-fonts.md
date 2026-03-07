# Phase 07 - Assets and Fonts Verification

## Scope

Verify that active graphics/font references are registered and available, with focus on migration safety for macOS and Yocto targets.

## Changes Made

- Added verification automation:
  - `Scripts/migration/verify_assets.py`
- Generated verification artifacts:
  - `docs/migration/assets-fonts-verification.json`
  - `docs/migration/assets-fonts-verification.md`

## Validation Highlights

- `MaterialSymbolsOutlined.ttf` exists on disk and is registered in `qml.qrc`.
- Active `qrc:/Resources/...` references are reconciled against `qml.qrc` registrations.
- Unreferenced graphics/font entries are documented for later cleanup decisions.

## Rollback

- Remove verification script and generated reports if this phase is reworked.

## Follow-Up

- Validate deployment packaging includes all required resources on Yocto image.
- Review unreferenced entries against intentional reserve assets before removing anything.
