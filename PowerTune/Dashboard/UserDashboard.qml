import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.0
import Qt.labs.settings 1.0
import PowerTune.Gauges.Widgets 1.0
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: mainwindow
    property int dashIndex: 0
    anchors.fill: parent
    property string datastore: ""
    property string saveDashtofilestring: ""
    property string backroundpicturesource: ""
    property int touchCounter: 0
    property real lastTouchTime: 0

    Drag.active: true

    MyTextLabel {
        x: 10
        y: 10
        z: 300
    }

    ListModel {
        id: gaugelist
    }

    Rectangle {
        id: mainbackroundcolor
        anchors.fill: parent
    }

    Image {
        id: backroundpicture
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        z: 0
        onSourceChanged: {
            if (source.toString().endsWith("None") || source.toString() === "")
                source = "";
        }
    }

    ComboBox {
        id: dashvalue
        width: mainwindow.width * 0.25
        model: UI.dashSetup(dashIndex)
        visible: false
        font.pixelSize: mainwindow.width * 0.018
        delegate: ItemDelegate {
            width: dashvalue.width
            text: dashvalue.textRole ? (Array.isArray(dashvalue.model) ? modelData[dashvalue.textRole] : model[dashvalue.textRole]) : modelData
            font.weight: dashvalue.currentIndex === index ? Font.DemiBold : Font.Normal
            font.family: dashvalue.font.family
            font.pixelSize: dashvalue.font.pixelSize
            highlighted: dashvalue.highlightedIndex === index
            hoverEnabled: dashvalue.hoverEnabled
        }
    }

    Component.onCompleted: {
        if (datastore) {
            gaugelist.clear();
            try {
                var datamodel = JSON.parse(datastore);
                for (var i = 0; i < datamodel.length; ++i)
                    gaugelist.append(datamodel[i]);
            } catch (e) {
                console.warn("UserDashboard: Ignoring invalid stored dash JSON:", e);
            }
        }
        createDash();
        bgPanel.syncBackgroundColor(mainbackroundcolor.color);
    }

    Settings {
        category: "UserDashboard_" + dashIndex
        property alias datastore: mainwindow.datastore
        property alias rpmbackround: bgPanel.rpmStyleIndex
        property alias extraLoader: bgPanel.extraIndex
        property alias savebackroundpicture: backroundpicture.source
        property alias savemainbackroundcolor: mainbackroundcolor.color
    }

    Connections {
        target: UI
        function onBackroundpicturesChanged() {
            bgPanel.updatePicList(backroundpicture.source);
        }
        function onDashSetupChanged(index) {
            if (index !== dashIndex)
                return;
            dashvalue.model = UI.dashSetup(dashIndex);
            if (dashvalue.textAt(1) !== "") {
                var csvLine = "";
                for (var k = 0; k < dashvalue.count; k++) {
                    if (k > 0)
                        csvLine += ",";
                    csvLine += dashvalue.textAt(k);
                }
                GaugeFactory.deserializeCSVLine(csvLine, userDash);
            }
        }
    }

    Loader {
        id: rpmbarloader
        anchors.fill: parent
        source: ""
    }

    Rectangle {
        anchors.fill: parent
        z: 300
        color: "transparent"
        WarningLoader {}
    }

    Loader {
        id: extraLoader
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: parent.height / 2.2
        width: parent.width / 2.7
    }

    MouseArea {
        id: touchArea
        anchors.fill: parent
        z: -1
        enabled: UI.draggable === 0
        onPressed: function (mouse) {
            touchCounter++;
            if (touchCounter == 1) {
                lastTouchTime = Date.now();
                timerDoubleClick.restart();
            } else if (touchCounter == 2) {
                var currentTime = Date.now();
                if (currentTime - lastTouchTime <= 500) {
                    console.log("Dashboard double-tap detected at", mouse.x, mouse.y);
                }
                touchCounter = 0;
                timerDoubleClick.stop();
                gaugeCreationMenu.visible = true;
                UI.draggable = 1;
            }
        }
    }

    Timer {
        id: timerDoubleClick
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            touchCounter = 0;
        }
    }

    Item {
        id: userDash
        anchors.fill: parent
    }

    BackgroundSettingsPanel {
        id: bgPanel
        dashWindow: mainwindow
        onRpmSourceChanged: function (source) {
            rpmbarloader.source = source;
        }
        onBackgroundImageChanged: function (path) {
            backroundpicturesource = path;
            backroundpicture.source = path;
        }
        onBackgroundColorChanged: function (c) {
            mainbackroundcolor.color = c;
        }
        onExtraChanged: function (index) {
            extraLoader.source = "";
        }
    }

    GaugeCreationMenu {
        id: gaugeCreationMenu
        gaugeParent: userDash
        dashWindow: mainwindow
        dashIndex: mainwindow.dashIndex
        onMenuClosed: {
            UI.draggable = 0;
        }
        onSaveRequested: {
            savedash();
        }
        onExportCSVRequested: {
            savedash();
            saveDashtofile();
            Connect.saveDashtoFile("Dash" + (dashIndex + 1) + "Export", saveDashtofilestring);
        }
        onExportJSONRequested: {
            savedash();
            var jsonStr = GaugeFactory.serializeDashboardToJSON(userDash);
            Connect.saveDashtoFile("Dash" + (dashIndex + 1) + "Export.json", jsonStr);
        }
        onImportFileRequested: function (filename) {
            Connect.setDashFilename(dashIndex, filename);
            Connect.readDashSetup(dashIndex);
        }
        onBackgroundSettingsRequested: {
            bgPanel.visible = true;
            Connect.readavailablebackrounds();
        }
        onColorSettingsRequested: {
            colorPanel.visible = true;
        }
        onClearRequested: {
            for (var i = 0; i < userDash.children.length; ++i) {
                userDash.children[i].destroy();
            }
            UI.draggable = 0;
        }
    }

    ColorSelectionPanel {
        id: colorPanel
        gaugeParent: userDash
        dashWindow: mainwindow
    }

    function saveDashtofile() {
        saveDashtofilestring = "";
        for (var i = 0; i < userDash.children.length; ++i) {
            if (userDash.children[i].information) {
                saveDashtofilestring += GaugeFactory.serializeGaugeForCSV(userDash.children[i]) + "\r\n";
            }
        }
    }

    function createDash() {
        for (var i = 0; i < gaugelist.rowCount(); ++i) {
            var item = gaugelist.get(i);
            GaugeFactory.deserializeGauge(item, userDash);
        }
    }

    function savedash() {
        gaugelist.clear();
        for (var i = 0; i < userDash.children.length; ++i) {
            if (userDash.children[i].information) {
                var data = GaugeFactory.serializeGauge(userDash.children[i]);
                if (data)
                    gaugelist.append(data);
            }
        }
        var datamodel = [];
        for (var j = 0; j < gaugelist.count; ++j)
            datamodel.push(gaugelist.get(j));
        datastore = JSON.stringify(datamodel);
    }
}
