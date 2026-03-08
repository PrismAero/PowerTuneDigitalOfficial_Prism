import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    width: parent ? parent.width : 1600
    height: 40
    color: "#0A0A0A"

    property string information: "AiM status bar"
    property string teamName: "Cardinal Racing"
    property string systemLabel: "System"
    property bool systemOk: true
    property bool configMenuEnabled: true
    property string increasedecreaseident
    property int _clockTick: 0

    FontLoader { id: statusFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }

    readonly property string _clockText: {
        void _clockTick;
        var d = new Date();
        var h = d.getHours();
        var ampm = h >= 12 ? "Pm" : "Am";
        h = h % 12;
        if (h === 0) h = 12;
        var m = d.getMinutes().toString().padStart(2, "0");
        return h + ":" + m + " " + ampm;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root._clockTick++
    }

    MouseArea {
        anchors.fill: parent
        property real _lastTapTime: 0
        onPressed: function(mouse) {
            var now = Date.now();
            if (root.configMenuEnabled && now - _lastTapTime < 360) {
                _lastTapTime = 0;
                configMenu.show(mouse.x, mouse.y);
            } else {
                _lastTapTime = now;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        opacity: 0.12

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: GaugeTheme.aimStatusBarGradientA }
            GradientStop { position: 1.0; color: GaugeTheme.aimStatusBarGradientB }
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Qt.rgba(1, 1, 1, 0.08)
    }

    Row {
        id: leftSection
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10

        Text {
            text: root.systemLabel
            font.family: statusFont.name
            font.pixelSize: root.height * 0.6
            font.italic: true
            font.letterSpacing: -0.96
            color: "#FFFFFF"
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 16
            height: 16
            radius: 8
            color: root.systemOk ? GaugeTheme.aimStatusGood : GaugeTheme.aimStatusBad
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Text {
        id: centerText
        anchors.centerIn: parent
        text: root.teamName
        font.family: statusFont.name
        font.pixelSize: root.height * 0.6
        font.italic: true
        font.letterSpacing: -0.96
        color: "#FFFFFF"
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: clockText
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        text: root._clockText
        font.family: statusFont.name
        font.pixelSize: root.height * 0.6
        font.italic: true
        font.letterSpacing: -0.96
        color: "#FFFFFF"
        horizontalAlignment: Text.AlignRight
    }

    Accessible.role: Accessible.StatusBar
    Accessible.name: "AiM Status Bar"

    GaugeConfigMenu {
        id: configMenu
        target: root
        allowDelete: false
        sections: [
            QtObject {
                property Component component: Component {
                    Column {
                        property Item target
                        spacing: 6
                        width: parent ? parent.width : 260

                        Text { text: "Status Bar"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Team:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
                            TextField { width: 190; text: root.teamName; font.pixelSize: 12; onTextChanged: root.teamName = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "System:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
                            TextField { width: 190; text: root.systemLabel; font.pixelSize: 12; onTextChanged: root.systemLabel = text }
                        }
                        Switch { text: "Visible"; checked: root.visible; onCheckedChanged: root.visible = checked }
                    }
                }
            }
        ]
    }
}
