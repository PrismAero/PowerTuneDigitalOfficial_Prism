// * PowerTune Intro/Default Dashboard
// * Shows the logo as the default first dashboard until user configures their preferred dash
import QtQuick 2.15

Rectangle {
    id: intro

    anchors.fill: parent
    color: "black"

    Image {
        id: introLogo

        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        height: parent.height
        width: parent.width

        // Use the bundled resource first so the default page still renders
        // even if the external deployment asset is missing or unreadable.
        source: "qrc:/Resources/graphics/Logo.png"

        onStatusChanged: {
            if (status === Image.Error && source !== "file:///home/pi/Logo/Logo.png")
                source = "file:///home/pi/Logo/Logo.png";
        }
    }
}
