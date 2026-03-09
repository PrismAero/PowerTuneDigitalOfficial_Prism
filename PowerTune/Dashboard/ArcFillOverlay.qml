import QtQuick

Item {
    id: root

    property real value: 0
    property real minValue: 0
    property real maxValue: 10000

    property real startAngleDeg: 135
    property real sweepAngleDeg: 270

    property real arcOuterRadius: 0.43
    property real arcInnerRadius: 0.22

    property color arcColorStart: "#E88A1A"
    property color arcColorEnd: "#C45A00"

    property bool startupAnimation: false

    width: 100
    height: 100

    property real _animatedProgress: 0
    readonly property real _dataProgress: Math.max(0, Math.min(1, (value - minValue) / (maxValue - minValue)))

    property bool _startupDone: false

    Behavior on _animatedProgress {
        NumberAnimation { duration: 150; easing.type: Easing.OutQuad }
    }

    SequentialAnimation {
        id: startupSweep
        running: root.startupAnimation

        NumberAnimation {
            target: root; property: "_animatedProgress"
            from: 0; to: 1; duration: 800
            easing.type: Easing.InOutCubic
        }
        NumberAnimation {
            target: root; property: "_animatedProgress"
            from: 1; to: 0; duration: 600
            easing.type: Easing.InOutCubic
        }
        ScriptAction { script: root._startupDone = true }
    }

    onValueChanged: {
        if (_startupDone || !startupAnimation)
            _animatedProgress = _dataProgress
    }

    Canvas {
        id: fillCanvas
        anchors.fill: parent

        property real prog: root._animatedProgress
        onProgChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            if (root._animatedProgress < 0.002) return

            var cx = width / 2
            var cy = height / 2
            var outerR = cx * root.arcOuterRadius * 2
            var innerR = cx * root.arcInnerRadius * 2

            var startRad = root.startAngleDeg * Math.PI / 180.0
            var sweepRad = root.sweepAngleDeg * Math.PI / 180.0
            var fillSweep = sweepRad * root._animatedProgress

            var canvasStart = startRad - Math.PI / 2
            var canvasEnd = canvasStart + fillSweep

            var grad = ctx.createConicalGradient(cx, cy, -startRad * 180 / Math.PI + 90)
            var sweepDeg = root.sweepAngleDeg
            grad.addColorStop(0.0, root.arcColorStart.toString())
            grad.addColorStop(Math.min(1.0, sweepDeg / 360.0), root.arcColorEnd.toString())
            grad.addColorStop(1.0, root.arcColorEnd.toString())

            ctx.fillStyle = grad
            ctx.beginPath()
            ctx.arc(cx, cy, outerR, canvasStart, canvasEnd, false)
            ctx.arc(cx, cy, innerR, canvasEnd, canvasStart, true)
            ctx.closePath()
            ctx.fill()

            var endAngle = canvasEnd
            var midR = (outerR + innerR) / 2
            var capSpan = 0.04

            var tipX = cx + outerR * Math.cos(endAngle)
            var tipY = cy + outerR * Math.sin(endAngle)
            var tipInnerX = cx + innerR * Math.cos(endAngle)
            var tipInnerY = cy + innerR * Math.sin(endAngle)
            var trailOuterX = cx + outerR * Math.cos(endAngle - capSpan)
            var trailOuterY = cy + outerR * Math.sin(endAngle - capSpan)
            var trailInnerX = cx + innerR * Math.cos(endAngle - capSpan)
            var trailInnerY = cy + innerR * Math.sin(endAngle - capSpan)

            var capGrad = ctx.createLinearGradient(trailInnerX, trailInnerY, tipX, tipY)
            capGrad.addColorStop(0.0, Qt.rgba(root.arcColorEnd.r, root.arcColorEnd.g, root.arcColorEnd.b, 0.2))
            capGrad.addColorStop(0.7, Qt.rgba(root.arcColorStart.r, root.arcColorStart.g, root.arcColorStart.b, 0.8))
            capGrad.addColorStop(1.0, Qt.rgba(1, 1, 1, 0.6))

            ctx.fillStyle = capGrad
            ctx.beginPath()
            ctx.moveTo(trailInnerX, trailInnerY)
            ctx.lineTo(trailOuterX, trailOuterY)
            ctx.lineTo(tipX, tipY)
            ctx.lineTo(tipInnerX, tipInnerY)
            ctx.closePath()
            ctx.fill()
        }
    }
}
