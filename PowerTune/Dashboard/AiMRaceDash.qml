import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Widgets 1.0
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: raceDash
    anchors.fill: parent
    property int dashIndex: 0
    property bool configMenuEnabled: true
    property real maxSpeedValue: 320
    property real maxRpmValue: 22000
    property bool leftColumnVisible: true
    property bool rightColumnVisible: true
    property bool centerClusterVisible: true
    property bool bottomDataBandVisible: true
    property bool lowerStripVisible: true
    property bool statusBarVisible: true
    property string lowerStripTitle: "AIM STYLE"
    property string lowerStripMinimumLabel: "0"
    property string lowerStripMaximumLabel: ""
    property string trackNameText: "CIRCUITO INTERNAZIONALE DEL MUGELLO"
    property string gpsStatusText: "GPS: GOOD"
    property string statusSlot1Label: "OIL"
    property string statusSlot2Label: "WATER"

    FontLoader { id: regularFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }
    FontLoader { id: condensedBoldFont; source: "qrc:/Resources/fonts/hyperspacerace-condensedbold.otf" }

    QtObject {
        id: leftSlot1
        property string sectionTitle: "Left 1"
        property string source: "EXAnalogCalc0"
        property string label: "ENGINE OIL PRESS"
        property string unit: "PSI"
        property int decimals: 2
        property string displayMode: "number"
        property bool visible: true
        property bool alignRight: false
    }
    QtObject {
        id: leftSlot2
        property string sectionTitle: "Left 2"
        property string source: "EXAnalogCalc1"
        property string label: "WATER PRESS"
        property string unit: "BAR"
        property int decimals: 2
        property string displayMode: "number"
        property bool visible: true
        property bool alignRight: false
    }
    QtObject {
        id: leftSlot3
        property string sectionTitle: "Left 3"
        property string source: "EXAnalogCalc2"
        property string label: "FUEL PRESS"
        property string unit: "PSI"
        property int decimals: 2
        property string displayMode: "number"
        property bool visible: true
        property bool alignRight: false
    }
    QtObject {
        id: rightSlot1
        property string sectionTitle: "Right 1"
        property string source: "EXAnalogCalc3"
        property string label: "ENGINE OIL TEMP"
        property string unit: "F"
        property int decimals: 2
        property string displayMode: "number"
        property bool visible: true
        property bool alignRight: true
    }
    QtObject {
        id: rightSlot2
        property string sectionTitle: "Right 2"
        property string source: "Watertemp"
        property string label: "WATER TEMP"
        property string unit: "C"
        property int decimals: 2
        property string displayMode: "number"
        property bool visible: true
        property bool alignRight: true
    }
    QtObject {
        id: rightSlot3
        property string sectionTitle: "Right 3"
        property string source: speedTach.gearSource
        property string label: "GEAR"
        property string unit: ""
        property int decimals: 0
        property string displayMode: "gear"
        property bool visible: true
        property bool alignRight: true
    }
    QtObject {
        id: bottomSlot1
        property string sectionTitle: "Bottom 1"
        property string source: speedTach.speedSource
        property string label: "SPEED"
        property string unit: Settings.speedunits === "imperial" ? "MPH" : "KM/H"
        property int decimals: 0
        property string displayMode: "number"
        property bool visible: true
        property bool alignRight: false
        property real weight: 1.2
    }
    QtObject {
        id: bottomSlot2
        property string sectionTitle: "Bottom 2"
        property string source: speedTach.rpmSource
        property string label: "RPM"
        property string unit: ""
        property int decimals: 0
        property string displayMode: "number"
        property bool visible: true
        property bool alignRight: false
        property real weight: 1.2
    }
    QtObject {
        id: bottomSlot3
        property string sectionTitle: "Bottom 3"
        property string source: speedTach.gearSource
        property string label: "GEAR"
        property string unit: ""
        property int decimals: 0
        property string displayMode: "gear"
        property bool visible: true
        property bool alignRight: false
        property real weight: 0.9
    }
    QtObject {
        id: bottomSlot4
        property string sectionTitle: "Bottom 4"
        property string source: "MAP"
        property string label: "MAP"
        property string unit: "KPA"
        property int decimals: 0
        property string displayMode: "number"
        property bool visible: true
        property bool alignRight: false
        property real weight: 1.0
    }
    QtObject {
        id: bottomSlot5
        property string sectionTitle: "Bottom 5"
        property string source: "Watertemp"
        property string label: "ECT"
        property string unit: "C"
        property int decimals: 0
        property string displayMode: "number"
        property bool visible: true
        property bool alignRight: true
        property real weight: 1.3
    }

    readonly property var _sideSlotConfigs: [leftSlot1, leftSlot2, leftSlot3, rightSlot1, rightSlot2, rightSlot3]
    readonly property var _bottomSlotConfigs: [bottomSlot1, bottomSlot2, bottomSlot3, bottomSlot4, bottomSlot5]

    Rectangle {
        anchors.fill: parent
        color: "#000000"
    }

    MouseArea {
        anchors.fill: parent
        z: 1
        propagateComposedEvents: true
        onPressed: function(mouse) {
            mouse.accepted = false;
        }
        onDoubleClicked: function(mouse) {
            if (!raceDash.configMenuEnabled)
                return;
            mouse.accepted = true;
            configMenu.show(mouse.x, mouse.y);
        }
    }

    readonly property real _sideWidth: raceDash.width * 0.18
    readonly property real _centerWidth: raceDash.width * 0.52
    readonly property real _topMargin: raceDash.height * 0.05
    readonly property real _statusBarHeight: raceDash.height * 0.18
    readonly property real _contentHeight: raceDash.height - raceDash._statusBarHeight - raceDash._topMargin * 0.9
    readonly property real _cellHeight: raceDash._contentHeight * 0.23
    readonly property real _columnSpacing: raceDash.height * 0.02
    readonly property real _rpmFraction: {
        if (speedTach.maxRPM <= 0)
            return 0;
        return Math.max(0, Math.min(1, speedTach.rpmValue / speedTach.maxRPM));
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.05) }
            GradientStop { position: 0.25; color: "transparent" }
            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.20) }
        }
    }

    Rectangle {
        width: raceDash.width * 0.44
        height: raceDash.height * 0.12
        anchors.left: parent.left
        anchors.top: parent.top
        color: Qt.rgba(1, 1, 1, 0.025)
        rotation: -8
        transformOrigin: Item.TopLeft
    }

    Rectangle {
        width: raceDash.width * 0.34
        height: raceDash.height * 0.11
        anchors.right: parent.right
        anchors.top: parent.top
        color: Qt.rgba(1, 1, 1, 0.02)
        rotation: 7
        transformOrigin: Item.TopRight
    }

    Item {
        id: contentArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: statusBar.top
        anchors.leftMargin: raceDash.width * 0.012
        anchors.rightMargin: raceDash.width * 0.012
        anchors.topMargin: raceDash._topMargin
        anchors.bottomMargin: raceDash.height * 0.01

        Column {
            id: leftColumn
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: bottomDataBand.top
            width: raceDash._sideWidth
            spacing: raceDash._columnSpacing
            visible: raceDash.leftColumnVisible

            AiMInfoCell {
                id: cellL1
                width: parent.width
                height: raceDash._cellHeight
                configMenuEnabled: false
                visible: leftSlot1.visible
                labeltext: leftSlot1.label
                unittext: leftSlot1.unit
                mainvaluename: leftSlot1.source
                decimalpoints: leftSlot1.decimals
                displayMode: leftSlot1.displayMode
                alignRight: leftSlot1.alignRight
            }
            AiMInfoCell {
                id: cellL2
                width: parent.width
                height: raceDash._cellHeight
                configMenuEnabled: false
                visible: leftSlot2.visible
                labeltext: leftSlot2.label
                unittext: leftSlot2.unit
                mainvaluename: leftSlot2.source
                decimalpoints: leftSlot2.decimals
                displayMode: leftSlot2.displayMode
                alignRight: leftSlot2.alignRight
            }
            AiMInfoCell {
                id: cellL3
                width: parent.width
                height: raceDash._cellHeight
                configMenuEnabled: false
                visible: leftSlot3.visible
                labeltext: leftSlot3.label
                unittext: leftSlot3.unit
                mainvaluename: leftSlot3.source
                decimalpoints: leftSlot3.decimals
                displayMode: leftSlot3.displayMode
                alignRight: leftSlot3.alignRight
            }
        }

        Column {
            id: rightColumn
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: bottomDataBand.top
            width: raceDash._sideWidth
            spacing: raceDash._columnSpacing
            visible: raceDash.rightColumnVisible

            AiMInfoCell {
                id: cellR1
                width: parent.width
                height: raceDash._cellHeight
                configMenuEnabled: false
                visible: rightSlot1.visible
                labeltext: rightSlot1.label
                unittext: rightSlot1.unit
                mainvaluename: rightSlot1.source
                decimalpoints: rightSlot1.decimals
                displayMode: rightSlot1.displayMode
                alignRight: rightSlot1.alignRight
            }
            AiMInfoCell {
                id: cellR2
                width: parent.width
                height: raceDash._cellHeight
                configMenuEnabled: false
                visible: rightSlot2.visible
                labeltext: rightSlot2.label
                unittext: rightSlot2.unit
                mainvaluename: rightSlot2.source
                decimalpoints: rightSlot2.decimals
                displayMode: rightSlot2.displayMode
                alignRight: rightSlot2.alignRight
            }
            AiMInfoCell {
                id: cellR3
                width: parent.width
                height: raceDash._cellHeight
                configMenuEnabled: false
                visible: rightSlot3.visible
                labeltext: rightSlot3.label
                unittext: rightSlot3.unit
                mainvaluename: rightSlot3.source
                displayMode: rightSlot3.displayMode
                decimalpoints: rightSlot3.decimals
                alignRight: rightSlot3.alignRight
            }
        }

        Rectangle {
            anchors.left: leftColumn.right
            anchors.leftMargin: 2
            anchors.top: parent.top
            anchors.topMargin: raceDash.height * 0.04
            anchors.bottom: bottomDataBand.top
            width: 1
            color: GaugeTheme.aimSeparator
            opacity: 0.5
        }

        Rectangle {
            anchors.right: rightColumn.left
            anchors.rightMargin: 2
            anchors.top: parent.top
            anchors.topMargin: raceDash.height * 0.04
            anchors.bottom: bottomDataBand.top
            width: 1
            color: GaugeTheme.aimSeparator
            opacity: 0.5
        }

        Item {
            id: centerCluster
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: raceDash._centerWidth
            height: parent.height * 0.74
            visible: raceDash.centerClusterVisible

            Shape {
                anchors.fill: parent
                antialiasing: true
                opacity: 0.95

                ShapePath {
                    strokeWidth: 2
                    strokeColor: GaugeTheme.aimPanelStrokeSoft
                    fillColor: Qt.rgba(0, 0, 0, 0.24)
                    startX: width * 0.07
                    startY: height * 0.20
                    PathQuad { x: width * 0.50; y: height * 0.02; controlX: width * 0.28; controlY: height * 0.02 }
                    PathQuad { x: width * 0.93; y: height * 0.20; controlX: width * 0.72; controlY: height * 0.02 }
                    PathLine { x: width * 0.83; y: height * 0.92 }
                    PathQuad { x: width * 0.17; y: height * 0.92; controlX: width * 0.50; controlY: height * 1.06 }
                    PathLine { x: width * 0.07; y: height * 0.20 }
                }
            }

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.055) }
                    GradientStop { position: 0.23; color: Qt.rgba(1, 1, 1, 0.012) }
                    GradientStop { position: 0.70; color: "transparent" }
                    GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.18) }
                }
            }

            AiMSpeedTach {
                id: speedTach
                anchors.fill: parent
                anchors.topMargin: -raceDash.height * 0.01
                speedUnit: Settings.speedunits === "imperial" ? "MPH" : "KM/H"
                maxSpeed: raceDash.maxSpeedValue
                maxRPM: raceDash.maxRpmValue
            }
        }

        Rectangle {
            anchors.left: leftColumn.right
            anchors.right: rightColumn.left
            anchors.leftMargin: raceDash.width * 0.014
            anchors.rightMargin: raceDash.width * 0.014
            anchors.bottom: bottomDataBand.top
            anchors.bottomMargin: -1
            height: 1
            color: GaugeTheme.aimBottomStripEdge
        }

        Rectangle {
            anchors.left: leftColumn.right
            anchors.right: rightColumn.left
            anchors.leftMargin: raceDash.width * 0.014
            anchors.rightMargin: raceDash.width * 0.014
            anchors.bottom: bottomDataBand.top
            anchors.bottomMargin: -2
            height: 3
            color: GaugeTheme.aimBottomStripGlow
        }

        Item {
            id: bottomDataBand
            anchors.left: leftColumn.right
            anchors.right: rightColumn.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: raceDash.width * 0.014
            anchors.rightMargin: raceDash.width * 0.014
            height: parent.height * 0.24
            visible: raceDash.bottomDataBandVisible

            Shape {
                anchors.fill: parent
                antialiasing: true

                ShapePath {
                    strokeWidth: 1
                    strokeColor: GaugeTheme.aimPanelStrokeSoft
                    fillColor: Qt.rgba(0, 0, 0, 0.30)
                    startX: width * 0.03
                    startY: 0
                    PathLine { x: width * 0.97; y: 0 }
                    PathLine { x: width; y: height * 0.28 }
                    PathLine { x: width; y: height }
                    PathLine { x: 0; y: height }
                    PathLine { x: 0; y: height * 0.28 }
                    PathLine { x: width * 0.03; y: 0 }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: parent.height * 0.44
                color: "transparent"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.05) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            RowLayout {
                id: bottomMetricsRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.topMargin: parent.height * 0.02
                anchors.leftMargin: parent.width * 0.03
                anchors.rightMargin: parent.width * 0.03
                height: parent.height * 0.46
                spacing: parent.width * 0.018

                AiMInfoCell {
                    Layout.fillWidth: true
                    Layout.preferredWidth: bottomSlot1.weight
                    height: parent.height
                    configMenuEnabled: false
                    visible: bottomSlot1.visible
                    labeltext: bottomSlot1.label
                    unittext: bottomSlot1.unit
                    mainvaluename: bottomSlot1.source
                    decimalpoints: bottomSlot1.decimals
                    displayMode: bottomSlot1.displayMode
                    alignRight: bottomSlot1.alignRight
                }
                AiMInfoCell {
                    Layout.fillWidth: true
                    Layout.preferredWidth: bottomSlot2.weight
                    height: parent.height
                    configMenuEnabled: false
                    visible: bottomSlot2.visible
                    labeltext: bottomSlot2.label
                    unittext: bottomSlot2.unit
                    mainvaluename: bottomSlot2.source
                    decimalpoints: bottomSlot2.decimals
                    displayMode: bottomSlot2.displayMode
                    alignRight: bottomSlot2.alignRight
                }
                AiMInfoCell {
                    Layout.fillWidth: true
                    Layout.preferredWidth: bottomSlot3.weight
                    height: parent.height
                    configMenuEnabled: false
                    visible: bottomSlot3.visible
                    labeltext: bottomSlot3.label
                    unittext: bottomSlot3.unit
                    mainvaluename: bottomSlot3.source
                    displayMode: bottomSlot3.displayMode
                    decimalpoints: bottomSlot3.decimals
                    alignRight: bottomSlot3.alignRight
                }
                AiMInfoCell {
                    Layout.fillWidth: true
                    Layout.preferredWidth: bottomSlot4.weight
                    height: parent.height
                    configMenuEnabled: false
                    visible: bottomSlot4.visible
                    labeltext: bottomSlot4.label
                    unittext: bottomSlot4.unit
                    mainvaluename: bottomSlot4.source
                    decimalpoints: bottomSlot4.decimals
                    displayMode: bottomSlot4.displayMode
                    alignRight: bottomSlot4.alignRight
                }
                AiMInfoCell {
                    Layout.fillWidth: true
                    Layout.preferredWidth: bottomSlot5.weight
                    height: parent.height
                    configMenuEnabled: false
                    visible: bottomSlot5.visible
                    labeltext: bottomSlot5.label
                    unittext: bottomSlot5.unit
                    mainvaluename: bottomSlot5.source
                    decimalpoints: bottomSlot5.decimals
                    displayMode: bottomSlot5.displayMode
                    alignRight: bottomSlot5.alignRight
                }
            }

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height * 0.14
                height: parent.height * 0.22
                visible: raceDash.lowerStripVisible

                Rectangle {
                    id: lowerTrack
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: parent.width * 0.18
                    anchors.rightMargin: parent.width * 0.06
                    anchors.verticalCenter: parent.verticalCenter
                    height: 10
                    color: "#161616"

                    Row {
                        anchors.left: parent.left
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: parent.width * raceDash._rpmFraction
                        clip: true
                        spacing: 0

                        Repeater {
                            model: 48
                            Rectangle {
                                width: lowerTrack.width / 48
                                height: lowerTrack.height
                                color: {
                                    var f = (index + 0.5) / 48;
                                    if (f < 0.55) return GaugeTheme.aimArcGreen;
                                    if (f < 0.82) return GaugeTheme.aimArcYellow;
                                    return GaugeTheme.aimArcRed;
                                }
                            }
                        }
                    }

                    Rectangle {
                        x: lowerTrack.width * raceDash._rpmFraction - 1
                        y: -4
                        width: 2
                        height: lowerTrack.height + 8
                        color: "#FFFFFF"
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: lowerTrack.verticalCenter
                    text: raceDash.lowerStripTitle
                    font.family: condensedBoldFont.name
                    font.pixelSize: 14
                    font.letterSpacing: 1.0
                    color: GaugeTheme.aimTrackName
                }

                Text {
                    anchors.left: lowerTrack.left
                    anchors.bottom: lowerTrack.top
                    anchors.bottomMargin: 3
                    text: raceDash.lowerStripMinimumLabel
                    font.family: regularFont.name
                    font.pixelSize: 10
                    color: GaugeTheme.aimTrackName
                }

                Text {
                    anchors.right: lowerTrack.right
                    anchors.bottom: lowerTrack.top
                    anchors.bottomMargin: 3
                    text: raceDash.lowerStripMaximumLabel !== "" ? raceDash.lowerStripMaximumLabel : speedTach.maxRPM.toFixed(0)
                    font.family: regularFont.name
                    font.pixelSize: 10
                    color: GaugeTheme.aimTrackName
                }
            }
        }
    }

    AiMStatusBar {
        id: statusBar
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: raceDash._statusBarHeight
        visible: raceDash.statusBarVisible
        configMenuEnabled: false
        infoSlot1Source: leftSlot1.source
        infoSlot1Label: raceDash.statusSlot1Label
        infoSlot2Source: rightSlot2.source
        infoSlot2Label: raceDash.statusSlot2Label
        progressValue: speedTach.rpmValue
        progressMaximum: speedTach.maxRPM
        trackName: raceDash.trackNameText
        gpsText: raceDash.gpsStatusText
    }

    GaugeConfigMenu {
        id: configMenu
        target: raceDash
        allowDelete: false
        panelWidth: 380
        sections: [
            QtObject {
                property Component component: Component {
                    Column {
                        spacing: 6
                        width: parent ? parent.width : 320

                        Text { text: "Layout"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Switch { text: "Show left column"; checked: raceDash.leftColumnVisible; onCheckedChanged: raceDash.leftColumnVisible = checked }
                        Switch { text: "Show right column"; checked: raceDash.rightColumnVisible; onCheckedChanged: raceDash.rightColumnVisible = checked }
                        Switch { text: "Show center cluster"; checked: raceDash.centerClusterVisible; onCheckedChanged: raceDash.centerClusterVisible = checked }
                        Switch { text: "Show bottom band"; checked: raceDash.bottomDataBandVisible; onCheckedChanged: raceDash.bottomDataBandVisible = checked }
                        Switch { text: "Show lower strip"; checked: raceDash.lowerStripVisible; onCheckedChanged: raceDash.lowerStripVisible = checked }
                        Switch { text: "Show status bar"; checked: raceDash.statusBarVisible; onCheckedChanged: raceDash.statusBarVisible = checked }

                        Row {
                            spacing: 4
                            Text { text: "Max Speed:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: 10; to: 999; value: raceDash.maxSpeedValue; editable: true; onValueChanged: raceDash.maxSpeedValue = value }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Max RPM:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            SpinBox { from: 1000; to: 30000; stepSize: 500; value: raceDash.maxRpmValue; editable: true; onValueChanged: raceDash.maxRpmValue = value }
                        }
                    }
                }
            },
            QtObject {
                property Component component: Component {
                    Column {
                        spacing: 6
                        width: parent ? parent.width : 340

                        Text { text: "Side Slots"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Repeater {
                            model: raceDash._sideSlotConfigs
                            delegate: Column {
                                property var slot: modelData
                                spacing: 4
                                width: parent.width

                                Rectangle { width: parent.width; height: 1; color: Qt.rgba(1,1,1,0.08) }
                                Text { text: slot.sectionTitle; font.bold: true; font.pixelSize: 12; color: "#F0F0F0" }
                                Switch { text: "Visible"; checked: slot.visible; onCheckedChanged: slot.visible = checked }
                                Row {
                                    spacing: 4
                                    Text { text: "Source:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    ComboBox {
                                        width: 230
                                        model: DatasourceService.allSources
                                        textRole: "titlename"
                                        font.pixelSize: 12
                                        Component.onCompleted: {
                                            for (var i = 0; i < model.count; ++i) {
                                                if (DatasourceService.allSources.get(i).sourcename === slot.source) {
                                                    currentIndex = i;
                                                    break;
                                                }
                                            }
                                        }
                                        onActivated: slot.source = DatasourceService.allSources.get(currentIndex).sourcename
                                    }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Label:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    TextField { width: 230; text: slot.label; font.pixelSize: 12; onTextChanged: slot.label = text }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Unit:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    TextField { width: 230; text: slot.unit; font.pixelSize: 12; onTextChanged: slot.unit = text }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Decimals:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    SpinBox { from: 0; to: 6; value: slot.decimals; onValueChanged: slot.decimals = value }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Mode:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    ComboBox {
                                        width: 230
                                        model: ["number", "gear"]
                                        Component.onCompleted: currentIndex = Math.max(0, model.indexOf(slot.displayMode))
                                        onActivated: slot.displayMode = model[index]
                                    }
                                }
                            }
                        }
                    }
                }
            },
            QtObject {
                property Component component: Component {
                    Column {
                        spacing: 6
                        width: parent ? parent.width : 340

                        Text { text: "Bottom Slots"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Repeater {
                            model: raceDash._bottomSlotConfigs
                            delegate: Column {
                                property var slot: modelData
                                spacing: 4
                                width: parent.width

                                Rectangle { width: parent.width; height: 1; color: Qt.rgba(1,1,1,0.08) }
                                Text { text: slot.sectionTitle; font.bold: true; font.pixelSize: 12; color: "#F0F0F0" }
                                Switch { text: "Visible"; checked: slot.visible; onCheckedChanged: slot.visible = checked }
                                Row {
                                    spacing: 4
                                    Text { text: "Source:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    ComboBox {
                                        width: 230
                                        model: DatasourceService.allSources
                                        textRole: "titlename"
                                        font.pixelSize: 12
                                        Component.onCompleted: {
                                            for (var i = 0; i < model.count; ++i) {
                                                if (DatasourceService.allSources.get(i).sourcename === slot.source) {
                                                    currentIndex = i;
                                                    break;
                                                }
                                            }
                                        }
                                        onActivated: slot.source = DatasourceService.allSources.get(currentIndex).sourcename
                                    }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Label:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    TextField { width: 230; text: slot.label; font.pixelSize: 12; onTextChanged: slot.label = text }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Unit:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    TextField { width: 230; text: slot.unit; font.pixelSize: 12; onTextChanged: slot.unit = text }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Decimals:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    SpinBox { from: 0; to: 6; value: slot.decimals; onValueChanged: slot.decimals = value }
                                }
                                Row {
                                    spacing: 4
                                    Text { text: "Weight:"; font.pixelSize: 12; color: "#CCC"; width: 70 }
                                    TextField { width: 230; text: slot.weight; font.pixelSize: 12; onEditingFinished: slot.weight = Number(text) }
                                }
                            }
                        }
                    }
                }
            },
            QtObject {
                property Component component: Component {
                    Column {
                        spacing: 6
                        width: parent ? parent.width : 320

                        Text { text: "Strip And Status"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Strip Title:"; font.pixelSize: 12; color: "#CCC"; width: 90 }
                            TextField { width: 220; text: raceDash.lowerStripTitle; font.pixelSize: 12; onTextChanged: raceDash.lowerStripTitle = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Min Label:"; font.pixelSize: 12; color: "#CCC"; width: 90 }
                            TextField { width: 220; text: raceDash.lowerStripMinimumLabel; font.pixelSize: 12; onTextChanged: raceDash.lowerStripMinimumLabel = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Max Label:"; font.pixelSize: 12; color: "#CCC"; width: 90 }
                            TextField { width: 220; text: raceDash.lowerStripMaximumLabel; font.pixelSize: 12; placeholderText: "auto"; onTextChanged: raceDash.lowerStripMaximumLabel = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Track:"; font.pixelSize: 12; color: "#CCC"; width: 90 }
                            TextField { width: 220; text: raceDash.trackNameText; font.pixelSize: 12; onTextChanged: raceDash.trackNameText = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "GPS:"; font.pixelSize: 12; color: "#CCC"; width: 90 }
                            TextField { width: 220; text: raceDash.gpsStatusText; font.pixelSize: 12; onTextChanged: raceDash.gpsStatusText = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Status 1:"; font.pixelSize: 12; color: "#CCC"; width: 90 }
                            TextField { width: 220; text: raceDash.statusSlot1Label; font.pixelSize: 12; onTextChanged: raceDash.statusSlot1Label = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Status 2:"; font.pixelSize: 12; color: "#CCC"; width: 90 }
                            TextField { width: 220; text: raceDash.statusSlot2Label; font.pixelSize: 12; onTextChanged: raceDash.statusSlot2Label = text }
                        }
                    }
                }
            }
        ]
    }
}
