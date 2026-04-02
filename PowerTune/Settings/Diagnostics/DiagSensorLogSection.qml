import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

RowLayout {
    id: root

    property bool showAllSensors: Diagnostics.showAllSensors

    Layout.fillWidth: true
    spacing: SettingsTheme.sectionSpacing

    ListModel {
        id: logLevelModel

        ListElement { label: "All"; level: 0 }
        ListElement { label: "Info"; level: 1 }
        ListElement { label: "Warn"; level: 2 }
        ListElement { label: "Error"; level: 3 }
    }

    SettingsSection {
        Layout.fillHeight: true
        Layout.fillWidth: true
        title: "Live Sensor Data"

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: Diagnostics.liveSensorEntries.length + " sensors"
            }

            Rectangle {
                Layout.preferredHeight: SettingsTheme.controlHeight
                Layout.preferredWidth: 120
                border.color: SettingsTheme.border
                border.width: SettingsTheme.borderWidth
                color: toggleArea.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
                radius: SettingsTheme.radiusSmall

                Text {
                    anchors.centerIn: parent
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: showAllSensors ? "Show Active" : "Show All"
                }

                MouseArea {
                    id: toggleArea

                    anchors.fill: parent

                    onClicked: Diagnostics.showAllSensors = !Diagnostics.showAllSensors
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            Text {
                Layout.preferredWidth: 160
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Name"
            }

            Text {
                Layout.preferredWidth: 100
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Source"
            }

            Text {
                Layout.fillWidth: true
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Live Value"
            }

            Text {
                Layout.preferredWidth: 60
                color: SettingsTheme.accent
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                font.weight: Font.DemiBold
                text: "Unit"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            color: SettingsTheme.border
            height: SettingsTheme.borderWidth
        }

        ListView {
            id: sensorListView

            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            model: Diagnostics.liveSensorEntries
            spacing: 1

            ScrollBar.vertical: ScrollBar {
                policy: sensorListView.contentHeight > sensorListView.height ? ScrollBar.AsNeeded :
                                                                               ScrollBar.AlwaysOff
            }
            delegate: Rectangle {
                required property int index
                required property var modelData

                color: index % 2 === 0 ? SettingsTheme.surface : SettingsTheme.background
                height: 32
                width: sensorListView.width

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: SettingsTheme.contentSpacing / 2
                    anchors.rightMargin: SettingsTheme.contentSpacing / 2
                    spacing: SettingsTheme.contentSpacing

                    Rectangle {
                        color: modelData.active ? SettingsTheme.success : SettingsTheme.textDisabled
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }

                    Text {
                        Layout.preferredWidth: 160
                        color: SettingsTheme.textPrimary
                        elide: Text.ElideRight
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: modelData.name
                    }

                    Text {
                        Layout.preferredWidth: 100
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: modelData.source
                    }

                    Text {
                        Layout.fillWidth: true
                        color: modelData.active ? SettingsTheme.success : SettingsTheme.textDisabled
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        font.weight: Font.DemiBold
                        text: modelData.unit === "" ? Number(modelData.value).toFixed(0) : Number(
                                                          modelData.value).toFixed(3)
                    }

                    Text {
                        Layout.preferredWidth: 60
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: modelData.unit
                    }
                }
            }
        }
    }

    SettingsSection {
        Layout.fillHeight: true
        Layout.fillWidth: true
        title: "System Log"

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.contentSpacing

            Item {
                Layout.fillWidth: true
            }

            Repeater {
                model: logLevelModel

                Rectangle {
                    Layout.preferredHeight: SettingsTheme.controlHeight
                    Layout.preferredWidth: 60
                    border.color: Diagnostics.logLevel === model.level ? SettingsTheme.accent : SettingsTheme.border
                    border.width: SettingsTheme.borderWidth
                    color: Diagnostics.logLevel === model.level ? SettingsTheme.accent : SettingsTheme.controlBg
                    radius: SettingsTheme.radiusSmall

                    Text {
                        anchors.centerIn: parent
                        color: Diagnostics.logLevel === model.level ? SettingsTheme.textPrimary :
                                                                      SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: model.label
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: Diagnostics.logLevel = model.level
                    }
                }
            }

            Rectangle {
                Layout.preferredHeight: SettingsTheme.controlHeight
                Layout.preferredWidth: 60
                border.color: SettingsTheme.border
                border.width: SettingsTheme.borderWidth
                color: clearArea.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
                radius: SettingsTheme.radiusSmall

                Text {
                    anchors.centerIn: parent
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    text: "Clear"
                }

                MouseArea {
                    id: clearArea

                    anchors.fill: parent

                    onClicked: Diagnostics.clearLog()
                }
            }
        }

        Rectangle {
            Layout.fillHeight: true
            Layout.fillWidth: true
            color: SettingsTheme.consoleBg
            radius: SettingsTheme.radiusSmall

            ListView {
                id: logListView

                anchors.fill: parent
                anchors.margins: SettingsTheme.radiusSmall
                clip: true
                model: Diagnostics.filteredLogMessages
                spacing: 1

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }
                delegate: Text {
                    color: {
                        if (modelData.indexOf("[ERROR]") !== -1 || modelData.indexOf("[FATAL]") !== -1)
                            return SettingsTheme.error;
                        if (modelData.indexOf("[WARN]") !== -1)
                            return SettingsTheme.warning;
                        if (modelData.indexOf("[DEBUG]") !== -1)
                            return SettingsTheme.textDisabled;
                        return SettingsTheme.consoleText;
                    }
                    font.family: SettingsTheme.fontFamilyMono
                    font.pixelSize: SettingsTheme.fontCaption
                    text: modelData
                    width: logListView.width
                    wrapMode: Text.WrapAnywhere
                }

                onCountChanged: {
                    Qt.callLater(function () {
                        logListView.positionViewAtEnd();
                    });
                }
            }
        }
    }
}
