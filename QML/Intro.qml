import QtQuick 2.15

Rectangle {
    id: intro
    anchors.fill: parent
    color: "black"

    Image {
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectFit
        // * Use bundled logo, fallback to Linux path for Pi deployment
        source: {
            if (Qt.platform.os === "linux") {
                return "file:///home/pi/Logo/Logo.png"
            }
            return "qrc:/Resources/graphics/Logo.png"
        }
    }
}
