import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

Item {
    id: root
    objectName: "GaugeConfigMenuRoot"
    anchors.fill: parent
    z: 100000 + _raiseToken
    visible: false

    property Item target
    property int maxHeight: 600
    property list<QtObject> sections
    property real panelWidth: 320
    property bool allowDelete: false
    property real _raiseToken: 0
    property Item _overlayParent: null

    signal deleteRequested
    signal closed

    function _ensureOverlayParent() {
        if (_overlayParent)
            return;
        if (Window.window && Window.window.contentItem) {
            _overlayParent = Window.window.contentItem;
            parent = _overlayParent;
        } else {
            _overlayParent = parent;
        }
    }

    function _closeSiblingMenus() {
        if (!parent || !parent.children)
            return;
        for (var i = 0; i < parent.children.length; ++i) {
            var child = parent.children[i];
            if (child !== root && child.objectName === "GaugeConfigMenuRoot" && child.closeMenu)
                child.closeMenu(false);
        }
    }

    function closeMenu(emitSignal) {
        visible = false;
        if (emitSignal === undefined || emitSignal)
            closed();
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.visible
        onPressed: function(mouse) {
            var local = panel.mapFromItem(root, mouse.x, mouse.y);
            var inside = local.x >= 0 && local.y >= 0 && local.x <= panel.width && local.y <= panel.height;
            if (!inside) {
                root.closeMenu();
            } else {
                mouse.accepted = false;
            }
        }
    }

    Rectangle {
        id: panel
        width: root.panelWidth
        height: Math.min(contentColumn.implicitHeight + 56, root.maxHeight)
        radius: 10
        color: Qt.rgba(0.09, 0.09, 0.09, 0.96)
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, 0.14)

        Rectangle {
            x: 8
            y: 10
            width: parent.width
            height: parent.height
            radius: parent.radius
            color: Qt.rgba(0, 0, 0, 0.45)
            z: -1
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 34
            radius: parent.radius
            color: Qt.rgba(1, 1, 1, 0.04)
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 1
            color: Qt.rgba(1, 1, 1, 0.14)
        }

        Text {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: dragHandle.verticalCenter
            text: root.target && root.target.information ? root.target.information : "Config"
            color: "#F2F2F2"
            font.pixelSize: 13
            font.bold: true
        }

        MouseArea {
            id: dragHandle
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            height: 34
            drag.target: panel
            cursorShape: Qt.OpenHandCursor
        }

        Flickable {
            id: flickable
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: dragHandle.bottom
            anchors.bottom: parent.bottom
            anchors.margins: 10
            contentHeight: contentColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            ColumnLayout {
                id: contentColumn
                width: flickable.width
                spacing: 8

                Repeater {
                    model: root.sections
                    delegate: Loader {
                        Layout.fillWidth: true
                        sourceComponent: modelData.component
                        active: modelData.active !== undefined ? modelData.active : true
                        onLoaded: {
                            if (item && root.target)
                                item.target = root.target;
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Button {
                        text: "Delete"
                        Layout.fillWidth: true
                        visible: root.allowDelete
                        onClicked: {
                            root.closeMenu(false);
                            root.deleteRequested();
                        }
                    }

                    Button {
                        text: "Close"
                        Layout.fillWidth: true
                        highlighted: true
                        onClicked: root.closeMenu()
                    }
                }
            }
        }
    }

    function show(mx, my) {
        _ensureOverlayParent();
        _closeSiblingMenus();
        _raiseToken = Date.now();

        var px = 24;
        var py = 24;
        if (target) {
            var mapped = target.mapToItem(root, mx, my);
            px = mapped.x + 12;
            py = mapped.y + 12;
        }
        visible = true;
        panel.x = Math.max(12, Math.min(root.width - panel.width - 12, px));
        panel.y = Math.max(12, Math.min(root.height - panel.height - 12, py));
    }
}
