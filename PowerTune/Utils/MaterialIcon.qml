// * Material Design Icons component
// * Uses Material Symbols font for consistent icons across the app
import QtQuick 2.15

Text {
    id: root
    
    // * Icon name - use Material Symbols codepoints
    // * Common icons: brightness_low, brightness_high, speed, thermostat, 
    // *               settings, sensors, compass, rotate_right, analytics, etc.
    property string icon: ""
    
    // * Icon size in pixels
    property int iconSize: 24
    
    // * Icon color
    property color iconColor: "#FFFFFF"
    
    // * Font loader for Material Symbols
    FontLoader {
        id: materialFont
        source: "qrc:/Resources/fonts/MaterialSymbolsOutlined.ttf"
    }
    
    font.family: materialFont.name
    font.pixelSize: iconSize
    color: iconColor
    
    // * Material Symbols icon mapping (ligature-based)
    text: icon
    
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
