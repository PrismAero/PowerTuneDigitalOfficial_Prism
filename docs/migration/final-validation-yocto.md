# Final Validation - Yocto Target

## Execution Status

- Direct Yocto runtime execution was not performed in this macOS development session.
- This document captures deployment-time checks required for sign-off.

## Required Yocto Validation Checklist

1. Deploy updated binary and qml/resources package to target image.
2. Confirm module loading for:
   - `PowerTune.UI`
   - `PrismPT.Dashboard` (including `DashboardTheme`)
3. Verify dashboard switching and gauge creation/edit flows.
4. Verify dashboard save/load behavior with malformed and valid payloads.
5. Verify keyboard behavior across numeric/text fields and dock/popout transitions.
6. Verify resources:
   - `qrc:/Resources/graphics/*` images load
   - `qrc:/Resources/fonts/MaterialSymbolsOutlined.ttf` icon rendering works
7. Validate no regressions in fixed `1600x720` layout behavior.

## Pass Criteria

- No loader failures or missing-resource errors in runtime logs.
- No startup/parsing crashes on stored dashboard data.
- UI interaction parity with pre-migration behavior.
