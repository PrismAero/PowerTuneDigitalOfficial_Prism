# PowerTune Dashboard

Minimal dashboard shell. All gauge widgets, styles, and the old creation/serialization
infrastructure have been removed. This shell renders a blank screen with a warning
overlay and persists background color and image via `Qt.labs.settings`.

## Files

| File | Purpose |
|------|---------|
| `UserDashboard.qml` | Blank dashboard shell with background, warning overlay, and double-tap placeholder |
| `DashboardTheme.qml` | Singleton theme for dashboard panel styling (background, border, text, radius) |

## Warning System

The warning system is self-contained in `PowerTune/Gauges/Shared/`:

```
WarningLoader.qml
  |-- Listens to Engine.rpm, Engine.Watertemp, Engine.Knock, Engine.pim/BoostPres
  |-- Compares values against Settings.rpmwarn, Settings.waterwarn, etc.
  |-- On threshold breach: loads Warning.qml with the warning message
  |
  +-> Warning.qml
        Flashing red/orange rectangle overlay with "Warning!!!" + detail text
```

`WarningLoader` is embedded inside `UserDashboard.qml` at z-index 300 so it
renders above all other content. It connects directly to the C++ `Engine` context
property and the `Settings` context property for thresholds.

## Datasource Binding Flow

Datasource infrastructure is preserved in `PowerTune/Gauges/Shared/` for future
gauge components to consume:

```
DatasourcesList.qml          ~400 ListElement entries
       |                     Each has: sourcename, titlename, maxvalue,
       |                     decimalpoints, defaultsymbol, stepsize, divisor
       v
DatasourceService.qml        Singleton (pragma Singleton)
       |                     Normalizes raw entries into allSources ListModel
       |                     Provides: allSources, filteredSources, getBySourceName()
       v
[Future gauge component]     Reads DatasourceService.allSources to populate
       |                     source selection UI, then binds via:
       v
PropertyRouter.getValue()    C++ context property
       |                     Maps property names to domain models
       v
Engine / Vehicle / GPS       The actual telemetry data models
```

### PropertyRouter API (C++)

Exposed as `PropertyRouter` context property in QML:

- `getValue(propertyName)` - Returns the current value from the owning domain model
- `getModelName(propertyName)` - Returns which model owns the property (e.g. "Engine")
- `hasProperty(propertyName)` - Returns whether the property exists in any model

### Binding Pattern

To bind a gauge to a datasource:

```qml
property string mainvaluename: "rpm"
property real value: 0

Component.onCompleted: {
    if (mainvaluename)
        value = Qt.binding(function() {
            return PropertyRouter.getValue(mainvaluename);
        });
}
```

## What Was Removed

The following were removed to create a clean slate for the new gauge system:

### Dashboard files removed
- `GaugeCreationMenu.qml` - Gauge creation UI (depended on GaugeFactory)
- `ColorSelectionPanel.qml` - Square gauge color editor (depended on ColorList)
- `BackgroundSettingsPanel.qml` - RPM bar and background settings (depended on ColorList, deleted styles)

### Gauges/Core (entire module removed)
- `CircularGauge.qml`, `CircularGaugeStyle.qml`, `Gauge.qml`, `GaugeStyle.qml`

### Gauges/Styles (entire module removed)
- `DashboardGaugeStyle.qml`, `NormalGaugeStyle.qml`, `TachometerStyle.qml`, `RPMBarStyle1.qml`

### Gauges/Widgets (entire module removed)
- `RoundGauge.qml`, `SquareGauge.qml`, `BarGauge.qml`, `RPMBar.qml`, `ShiftLights.qml`,
  `NumericCell.qml`, `GearIndicator.qml`, `ModernRoundGauge.qml`, `MyTextLabel.qml`

### Gauges/Shared files removed
- `GaugeFactory.qml` - Gauge creation/serialization singleton
- `GaugeTheme.qml` - Gauge color theme singleton
- `GaugeConfigMenu.qml` - Runtime gauge configuration overlay
- `GaugeMouseHandler.qml` - Drag/resize handler for gauges
- `ColorList.qml` - Named color palette model
- `ColorComboBox.qml`, `FontComboBox.qml`, `NumericStepper.qml` - Config UI primitives
- Various section components (ArcSettings, Colors, Description, Font, Image, Label,
  Needle, NeedleTrail, Range, SecondarySource, Size, Ticks, UnitSymbol, VisibilityToggles)
- `DatasourceComboBox.qml`, `DatasourceSection.qml`, `WarningRedZoneSection.qml`

## Reconnecting Future Gauge Components

When adding new gauge widgets:

1. Create the widget QML file in `PowerTune/Gauges/Widgets/`
2. Register it in `CMakeLists.txt` under a new `GaugesWidgetsLib` module
3. Import `PowerTune.Gauges.Shared 1.0` to access `DatasourceService`
4. Use the binding pattern above to connect to `PropertyRouter`
5. Add a gauge creation menu in the Dashboard that instantiates the widget
6. The warning system will continue working independently
