// * Qt6-compatible GaugeStyle - drop-in replacement for QtQuick.Controls.Styles 1.4
// * Used with Gauge { style: GaugeStyle { ... } }

import QtQuick 2.15

QtObject {
    id: root

    // * Reference to the parent Gauge (set automatically)
    property Item control: null

    // * Style configuration properties - match Qt5 API exactly
    property real tickmarkStepSize: control ? control.tickmarkStepSize : 25
    property int minorTickmarkCount: control ? control.minorTickmarkCount : 4

    // * Component properties for customization
    property Component valueBar: null
    property Component tickmark: null
    property Component minorTickmark: null
    property Component tickmarkLabel: null
    property Component background: null
    property Component foreground: null
}
