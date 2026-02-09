// * Qt6-compatible CircularGaugeStyle - drop-in replacement for QtQuick.Controls.Styles 1.4
// * Can be used as root element: CircularGaugeStyle { } or inherited from
// ! IMPORTANT: Style components (needle, background, etc.) must access helper functions
// ! and properties through their parent style object, not directly.
// ! Use Qt.binding or reference via 'gauge.style.toPixels(...)' pattern

import QtQuick 2.15

QtObject {
    id: styleRoot

    // * Reference to the parent CircularGauge (set automatically by gauge)
    property Item control: null

    // * Computed property from control - exposed for style components
    readonly property real outerRadius: control ? Math.min(control.width, control.height) / 2 : 100
    
    // * Expose the gauge's value for style components
    readonly property real value: control ? control.value : 0
    readonly property real minimumValue: control ? control.minimumValue : 0
    readonly property real maximumValue: control ? control.maximumValue : 100

    // * Style configuration properties - match Qt5 API exactly
    property real minimumValueAngle: -145
    property real maximumValueAngle: 145
    property real tickmarkStepSize: 10
    property int minorTickmarkCount: 4
    property real labelStepSize: tickmarkStepSize
    property real tickmarkInset: 0
    property real minorTickmarkInset: tickmarkInset
    property real labelInset: outerRadius * 0.25

    // * Component properties for customization
    property Component needle: null
    property Component background: null
    property Component foreground: null
    property Component tickmark: null
    property Component minorTickmark: null
    property Component tickmarkLabel: null

    // * Helper functions - available to style components and subclasses
    function toPixels(percentage) {
        return percentage * outerRadius;
    }

    function valueToAngle(value) {
        if (!control) return minimumValueAngle;
        var range = control.maximumValue - control.minimumValue;
        if (range === 0) return minimumValueAngle;
        var normalized = (value - control.minimumValue) / range;
        return minimumValueAngle + normalized * (maximumValueAngle - minimumValueAngle);
    }

    function degToRad(degrees) {
        return degrees * (Math.PI / 180);
    }

    function radToDeg(radians) {
        return radians * (180 / Math.PI);
    }
    
    // * Expose angleRange for TachometerStyle compatibility
    readonly property real angleRange: maximumValueAngle - minimumValueAngle
}
