// Copyright (c) 2026 Kai Wyborny. All rights reserved.
// Self-contained Material Symbols icon component for Prism.Keyboard module.
// Uses ligature-based rendering with the MaterialSymbolsOutlined font.
// The host application must embed the font as a Qt resource at the path below.
import QtQuick 2.15

Text {
    id: root

    // Icon name using Material Symbols ligature (e.g. "backspace", "keyboard_return")
    property string icon: ""

    // Icon size in pixels
    property int iconSize: 24

    // Icon color
    property color iconColor: "#FFFFFF"

    FontLoader {
        id: materialFont
        source: "qrc:/Resources/fonts/MaterialSymbolsOutlined.ttf"
    }

    font.family: materialFont.name
    font.pixelSize: iconSize
    color: iconColor
    text: icon
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
