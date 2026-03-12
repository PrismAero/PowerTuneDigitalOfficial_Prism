import QtQuick 2.15
import QtQuick.Controls 2.15

import PowerTune.Settings 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: helpBackground

    anchors.fill: parent
    color: "grey"

    Column {
        anchors.centerIn: parent

        Text {
            id: supportText

            bottomPadding: helpBackground.height * 0.5
            font.bold: true
            font.pixelSize: helpBackground.width * 0.02
            horizontalAlignment: Text.AlignHCenter
            text: Translator.translate("Support", Settings.language)
        }
    }

    Text {
        id: contactText

        bottomPadding: 10
        font.bold: true
        font.family: SettingsTheme.fontFamily
        font.pixelSize: helpBackground.width * 0.018 //36
        text: "Contact Page"
        x: 30
        y: 370

        Component.onCompleted: {
            if (helpBackground.width == 800) {
                contactText.x = 15;
                contactText.y = 300;
            }
        }
    }

    Text {
        id: facebookText

        bottomPadding: 10
        font.bold: true
        font.family: SettingsTheme.fontFamily
        font.pixelSize: helpBackground.width * 0.018
        text: "Facebook"
        x: 390
        y: 370

        Component.onCompleted: {
            if (helpBackground.width == 800) {
                facebookText.x = 195;
                facebookText.y = 300;
            }
        }
    }

    Text {
        id: instagramText

        bottomPadding: 10
        font.bold: true
        font.family: SettingsTheme.fontFamily
        font.pixelSize: helpBackground.width * 0.018
        text: "Instagram"
        x: 720
        y: 370

        Component.onCompleted: {
            if (helpBackground.width == 800) {
                instagramText.x = 360;
                instagramText.y = 300;
            }
        }
    }

    Text {
        id: manualText

        bottomPadding: 10
        font.bold: true
        font.family: SettingsTheme.fontFamily
        font.pixelSize: helpBackground.width * 0.018
        text: "Manual"
        x: 1080
        y: 370

        Component.onCompleted: {
            if (helpBackground.width == 800) {
                manualText.x = 540;
                manualText.y = 300;
            }
        }
    }

    Text {
        id: warrantyText

        bottomPadding: 10
        font.bold: true
        font.family: SettingsTheme.fontFamily
        font.pixelSize: helpBackground.width * 0.018
        text: "Warranty"
        x: 1400
        y: 370

        Component.onCompleted: {
            if (helpBackground.width == 800) {
                warrantyText.x = 700;
                warrantyText.y = 300;
            }
        }
    }

    Grid {
        id: qrImage

        columns: 5
        rows: 1
        spacing: parent.width * 0.05

        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        Image {
            id: contactQR

            height: helpBackground.width * 0.16 //256 // Adjust as needed
            source: "qrc:/Resources/graphics/contactQR.png" // Replace with your image file path
            width: helpBackground.width * 0.16 //256
        }

        Image {
            id: facebookQR

            height: helpBackground.width * 0.16 //256 // Adjust as needed
            source: "qrc:/Resources/graphics/facebookQR.png" // Replace with your image file path
            width: helpBackground.width * 0.16 //256
        }

        Image {
            id: instagramQR

            height: helpBackground.width * 0.16 //256 // Adjust as needed
            source: "qrc:/Resources/graphics/instagramQR.png" // Replace with your image file path
            width: helpBackground.width * 0.16 //256
        }

        Image {
            id: userManualQR

            height: helpBackground.width * 0.16 //256 // Adjust as needed
            source: "qrc:/Resources/graphics/userManualQR.png" // Replace with your image file path
            width: helpBackground.width * 0.16 //256
        }

        Image {
            id: reviewQR

            height: helpBackground.width * 0.16 //256 // Adjust as needed
            source: "qrc:/Resources/graphics/warrantyQR.png" // Replace with your image file path
            width: helpBackground.width * 0.16 //256
        }
    }
}
