import QtQuick

Item {
    id: root

    property real value: 0
    property real minValue: 0
    property real maxValue: 10000
    property real startAngleDeg: 135
    property real sweepAngleDeg: 270
    property color arcColorStart: "#E88A1A"
    property color arcColorEnd: "#C45A00"
    property real gaugeSize: 595

    property real outerRingThickness: 0.06
    property real innerRingThickness: 0.015
    property real gapFromEdge: 0.008

    property bool startupAnimation: false

    default property alias centerContent: centerArea.data

    width: gaugeSize
    height: gaugeSize

    property real _animatedProgress: 0
    readonly property real _dataProgress: Math.max(0, Math.min(1, (value - minValue) / (maxValue - minValue)))
    readonly property real _startRad: startAngleDeg * Math.PI / 180.0
    readonly property real _sweepRad: sweepAngleDeg * Math.PI / 180.0

    readonly property real _outerEdge: 0.5 - gapFromEdge
    readonly property real _outerInner: _outerEdge - outerRingThickness
    readonly property real _innerOuter: _outerInner - 0.21
    readonly property real _innerInner: _innerOuter - innerRingThickness

    property bool _startupDone: false

    Behavior on _animatedProgress {
        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
    }

    SequentialAnimation {
        id: startupSweep
        running: root.startupAnimation

        NumberAnimation {
            target: root
            property: "_animatedProgress"
            from: 0; to: 1
            duration: 800
            easing.type: Easing.InOutCubic
        }
        NumberAnimation {
            target: root
            property: "_animatedProgress"
            from: 1; to: 0
            duration: 600
            easing.type: Easing.InOutCubic
        }
        ScriptAction {
            script: root._startupDone = true
        }
    }

    onValueChanged: {
        if (_startupDone || !startupAnimation)
            _animatedProgress = _dataProgress
    }

    Canvas {
        id: arcBackground
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var cx = width / 2
            var cy = height / 2
            var outerR = cx * (root._outerEdge * 2)
            var innerR = cx * (root._innerInner * 2)

            var startA = root._startRad - Math.PI / 2
            var endA = startA + root._sweepRad

            ctx.fillStyle = "#151518"
            ctx.beginPath()
            ctx.arc(cx, cy, outerR, startA, endA, false)
            ctx.arc(cx, cy, innerR, endA, startA, true)
            ctx.closePath()
            ctx.fill()
        }
    }

    ShaderEffect {
        id: shaderItem
        anchors.fill: parent

        fragmentShader: "qrc:/shaders/arcgauge.frag.qsb"
        vertexShader: "qrc:/shaders/arcgauge.vert.qsb"

        property real progress: root._animatedProgress
        property real startAngle: root._startRad
        property real sweepAngle: root._sweepRad
        property real outerRadius: root._outerInner
        property real innerRadius: root._innerOuter
        property real chromeOuterRadius: root._outerEdge
        property real chromeInnerRadius: root._innerInner

        property color colorStart: root.arcColorStart
        property color colorEnd: root.arcColorEnd
        property color chromeDark: "#282828"
        property color chromeLight: "#6A6A6A"
        property color backgroundColor: "#151518"

        property real bevelStrength: 0.9
        property real antiAlias: 1.5 / root.gaugeSize
    }

    Canvas {
        id: arcIndicator
        anchors.fill: parent
        visible: root._animatedProgress > 0.005

        property real _fillAngle: root._startRad + root._sweepRad * root._animatedProgress

        onPaint: paintIndicator()
        on_FillAngleChanged: requestPaint()

        function paintIndicator() {
            var ctx = getContext("2d")
            ctx.reset()

            if (root._animatedProgress < 0.005) return

            var cx = width / 2
            var cy = height / 2

            var outerR = cx * (root._outerInner * 2)
            var innerR = cx * (root._innerOuter * 2)

            var angle = _fillAngle - Math.PI / 2
            var wedgeSpan = 0.055

            var tipOuterX = cx + outerR * Math.cos(angle)
            var tipOuterY = cy + outerR * Math.sin(angle)

            var tipInnerX = cx + innerR * Math.cos(angle)
            var tipInnerY = cy + innerR * Math.sin(angle)

            var trailOuterX = cx + outerR * Math.cos(angle - wedgeSpan)
            var trailOuterY = cy + outerR * Math.sin(angle - wedgeSpan)

            var trailInnerX = cx + innerR * Math.cos(angle - wedgeSpan)
            var trailInnerY = cy + innerR * Math.sin(angle - wedgeSpan)

            var grad = ctx.createLinearGradient(trailInnerX, trailInnerY, tipOuterX, tipOuterY)
            grad.addColorStop(0.0, Qt.rgba(root.arcColorEnd.r, root.arcColorEnd.g, root.arcColorEnd.b, 0.3))
            grad.addColorStop(0.6, Qt.rgba(root.arcColorStart.r, root.arcColorStart.g, root.arcColorStart.b, 0.85))
            grad.addColorStop(1.0, Qt.rgba(1, 1, 1, 0.7))

            ctx.fillStyle = grad
            ctx.beginPath()
            ctx.moveTo(trailInnerX, trailInnerY)
            ctx.lineTo(trailOuterX, trailOuterY)
            ctx.lineTo(tipOuterX, tipOuterY)
            ctx.lineTo(tipInnerX, tipInnerY)
            ctx.closePath()
            ctx.fill()
        }
    }

    Item {
        id: centerArea
        anchors.centerIn: parent
        width: parent.width * root._innerOuter * 2 * 0.85
        height: parent.height * root._innerOuter * 2 * 0.85
    }
}
