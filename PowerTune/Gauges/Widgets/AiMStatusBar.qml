import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    width: parent ? parent.width : 1280
    height: 110
    color: bgColor

    property string information: "AiM status bar"
    property color bgColor: GaugeTheme.aimBottomStrip
    property color textColor: GaugeTheme.aimStatusBarText
    property color statusGoodColor: GaugeTheme.aimStatusGood
    property color statusWarningColor: GaugeTheme.aimStatusWarning
    property color statusBadColor: GaugeTheme.aimStatusBad
    property color borderTopColor: GaugeTheme.aimSeparator
    property bool dateTimeVisible: true
    property bool configMenuEnabled: true
    property bool showSystemRow: true
    property bool showEcuRow: true
    property bool showGpsLine: true
    property bool showInfoSlot1: true
    property bool showInfoSlot2: true
    property bool showClockBlock: true
    property bool showProgressBar: true
    property bool showTrackName: true
    property bool showDateBlock: true
    property string systemStatusText: "SYS: OK"
    property string ecuLabelPrefix: "ECU"
    property string clockLabel: "CLOCK"
    property string infoSlot1FallbackLabel: "AUX 1"
    property string infoSlot2FallbackLabel: "AUX 2"
    property string fontFamily: ""
    property string infoSlot1Source: ""
    property string infoSlot1Label: ""
    property string infoSlot2Source: ""
    property string infoSlot2Label: ""
    property string trackName: "CIRCUITO INTERNAZIONALE DEL MUGELLO"
    property string gpsText: "GPS: GOOD"
    property double progressValue: 0
    property double progressMaximum: 1
    property double infoSlot1Value: 0
    property double infoSlot2Value: 0
    property string increasedecreaseident
    property int _clockTick: 0

    FontLoader { id: regularFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }
    FontLoader { id: condensedBoldFont; source: "qrc:/Resources/fonts/hyperspacerace-condensedbold.otf" }
    FontLoader { id: boldFont; source: "qrc:/Resources/fonts/hyperspacerace-bold.otf" }

    readonly property string _resolvedFont: fontFamily !== "" ? fontFamily : regularFont.name
    readonly property string _resolvedCondensedFont: fontFamily !== "" ? fontFamily : condensedBoldFont.name
    readonly property string _resolvedBoldFont: fontFamily !== "" ? fontFamily : boldFont.name
    readonly property real _progressFraction: {
        if (progressMaximum <= 0)
            return 0;
        return Math.max(0, Math.min(1, progressValue / progressMaximum));
    }
    readonly property string _ecuStatus: {
        if (typeof Connect !== "undefined" && Connect.SerialStat)
            return Connect.SerialStat;
        return "OFFLINE";
    }
    readonly property bool _ecuConnected: {
        var s = _ecuStatus.toLowerCase();
        return s.indexOf("connected") >= 0 || s.indexOf("open") >= 0;
    }
    readonly property string _fullDateText: {
        if (!dateTimeVisible)
            return "";
        void _clockTick;
        var d = new Date();
        var day = d.getDate().toString().padStart(2, "0");
        var month = (d.getMonth() + 1).toString().padStart(2, "0");
        var year = d.getFullYear();
        var hours = d.getHours();
        var ampm = hours >= 12 ? "PM" : "AM";
        hours = hours % 12;
        if (hours === 0)
            hours = 12;
        var mins = d.getMinutes().toString().padStart(2, "0");
        return day + "." + month + "." + year + " " + hours.toString().padStart(2, "0") + "." + mins + " " + ampm;
    }
    readonly property string _clockText: {
        void _clockTick;
        var d = new Date();
        var h = d.getHours().toString().padStart(2, "0");
        var m = d.getMinutes().toString().padStart(2, "0");
        var s = d.getSeconds().toString().padStart(2, "0");
        return h + "." + m + "." + s;
    }

    function _bindValues() {
        if (infoSlot1Source)
            infoSlot1Value = Qt.binding(function() { return PropertyRouter.getValue(infoSlot1Source); });
        if (infoSlot2Source)
            infoSlot2Value = Qt.binding(function() { return PropertyRouter.getValue(infoSlot2Source); });
    }

    function _formatMetric(value) {
        if (!isFinite(value))
            return "--";
        return Number(value).toFixed(2);
    }

    Component.onCompleted: _bindValues()
    onInfoSlot1SourceChanged: _bindValues()
    onInfoSlot2SourceChanged: _bindValues()

    MouseArea {
        anchors.fill: parent
        property real _lastTapTime: 0
        onPressed: function(mouse) {
            var now = Date.now();
            if (root.configMenuEnabled && now - _lastTapTime < 360) {
                _lastTapTime = 0;
                configMenu.show(mouse.x, mouse.y);
            } else {
                _lastTapTime = now;
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: bgColor
        gradient: Gradient {
            GradientStop { position: 0.0; color: GaugeTheme.aimBottomStripEdge }
            GradientStop { position: 0.2; color: bgColor }
            GradientStop { position: 1.0; color: "#050505" }
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: root.borderTopColor
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: parent.height * 0.35
        color: "transparent"
        gradient: Gradient {
            GradientStop { position: 0.0; color: GaugeTheme.aimBottomStripGlow }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    Item {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 10
        anchors.bottomMargin: 8

        Item {
            id: leftPod
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * 0.24

            Column {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Row {
                    spacing: 8
                    visible: root.showSystemRow
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: root.statusGoodColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: root.systemStatusText
                        font.family: root._resolvedFont
                        font.pixelSize: 18
                        color: root.textColor
                    }
                }

                Row {
                    spacing: 8
                    visible: root.showEcuRow
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: root._ecuConnected ? root.statusGoodColor : root.statusBadColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: root.ecuLabelPrefix + ": " + root._ecuStatus.toUpperCase()
                        font.family: root._resolvedFont
                        font.pixelSize: 18
                        color: root.textColor
                    }
                }

                Text {
                    text: root.gpsText
                    font.family: root._resolvedCondensedFont
                    font.pixelSize: 14
                    color: GaugeTheme.aimTrackName
                    visible: root.showGpsLine && text.length > 0
                }
            }
        }

        Item {
            id: rightPod
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * 0.20

            Text {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                text: root._fullDateText
                font.family: root._resolvedFont
                font.pixelSize: 17
                color: root.textColor
                visible: root.dateTimeVisible && root.showDateBlock
            }
        }

        Item {
            id: centerBand
            anchors.left: leftPod.right
            anchors.right: rightPod.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            Rectangle {
                anchors.fill: parent
                color: "transparent"
                border.width: 1
                border.color: GaugeTheme.aimPanelStrokeSoft
            }

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: parent.height * 0.60

                Item {
                    width: parent.width / 3
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.infoSlot1Label !== "" ? root.infoSlot1Label.toUpperCase() : root.infoSlot1FallbackLabel
                        font.family: root._resolvedCondensedFont
                        font.pixelSize: 14
                        font.letterSpacing: 1.2
                        color: GaugeTheme.aimTrackName
                    }
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root._formatMetric(root.infoSlot1Value)
                        font.family: root._resolvedBoldFont
                        font.pixelSize: 34
                        color: GaugeTheme.aimValueWhite
                    }
                    visible: root.showInfoSlot1
                }

                Item {
                    width: parent.width / 3
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.infoSlot2Label !== "" ? root.infoSlot2Label.toUpperCase() : root.infoSlot2FallbackLabel
                        font.family: root._resolvedCondensedFont
                        font.pixelSize: 14
                        font.letterSpacing: 1.2
                        color: GaugeTheme.aimTrackName
                    }
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root._formatMetric(root.infoSlot2Value)
                        font.family: root._resolvedBoldFont
                        font.pixelSize: 34
                        color: GaugeTheme.aimValueWhite
                    }
                    visible: root.showInfoSlot2
                }

                Item {
                    width: parent.width / 3
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom

                    Text {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.clockLabel
                        font.family: root._resolvedCondensedFont
                        font.pixelSize: 14
                        font.letterSpacing: 1.2
                        color: GaugeTheme.aimTrackName
                    }
                    Text {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root._clockText
                        font.family: root._resolvedBoldFont
                        font.pixelSize: 34
                        color: GaugeTheme.aimValueWhite
                    }
                    visible: root.showClockBlock
                }
            }

            Rectangle {
                id: progressTrack
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: 10
                color: "#1A1A1A"
                visible: root.showProgressBar

                Rectangle {
                    anchors.left: parent.left
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width * root._progressFraction
                    clip: true

                    Row {
                        anchors.fill: parent
                        spacing: 0

                        Repeater {
                            model: 40
                            Rectangle {
                                width: progressTrack.width / 40
                                height: progressTrack.height
                                color: {
                                    var f = (index + 0.5) / 40;
                                    if (f < 0.45) return GaugeTheme.aimArcGreen;
                                    if (f < 0.75) return GaugeTheme.aimArcYellow;
                                    return GaugeTheme.aimCyan;
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    x: progressTrack.width * Math.max(0, Math.min(1, root._progressFraction)) - 1
                    width: 2
                    height: progressTrack.height + 8
                    y: -4
                    color: "#FFFFFF"
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: progressTrack.top
                anchors.bottomMargin: 2
                text: root.trackName
                font.family: root._resolvedCondensedFont
                font.pixelSize: 15
                font.letterSpacing: 1.4
                color: GaugeTheme.aimTrackName
                elide: Text.ElideRight
                width: parent.width * 0.8
                horizontalAlignment: Text.AlignHCenter
                visible: root.showTrackName && text.length > 0
            }
        }
    }

    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: root._clockTick++
    }

    Accessible.role: Accessible.StatusBar
    Accessible.name: "AiM Status Bar"

    GaugeConfigMenu {
        id: configMenu
        target: root
        allowDelete: false
        sections: [
            QtObject {
                property Component component: Component {
                    Column {
                        property Item target
                        spacing: 6
                        width: parent ? parent.width : 260

                        Text { text: "Info Slots"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Slot 1:"; font.pixelSize: 12; color: "#CCC"; width: 50; verticalAlignment: Text.AlignVCenter }
                            ComboBox {
                                width: 190
                                model: DatasourceService.allSources
                                textRole: "titlename"
                                font.pixelSize: 12
                                Component.onCompleted: {
                                    for (var i = 0; i < model.count; ++i)
                                        if (DatasourceService.allSources.get(i).sourcename === root.infoSlot1Source)
                                            currentIndex = i;
                                }
                                onCurrentIndexChanged: {
                                    if (currentIndex >= 0) {
                                        root.infoSlot1Source = DatasourceService.allSources.get(currentIndex).sourcename;
                                        root.infoSlot1Value = Qt.binding(function() { return PropertyRouter.getValue(root.infoSlot1Source); });
                                    }
                                }
                            }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Label 1:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.infoSlot1Label; font.pixelSize: 12; onTextChanged: root.infoSlot1Label = text }
                        }

                        Row {
                            spacing: 4
                            Text { text: "Slot 2:"; font.pixelSize: 12; color: "#CCC"; width: 50; verticalAlignment: Text.AlignVCenter }
                            ComboBox {
                                width: 190
                                model: DatasourceService.allSources
                                textRole: "titlename"
                                font.pixelSize: 12
                                Component.onCompleted: {
                                    for (var i = 0; i < model.count; ++i)
                                        if (DatasourceService.allSources.get(i).sourcename === root.infoSlot2Source)
                                            currentIndex = i;
                                }
                                onCurrentIndexChanged: {
                                    if (currentIndex >= 0) {
                                        root.infoSlot2Source = DatasourceService.allSources.get(currentIndex).sourcename;
                                        root.infoSlot2Value = Qt.binding(function() { return PropertyRouter.getValue(root.infoSlot2Source); });
                                    }
                                }
                            }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Label 2:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.infoSlot2Label; font.pixelSize: 12; onTextChanged: root.infoSlot2Label = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Track:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.trackName; font.pixelSize: 12; onTextChanged: root.trackName = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "GPS Text:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.gpsText; font.pixelSize: 12; onTextChanged: root.gpsText = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "System:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.systemStatusText; font.pixelSize: 12; onTextChanged: root.systemStatusText = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Clock:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.clockLabel; font.pixelSize: 12; onTextChanged: root.clockLabel = text }
                        }

                        Text { text: "Colors"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF"; topPadding: 8 }
                        Row {
                            spacing: 4
                            Text { text: "Text:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.textColor; font.pixelSize: 12; onEditingFinished: root.textColor = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Background:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.bgColor; font.pixelSize: 12; onEditingFinished: root.bgColor = text }
                        }

                        Text { text: "Display"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF"; topPadding: 8 }
                        Switch {
                            text: "Show Date/Time"
                            checked: root.dateTimeVisible
                            onCheckedChanged: root.dateTimeVisible = checked
                        }
                        Switch { text: "Show system row"; checked: root.showSystemRow; onCheckedChanged: root.showSystemRow = checked }
                        Switch { text: "Show ECU row"; checked: root.showEcuRow; onCheckedChanged: root.showEcuRow = checked }
                        Switch { text: "Show GPS"; checked: root.showGpsLine; onCheckedChanged: root.showGpsLine = checked }
                        Switch { text: "Show slot 1"; checked: root.showInfoSlot1; onCheckedChanged: root.showInfoSlot1 = checked }
                        Switch { text: "Show slot 2"; checked: root.showInfoSlot2; onCheckedChanged: root.showInfoSlot2 = checked }
                        Switch { text: "Show clock"; checked: root.showClockBlock; onCheckedChanged: root.showClockBlock = checked }
                        Switch { text: "Show progress"; checked: root.showProgressBar; onCheckedChanged: root.showProgressBar = checked }
                        Switch { text: "Show track name"; checked: root.showTrackName; onCheckedChanged: root.showTrackName = checked }
                    }
                }
            }
        ]
    }
}
