import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
import PowerTune.Utils 1.0
import PowerTune.Settings 1.0

Rectangle {
    anchors.fill: parent
    color: "#1a1a2e"
    id: main

    // * Shared sizing constants for grid cells
    readonly property int fieldWidth: main.width / 12
    readonly property int fieldHeight: main.height / 15
    readonly property int fieldFontSize: main.width / 55
    readonly property int labelFontSize: main.width / 55

    Item {
        id: dashSettings
        Settings {

            property alias an00save : an00.text
            property alias an05save : an05.text
            property alias an10save : an10.text
            property alias an15save : an15.text
            property alias an20save : an20.text
            property alias an25save : an25.text
            property alias an30save : an30.text
            property alias an35save : an35.text
            property alias an40save : an40.text
            property alias an45save : an45.text
            property alias an50save : an50.text
            property alias an55save : an55.text
            property alias an60save : an60.text
            property alias an65save : an65.text
            property alias an70save : an70.text
            property alias an75save : an75.text
            property alias an80save : an80.text
            property alias an85save : an85.text
            property alias an90save : an90.text
            property alias an95save : an95.text
            property alias an100save : an100.text
            property alias an105save : an105.text

        }
    }

    Grid {
        id:inputgrid
        rows:12
        columns: 3
        spacing: 5
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 20
        anchors.leftMargin: 16
        Text { text: "  "
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        Text { text: "Val. @ 0V"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        Text { text: "Val. @ 5V"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "0"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an00
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an05
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "1"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an10
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an15
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "2"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an20
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an25
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "3"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an30
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an35
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "4"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an40
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an45
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "5"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an50
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an55
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "6"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an60
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an65
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "7"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an70
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an75
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "8"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an80
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an85
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "9"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an90
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an95
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        Text { text: Translator.translate("Analog", Settings.language) + " " + "10"
            font.pixelSize: labelFontSize; color: "#FFFFFF" }
        StyledTextField {
            id: an100
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()

        }
        StyledTextField {
            id: an105
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly  // this ensures valid inputs are number only
            onEditingFinished: inputs.setInputs()
            Component.onCompleted: inputs.setInputs()
        }
        Item {
            id: inputs
            function setInputs()
            {
            AppSettings.writeAnalogSettings(an00.text,an05.text,an10.text,an15.text,an20.text,an25.text,an30.text,an35.text,an40.text,an45.text,an50.text,an55.text,an60.text,an65.text,an70.text,an75.text,an80.text,an85.text,an90.text,an95.text,an100.text,an105.text)
            }
        }
    }

    Text {
        id: explanationtext
        anchors.left: inputgrid.right
        anchors.leftMargin: 20
        anchors.top: parent.top
        anchors.topMargin: 40
        font.pixelSize: parent.width / 55
        font.bold: true
        width: parent.width / 2.5
        horizontalAlignment: Text.AlignHCenter
        color: "#FFFFFF"
        wrapMode: Text.WordWrap
        text: Translator.translate("Analogexplanation", Settings.language)
    }
}
