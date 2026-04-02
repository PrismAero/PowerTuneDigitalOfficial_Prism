import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

SettingsSection {
    id: canSection

    Layout.fillWidth: true
    collapsed: true
    collapsible: true
    title: "CAN Messages"

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.contentSpacing

        StyledSwitch {
            id: canCaptureToggle

            checked: Diagnostics.canCaptureEnabled

            onCheckedChanged: Diagnostics.canCaptureEnabled = checked
        }

        Text {
            color: canCaptureToggle.checked ? SettingsTheme.success : SettingsTheme.textSecondary
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            text: canCaptureToggle.checked ? "Capturing" : "Stopped"
        }

        Item {
            Layout.fillWidth: true
        }

        StyledTextField {
            Layout.preferredWidth: 140
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: "Filter CAN ID (hex)"
            text: Diagnostics.canIdFilter

            onTextChanged: Diagnostics.canIdFilter = text
        }

        StyledButton {
            primary: false
            text: "Clear"

            onClicked: Diagnostics.clearCanFrameBuffer()
        }

        StyledButton {
            primary: false
            text: "Reset Errors"

            onClicked: Diagnostics.resetCanErrors()
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: SettingsTheme.contentSpacing

        Text {
            Layout.preferredWidth: 80
            color: SettingsTheme.accent
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            font.weight: Font.DemiBold
            text: "ID"
        }

        Text {
            Layout.preferredWidth: 30
            color: SettingsTheme.accent
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            font.weight: Font.DemiBold
            text: "Len"
        }

        Text {
            Layout.fillWidth: true
            color: SettingsTheme.accent
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            font.weight: Font.DemiBold
            text: "Payload (hex)"
        }

        Text {
            Layout.preferredWidth: 80
            color: SettingsTheme.accent
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontCaption
            font.weight: Font.DemiBold
            text: "ASCII"
        }
    }

    Rectangle {
        Layout.fillWidth: true
        color: SettingsTheme.border
        height: SettingsTheme.borderWidth
    }

    ListView {
        id: canFrameList

        Layout.fillWidth: true
        Layout.preferredHeight: 300
        clip: true
        model: CanFrameModel
        spacing: 1

        ScrollBar.vertical: ScrollBar {
            policy: canFrameList.contentHeight > canFrameList.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        }
        delegate: Rectangle {
            required property int index
            required property string canId
            required property string payload

            function payloadLength(value) {
                if (!value || value.trim().length === 0)
                    return 0;
                return value.trim().split(/\s+/).length;
            }

            function payloadAscii(value) {
                if (!value || value.trim().length === 0)
                    return "";
                var parts = value.trim().split(/\s+/);
                var ascii = "";
                for (var i = 0; i < parts.length; ++i) {
                    var n = parseInt(parts[i], 16);
                    if (isNaN(n))
                        continue;
                    ascii += (n >= 32 && n <= 126) ? String.fromCharCode(n) : ".";
                }
                return ascii;
            }

            color: index % 2 === 0 ? SettingsTheme.surface : SettingsTheme.background
            height: 28
            width: canFrameList.width

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 4
                spacing: SettingsTheme.contentSpacing

                Text {
                    Layout.preferredWidth: 80
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamilyMono
                    font.pixelSize: SettingsTheme.fontCaption
                    text: canId
                }

                Text {
                    Layout.preferredWidth: 30
                    color: SettingsTheme.textSecondary
                    font.family: SettingsTheme.fontFamilyMono
                    font.pixelSize: SettingsTheme.fontCaption
                    text: payloadLength(payload)
                }

                Text {
                    Layout.fillWidth: true
                    color: SettingsTheme.textPrimary
                    font.family: SettingsTheme.fontFamilyMono
                    font.pixelSize: SettingsTheme.fontCaption
                    text: payload
                }

                Text {
                    Layout.preferredWidth: 80
                    color: SettingsTheme.textDisabled
                    font.family: SettingsTheme.fontFamilyMono
                    font.pixelSize: SettingsTheme.fontCaption
                    text: payloadAscii(payload)
                }
            }
        }
    }
}
