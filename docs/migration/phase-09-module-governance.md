# Phase 09 - QML Module Governance

## Scope

Define explicit module boundaries and ownership rules to prevent future coupling regressions while preserving Yocto/build artifacts.

## Module Map

- `PowerTune.Core`: app shell and runtime orchestration
- `PowerTune.UI`: shared non-gauge UI primitives and UI theme singleton
- `PowerTune.Settings`: settings pages and integration logic
- `PowerTune.Gauges.Core|Styles|Widgets|Media|Sensors|Shared`: gauge stack
- `PrismPT.Dashboard`: dashboard runtime canvas + dashboard theme
- `Prism.Keyboard`: custom keyboard

## Import Rules

1. Dashboard files should consume `DashboardTheme` and avoid direct dependency on settings UI theme.
2. Settings/menu files should consume `PowerTune.UI` for shared non-gauge primitives.
3. Gauge widgets should not import `PowerTune.UI` to preserve visual autonomy.
4. Resource loading for active QML components should use module-relative resolution, not hardcoded `/qt/qml` qrc paths.

## Artifact Preservation Rule

- `docs-misc`, Yocto-related trees, and build/deployment artifacts remain untouched unless explicitly requested for cleanup.

## Validation

- CMake module graph now includes dedicated `PowerTune.UI` and dashboard theme singleton registration.
- No existing settings component implementation duplication was introduced.

## Follow-Up

- Add CI/static checks for import-boundary violations in future PR workflow.
