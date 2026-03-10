import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property int from: 0
    property int to: 100
    property int value: 0
    property int stepSize: 1

    implicitWidth: 140
    implicitHeight: SettingsTheme.controlHeight

    onValueChanged: {
        if (value < from) value = from;
        if (value > to) value = to;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: minusBtn
            Layout.preferredWidth: root.height
            Layout.fillHeight: true
            radius: SettingsTheme.radiusSmall
            color: minusArea.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth
            opacity: root.value > root.from ? 1.0 : 0.4

            Text {
                text: "-"
                font.pixelSize: SettingsTheme.fontControl
                font.weight: Font.Bold
                font.family: SettingsTheme.fontFamily
                color: SettingsTheme.textPrimary
                anchors.centerIn: parent
            }

            TapHandler {
                id: minusArea
                onTapped: {
                    if (root.value - root.stepSize >= root.from)
                        root.value -= root.stepSize;
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: SettingsTheme.controlBg
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth

            Text {
                text: root.value.toString()
                font.pixelSize: SettingsTheme.fontControl
                font.family: SettingsTheme.fontFamily
                color: SettingsTheme.textPrimary
                anchors.centerIn: parent
            }
        }

        Rectangle {
            id: plusBtn
            Layout.preferredWidth: root.height
            Layout.fillHeight: true
            radius: SettingsTheme.radiusSmall
            color: plusArea.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth
            opacity: root.value < root.to ? 1.0 : 0.4

            Text {
                text: "+"
                font.pixelSize: SettingsTheme.fontControl
                font.weight: Font.Bold
                font.family: SettingsTheme.fontFamily
                color: SettingsTheme.textPrimary
                anchors.centerIn: parent
            }

            TapHandler {
                id: plusArea
                onTapped: {
                    if (root.value + root.stepSize <= root.to)
                        root.value += root.stepSize;
                }
            }
        }
    }
}
