// * Qt6-compatible CircularGauge - drop-in replacement for QtQuick.Extras 1.4 CircularGauge
// * Maintains full API compatibility with Qt5 version

import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root

    // * Public API - matches QtQuick.Extras.CircularGauge
    property real value: 0
    property real minimumValue: 0
    property real maximumValue: 100
    property real stepSize: 1

    // * Style property - accepts inline CircularGaugeStyle { } or style object
    property QtObject style: null

    // * Expose these for style components to access
    readonly property real outerRadius: Math.min(width, height) / 2

    // * Helper functions available to style components
    function valueToAngle(val) {
        var minAngle = style ? style.minimumValueAngle : -145;
        var maxAngle = style ? style.maximumValueAngle : 145;
        var range = maximumValue - minimumValue;
        if (range === 0) return minAngle;
        var normalized = (val - minimumValue) / range;
        return minAngle + normalized * (maxAngle - minAngle);
    }

    function toPixels(percentage) {
        return percentage * outerRadius;
    }

    function degToRad(degrees) {
        return degrees * (Math.PI / 180);
    }

    // * Connect style to this control
    onStyleChanged: {
        if (style) {
            style.control = root;
        }
    }

    Component.onCompleted: {
        if (style) {
            style.control = root;
        }
    }

    // * Background layer
    Loader {
        id: backgroundLoader
        anchors.fill: parent
        sourceComponent: style && style.background ? style.background : null
        property real outerRadius: root.outerRadius
        
        onLoaded: {
            if (item) {
                // * Inject outerRadius binding into loaded item if it has the property
                if (typeof item.outerRadius !== 'undefined') {
                    item.outerRadius = Qt.binding(function() { return root.outerRadius; });
                }
            }
        }
    }

    // * Major tickmarks
    Repeater {
        id: majorTickmarksRepeater
        model: {
            var stepSize = style && style.tickmarkStepSize ? style.tickmarkStepSize : 10;
            if (stepSize <= 0) return 0;
            return Math.floor((root.maximumValue - root.minimumValue) / stepSize) + 1;
        }

        Item {
            id: majorTickmarkContainer
            property real tickmarkStepSize: style && style.tickmarkStepSize ? style.tickmarkStepSize : 10
            property real tickValue: root.minimumValue + index * tickmarkStepSize
            property real tickAngle: valueToAngle(tickValue)
            property real inset: style && style.tickmarkInset !== undefined ? style.tickmarkInset : 0

            anchors.centerIn: parent
            width: root.width
            height: root.height

            Loader {
                id: majorTickmarkLoader
                sourceComponent: style && style.tickmark ? style.tickmark : defaultTickmark
                
                // * Position at top center, then rotate
                x: parent.width / 2 - (item ? item.implicitWidth / 2 : 2)
                y: majorTickmarkContainer.inset

                property var styleData: QtObject {
                    readonly property real value: majorTickmarkContainer.tickValue
                    readonly property int index: majorTickmarkContainer.index
                }

                transform: Rotation {
                    origin.x: majorTickmarkLoader.item ? majorTickmarkLoader.item.implicitWidth / 2 : 2
                    origin.y: root.outerRadius - majorTickmarkContainer.inset
                    angle: majorTickmarkContainer.tickAngle
                }
            }
        }
    }

    // * Minor tickmarks  
    Repeater {
        id: minorTickmarksRepeater
        model: {
            var stepSize = style && style.tickmarkStepSize ? style.tickmarkStepSize : 10;
            var minorCount = style && style.minorTickmarkCount !== undefined ? style.minorTickmarkCount : 4;
            if (stepSize <= 0 || minorCount <= 0) return 0;
            var majorCount = Math.floor((root.maximumValue - root.minimumValue) / stepSize);
            return majorCount * minorCount;
        }

        Item {
            id: minorTickmarkContainer
            property real tickmarkStepSize: style && style.tickmarkStepSize ? style.tickmarkStepSize : 10
            property int minorTickmarkCount: style && style.minorTickmarkCount !== undefined ? style.minorTickmarkCount : 4
            property int majorIndex: Math.floor(index / minorTickmarkCount)
            property int minorIndex: index % minorTickmarkCount
            property real minorStep: tickmarkStepSize / (minorTickmarkCount + 1)
            property real tickValue: root.minimumValue + majorIndex * tickmarkStepSize + (minorIndex + 1) * minorStep
            property real tickAngle: valueToAngle(tickValue)
            property real inset: style && style.minorTickmarkInset !== undefined ? style.minorTickmarkInset : (style && style.tickmarkInset !== undefined ? style.tickmarkInset : 0)

            anchors.centerIn: parent
            width: root.width
            height: root.height

            Loader {
                id: minorTickmarkLoader
                sourceComponent: style && style.minorTickmark ? style.minorTickmark : defaultMinorTickmark

                x: parent.width / 2 - (item ? item.implicitWidth / 2 : 1)
                y: minorTickmarkContainer.inset

                property var styleData: QtObject {
                    readonly property real value: minorTickmarkContainer.tickValue
                    readonly property int index: minorTickmarkContainer.index
                }

                transform: Rotation {
                    origin.x: minorTickmarkLoader.item ? minorTickmarkLoader.item.implicitWidth / 2 : 1
                    origin.y: root.outerRadius - minorTickmarkContainer.inset
                    angle: minorTickmarkContainer.tickAngle
                }
            }
        }
    }

    // * Tickmark labels
    Repeater {
        id: labelsRepeater
        model: {
            var stepSize = style && style.labelStepSize ? style.labelStepSize : (style && style.tickmarkStepSize ? style.tickmarkStepSize : 10);
            if (stepSize <= 0) return 0;
            return Math.floor((root.maximumValue - root.minimumValue) / stepSize) + 1;
        }

        Loader {
            id: labelLoader
            property real labelStepSize: style && style.labelStepSize ? style.labelStepSize : (style && style.tickmarkStepSize ? style.tickmarkStepSize : 10)
            property real labelValue: root.minimumValue + index * labelStepSize
            property real labelAngle: valueToAngle(labelValue)
            property real labelInset: style && style.labelInset !== undefined ? style.labelInset : root.outerRadius * 0.25
            property real labelRadius: root.outerRadius - labelInset

            sourceComponent: style && style.tickmarkLabel ? style.tickmarkLabel : defaultLabel

            property var styleData: QtObject {
                readonly property real value: labelLoader.labelValue
                readonly property int index: labelLoader.index
            }

            x: root.width / 2 + labelRadius * Math.sin(degToRad(labelAngle)) - (item ? item.width / 2 : 0)
            y: root.height / 2 - labelRadius * Math.cos(degToRad(labelAngle)) - (item ? item.height / 2 : 0)
        }
    }

    // * Needle
    Loader {
        id: needleLoader
        sourceComponent: style && style.needle ? style.needle : defaultNeedle
        
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height / 2 - (item ? item.implicitHeight : root.outerRadius * 0.8)

        property var styleData: QtObject {
            readonly property real value: root.value
        }

        transform: Rotation {
            origin.x: needleLoader.item ? needleLoader.item.implicitWidth / 2 : root.outerRadius * 0.015
            origin.y: needleLoader.item ? needleLoader.item.implicitHeight : root.outerRadius * 0.8
            angle: valueToAngle(root.value)
        }
    }

    // * Foreground layer (center cap, etc)
    Loader {
        id: foregroundLoader
        anchors.centerIn: parent
        sourceComponent: style && style.foreground ? style.foreground : null
        property real outerRadius: root.outerRadius
    }

    // * Default components
    Component {
        id: defaultTickmark
        Rectangle {
            implicitWidth: root.toPixels(0.02)
            implicitHeight: root.toPixels(0.06)
            color: "#c8c8c8"
            antialiasing: true
        }
    }

    Component {
        id: defaultMinorTickmark
        Rectangle {
            implicitWidth: root.toPixels(0.01)
            implicitHeight: root.toPixels(0.03)
            color: "#808080"
            antialiasing: true
        }
    }

    Component {
        id: defaultLabel
        Text {
            text: styleData ? styleData.value : ""
            font.pixelSize: Math.max(6, root.toPixels(0.08))
            color: "#c8c8c8"
            antialiasing: true
        }
    }

    Component {
        id: defaultNeedle
        Rectangle {
            implicitWidth: root.toPixels(0.03)
            implicitHeight: root.outerRadius * 0.8
            color: "#e34c22"
            antialiasing: true
        }
    }
}
