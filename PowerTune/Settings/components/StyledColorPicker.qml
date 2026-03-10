import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property string colorValue: ""
    property string placeholderText: "#RRGGBB"

    signal colorEdited(string newColor)

    implicitWidth: 200
    implicitHeight: SettingsTheme.controlHeight

    readonly property color _previewColor: {
        if (colorValue.length === 7 && colorValue.charAt(0) === '#')
            return colorValue;
        if (colorValue.length === 9 && colorValue.charAt(0) === '#')
            return colorValue;
        return "transparent";
    }

    readonly property var _presetColors: [
        "#E88A1A", "#C45A00", "#FF5722", "#F44336",
        "#E91E63", "#9C27B0", "#673AB7", "#3F51B5",
        "#2196F3", "#03A9F4", "#00BCD4", "#009688",
        "#4CAF50", "#8BC34A", "#CDDC39", "#FFEB3B",
        "#FFC107", "#FF9800", "#795548", "#607D8B",
        "#FFFFFF", "#B0B0B0", "#808080", "#404040"
    ]

    RowLayout {
        anchors.fill: parent
        spacing: 4

        Rectangle {
            id: previewSwatch
            Layout.preferredWidth: root.height
            Layout.fillHeight: true
            radius: SettingsTheme.radiusSmall
            color: root._previewColor === "transparent" ? SettingsTheme.controlBg : root._previewColor
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth

            // Checkerboard pattern for transparent indication
            Canvas {
                anchors.fill: parent
                anchors.margins: SettingsTheme.borderWidth
                visible: root._previewColor === "transparent"
                onPaint: {
                    var ctx = getContext("2d");
                    var s = 6;
                    for (var y = 0; y < height; y += s) {
                        for (var x = 0; x < width; x += s) {
                            ctx.fillStyle = ((x / s + y / s) % 2 === 0) ? "#3A3B3E" : "#2F3032";
                            ctx.fillRect(x, y, s, s);
                        }
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Ensure the text field does not gain focus from swatch tap
                    root.forceActiveFocus()
                    presetPopup.open()
                }
            }
        }

        StyledTextField {
            id: hexInput
            Layout.fillWidth: true
            Layout.fillHeight: true
            text: root.colorValue
            placeholderText: root.placeholderText
            onTextEdited: {
                root.colorValue = text;
                root.colorEdited(text);
            }
        }
    }

    Popup {
        id: presetPopup
        x: 0
        y: root.height + 4
        width: 220
        height: 180
        padding: 8

        background: Rectangle {
            color: SettingsTheme.surfaceElevated
            radius: SettingsTheme.radiusLarge
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth
        }

        contentItem: ColumnLayout {
            spacing: 6

            Text {
                text: "Color Presets"
                font.pixelSize: SettingsTheme.fontCaption
                font.family: SettingsTheme.fontFamily
                font.weight: Font.DemiBold
                color: SettingsTheme.textSecondary
            }

            GridLayout {
                columns: 8
                rowSpacing: 4
                columnSpacing: 4
                Layout.fillWidth: true

                Repeater {
                    model: root._presetColors

                    Rectangle {
                        width: 22; height: 22
                        radius: 3
                        color: modelData
                        border.color: root.colorValue === modelData ? SettingsTheme.textPrimary : SettingsTheme.border
                        border.width: root.colorValue === modelData ? 2 : 1

                        TapHandler {
                            onTapped: {
                                root.colorValue = modelData;
                                root.colorEdited(modelData);
                                hexInput.text = modelData;
                                presetPopup.close();
                            }
                        }
                    }
                }
            }
        }
    }
}
