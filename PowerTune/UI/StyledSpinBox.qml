import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property int from: 0
    property int stepSize: 1
    property int to: 100
    property int value: 0

    implicitHeight: SettingsTheme.controlHeight
    implicitWidth: 140

    onValueChanged: {
        if (value < from)
            value = from;
        if (value > to)
            value = to;
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            id: minusBtn

            Layout.fillHeight: true
            Layout.preferredWidth: root.height
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth
            color: minusArea.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
            opacity: root.value > root.from ? 1.0 : 0.4
            radius: SettingsTheme.radiusSmall

            Text {
                anchors.centerIn: parent
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontControl
                font.weight: Font.Bold
                text: "-"
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
            Layout.fillHeight: true
            Layout.fillWidth: true
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth
            color: SettingsTheme.controlBg

            Text {
                anchors.centerIn: parent
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontControl
                text: root.value.toString()
            }
        }

        Rectangle {
            id: plusBtn

            Layout.fillHeight: true
            Layout.preferredWidth: root.height
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth
            color: plusArea.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
            opacity: root.value < root.to ? 1.0 : 0.4
            radius: SettingsTheme.radiusSmall

            Text {
                anchors.centerIn: parent
                color: SettingsTheme.textPrimary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontControl
                font.weight: Font.Bold
                text: "+"
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
