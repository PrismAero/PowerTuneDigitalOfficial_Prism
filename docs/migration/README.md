# PowerTune Qt6 Finalization Tracker

This directory tracks phased execution for the full-repo Qt6 finalization and QML module/resource cutover.

## Environment and Targets

- Development host: macOS
- Deployment/runtime target: Yocto (Raspberry Pi class hardware)
- Display contract: fixed `1600x720` (no policy changes in this migration)

## Phase Progress

- `phase-00-baseline.md` - governance, branch baseline, current risks
- `phase-01-qrc-audit.md` - full qrc inventory + qrc usage mapping
- `phase-02-critical-hardening.md` - critical runtime fixes
- `phase-03-ui-module.md` - new non-gauge UI module
- `phase-04-dashboard-theme.md` - dashboard theming separation
- `phase-05-qt6-finalization.md` - Qt5->Qt6 cleanup and validation
- `phase-06-qrc-cutover.md` - qrc to module cutover
- `phase-07-assets-fonts.md` - resource and font verification
- `phase-08-keyboard.md` - keyboard modernization
- `phase-09-module-governance.md` - module boundaries and import rules
- `final-validation-macos.md` - final host validation summary
- `final-validation-yocto.md` - final target validation summary
- `final-migration-summary.md` - closeout summary

## Required Gate for Each Phase

Each phase must include:

1. Scope and intent
2. Changes made
3. Validation evidence
4. Risk/rollback notes
5. Follow-up items

No phase should be marked complete until the documentation and validation notes are present.
