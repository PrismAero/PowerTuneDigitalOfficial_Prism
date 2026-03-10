import QtQuick
import PowerTune.UI 1.0

Item {
    id: root

    property string overlayId: ""
    property string configType: ""
    property bool editMode: false
    property real defaultX: 0
    property real defaultY: 0

    default property alias content: contentContainer.data

    signal positionChanged(string id, real newX, real newY)
    signal configRequested(string overlayId, string configType)

    property int _tapCount: 0
    readonly property bool _locked: OverlayConfig.positionsLocked
    readonly property bool _isDragging: dragHandler.active

    Component.onCompleted: {
        defaultX = x;
        defaultY = y;
        var pos = OverlayConfig.getPosition(overlayId);
        if (pos.x !== undefined) {
            x = Number(pos.x);
            y = Number(pos.y);
        }
    }

    Connections {
        target: OverlayConfig
        function onPositionsReset() {
            root.x = root.defaultX;
            root.y = root.defaultY;
        }
    }

    Timer {
        id: tapTimer
        interval: 400
        onTriggered: {
            if (root._tapCount === 2)
                root.editMode = !root.editMode;
            root._tapCount = 0;
        }
    }

    // Alignment guides (visible only while dragging)
    Rectangle {
        id: guideH
        visible: root._isDragging
        width: 1600; height: 1
        color: Qt.rgba(SettingsTheme.accent.r, SettingsTheme.accent.g, SettingsTheme.accent.b, 0.25)
        x: -root.x
        y: root.height / 2
        z: 200
    }
    Rectangle {
        id: guideV
        visible: root._isDragging
        width: 1; height: 720
        color: Qt.rgba(SettingsTheme.accent.r, SettingsTheme.accent.g, SettingsTheme.accent.b, 0.25)
        x: root.width / 2
        y: -root.y
        z: 200
    }
    // Center crosshair of the dashboard
    Rectangle {
        id: guideCenterH
        visible: root._isDragging
        width: 1600; height: 1
        color: Qt.rgba(SettingsTheme.textPrimary.r, SettingsTheme.textPrimary.g, SettingsTheme.textPrimary.b, 0.125)
        x: -root.x
        y: 360 - root.y
        z: 199
    }
    Rectangle {
        id: guideCenterV
        visible: root._isDragging
        width: 1; height: 720
        color: Qt.rgba(SettingsTheme.textPrimary.r, SettingsTheme.textPrimary.g, SettingsTheme.textPrimary.b, 0.125)
        x: 800 - root.x
        y: -root.y
        z: 199
    }

    // Snap indicator text
    Text {
        visible: root._isDragging
        text: Math.round(root.x) + ", " + Math.round(root.y)
        font.pixelSize: SettingsTheme.fontCaption
        font.family: SettingsTheme.fontFamily
        color: Qt.rgba(SettingsTheme.accent.r, SettingsTheme.accent.g, SettingsTheme.accent.b, 0.5)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 4
        z: 201
    }

    Rectangle {
        id: editBorder
        anchors.fill: parent
        anchors.margins: -4
        color: "transparent"
        border.color: editMode ? Qt.rgba(SettingsTheme.accent.r, SettingsTheme.accent.g, SettingsTheme.accent.b, 0.375) : "transparent"
        border.width: editMode ? 2 : 0
        radius: 4
        visible: editMode

        Rectangle {
            id: closeBtn
            width: 28; height: 28
            radius: 14
            color: Qt.rgba(SettingsTheme.surface.r, SettingsTheme.surface.g, SettingsTheme.surface.b, 0.8)
            border.color: Qt.rgba(SettingsTheme.textPrimary.r, SettingsTheme.textPrimary.g, SettingsTheme.textPrimary.b, 0.5)
            border.width: 1
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: -6

            Text {
                text: "X"
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.Bold
                font.family: SettingsTheme.fontFamily
                color: SettingsTheme.textPrimary
                anchors.centerIn: parent
            }

            TapHandler {
                onTapped: root.editMode = false
            }
        }

        Rectangle {
            id: configBtn
            width: 28; height: 28
            radius: 14
            color: Qt.rgba(SettingsTheme.surface.r, SettingsTheme.surface.g, SettingsTheme.surface.b, 0.8)
            border.color: Qt.rgba(SettingsTheme.accent.r, SettingsTheme.accent.g, SettingsTheme.accent.b, 0.5)
            border.width: 1
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.margins: -6
            visible: root.configType !== ""

            Text {
                text: "C"
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.Bold
                font.family: SettingsTheme.fontFamily
                color: SettingsTheme.accent
                anchors.centerIn: parent
            }

            TapHandler {
                onTapped: root.configRequested(root.overlayId, root.configType)
            }
        }

        Text {
            text: root.overlayId
            font.pixelSize: 10
            font.family: SettingsTheme.fontFamily
            color: Qt.rgba(SettingsTheme.textPrimary.r, SettingsTheme.textPrimary.g, SettingsTheme.textPrimary.b, 0.5)
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 4
        }

        Text {
            text: Math.round(root.x) + ", " + Math.round(root.y)
            font.pixelSize: 10
            font.family: SettingsTheme.fontFamily
            color: Qt.rgba(SettingsTheme.textPrimary.r, SettingsTheme.textPrimary.g, SettingsTheme.textPrimary.b, 0.5)
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 4
        }
    }

    Item {
        id: contentContainer
        anchors.fill: parent
    }

    TapHandler {
        gesturePolicy: TapHandler.WithinBounds
        onTapped: {
            root._tapCount++;
            if (root._tapCount === 3) {
                tapTimer.stop();
                root._tapCount = 0;
                if (root.configType !== "")
                    root.configRequested(root.overlayId, root.configType);
            } else {
                tapTimer.restart();
            }
        }
    }

    DragHandler {
        id: dragHandler
        enabled: root.editMode && !root._locked
        target: root
        onActiveChanged: {
            if (!active) {
                root.positionChanged(root.overlayId, root.x, root.y);
                OverlayConfig.savePosition(root.overlayId, root.x, root.y);
            }
        }
    }
}
