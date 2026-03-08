import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0

Item {
    id: mainwindow
    anchors.fill: parent

    property int dashIndex: 0
    property string backroundpicturesource: ""

    Component.onCompleted: {
        var config = AppSettings.loadDashboardConfig(dashIndex)
        mainbackroundcolor.color = config.backgroundColor
        backroundpicture.source = config.backgroundPicture
    }

    Rectangle {
        id: mainbackroundcolor
        anchors.fill: parent
        color: "#000000"
        onColorChanged: AppSettings.writeDashboardConfig(dashIndex, backroundpicture.source.toString(), color.toString())
    }

    Image {
        id: backroundpicture
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        z: 0
        onSourceChanged: {
            if (source.toString().endsWith("None") || source.toString() === "")
                source = "";
            AppSettings.writeDashboardConfig(dashIndex, source.toString(), mainbackroundcolor.color.toString())
        }
    }

    Item {
        id: gaugeContainer
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent
        z: 300
        color: "transparent"
        WarningLoader {}
    }

    MouseArea {
        id: touchArea
        anchors.fill: parent
        z: -1
        property int _tapCount: 0
        property real _lastTapTime: 0

        onPressed: function(mouse) {
            _tapCount++;
            if (_tapCount === 1) {
                _lastTapTime = Date.now();
                doubleTapTimer.restart();
            } else if (_tapCount >= 2) {
                doubleTapTimer.stop();
                _tapCount = 0;
                if (Date.now() - _lastTapTime <= 500)
                    console.log("Dashboard double-tap at", mouse.x, mouse.y, "- gauge menu placeholder");
            }
        }

        Timer {
            id: doubleTapTimer
            interval: 500
            onTriggered: touchArea._tapCount = 0
        }
    }
}
