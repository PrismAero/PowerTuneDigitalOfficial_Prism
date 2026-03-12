import QtQuick 2.15
import PowerTune.Gauges.Shared 1.0

Item {
    id: root

    property bool active: false
    property real arcScale: 0.945
    property real arcWidth: 0.285
    property real centerOffsetX: 5
    property real centerOffsetY: 0
    readonly property real centerRadius: (outerRadius + innerRadius) * 0.5
    readonly property real centerX: (width * 0.5) + centerOffsetX
    readonly property real centerY: (height * 0.5) + centerOffsetY
    property bool enabled: false
    property real endAngle: 56
    property bool flashEnabled: true
    property int flashRate: 200
    readonly property real innerRadius: Math.max(0, outerRadius * (1.0 - Math.max(0.01, Math.min(0.95, arcWidth))))
    readonly property real markerAngle: startAngle + (sweepAngle * normalizedThreshold)
    property color markerColor: "#FF0000"
    readonly property real markerLength: Math.max(18, (outerRadius - innerRadius) * 0.92)
    readonly property real markerThickness: Math.max(4, (outerRadius - innerRadius) * 0.18)
    readonly property real markerX: centerX + (Math.sin(radians) * centerRadius)
    readonly property real markerY: centerY - (Math.cos(radians) * centerRadius)
    property real maxValue: 100
    property real minValue: 0
    readonly property real normalizedThreshold: {
        if (maxValue <= minValue)
            return 0;
        return Math.max(0, Math.min(1, (thresholdValue - minValue) / (maxValue - minValue)));
    }
    readonly property real outerRadius: (Math.min(width, height) * 0.5) * Math.max(0.1, arcScale)
    readonly property real radians: markerAngle * Math.PI / 180.0
    property real startAngle: 225
    readonly property real sweepAngle: {
        var start = ((startAngle % 360) + 360) % 360;
        var finish = ((endAngle % 360) + 360) % 360;
        var sweep = finish - start;
        if (sweep < 0)
            sweep += 360;
        return sweep === 0 ? 359.999 : sweep;
    }
    property real thresholdValue: 0

    anchors.fill: parent
    visible: enabled

    WarningFlashTimer {
        id: flashTimer

        active: root.active
        flashEnabled: root.flashEnabled
        flashRate: root.flashRate
    }

    Rectangle {
        color: root.markerColor
        height: root.markerLength
        opacity: root.active ? (flashTimer.phase ? 0.28 : 1.0) : 0.82
        radius: width * 0.5
        rotation: root.markerAngle
        transformOrigin: Item.Center
        width: root.markerThickness
        x: root.markerX - (width * 0.5)
        y: root.markerY - (height * 0.5)
    }
}
