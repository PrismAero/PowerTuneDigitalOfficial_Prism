// * Qt6-compatible Gauge - drop-in replacement for QtQuick.Extras 1.4 Gauge
// * Linear bar gauge with full API compatibility

import QtQuick 2.15

Item {
    id: root

    // * Public API - matches QtQuick.Extras.Gauge
    property real value: 0
    property real minimumValue: 0
    property real maximumValue: 100
    property int orientation: Qt.Vertical
    property int tickmarkAlignment: Qt.AlignLeft
    property int tickmarkStepSize: maximumValue > 0 ? maximumValue / 4 : 25
    property int minorTickmarkCount: 4
    property font font: Qt.font({ pixelSize: 12 })

    // * Style property - accepts inline GaugeStyle { } or style object
    property QtObject style: null

    // * Internal calculations
    readonly property bool isVertical: orientation === Qt.Vertical
    readonly property real valueRatio: {
        var range = maximumValue - minimumValue;
        if (range === 0) return 0;
        return Math.max(0, Math.min(1, (value - minimumValue) / range));
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

    // * Background
    Loader {
        id: backgroundLoader
        anchors.fill: parent
        sourceComponent: style && style.background ? style.background : null
    }

    // * Track area (contains value bar)
    Rectangle {
        id: trackArea
        color: "#404040"
        
        // * Position based on tickmark alignment
        anchors {
            left: isVertical && tickmarkAlignment === Qt.AlignRight ? parent.left : undefined
            right: isVertical && tickmarkAlignment === Qt.AlignLeft ? parent.right : undefined
            top: !isVertical && tickmarkAlignment === Qt.AlignBottom ? parent.top : undefined
            bottom: !isVertical && tickmarkAlignment === Qt.AlignTop ? parent.bottom : undefined
            verticalCenter: isVertical ? parent.verticalCenter : undefined
            horizontalCenter: !isVertical ? parent.horizontalCenter : undefined
        }

        width: isVertical ? parent.width * 0.3 : parent.width
        height: isVertical ? parent.height : parent.height * 0.3

        // * Value bar
        Loader {
            id: valueBarLoader
            sourceComponent: style && style.valueBar ? style.valueBar : defaultValueBar

            anchors {
                left: isVertical ? parent.left : undefined
                right: isVertical ? parent.right : undefined  
                bottom: parent.bottom
                top: !isVertical ? parent.top : undefined
            }

            width: isVertical ? parent.width : parent.width * root.valueRatio
            height: isVertical ? parent.height * root.valueRatio : parent.height
        }
    }

    // * Tickmarks and labels
    Repeater {
        id: tickmarksRepeater
        model: {
            var step = style && style.tickmarkStepSize ? style.tickmarkStepSize : root.tickmarkStepSize;
            if (step <= 0) return 0;
            return Math.floor((root.maximumValue - root.minimumValue) / step) + 1;
        }

        Item {
            id: tickmarkItem
            property real stepSize: style && style.tickmarkStepSize ? style.tickmarkStepSize : root.tickmarkStepSize
            property real tickValue: root.minimumValue + index * stepSize
            property real tickPosition: {
                var range = root.maximumValue - root.minimumValue;
                if (range === 0) return 0;
                return (tickValue - root.minimumValue) / range;
            }

            // * Tickmark
            Loader {
                id: tickLoader
                sourceComponent: style && style.tickmark ? style.tickmark : defaultTickmark

                property var styleData: QtObject {
                    readonly property real value: tickmarkItem.tickValue
                    readonly property int index: tickmarkItem.index
                }

                x: isVertical 
                    ? (tickmarkAlignment === Qt.AlignLeft ? 0 : root.width - (item ? item.implicitWidth : 10))
                    : root.width * tickmarkItem.tickPosition - (item ? item.implicitWidth / 2 : 5)
                y: isVertical
                    ? root.height * (1 - tickmarkItem.tickPosition) - (item ? item.implicitHeight / 2 : 1)
                    : (tickmarkAlignment === Qt.AlignTop ? 0 : root.height - (item ? item.implicitHeight : 10))
            }

            // * Label
            Loader {
                id: labelLoader  
                sourceComponent: style && style.tickmarkLabel ? style.tickmarkLabel : defaultLabel

                property var styleData: QtObject {
                    readonly property real value: tickmarkItem.tickValue
                    readonly property int index: tickmarkItem.index
                }

                x: isVertical
                    ? (tickmarkAlignment === Qt.AlignLeft 
                        ? (tickLoader.item ? tickLoader.item.implicitWidth + 4 : 14)
                        : root.width * 0.02)
                    : root.width * tickmarkItem.tickPosition - (item ? item.width / 2 : 0)
                y: isVertical
                    ? root.height * (1 - tickmarkItem.tickPosition) - (item ? item.height / 2 : 0)
                    : (tickmarkAlignment === Qt.AlignTop
                        ? (tickLoader.item ? tickLoader.item.implicitHeight + 4 : 14)
                        : root.height * 0.7)
            }
        }
    }

    // * Minor tickmarks
    Repeater {
        id: minorTickmarksRepeater
        model: {
            var step = style && style.tickmarkStepSize ? style.tickmarkStepSize : root.tickmarkStepSize;
            var minorCount = style && style.minorTickmarkCount !== undefined ? style.minorTickmarkCount : root.minorTickmarkCount;
            if (step <= 0 || minorCount <= 0) return 0;
            var majorCount = Math.floor((root.maximumValue - root.minimumValue) / step);
            return majorCount * minorCount;
        }

        Loader {
            id: minorTickLoader
            property real stepSize: style && style.tickmarkStepSize ? style.tickmarkStepSize : root.tickmarkStepSize
            property int minorCount: style && style.minorTickmarkCount !== undefined ? style.minorTickmarkCount : root.minorTickmarkCount
            property int majorIndex: Math.floor(index / minorCount)
            property int minorIndex: index % minorCount
            property real minorStep: stepSize / (minorCount + 1)
            property real tickValue: root.minimumValue + majorIndex * stepSize + (minorIndex + 1) * minorStep
            property real tickPosition: {
                var range = root.maximumValue - root.minimumValue;
                if (range === 0) return 0;
                return (tickValue - root.minimumValue) / range;
            }

            sourceComponent: style && style.minorTickmark ? style.minorTickmark : defaultMinorTickmark

            property var styleData: QtObject {
                readonly property real value: minorTickLoader.tickValue
                readonly property int index: minorTickLoader.index
            }

            x: isVertical
                ? (tickmarkAlignment === Qt.AlignLeft ? 0 : root.width - (item ? item.implicitWidth : 5))
                : root.width * tickPosition - (item ? item.implicitWidth / 2 : 2)
            y: isVertical
                ? root.height * (1 - tickPosition) - (item ? item.implicitHeight / 2 : 0)
                : (tickmarkAlignment === Qt.AlignTop ? 0 : root.height - (item ? item.implicitHeight : 5))
        }
    }

    // * Foreground
    Loader {
        id: foregroundLoader
        anchors.fill: parent
        sourceComponent: style && style.foreground ? style.foreground : null
    }

    // * Default components
    Component {
        id: defaultValueBar
        Rectangle {
            implicitWidth: 20
            implicitHeight: 20
            color: Qt.rgba(root.value / root.maximumValue, 0, 1 - root.value / root.maximumValue, 1)
        }
    }

    Component {
        id: defaultTickmark
        Rectangle {
            implicitWidth: isVertical ? 10 : 2
            implicitHeight: isVertical ? 2 : 10
            color: "#c8c8c8"
        }
    }

    Component {
        id: defaultMinorTickmark
        Rectangle {
            implicitWidth: isVertical ? 5 : 1
            implicitHeight: isVertical ? 1 : 5
            color: "#808080"
        }
    }

    Component {
        id: defaultLabel
        Text {
            text: styleData ? styleData.value : ""
            font: root.font
            color: "#c8c8c8"
        }
    }
}
