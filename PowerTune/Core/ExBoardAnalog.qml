import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import Qt.labs.settings 1.0
import PowerTune.Utils 1.0
import PowerTune.Settings 1.0

Rectangle {
    id: mainWindow
    anchors.fill: parent
    color: "#1a1a2e"
    property double rpmfrequencydivider

    property int digiValue
    property string digiStringValue
    property int maxBrightnessOnBoot

    // * Shared sizing constants for grid cells
    readonly property int fieldWidth: mainWindow.width / 15
    readonly property int fieldHeight: mainWindow.height / 15
    readonly property int fieldFontSize: mainWindow.width / 55
    readonly property int labelFontSize: mainWindow.width / 60
    readonly property int shFieldWidth: mainWindow.width / 12
    readonly property int shFieldFontSize: mainWindow.width / 65
    readonly property int checkWidth: mainWindow.width / 20

    ListModel {
        id: comboBoxModel
        ListElement {
            text: "Ex Digital Input 1"
        }
        ListElement {
            text: "Ex Digital Input 2"
        }
        ListElement {
            text: "Ex Digital Input 3"
        }
        ListElement {
            text: "Ex Digital Input 4"
        }
        ListElement {
            text: "Ex Digital Input 5"
        }
        ListElement {
            text: "Ex Digital Input 6"
        }
        ListElement {
            text: "Ex Digital Input 7"
        }
        ListElement {
            text: "Ex Digital Input 8"
        }
    }

    Item {
        id: exsave
        Settings {
            id: settings
            property alias ex00save: ex00.text
            property alias ex05save: ex05.text
            property alias ex10save: ex10.text
            property alias ex15save: ex15.text
            property alias ex20save: ex20.text
            property alias ex25save: ex25.text
            property alias ex30save: ex30.text
            property alias ex35save: ex35.text
            property alias ex40save: ex40.text
            property alias ex45save: ex45.text
            property alias ex50save: ex50.text
            property alias ex55save: ex55.text
            property alias ex60save: ex60.text
            property alias ex65save: ex65.text
            property alias ex70save: ex70.text
            property alias ex75save: ex75.text
            property alias checkan0ntcsave: checkan0ntc.checkState
            property alias checkan1ntcsave: checkan1ntc.checkState
            property alias checkan2ntcsave: checkan2ntc.checkState
            property alias checkan3ntcsave: checkan3ntc.checkState
            property alias checkan4ntcsave: checkan4ntc.checkState
            property alias checkan5ntcsave: checkan5ntc.checkState
            property alias checkan0100save: checkan0100.checkState
            property alias checkan01Ksave: checkan01k.checkState
            property alias checkan1100save: checkan1100.checkState
            property alias checkan11Ksave: checkan11k.checkState
            property alias checkan2100save: checkan2100.checkState
            property alias checkan21Ksave: checkan21k.checkState
            property alias checkan3100save: checkan3100.checkState
            property alias checkan31Ksave: checkan31k.checkState
            property alias checkan4100save: checkan4100.checkState
            property alias checkan41Ksave: checkan41k.checkState
            property alias checkan5100save: checkan5100.checkState
            property alias checkan51Ksave: checkan51k.checkState
            property alias rpmcheckboxsave: rpmcheckbox.checkState
            //            property alias di1RPMsave  : enablefrequencydi1rpm.checkState
            property alias cylindercomboboxsave: cylindercombobox.currentIndex
            property alias cylindercomboboxv2save: cylindercomboboxv2.currentIndex
            property alias rpmcanversionselectorsave: rpmcanversionselector.currentIndex
            //            property alias cylindercomboboxDi1save : cylindercomboboxDi1.currentIndex
            //            property alias  cylindercomboboxDi1save :cylindercomboboxDi1.text
            property alias t10save: t10.text
            property alias r10save: r10.text
            property alias t20save: t20.text
            property alias r20save: r20.text
            property alias t30save: t30.text
            property alias r30save: r30.text
            property alias t11save: t11.text
            property alias r11save: r11.text
            property alias t21save: t21.text
            property alias r21save: r21.text
            property alias t31save: t31.text
            property alias r31save: r31.text
            property alias t12save: t12.text
            property alias r12save: r12.text
            property alias t22save: t22.text
            property alias r22save: r22.text
            property alias t32save: t32.text
            property alias r32save: r32.text
            property alias t13save: t13.text
            property alias r13save: r13.text
            property alias t23save: t23.text
            property alias r23save: r23.text
            property alias t33save: t33.text
            property alias r33save: r33.text
            property alias t14save: t14.text
            property alias r14save: r14.text
            property alias t24save: t24.text
            property alias r24save: r24.text
            property alias t34save: t34.text
            property alias r34save: r34.text
            property alias t15save: t15.text
            property alias r15save: r15.text
            property alias t25save: t25.text
            property alias r25save: r25.text
            property alias t35save: t35.text
            property alias r35save: r35.text
            property alias an7dampingfactorsave: an7dampingfactor.text

            property alias selectedValue: digitalExtender.currentIndex
            property alias switchValue: maxBrightnessBoot.checked
        }
    }
    property int rpmCheckboxSaveValue: settings.rpmcheckboxsave
    function getRpmCheckboxSaveValue() {
        return rpmCheckboxSaveValue;
    }

    // * Left section: Analog input values grid (EX AN 0-7)
    Grid {
        id: inputgrid
        rows: 10
        columns: 3
        spacing: 3
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.top: parent.top
        anchors.topMargin: 40
        Text {
            text: " "
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        Text {
            text: "Val. @ 0V"
            rightPadding: 3
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        Text {
            text: "Val. @ 5V"
            rightPadding: 3
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }

        Text {
            text: "EX AN 0"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        StyledTextField {
            id: ex00
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            enabled: checkan0ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: ex05
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            enabled: checkan0ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }

        Text {
            text: "EX AN 1"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        StyledTextField {
            id: ex10
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            enabled: checkan1ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: ex15
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            enabled: checkan1ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        Text {
            text: "EX AN 2"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        StyledTextField {
            id: ex20
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            enabled: checkan2ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: ex25
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            enabled: checkan2ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        Text {
            text: "EX AN 3"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        StyledTextField {
            id: ex30
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            enabled: checkan3ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: ex35
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            enabled: checkan3ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        Text {
            text: "EX AN 4"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        StyledTextField {
            id: ex40
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            enabled: checkan4ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: ex45
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            enabled: checkan4ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        Text {
            text: "EX AN 5"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        StyledTextField {
            id: ex50
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            enabled: checkan5ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: ex55
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            enabled: checkan5ntc.checked == true ? false : true
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        Text {
            text: "EX AN 6"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        StyledTextField {
            id: ex60
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: ex65
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        Text {
            text: "EX AN 7"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        StyledTextField {
            id: ex70
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: ex75
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "5"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        Text {
            text: "Ex AN 7"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        Text {

            text: Translator.translate("Damping", Settings.language)
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        StyledTextField {
            id: an7dampingfactor
            width: fieldWidth
            height: fieldHeight
            font.pixelSize: fieldFontSize
            text: "0"
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            validator: RegularExpressionValidator {
                regularExpression: /^(?:[1-9]\d{0,2}|1000)$/
            }
            onEditingFinished: inputs.setInputs()
        }

        Item {
            id: inputs
            function setInputs() {
                AppSettings.writeExternalrpm(rpmcheckbox.checked);
                AppSettings.writeEXAN7dampingSettings(an7dampingfactor.text);
                AppSettings.writeEXBoardSettings(ex00.text, ex05.text, ex10.text, ex15.text, ex20.text, ex25.text, ex30.text, ex35.text, ex40.text, ex45.text, ex50.text, ex55.text, ex60.text, ex65.text, ex70.text, ex75.text, checkan0ntc.checkState, checkan1ntc.checkState, checkan2ntc.checkState, checkan3ntc.checkState, checkan4ntc.checkState, checkan5ntc.checkState, checkan0100.checkState, checkan01k.checkState, checkan1100.checkState, checkan11k.checkState, checkan2100.checkState, checkan21k.checkState, checkan3100.checkState, checkan31k.checkState, checkan4100.checkState, checkan41k.checkState, checkan5100.checkState, checkan51k.checkState);
                AppSettings.writeSteinhartSettings(t10.text, t20.text, t30.text, r10.text, r20.text, r30.text, t11.text, t21.text, t31.text, r11.text, r21.text, r31.text, t12.text, t22.text, t32.text, r12.text, r22.text, r32.text, t13.text, t23.text, t33.text, r13.text, r23.text, r33.text, t14.text, t24.text, t34.text, r14.text, r24.text, r34.text, t15.text, t25.text, t35.text, r15.text, r25.text, r35.text);
                if (rpmcheckbox.checked == true) {
                    if (rpmcanversionselector.currentIndex == 0) {
                        AppSettings.writeCylinderSettings(cylindercombobox.textAt(cylindercombobox.currentIndex));
                    }
                    if (rpmcanversionselector.currentIndex == 1) {
                        switch (cylindercomboboxv2.currentIndex) {
                        case 0: //1cyl
                            {
                                AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                                break;
                            }
                        case 1: //2cyl
                            {
                                AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                                break;
                            }
                        case 2: //3cyl
                            {
                                AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                                break;
                            }
                        case 3: //4cyl
                            {
                                AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                                break;
                            }
                        case 4: //5cyl
                            {
                                AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                                break;
                            }
                        case 5: //6cyl
                            {
                                AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 4);     //Confirmed
                                break;
                            }
                        case 6: //8cyl
                            {
                                AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);     //Confirmed
                                // //console.log("8 Cyl")
                                break;
                            }
                        case 7: //10cyl
                            {
                                AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                                break;
                            }
                        case 8: //12cyl
                            {
                                AppSettings.writeCylinderSettings(cylindercomboboxv2.textAt(cylindercomboboxv2.currentIndex) * 2);
                                break;
                            }
                        }
                    }

                    AppSettings.writeRPMFrequencySettings(rpmfrequencydivider, 0);
                }
            }
        }
        Item {
            id: cylindercalcrpmdi1
            function cylindercalcrpmdi1() {
                switch (cylindercomboboxDi1.currentIndex) {
                case 0: //1cyl
                    {
                        rpmfrequencydivider = 0.25;//0.5;
                        break;
                    }
                case 1: //2cyl
                    {
                        rpmfrequencydivider = 0.5;//1;
                        break;
                    }
                case 2: //3cyl
                    {
                        rpmfrequencydivider = 0.75;//1.5;
                        break;
                    }
                case 3: //4cyl
                    {
                        rpmfrequencydivider = 1;//2;
                        break;
                    }
                case 4: //5cyl
                    {
                        rpmfrequencydivider = 1.25;//2.5;
                        break;
                    }
                case 5: //6cyl
                    {
                        rpmfrequencydivider = 1.5;//3;
                        break;
                    }
                case 6: //8cyl
                    {
                        rpmfrequencydivider = 2;//4;
                        break;
                    }
                case 7: //10cyl
                    {
                        rpmfrequencydivider = 2.5;//5;
                        break;
                    }
                case 8: //12cyl
                    {
                        rpmfrequencydivider = 3;//6;
                        break;
                    }
                }
                inputs.setInputs();
            }
        }
    }

    // * RPM CAN settings row
    Grid {
        id: rpmcangrid
        rows: 2
        columns: 6
        spacing: 5
        anchors.leftMargin: 16
        anchors.left: parent.left
        anchors.top: inputgrid.bottom
        anchors.topMargin: 5
        Text {
            text: "RPM CAN"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        StyledCheckBox {
            id: rpmcheckbox
            width: mainWindow.width / 14
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }

        Text {
            text: "RPMCAN " + Translator.translate("Version", Settings.language)
            font.pixelSize: labelFontSize
            visible: {
                (rpmcheckbox.checked == true) ? true : false;
            }
            color: "#FFFFFF"
        }
        StyledComboBox {
            id: rpmcanversionselector
            visible: {
                (rpmcheckbox.checked == true) ? true : false;
            }
            width: mainWindow.width / 8
            height: fieldHeight
            font.pixelSize: mainWindow.width / 75
            model: ["V1", "V2"]
            onActivated: inputs.setInputs()
        }
        Text {
            text: Translator.translate("Cylinders", Settings.language)
            font.pixelSize: labelFontSize
            visible: {
                (rpmcheckbox.checked == true) ? true : false;
            }
            color: "#FFFFFF"
        }
        StyledComboBox {
            id: cylindercombobox
            visible: {
                (rpmcanversionselector.currentIndex == 0 && rpmcheckbox.checked == true) ? true : false;
            }
            width: mainWindow.width / 8
            height: fieldHeight
            font.pixelSize: mainWindow.width / 75
            model: ["0.5", "0.6", "0.7", "0.8", "0.9", "1", "1.1", "1.2", "1.3", "1.4", "1.5", "1.6", "1.7", "1.8", "1.9", "2", "2.1", "2.2", "2.3", "2.4", "2.5", "2.6", "2.7", "2.8", "2.9", "3", "3.1", "3.2", "3.3", "3.4", "3.5", "3.6", "3.7", "3.8", "3.9", "4", "4.1", "4.2", "4.3", "4.4", "4.5", "4.6", "4.7", "4.8", "4.9", "5", "5.1", "5.2", "5.3", "5.4", "5.5", "5.6", "5.7", "5.8", "5.9", "6", "6.1", "6.2", "6.3", "6.4", "6.5", "6.6", "6.7", "6.8", "6.9", "7", "7.1", "7.2", "7.3", "7.4", "7.5", "7.6", "7.7", "7.8", "7.9", "8", "8.1", "8.2", "8.3", "8.4", "8.5", "8.6", "8.7", "8.8", "8.9", "9", "9.1", "9.2", "9.3", "9.4", "9.5", "9.6", "9.7", "9.8", "9.9", "10", "10.1", "10.2", "10.3", "10.4", "10.5", "10.6", "10.7", "10.8", "10.9", "11", "11.1", "11.2", "11.3", "11.4", "11.5", "11.6", "11.7", "11.8", "11.9", "12", "12.1", "12.2", "12.3", "12.4", "12.5", "12.6", "12.7", "12.8", "12.9"]
            onActivated: inputs.setInputs()
        }
        StyledComboBox {
            id: cylindercomboboxv2
            visible: {
                (rpmcanversionselector.currentIndex == 1 && rpmcheckbox.checked == true) ? true : false;
            }
            width: mainWindow.width / 8
            height: fieldHeight
            font.pixelSize: mainWindow.width / 75
            model: ["1", "2", "3", "4", "5", "6", "8", "12"]
            onActivated: inputs.setInputs()
        }
    }

    // * Right section header: Voltage divider jumpers
    Text {
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.right: parent.right
        text: Translator.translate("Voltage divider jumpers", Settings.language)
        font.pixelSize: labelFontSize
        color: "#FFFFFF"
    }

    // * Right section: Steinhart-Hart coefficients + voltage divider jumper checkboxes
    Grid {
        id: inputgrid2
        anchors.right: parent.right
        anchors.leftMargin: 10
        anchors.top: parent.top
        anchors.topMargin: 40
        rows: 10
        columns: 9
        spacing: 3
        Text {
            text: Translator.translate("Temp In.", Settings.language)
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
            rightPadding: mainWindow.width * 0.01675
        }
        Text {
            id: t1
            text: "T1 (C)"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        Text {
            text: "R1 (Ohm)"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        Text {
            text: "T2 (C)"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        Text {
            text: "R2 (Ohm)"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        Text {
            text: "T3 (C)"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        Text {
            text: "R3 (Ohm)"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        Text {
            text: "100 Ohm"
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }
        Text {
            text: "1K Ohm J."
            font.pixelSize: labelFontSize
            color: "#FFFFFF"
        }

        // * AN 0 Steinhart-Hart row
        StyledCheckBox {
            id: checkan0ntc
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledTextField {
            id: t10
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan0ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r10
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan0ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t20
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan0ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r20
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan0ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t30
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan0ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r30
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan0ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan0100
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan01k
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }

        // * AN 1 Steinhart-Hart row
        StyledCheckBox {
            id: checkan1ntc
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledTextField {
            id: t11
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan1ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r11
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan1ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t21
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan1ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r21
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan1ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t31
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan1ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r31
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan1ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan1100
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan11k
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }

        // * AN 2 Steinhart-Hart row
        StyledCheckBox {
            id: checkan2ntc
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledTextField {
            id: t12
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan2ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r12
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan2ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t22
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan2ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r22
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan2ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t32
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan2ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r32
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan2ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan2100
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan21k
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }

        // * AN 3 Steinhart-Hart row
        StyledCheckBox {
            id: checkan3ntc
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledTextField {
            id: t13
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan3ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r13
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan3ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t23
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan3ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r23
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan3ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t33
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan3ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r33
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan3ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan3100
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan31k
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }

        // * AN 4 Steinhart-Hart row
        StyledCheckBox {
            id: checkan4ntc
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledTextField {
            id: t14
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan4ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r14
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan4ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t24
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan4ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r24
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan4ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t34
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan4ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r34
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan4ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan4100
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan41k
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }

        // * AN 5 Steinhart-Hart row
        StyledCheckBox {
            id: checkan5ntc
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledTextField {
            id: t15
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan5ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r15
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan5ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t25
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan5ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r25
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan5ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: t35
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan5ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledTextField {
            id: r35
            width: shFieldWidth
            height: fieldHeight
            font.pixelSize: shFieldFontSize
            enabled: checkan5ntc.checked == true ? true : false
            inputMethodHints: Qt.ImhFormattedNumbersOnly
            onEditingFinished: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan5100
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
        StyledCheckBox {
            id: checkan51k
            width: checkWidth
            height: fieldHeight
            onCheckStateChanged: inputs.setInputs()
        }
    }
    Component.onCompleted: {
        inputs.setInputs();
    }

    // * Bottom bar: Digital input headlight channel selector
    Row {
        id: row1
        anchors.bottom: mainWindow.bottom
        bottomPadding: 15
        leftPadding: 16
        Text {
            id: digitalSwitchText
            text: "Digital input headlight channel:"
            color: "#FFFFFF"
            topPadding: 7
            rightPadding: 5

            font.family: "Eurostile"
            font.bold: true
            font.pixelSize: mainWindow.width / 70
            Component.onCompleted: {
                if (mainWindow.width == 800) {
                    digitalSwitchText.font.pixelSize = 15;
                }
            }
        }

        StyledComboBox {
            id: digitalExtender
            model: comboBoxModel
            textRole: "text"
            width: mainWindow.width * 0.18
            font.pixelSize: 20

            Component.onCompleted: {
                if (mainWindow.width == 800) {
                    digitalExtender.width = 170;
                    digitalExtender.height = 35;
                    digitalExtender.font.pixelSize = 12;
                }
            }
            onCurrentIndexChanged: {
                if (digitalExtender.textAt(currentIndex) === "Ex Digital Input 1") {
                    digiValue = 0;
                    digiStringValue = "Ex Digital Input 1";
                    return;
                } else if (digitalExtender.textAt(currentIndex) === "Ex Digital Input 2") {
                    digiValue = 1;
                    digiStringValue = "Ex Digital Input 2";
                    return;
                } else if (digitalExtender.textAt(currentIndex) === "Ex Digital Input 3") {
                    digiValue = 2;
                    digiStringValue = "Ex Digital Input 3";
                    return;
                } else if (digitalExtender.textAt(currentIndex) === "Ex Digital Input 4") {
                    digiValue = 3;
                    digiStringValue = "Ex Digital Input 4";
                    return;
                } else if (digitalExtender.textAt(currentIndex) === "Ex Digital Input 5") {
                    digiValue = 4;
                    digiStringValue = "Ex Digital Input 5";
                    return;
                } else if (digitalExtender.textAt(currentIndex) === "Ex Digital Input 6") {
                    digiValue = 5;
                    digiStringValue = "Ex Digital Input 6";
                    return;
                } else if (digitalExtender.textAt(currentIndex) === "Ex Digital Input 7") {
                    digiValue = 6;
                    digiStringValue = "Ex Digital Input 7";
                    return;
                } else if (digitalExtender.textAt(currentIndex) === "Ex Digital Input 8") {
                    digiValue = 7;
                    digiStringValue = "Ex Digital Input 8";
                    return;
                }
            }
        }
    }

    // * Bottom bar: CAN/IO Brightness switch
    Row {
        id: bottomExtenderRow
        anchors.left: row1.right
        anchors.bottom: mainWindow.bottom
        bottomPadding: 10
        leftPadding: 5
        spacing: 5
        Text {
            id: extenderSwitch
            text: "CAN/IO Brightness Function:"
            color: "#FFFFFF"
            font.family: "Eurostile"
            font.bold: true
            topPadding: 8
            font.pixelSize: mainWindow.width / 70
            Component.onCompleted: {
                if (mainWindow.width == 800) {
                    extenderSwitch.font.pixelSize = 15;
                } else {
                    extenderSwitch.topPadding = 4;
                }
            }
        }

        StyledSwitch {
            id: maxBrightnessBoot
            text: settings.switchValue ? "On" : "Off"
            checked: settings.value("switchChecked", false)
            width: mainWindow.width / 10
            onClicked: {
                settings.setValue("switchChecked", checked);
                maxBrightnessBoot.text = checked ? "On" : "Off";
            }
        }
    }

    function executeOnBootAction() {
        if (settings.switchValue) {
            maxBrightnessOnBoot = 1;
        }
    }
}
