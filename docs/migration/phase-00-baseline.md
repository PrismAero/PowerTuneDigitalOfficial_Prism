# Phase 00 - Governance and Baseline

## Scope

Establish branch and documentation governance before implementation and capture baseline repository state for migration work.

## Branch and Workflow

- Working branch: `feature/qt6-finalization-qml-cutover`
- Base branch target: `dev`
- Commit policy for this migration:
  - scoped commits during each phase
  - one explicit phase-complete commit after documentation
  - detailed commit messages focused on rationale

## Baseline Snapshot

- Repo contained local in-progress gauge section edits before branch switch:
  - `PowerTune/Gauges/Shared/NumericStepper.qml`
  - `PowerTune/Gauges/Shared/RangeSection.qml`
  - `PowerTune/Gauges/Shared/SizeSection.qml`
- `dev` branch had `RangeSection.qml` and `SizeSection.qml` deleted; local versions were intentionally restored on feature branch to preserve active work and keep gauge config UI functional.

## Known High-Risk Areas (Pre-Change)

1. QRC/module path inconsistencies (`PrismPT` vs `PowerTune`, nested duplicate segments)
2. Unprotected dashboard JSON parsing paths
3. Keyboard focus detection edge cases in `Main.qml`
4. Mixed boost source naming (`pim` and `BoostPres`)
5. Broad dependency on literal qrc loader strings instead of module component loading

## Validation Evidence

- Verified repository branch state and local branch availability.
- Confirmed existing Qt/QML module wiring in `CMakeLists.txt` and legacy `qml.qrc` coexistence.

## Rollback

- Branch-isolated work; rollback by reverting commits in this feature branch.
- Stash entry from branch switch retained in local stash history for safety.

## Follow-Ups

- Execute exhaustive qrc inventory and usage graph generation in Phase 01.
