import QtQuick
import PowerTune.UI 1.0

Item {
    id: root

    readonly property bool _isDragging: dragHandler.active
    readonly property bool _locked: OverlayConfig.positionsLocked
    property int _tapCount: 0
    property string configType: ""
    default property alias content: contentContainer.data
    property real defaultX: 0
    property real defaultY: 0
    property bool editMode: false
    property string overlayId: ""

    signal configRequested(string overlayId, string configType)
    signal positionChanged(string id, real newX, real newY)

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
        function onPositionsReset() {
            root.x = root.defaultX;
            root.y = root.defaultY;
        }

        target: OverlayConfig
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

        color: Qt.rgba(SettingsTheme.accent.r, SettingsTheme.accent.g, SettingsTheme.accent.b, 0.25)
        height: 1
        visible: root._isDragging
        width: 1600
        x: -root.x
        y: root.height / 2
        z: 200
    }

    Rectangle {
        id: guideV

        color: Qt.rgba(SettingsTheme.accent.r, SettingsTheme.accent.g, SettingsTheme.accent.b, 0.25)
        height: 720
        visible: root._isDragging
        width: 1
        x: root.width / 2
        y: -root.y
        z: 200
    }

    // Center crosshair of the dashboard
    Rectangle {
        id: guideCenterH

        color: Qt.rgba(SettingsTheme.textPrimary.r, SettingsTheme.textPrimary.g, SettingsTheme.textPrimary.b, 0.125)
        height: 1
        visible: root._isDragging
        width: 1600
        x: -root.x
        y: 360 - root.y
        z: 199
    }

    Rectangle {
        id: guideCenterV

        color: Qt.rgba(SettingsTheme.textPrimary.r, SettingsTheme.textPrimary.g, SettingsTheme.textPrimary.b, 0.125)
        height: 720
        visible: root._isDragging
        width: 1
        x: 800 - root.x
        y: -root.y
        z: 199
    }

    // Snap indicator text
    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: 4
        color: Qt.rgba(SettingsTheme.accent.r, SettingsTheme.accent.g, SettingsTheme.accent.b, 0.5)
        font.family: SettingsTheme.fontFamily
        font.pixelSize: SettingsTheme.fontCaption
        text: Math.round(root.x) + ", " + Math.round(root.y)
        visible: root._isDragging
        z: 201
    }

    Rectangle {
        id: editBorder

        anchors.fill: parent
        anchors.margins: -4
        border.color: editMode ? Qt.rgba(SettingsTheme.accent.r, SettingsTheme.accent.g, SettingsTheme.accent.b, 0.375) :
                                 "transparent"
        border.width: editMode ? 2 : 0
        color: "transparent"
        radius: 4
        visible: editMode

        Rectangle {
            id: closeBtn

            anchors.margins: -6
            anchors.right: parent.right
            anchors.top: parent.top
            border.color: Qt.rgba(SettingsTheme.textPrimary.r, SettingsTheme.textPrimary.g, SettingsTheme.textPrimary.b,
                                  0.5)
            border.width: 1
            color: Qt.rgba(SettingsTheme.surface.r, SettingsTheme.surface.g, SettingsTheme.surface.b, 0.8)
            height: 28
            radius: 14
            width: 28

            Text {
                anchors.centerIn: parent
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.Bold
                text: "X"
            }

            TapHandler {
                onTapped: root.editMode = false
            }
        }

        Rectangle {
            id: configBtn

            anchors.left: parent.left
            anchors.margins: -6
            anchors.top: parent.top
            border.color: Qt.rgba(SettingsTheme.accent.r, SettingsTheme.accent.g, SettingsTheme.accent.b, 0.5)
            border.width: 1
            color: Qt.rgba(SettingsTheme.surface.r, SettingsTheme.surface.g, SettingsTheme.surface.b, 0.8)
            height: 28
            radius: 14
            visible: root.configType !== ""
            width: 28

            Text {
                anchors.centerIn: parent
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.Bold
                text: "C"
            }

            TapHandler {
                onTapped: root.configRequested(root.overlayId, root.configType)
            }
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.margins: 4
            color: Qt.rgba(SettingsTheme.textPrimary.r, SettingsTheme.textPrimary.g, SettingsTheme.textPrimary.b, 0.5)
            font.family: SettingsTheme.fontFamily
            font.pixelSize: 10
            text: root.overlayId
        }

        Text {
            anchors.bottom: parent.bottom
            anchors.margins: 4
            anchors.right: parent.right
            color: Qt.rgba(SettingsTheme.textPrimary.r, SettingsTheme.textPrimary.g, SettingsTheme.textPrimary.b, 0.5)
            font.family: SettingsTheme.fontFamily
            font.pixelSize: 10
            text: Math.round(root.x) + ", " + Math.round(root.y)
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
