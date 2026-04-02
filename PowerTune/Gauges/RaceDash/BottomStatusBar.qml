import QtQuick
import QtQuick.Layouts

Item {
    id: root

    property string centerText: config.text !== undefined ? config.text : "Cardinal Racing"
    property string centerDisplayText: centerText
    property color centerDisplayColor: "#FFFFFF"
    property var config: ({})
    property string currentTimeText: ""
    property var dfiCodeRows: []
    property int dfiCodeIndex: 0
    property bool timeEnabled: config.timeEnabled !== undefined ? (config.timeEnabled === true || config.timeEnabled
                                                                   === "true") : true

    function statusColor() {
        if (!Diagnostics)
            return "#FF0909";
        if (Diagnostics.canStatusText === "Active")
            return "#1ED033";
        if (Diagnostics.canStatusText === "Waiting")
            return "#F1E83C";
        return "#FF0909";
    }

    function updateTime() {
        var now = new Date();
        currentTimeText = Qt.formatTime(now, "h:mm AP");
    }

    function refreshDfiCodes() {
        if (!PTExtenderCan) {
            dfiCodeRows = [];
            centerDisplayText = centerText;
            centerDisplayColor = "#FFFFFF";
            dfiCodeTicker.running = false;
            return;
        }

        dfiCodeRows = PTExtenderCan.filteredActiveCodeDetails();
        if (dfiCodeRows.length === 0) {
            dfiCodeIndex = 0;
            centerDisplayText = centerText;
            centerDisplayColor = "#FFFFFF";
            dfiCodeTicker.running = false;
            return;
        }

        dfiCodeIndex = 0;
        centerDisplayText = "DFI " + dfiCodeRows[0].code + ": " + dfiCodeRows[0].description;
        centerDisplayColor = "#F1E83C";
        dfiCodeTicker.running = dfiCodeRows.length > 1;
    }

    Component.onCompleted: {
        updateTime();
        refreshDfiCodes();
    }
    onCenterTextChanged: refreshDfiCodes()

    Timer {
        interval: 1000
        repeat: true
        running: true

        onTriggered: root.updateTime()
    }

    Timer {
        id: dfiCodeTicker

        interval: 3000
        repeat: true
        running: false
        onTriggered: {
            if (!root.dfiCodeRows || root.dfiCodeRows.length === 0) {
                running = false;
                root.centerDisplayText = root.centerText;
                root.centerDisplayColor = "#FFFFFF";
                return;
            }
            root.dfiCodeIndex = (root.dfiCodeIndex + 1) % root.dfiCodeRows.length;
            var row = root.dfiCodeRows[root.dfiCodeIndex];
            root.centerDisplayText = "DFI " + row.code + ": " + row.description;
            root.centerDisplayColor = "#F1E83C";
        }
    }

    Connections {
        target: PTExtenderCan
        function onActiveCodesChanged() {
            root.refreshDfiCodes();
        }
    }

    RowLayout {
        anchors.bottomMargin: 5
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 5
        spacing: 0

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 180

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Text {
                    color: "#FFFFFF"
                    font.family: "Hyperspace Race"
                    font.italic: true
                    font.pixelSize: 24
                    text: "System"
                }

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.statusColor()
                    height: 16
                    radius: 8
                    width: 16
                }
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.fillWidth: true

            Text {
                anchors.centerIn: parent
                color: root.centerDisplayColor
                font.family: "Hyperspace Race"
                font.italic: true
                font.pixelSize: 24
                text: root.centerDisplayText
            }
        }

        Item {
            Layout.fillHeight: true
            Layout.preferredWidth: 120

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                color: "#FFFFFF"
                font.family: "Hyperspace Race"
                font.italic: true
                font.pixelSize: 24
                text: root.currentTimeText
                visible: root.timeEnabled
            }
        }
    }
}
