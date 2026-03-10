import QtQuick

// GPU-accelerated arc gauge component using SDF-based fragment shader.
// Replaces Canvas-based rendering with ShaderEffect for anti-aliased edges,
// configurable gradient, value-driven fill, and warning flash support.
// Designed for the PrismPT.Dashboard overlay system on 1600x720 touchscreens.

Item {
    id: root

    // -- Data binding --
    property string datasource: ""
    property real currentValue: 0.0
    property real minValue: 0
    property real maxValue: 100

    // -- Arc geometry (degrees, converted to radians for shader) --
    // Angle convention: 0 = right (3 o'clock), CCW positive (math convention).
    // Default 135-405 deg produces a 270 deg arc from upper-left CW through
    // bottom to upper-right (standard gauge layout).
    property real startAngleDeg: 135
    property real endAngleDeg: 405
    property real arcWidthFraction: 0.08

    // -- Gradient colors --
    property color colorStart: "#00FF00"
    property color colorEnd: "#FF0000"
    property color colorMid: "#FFFF00"
    property bool useMidColor: true
    property color bgColor: "#1A1A1A"

    // -- Warning configuration --
    property real warningThreshold: -1       // normalized 0-1 threshold; -1 = disabled
    property color warningColor: "#FF0000"
    property bool warningEnabled: false

    // -- Startup animation --
    property bool startupAnimation: false

    // -- Config application from OverlayConfigPopup --
    function applyConfig(config) {
        if (config.sensorKey) datasource = config.sensorKey
        if (config.minValue !== undefined) minValue = Number(config.minValue)
        if (config.maxValue !== undefined) maxValue = Number(config.maxValue)
        if (config.startAngle !== undefined) startAngleDeg = Number(config.startAngle)
        if (config.sweepAngle !== undefined) endAngleDeg = Number(config.startAngle) + Number(config.sweepAngle)
        if (config.arcWidth !== undefined) arcWidthFraction = Number(config.arcWidth)
        if (config.arcColorStart) colorStart = config.arcColorStart
        if (config.arcColorEnd) colorEnd = config.arcColorEnd
        if (config.arcColorMid && config.arcColorMid !== "") {
            colorMid = config.arcColorMid
            useMidColor = true
        } else if (config.arcColorMid === "") {
            useMidColor = false
        }
        if (config.arcBgColor) bgColor = config.arcBgColor
        if (config.warningEnabled !== undefined) warningEnabled = config.warningEnabled === true || config.warningEnabled === "true"
        if (config.warningThreshold !== undefined) warningThreshold = Number(config.warningThreshold)
        if (config.warningColor) warningColor = config.warningColor
    }

    // -- Default content area for child items (e.g. labels) --
    default property alias centerContent: centerArea.data

    // -- Computed properties --
    readonly property real normalizedValue: {
        var range = maxValue - minValue;
        if (range <= 0) return 0;
        return Math.max(0, Math.min(1, (currentValue - minValue) / range));
    }

    // Internal animated progress supporting startup sweep
    property real _animatedProgress: 0
    property bool _startupDone: false

    width: 200
    height: 200

    Behavior on _animatedProgress {
        NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
    }

    // -- Startup sweep animation (full sweep out and back) --
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

    onCurrentValueChanged: {
        if (_startupDone || !startupAnimation)
            _animatedProgress = normalizedValue
    }

    // -- PropertyRouter reactive data binding --
    Connections {
        target: typeof PropertyRouter !== "undefined" ? PropertyRouter : null
        function onValueChanged(propertyName, value) {
            if (propertyName === root.datasource) {
                root.currentValue = Number(value)
            }
        }
    }

    // -- Warning flash timer --
    // Runs when warning is enabled and currentValue exceeds threshold.
    // Drives flashPhase from 0.0 to 1.0 in cyclic increments for shader pulse.
    Timer {
        id: flashTimer
        interval: 100
        running: root.warningEnabled
                 && root.warningThreshold >= 0
                 && root.normalizedValue >= root.warningThreshold
        repeat: true
        property real phase: 0.0
        onTriggered: phase = (phase + 0.2) % 1.0
    }

    // -- GPU-accelerated arc shader --
    ShaderEffect {
        id: arcShader
        anchors.fill: parent

        fragmentShader: "shaders/arcoverlay.frag.qsb"

        // Arc geometry (converted from degrees to radians)
        property real startAngle: root.startAngleDeg * Math.PI / 180.0
        property real endAngle: root.endAngleDeg * Math.PI / 180.0
        property real arcWidth: root.arcWidthFraction

        // Fill progress
        property real value: root._animatedProgress

        // Gradient colors
        property color colorStart: root.colorStart
        property color colorMid: root.colorMid
        property color colorEnd: root.colorEnd
        property color bgColor: root.bgColor

        // Warning state
        property color warningColor: root.warningColor
        property real warningActive: flashTimer.running ? 1.0 : 0.0
        property real flashPhase: flashTimer.phase
        property real useMidColor: root.useMidColor ? 1.0 : 0.0
    }

    // -- Center content area for child items (labels, numbers, icons) --
    Item {
        id: centerArea
        anchors.centerIn: parent
        // Size the content area to fit inside the inner radius of the arc.
        // innerRadius = 0.48 - arcWidthFraction in UV [-1,1] space,
        // mapped back to component pixel coordinates.
        width: parent.width * (0.48 - root.arcWidthFraction) * 2.0 * 0.85
        height: parent.height * (0.48 - root.arcWidthFraction) * 2.0 * 0.85
    }
}
