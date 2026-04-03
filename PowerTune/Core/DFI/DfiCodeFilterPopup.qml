import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

Popup {
    id: root

    anchors.centerIn: Overlay.overlay
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    modal: true
    padding: SettingsTheme.sectionPadding
    width: Math.min((parent ? parent.width : 800) * 0.85, 700)

    readonly property var knownCodes: [
        11, 12, 13, 14, 15, 21, 23, 24, 25, 31, 32, 33, 34, 35,
        36, 39, 46, 51, 52, 53, 54, 56, 62, 63, 64, 67, 83
    ]

    background: Rectangle {
        border.color: SettingsTheme.border
        border.width: SettingsTheme.borderWidth
        color: SettingsTheme.cardBg
        radius: SettingsTheme.radiusLarge
    }

    contentItem: ColumnLayout {
        spacing: SettingsTheme.contentSpacing

        Text {
            Layout.fillWidth: true
            color: SettingsTheme.textPrimary
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontSectionTitle
            font.weight: Font.Bold
            text: "DFI Code Filters"
        }

        Text {
            Layout.fillWidth: true
            color: SettingsTheme.textSecondary
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontStatus
            text: "Suppressed codes are hidden from the dashboard and diagnostics display."
            wrapMode: Text.WordWrap
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: SettingsTheme.controlGap

            StyledButton {
                text: "Suppress All"
                onClicked: DfiSerial.suppressAllKnownCodes()
            }
            StyledButton {
                primary: false
                text: "Enable All"
                onClicked: DfiSerial.enableAllCodes()
            }
            Item { Layout.fillWidth: true }
            StyledButton {
                primary: false
                text: "Close"
                onClicked: root.close()
            }
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(codeColumn.implicitHeight, 400)
            clip: true
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            background: Rectangle {
                border.color: SettingsTheme.border
                border.width: SettingsTheme.borderWidth
                color: SettingsTheme.surfaceElevated
                radius: SettingsTheme.radiusMedium
            }

            ColumnLayout {
                id: codeColumn
                width: parent ? parent.width : 0
                spacing: SettingsTheme.controlGap

                Repeater {
                    model: root.knownCodes
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        border.color: SettingsTheme.border
                        border.width: SettingsTheme.borderWidth
                        color: index % 2 === 0 ? SettingsTheme.controlBg : SettingsTheme.surface
                        implicitHeight: Math.max(SettingsTheme.controlHeight + 8, codeRow.implicitHeight + 8)
                        radius: SettingsTheme.radiusSmall

                        RowLayout {
                            id: codeRow

                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: SettingsTheme.controlGap

                            Text {
                                Layout.preferredWidth: 70
                                color: SettingsTheme.textPrimary
                                font.family: SettingsTheme.fontFamilyMono
                                font.pixelSize: SettingsTheme.fontLabel
                                text: "DFI " + modelData
                            }

                            Text {
                                Layout.fillWidth: true
                                color: SettingsTheme.textPrimary
                                font.family: SettingsTheme.fontFamily
                                font.pixelSize: SettingsTheme.fontCaption
                                text: DfiSerial.dfiCodeDescription(modelData)
                                wrapMode: Text.WordWrap
                            }

                            StyledSwitch {
                                checked: !DfiSerial.isCodeSuppressed(modelData)
                                label: checked ? "Enabled" : "Suppressed"
                                onCheckedChanged: {
                                    if (checked)
                                        DfiSerial.unsuppressCode(modelData);
                                    else
                                        DfiSerial.suppressCode(modelData);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
