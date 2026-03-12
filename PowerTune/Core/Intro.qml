// * PowerTune Intro/Default Dashboard
// * Shows the logo as the default first dashboard until user configures their preferred dash
import QtQuick 2.15

Rectangle {
    id: intro

    anchors.fill: parent
    color: "black"

    Image {
        fillMode: Image.PreserveAspectFit
        height: parent.height
        // * Use bundled logo, fallback to Linux path for Pi deployment
        source: {
            if (Qt.platform.os === "linux") {
                return "file:///home/pi/Logo/Logo.png";
            }
            return "qrc:/Resources/graphics/Logo.png";
        }
        width: parent.width
    }
}
