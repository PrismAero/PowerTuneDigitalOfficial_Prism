// * Material Design Icons component
// * Uses Material Symbols font for consistent icons across the app
import QtQuick

Text {
    id: root

    // * Icon name - use Material Symbols codepoints
    // * Common icons: brightness_low, brightness_high, speed, thermostat,
    // *               settings, sensors, compass, rotate_right, analytics, etc.
    property string icon: ""

    // * Icon color
    property color iconColor: "#FFFFFF"

    // * Icon size in pixels
    property int iconSize: 24

    color: iconColor
    font.family: materialFont.name
    font.pixelSize: iconSize
    horizontalAlignment: Text.AlignHCenter

    // * Material Symbols icon mapping (ligature-based)
    text: icon
    verticalAlignment: Text.AlignVCenter

    // * Font loader for Material Symbols
    FontLoader {
        id: materialFont

        source: "qrc:/Resources/fonts/MaterialSymbolsOutlined.ttf"
    }
}
