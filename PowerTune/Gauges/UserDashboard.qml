import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.0
import QtQml.Models 2.3
import Qt.labs.settings 1.0
import QtQuick.Dialogs
import "../Gauges"
import PowerTune.Gauges 1.0
import PowerTune.Utils 1.0

Item {
    id: mainwindow
    property int dashIndex: 0
    anchors.fill: parent
    property string datastore: ""
    property string saveDashtofilestring : ""
    property string gaugeType : ""
    property string backroundpicturesource : ""
    property bool val1: false
    property bool val2: false
    property bool val3: false
    property double val4 : 20000
    property int val5 : -20000
    property string val6 : "transparent"
    property string val7 : "transparent"
    property string val8 : "transparent"
    property string val9 : "transparent"
    property string val10 : "transparent"
    property string val11 : "transparent"
    property int val12
    property int val13
    property string val14 : "Square Gauge"
    property int parser
    property int touchCounter: 0
    property real lastTouchTime: 0

    Drag.active: true
    MyTextLabel{x:10
        y:10
        z:300}
    ListModel {
        id: gaugelist
    }
    Rectangle{
        id: mainbackroundcolor
        anchors.fill: parent

    }
    Image {
        id:backroundpicture
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        z: 0
    }

    ComboBox{
        id: dashvalue
        width: mainwindow.width * 0.25//200
        model: UI.dashSetup(dashIndex)
        visible:false
        font.pixelSize: mainwindow.width * 0.018//15
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
            gaugelist.clear()
            var datamodel = JSON.parse(datastore)
            for (var i = 0; i < datamodel.length; ++i) gaugelist.append(datamodel[i])
        }
        createDash()
    }

    Settings {
        category: "UserDashboard_" + dashIndex
        property alias datastore: mainwindow.datastore
        property alias rpmbackround: rpmstyleselector.currentIndex
        property alias extraLoader: extraSelector.currentIndex
        property alias savebackroundpicture: backroundpicture.source
        property alias savemainbackroundcolor: mainbackroundcolor.color

    }

    ////////Readout Gauge Elements from file and create dynamically ( only needed for importing a dash)
    Connections{
        target: UI

        function onBackroundpicturesChanged() { updatppiclist(); }
        function onDashSetupChanged(index)
        {
            if (index !== dashIndex) return;
            dashvalue.model = UI.dashSetup(dashIndex);
            if (dashvalue.textAt(1) !== "") {
                var csvLine = "";
                for (var k = 0; k < dashvalue.count; k++) {
                    if (k > 0) csvLine += ",";
                    csvLine += dashvalue.textAt(k);
                }
                GaugeFactory.deserializeCSVLine(csvLine, userDash);
            }
        }

    }

    Loader{
        id: rpmbarloader
        anchors.fill:parent
        source: ""
    }



    Item{
        id: rpmgauge
        function selector()
        {
            switch (rpmstyleselector.currentIndex) {

            case 0:
            {
                rpmbarloader.source = ""
                break;
            }
            case 1:
            {
                rpmbarloader.source = "qrc:/qt/qml/PowerTune/Gauges/PowerTune/Gauges/RPMBarStyle1.qml"
                break;
            }
            case 2:
            {
                rpmbarloader.source = "qrc:/qt/qml/PowerTune/Gauges/PowerTune/Gauges/RPMBarStyle2.qml"
                break;
            }
            case 3:
            {
                rpmbarloader.source = "qrc:/qt/qml/PowerTune/Gauges/PowerTune/Gauges/RPMBarStyle3.qml"
                break;
            }
            case 4:
            {
                rpmbarloader.source = "qrc:/qt/qml/PowerTune/Gauges/PowerTune/Gauges/RPMBar.qml"
                break;
            }
            }
        }
    }

    function updatppiclist()
    {
                    for(var i = 0; i < backroundSelector.count; ++i)
                        if (backroundpicture.source == "file:"  + backroundSelector.textAt(i))


                    backroundSelector.currentIndex = i
    }


    Rectangle{
        anchors.fill: parent
        z:300 //This makes the Rectangle appear in front of the bar gauges
        color: "transparent"
        WarningLoader{}
    }

    Loader{
        id: extraLoader
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        height: parent.height /2.2
        width: parent.width /2.7
    }


    // From Here we do all the Magic stuff for the dynamic creation of the Gauges


    MouseArea {
        id: touchArea
        anchors.fill: parent
        z: -1  // * Lower z-order so gauges receive events first when in edit mode
        // * Only active when NOT in edit mode - when draggable=1, gauges handle their own events
        enabled: UI.draggable === 0
        onPressed: function(mouse) {
            touchCounter++;
            if (touchCounter == 1) {
                lastTouchTime = Date.now();
                timerDoubleClick.restart();
            } else if (touchCounter == 2) {
                var currentTime = Date.now();
                if (currentTime - lastTouchTime <= 500) { // Double-tap detected within 500 ms
                    console.log("Dashboard double-tap detected at", mouse.x, mouse.y);
                }
                touchCounter = 0;
                timerDoubleClick.stop();
                btnbackround.visible = true;
                savetofile.visible = true;
                squaregaugemenu.visible =true;
                btnopencolorselect.visible = true;
                cbx_sources.visible = true;
                btnaddSquare.visible = true;
                btncancel.visible = true;
                btnsave.visible = true;
                btnclear.visible = true;
                loadfromfile.visible = true;
                squaregaugemenu.visible = true;
                btnaddRound.visible = true;
                btnaddText.visible = true;
                btnaddPicture.visible = true;
                btnaddStatePicture.visible = true;
                btnaddStateGIF.visible = true;
                btnaddBar.visible = true;
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
            touchCounter = 0; // Reset counter if time interval exceeds 500 ms
        }
    }




    /// RPM STYLE SELECTOR and Backround picture loader
    Rectangle{
        id: rpmbackroundselector
        width: mainwindow.width * 0.25 //200
        height: mainwindow.height * 0.625 //300
        color : "darkgrey"
        x: 0
        y: 0
        z:200
        visible: false
        MouseArea {
            id: touchArearpmbackroundselector
            anchors.fill:parent
            drag.target: rpmbackroundselector
        }
        Grid{
            rows:10
            columns: 1
            rowSpacing :5

            Text {
                text: Translator.translate("RPM2", Settings.language)+ " " +Translator.translate("Style", Settings.language)
                font.pixelSize: mainwindow.width * 0.025 //20
                font.bold: true
            }
            ComboBox {
                id: rpmstyleselector
                width: mainwindow.width * 0.25 //200
                height: mainwindow.height * 0.083 //40
                font.pixelSize: mainwindow.width * 0.018 //15
                model: [Translator.translate("None", Settings.language), Translator.translate("Style", Settings.language) + " 1",Translator.translate("Style", Settings.language) + " 2", Translator.translate("Style", Settings.language) + " 3", Translator.translate("Style", Settings.language) + " 4"]
                onCurrentIndexChanged: rpmgauge.selector();
                delegate: ItemDelegate {
                    width: rpmstyleselector.width
                    text: rpmstyleselector.textRole ? (Array.isArray(rpmstyleselector.model) ? modelData[rpmstyleselector.textRole] : model[rpmstyleselector.textRole]) : modelData
                    font.weight: rpmstyleselector.currentIndex === index ? Font.DemiBold : Font.Normal
                    font.family: rpmstyleselector.font.family
                    font.pixelSize: rpmstyleselector.font.pixelSize
                    highlighted: rpmstyleselector.highlightedIndex === index
                    hoverEnabled: rpmstyleselector.hoverEnabled
                }
            }
            Text {
                text: Translator.translate("Background", Settings.language) + " " + Translator.translate("Image", Settings.language)
                font.pixelSize: mainwindow.width * 0.025 //20
                font.bold: true
            }
            ComboBox {
                id: backroundSelector
                width: mainwindow.width * 0.25 //200
                height: mainwindow.height * 0.083 //40
                font.pixelSize: mainwindow.width * 0.015
                model: UI.backroundpictures
                currentIndex: 0
                onCurrentIndexChanged: {
                    // * Use platform-aware path for background images
                    var selectedFile = backroundSelector.textAt(backroundSelector.currentIndex);
                    if (Qt.platform.os === "linux") {
                        backroundpicturesource = "file:///home/pi/Logo/" + selectedFile;
                    } else if (Qt.platform.os === "osx") {
                        // * On macOS, use bundled resources if available
                        backroundpicturesource = "qrc:/Resources/graphics/" + selectedFile;
                    } else if (Qt.platform.os === "windows") {
                        backroundpicturesource = "file:///c:/Logo/" + selectedFile;
                    } else {
                        backroundpicturesource = "file:" + selectedFile;
                    }
                    backroundpicture.source = backroundpicturesource;
                }
                delegate: ItemDelegate {
                    width: backroundSelector.width
                    text: backroundSelector.textRole ? (Array.isArray(backroundSelector.model) ? modelData[backroundSelector.textRole] : model[backroundSelector.textRole]) : modelData
                    font.weight: backroundSelector.currentIndex === index ? Font.DemiBold : Font.Normal
                    font.family: backroundSelector.font.family
                    font.pixelSize: backroundSelector.font.pixelSize
                    highlighted: backroundSelector.highlightedIndex === index
                    hoverEnabled: backroundSelector.hoverEnabled
                }
            }
            Text {
                text: Translator.translate("Background", Settings.language) + " " + Translator.translate("Color", Settings.language)
                font.pixelSize: mainwindow.width * 0.025
                font.bold: true
            }
            ComboBox {
                id: mainbackroundcolorselect
                width: mainwindow.width * 0.25 //200
                height: mainwindow.height * 0.083 //40
                model: ColorList{}
                visible: true
                font.pixelSize: mainwindow.width * 0.018//15


                delegate:

                    ItemDelegate {
                    id:itemDelegate
                    width: mainbackroundcolorselect.width
                    height: mainbackroundcolorselect.height
                    font.pixelSize: mainwindow.width * 0.018//15
                    Rectangle {
                        id: backroundcolorcbxcolor
                        width: mainbackroundcolorselect.width
                        height: mainbackroundcolorselect.height //50
                        color:  itemColor

                        Text {

                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: mainwindow.width * 0.018//15
                        }
                    }
                }
                Component.onCompleted: {
                    for(var i = 1; i < mainbackroundcolorselect.model.count; ++i)
                   if (Qt.colorEqual(mainbackroundcolor.color,mainbackroundcolorselect.textAt(i)))
                    mainbackroundcolorselect.currentIndex = i
                }
                 onCurrentIndexChanged:  mainbackroundcolor.color = mainbackroundcolorselect.textAt(mainbackroundcolorselect.currentIndex)

            }
            Text {
                text: "Extra "//Translator.translate("Extra: ", Dashboard.language)
                font.pixelSize: mainwindow.width * 0.018
                font.bold: true
            }
            ComboBox {
                id: extraSelector
                width: mainwindow.width * 0.25 //200
                height: mainwindow.height * 0.083 //40
                font.pixelSize: mainwindow.width * 0.018//15
                model: [Translator.translate(Translator.translate("None", Settings.language), Settings.language), "PFC Sensors"]
                onCurrentIndexChanged: setextra();
                delegate: ItemDelegate {
                    width: extraSelector.width
                    text: extraSelector.textRole ? (Array.isArray(extraSelector.model) ? modelData[extraSelector.textRole] : model[extraSelector.textRole]) : modelData
                    font.weight: extraSelector.currentIndex === index ? Font.DemiBold : Font.Normal
                    font.family: extraSelector.font.family
                    font.pixelSize: extraSelector.font.pixelSize
                    highlighted: extraSelector.highlightedIndex === index
                    hoverEnabled: extraSelector.hoverEnabled
                }
            }
            Button {
                id: btncloserpm
                text: Translator.translate("Close", Settings.language)
                font.pixelSize: mainwindow.width * 0.018//15
                width: mainwindow.width * 0.25 //200
                height: mainwindow.height * 0.083 //40
                onClicked:{rpmbackroundselector.visible =false;}
            }
        }
    }
    /// The Gauge Creation Menu
    Rectangle{
        id: squaregaugemenu
        width: mainwindow.width * 0.24 //200
        height: mainwindow.height * 0.83 //400
        color : "darkgrey"
        x :590
        y: 0
        z:200
        visible: false
        MouseArea {
            id: touchAreasquaregaugemenu
            anchors.fill:parent
            drag.target: squaregaugemenu
        }
///////////////////
        /*
        //Combobox filtered by ECU. Datasources must still be filled with each supported ECU
        ComboBox {
            id: cbx_sources
            width: 200
            model: filteredModel // Use the filtered model as the model for the ComboBox
            textRole: "titlename" // Set the role for display text
            onActivated: {
                console.log("Selected:", cbx_sources.currentText);
            }

            // Filter the model based on the condition
            Component.onCompleted: {
                DatasourceService.allSources.append({supportedECUs: "Microtech"}); // Add a dummy element to trigger filtering
                DatasourceService.allSources.remove(DatasourceService.allSources.count - 1); // Remove the dummy element
            }

            // Filter and sort the model alphabetically
            property ListModel filteredModel: {
                var filteredModel = Qt.createQmlObject('import QtQuick 2.15; ListModel {}', cbx_sources);
                // Add a Dynamic Filter via Dashboard String
                var filterValues = ["Microtech"];

                // Create an array to store the filtered elements
                var filteredElements = [];

                for (var i = 0; i < DatasourceService.allSources.count; ++i) {
                    var element = DatasourceService.allSources.get(i);
                    if (element.supportedECUs !== undefined && element.supportedECUs !== null) {
                        // Remove trailing commas and split the string into an array
                        var ecuList = element.supportedECUs.replace(/,+$/, '').split(',');

                        for (var j = 0; j < filterValues.length; ++j) {
                            if (ecuList.indexOf(filterValues[j]) !== -1) {
                                filteredElements.push({"titlename": element.titlename});
                                break; // Break out of the inner loop if a match is found
                            }
                        }
                    }
                }

                // Sort the filtered elements alphabetically
                filteredElements.sort(function(a, b) {
                    return a.titlename.localeCompare(b.titlename);
                });

                // Add the sorted elements to the filtered model
                for (var k = 0; k < filteredElements.length; ++k) {
                    filteredModel.append(filteredElements[k]);
                }

                return filteredModel;
            }
        }
        */
        ComboBox {
            id: cbx_sources
            font.pixelSize: 14
            textRole: "titlename"
            width: parent.width
            height: parent.height * 0.083
            model: DatasourceService.allSources
            delegate: ItemDelegate {
                width: cbx_sources.width
                text: cbx_sources.textRole ? (Array.isArray(cbx_sources.model) ? modelData[cbx_sources.textRole] : model[cbx_sources.textRole]) : modelData
                font.weight: cbx_sources.currentIndex === index ? Font.DemiBold : Font.Normal
                font.family: cbx_sources.font.family
                font.pixelSize: cbx_sources.font.pixelSize
                highlighted: cbx_sources.highlightedIndex === index
                hoverEnabled: cbx_sources.hoverEnabled
            }
            Component.onCompleted: {
                if(mainwindow.width == 1600){
                    cbx_sources.font.pixelSize == 18;
                }
            }
        }


        ComboBox {
            id: loadfileselect
            font.pixelSize: mainwindow.width * 0.018//15
            model: UI.dashfiles
            width: parent.width
            height: parent.height * 0.083
            visible: false
            delegate: ItemDelegate {
                width: loadfileselect.width
                text: loadfileselect.textRole ? (Array.isArray(loadfileselect.model) ? modelData[loadfileselect.textRole] : model[loadfileselect.textRole]) : modelData
                font.weight: loadfileselect.currentIndex === index ? Font.DemiBold : Font.Normal
                font.family: loadfileselect.font.family
                font.pixelSize: loadfileselect.font.pixelSize
                highlighted: loadfileselect.highlightedIndex === index
                hoverEnabled: loadfileselect.hoverEnabled
            }
        }

        Grid{
            rows:7
            columns: 2
            x:0
            y:45
            //anchors.bottom: loadfileselect
            topPadding: 8
            width: parent.width
            height: parent.height
            layoutDirection: "RightToLeft"
            rowSpacing: 3
            //Calculate the total pixels of the parent item and divide it by (6/1280) which is 6 pixel spacing / total screen pixels of 7"
            spacing: (parent.width + parent.height) * 0.005

            Button {
                id: btnaddSquare
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text:  Translator.translate("Square", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                onClicked: {
                    var ds = DatasourceService.allSources.get(cbx_sources.currentIndex);
                    GaugeFactory.createGauge("Square gauge", userDash, {
                        "width": 266, "height": 119, "x": 0, "y": 240,
                        "maxvalue": 248, "decimalpoints": ds.decimalpoints,
                        "mainunit": ds.defaultsymbol, "title": ds.titlename,
                        "vertgaugevisible": false, "horigaugevisible": true,
                        "secvaluevisible": false, "mainvaluename": ds.sourcename,
                        "secvaluename": ds.sourcename, "warnvaluehigh": 10000,
                        "warnvaluelow": -20000, "framecolor": "lightsteelblue",
                        "resetbackroundcolor": "black", "resettitlecolor": "lightsteelblue",
                        "titletextcolor": "white", "textcolor": "white",
                        "barcolor": "blue", "titlefontsize": 25, "mainfontsize": 40,
                        "decimalpoints2": ds.decimalpoints2,
                        "textFonttype": "Lato", "valueFonttype": "Lato"
                    });
                    squaregaugemenu.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;
                }
            }
            Button {
                id: btnaddBar
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                //anchors.right: parent
                text: Translator.translate("Bar", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                onClicked: {
                    var dsBar = DatasourceService.allSources.get(cbx_sources.currentIndex);
                    GaugeFactory.createGauge("Bar gauge", userDash, {
                        "width": 320, "height": 80, "x": 10, "y": 0,
                        "minvalue": 0, "maxvalue": 8000,
                        "decimalpoints": dsBar.decimalpoints,
                        "gaugename": dsBar.titlename,
                        "mainvaluename": dsBar.sourcename,
                        "warnvaluehigh": 1000, "warnvaluelow": 0
                    });
                    squaregaugemenu.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;
                }
            }
            Button {
                id: btnaddRound
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Round", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                onClicked: {
                    var dsRound = DatasourceService.allSources.get(cbx_sources.currentIndex);
                    GaugeFactory.createGauge("Round gauge", userDash, {
                        "width": 400, "height": 400, "x": 20, "y": 20,
                        "mainvaluename": dsRound.sourcename,
                        "maxvalue": dsRound.maxvalue, "minvalue": 0,
                        "warnvaluehigh": dsRound.maxvalue, "warnvaluelow": -1000,
                        "startangle": -145, "endangle": 90,
                        "redareastart": dsRound.maxvalue,
                        "divider": dsRound.divisor,
                        "tickmarksteps": dsRound.stepsize,
                        "minortickmarksteps": 1,
                        "setlabelsteps": dsRound.stepsize,
                        "decimalpoints": dsRound.decimalpoints,
                        "needleinset": 2, "setlabelinset": 38,
                        "setminortickmarkinset": 3, "setmajortickmarkinset": 3,
                        "minortickmarkheight": 8, "minortickmarkwidth": 3,
                        "tickmarkheight": 15, "tickmarkwidth": 5,
                        "trailhighboarder": 0.50, "trailmidboarder": 0.40,
                        "traillowboarder": 0.33, "trailbottomboarder": 0.25,
                        "labelfontsize": 20, "needleTipWidth": 5,
                        "needleLength": 93, "needleBaseWidth": 8,
                        "redareainset": 0, "redareawidth": 0,
                        "needlecolor": "red", "needlecolor2": "darkred",
                        "backroundcolor": "aliceblue", "warningcolor": "red",
                        "minortickmarkcoloractive": "grey",
                        "minortickmarkcolorinactive": "darkgrey",
                        "majortickmarkcoloractive": "darkgrey",
                        "majortickmarkcolorinactive": "black",
                        "labelcoloractive": "grey", "labelcolorinactive": "black",
                        "outerneedlecolortrailsave": "dodgerblue",
                        "middleneedlecortrailsave": "deepskyblue",
                        "lowerneedlecolortrailsave": "lightskyblue",
                        "innerneedlecolortrailsave": "transparent",
                        "outerneedlecolortrail": "dodgerblue",
                        "middleneedlecortrail": "deepskyblue",
                        "lowerneedlecolortrail": "lightskyblue",
                        "innerneedlecolortrail": "transparent",
                        "needlevisible": true, "ringvisible": true,
                        "needlecentervisisble": true, "labelfont": "Lato",
                        "desctextx": 30, "desctexty": 50,
                        "desctextfontsize": 10, "desctextfontbold": false,
                        "desctextfonttype": "Lato",
                        "desctextdisplaytext": dsRound.titlename,
                        "desctextdisplaytextcolor": "red"
                    });
                    squaregaugemenu.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;
                }
            }
            Button {
                id: btnaddText
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Text", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                onClicked: {
                    GaugeFactory.createGauge("Text label gauge", userDash, {
                        "x": 100, "y": 50, "displaytext": "Textelement",
                        "fonttype": "Lato", "fontsize": 15, "textcolor": "red",
                        "resettextcolor": "red", "datasourcename": "",
                        "fontbold": true, "decimalpoints": 0,
                        "warnvaluehigh": 20000, "warnvaluelow": -20000
                    })
                    squaregaugemenu.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;
                }
            }
            Button {
                id: btnaddPicture
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Image", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                onClicked: {
                    GaugeFactory.createGauge("gauge image", userDash, {
                        "x": 10, "y": 10, "pictureheight": 100,
                        "picturesource": "qrc:/Resources/graphics/slectImage.png"
                    })
                    squaregaugemenu.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;
                }
            }
            Button {
                id: btnaddStatePicture
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("State", Settings.language) + " " + Translator.translate("Image", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                onClicked: {
                   // console.log("create State gauge ");
                    GaugeFactory.createGauge("State gauge", userDash, {
                        "x": 10, "y": 10, "pictureheight": 100,
                        "mainvaluename": "speed", "triggervalue": 1,
                        "statepicturesourceoff": "qrc:/Resources/graphics/selectStateImage.png",
                        "statepicturesourceon": "qrc:/Resources/graphics/selectStateImage.png"
                    });
                    squaregaugemenu.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;
                }
            }
            Button {
                id: btnaddStateGIF
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("State", Settings.language) + " " + Translator.translate("GIF", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                onClicked: {
                   // console.log("create State gauge ");
                    GaugeFactory.createGauge("State GIF", userDash, {
                        "x": 10, "y": 10, "pictureheight": 100,
                        "mainvaluename": "speed", "triggervalue": 1,
                        "statepicturesourceoff": "qrc:/Resources/graphics/StateGIF.gif",
                        "statepicturesourceon": "qrc:/Resources/graphics/StateGIF.gif",
                        "triggeroffvalue": 0
                    });
                    squaregaugemenu.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;
                }
            }


            Button {
                id: btnopencolorselect
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Colors", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                onClicked: {
                    selectcolor.visible =true;
                    squaregaugemenu.visible = false;
                    UI.draggable = 0;
                }
            }
            Button {
                id: btnclear
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Clear", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                onClicked:  {

                    selectcolor.visible =false;
                    squaregaugemenu.visible = false;
                    UI.draggable = 0;
                    for (var i=0; i<userDash.children.length; ++i)
                    {
                        userDash.children[i].destroy()
                    }
                }
            }

            Button{
                id: loadfromfile
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Import", Settings.language)
                font.pixelSize: mainwindow.width * 0.015

                onClicked: {
                    Connect.readavailabledashfiles();
                    btnaddRound.visible = false;
                    btnaddText.visible = false;
                    btnaddPicture.visible = false;
                    btnaddStatePicture.visible = false;
                    btnaddStateGIF.visible = false;
                    btnaddBar.visible = false;
                    btncancelload.visible = true;
                    loadfromfile.visible = false;
                    loadfileselect.visible = true;
                    btnaddSquare.visible = false;
                    btncancel.visible = false;
                    cbx_sources.visible = false;
                    btnsave.visible = false;
                    btnclear.visible = false;
                    selectcolor.visible = false;
                    savetofile.visible = false;
                    btnopencolorselect.visible = false;
                    loadfromfile.visible = false;
                    load.visible = true;
                    selectcolor.visible =false;
                    btnbackround.visible =false;
                    savedash();
                }
            }
            Button{
                id: savetofile
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Export", Settings.language) + " CSV"
                font.pixelSize: mainwindow.width * 0.015

                onClicked: {
                    squaregaugemenu.visible = false;
                    UI.draggable = 0;
                    btnaddRound.visible = false;
                    btnaddText.visible = false;
                    btnaddPicture.visible = false;
                    btnaddStatePicture.visible = false;
                    btnaddStateGIF.visible = false;
                    selectcolor.visible =false;
                    savedash();
                    saveDashtofile();
                    Connect.saveDashtoFile("Dash" + (dashIndex + 1) + "Export",saveDashtofilestring);
                }
            }
            Button{
                id: savetofileJSON
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Export", Settings.language) + " JSON"
                font.pixelSize: mainwindow.width * 0.015

                onClicked: {
                    squaregaugemenu.visible = false;
                    UI.draggable = 0;
                    btnaddRound.visible = false;
                    btnaddText.visible = false;
                    btnaddPicture.visible = false;
                    btnaddStatePicture.visible = false;
                    btnaddStateGIF.visible = false;
                    selectcolor.visible = false;
                    savedash();
                    var jsonStr = GaugeFactory.serializeDashboardToJSON(userDash);
                    Connect.saveDashtoFile("Dash" + (dashIndex + 1) + "Export.json", jsonStr);
                }
            }
            Button{
                id: btncancelload
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Cancel", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                visible: false
                onClicked: {
                    loadfileselect.visible = false;
                    btncancelload.visible = false;
                    squaregaugemenu.visible = false;
                    load.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;

                }
            }
            Button{
                id: load
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Load", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                visible: false
                onClicked: {
                    loadfileselect.visible = false;
                    Connect.setDashFilename(dashIndex, loadfileselect.textAt(loadfileselect.currentIndex));
                    btncancelload.visible = false;
                    squaregaugemenu.visible = false;
                    load.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;
                    Connect.readDashSetup(dashIndex);
                }
            }
            Button{
                id: btnbackround
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Background", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                onClicked: {
                    rpmbackroundselector.visible =true;
                    squaregaugemenu.visible = false;
                    btnbackround.visible =false;
                    UI.draggable = 0;
                    Connect.readavailablebackrounds();
                }
            }

            Button {
                id: btnsave
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Save", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                highlighted: true
                onClicked: {
                    squaregaugemenu.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;
                    savedash();
                }
            }

            Button {
                id: btncancel
                width: mainwindow.width * 0.118
                height: mainwindow.height * 0.083
                text: Translator.translate("Close", Settings.language)
                font.pixelSize: mainwindow.width * 0.015
                highlighted: true
                onClicked:  {
                    squaregaugemenu.visible = false;
                    selectcolor.visible =false;
                    UI.draggable = 0;
                }
            }
        }
    }
    //We put all Gauges here
    Item{
        id: userDash
        anchors.fill: parent
    }
    ///////////////////Functions
    function setextra()
    {
        switch (extraSelector.currentIndex){
        case 0:{
            extraLoader.source = "";
            break;
        }
        case 1:{
            extraLoader.setSource("qrc:/qt/qml/PowerTune/Gauges/PowerTune/Gauges/PFCSensors.qml",{ sizeoftext : mainwindow.width /54});
            break;
        }
        }
    }

    function saveDashtofile()
    {
        saveDashtofilestring = ""
        for (var i = 0; i < userDash.children.length; ++i) {
            if (userDash.children[i].information) {
                saveDashtofilestring += GaugeFactory.serializeGaugeForCSV(userDash.children[i]) + "\r\n";
            }
        }
    }
    function createDash()
    {
        for (var i = 0; i < gaugelist.rowCount(); ++i) {
            var item = gaugelist.get(i);
            GaugeFactory.deserializeGauge(item, userDash);
        }
    }

    function changeframeclolor()
    {
        for (var i=0; i<userDash.children.length; ++i)
        {
            if(userDash.children[i].information === "Square gauge")
            {
                userDash.children[i].framecolor = colorselect.textAt(colorselect.currentIndex)
                userDash.children[i].set()
            }
        }
    }
    function changetitlebarclolor()
    {
        for (var i=0; i<userDash.children.length; ++i)
        {
            if(userDash.children[i].information === "Square gauge")
            {
                userDash.children[i].resettitlecolor = colorselect.textAt(colorselecttitlebar.currentIndex)
                userDash.children[i].set()
            }
        }
    }

    function changebackroundcolor()
    {
        for (var i=0; i<userDash.children.length; ++i)
        {
            if(userDash.children[i].information === "Square gauge")
            {
                userDash.children[i].resetbackroundcolor = backroundcolor.textAt(backroundcolor.currentIndex)
                userDash.children[i].set()
            }
        }
    }
    function changebargaugecolor()
    {
        for (var i=0; i<userDash.children.length; ++i)
        {
            if(userDash.children[i].information === "Square gauge")
            {
                userDash.children[i].barcolor = bargaugecolor.textAt(bargaugecolor.currentIndex)
                userDash.children[i].set()
            }
        }
    }
    function changetitlecolor()
    {
        for (var i=0; i<userDash.children.length; ++i)
        {
            if(userDash.children[i].information === "Square gauge")
            {
                userDash.children[i].titletextcolor = titlecolor.textAt(titlecolor.currentIndex)
                userDash.children[i].set()
            }
        }
    }
    function changevaluetextcolor()
    {
        for (var i=0; i<userDash.children.length; ++i)
        {
            if(userDash.children[i].information === "Square gauge")
            {
                userDash.children[i].textcolor = valuetext.textAt(valuetext.currentIndex)
                userDash.children[i].set()
            }
        }
    }
    function savedash()
    {
        gaugelist.clear()
        for (var i = 0; i < userDash.children.length; ++i) {
            if (userDash.children[i].information) {
                var data = GaugeFactory.serializeGauge(userDash.children[i]);
                if (data)
                    gaugelist.append(data);
            }
        }
        var datamodel = []
        for (var j = 0; j < gaugelist.count; ++j) datamodel.push(gaugelist.get(j))
        datastore = JSON.stringify(datamodel)
    }
    //Color Selection panel
    Rectangle{
        id: selectcolor
        x:0
        y:0
        height : mainwindow.height * 0.41 //200
        width: mainwindow.width * 0.625 //500
        color: "darkgrey"
        visible: false

        MouseArea {
            id: touchAreacolorselect
            anchors.fill:parent
            drag.target: selectcolor
        }

        Grid{
            rows:5
            columns: 3
            anchors.centerIn: parent
            spacing:5
            // FrameColor
            Text {
                text: Translator.translate("Frame color", Settings.language)
                font.pixelSize: mainwindow.width * 0.018//15
            }
            Text {
                text: Translator.translate("Titlebar color", Settings.language)
                font.pixelSize: mainwindow.width * 0.018//15
            }
            Text {
                text: Translator.translate("Background color", Settings.language)
                font.pixelSize: mainwindow.width * 0.018//15
            }

            ComboBox {
                id: colorselect
                width: mainwindow.width * 0.1875 //150
                height: mainwindow.height * 0.083
                model: ColorList{}
                visible: true
                font.pixelSize: mainwindow.width * 0.018//15
                onCurrentIndexChanged: changeframeclolor()
                delegate:

                    ItemDelegate {
                    id:itemDelegate2
                    width: colorselect.width
                    height: colorselect.height
                    font.pixelSize: mainwindow.width * 0.018//15
                    Rectangle {
                        width: colorselect.width
                        height: colorselect.height //50
                        color:  itemColor
                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: mainwindow.width * 0.018//15
                        }
                    }
                }

                background:Rectangle{
                    width: colorselect.width
                    height: colorselect.height
                    color:  colorselect.currentText
                }
            }

            // Titlebarcolor
            ComboBox {
                id: colorselecttitlebar
                width: mainwindow.width * 0.1875 //150
                height: mainwindow.height * 0.083
                model: ColorList{}
                visible: true
                font.pixelSize: mainwindow.width * 0.018//15
                onCurrentIndexChanged: changetitlebarclolor()
                delegate:

                    ItemDelegate {
                    id:itemDelegate3
                    font.pixelSize: mainwindow.width * 0.018//15
                    width: colorselecttitlebar.width
                    height: colorselecttitlebar.height
                    Rectangle {
                        width: colorselecttitlebar.width
                        height: colorselecttitlebar.height //50
                        color:  itemColor

                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: mainwindow.width * 0.018//15
                        }
                    }
                }

                background:Rectangle{
                    width: colorselecttitlebar.width
                    height: colorselecttitlebar.height
                    color:  colorselecttitlebar.currentText
                }
            }
            // Backroundcolor
            ComboBox {

                id: backroundcolor
                width: mainwindow.width * 0.1875
                height: mainwindow.height * 0.083
                model: ColorList{}
                font.pixelSize: mainwindow.width * 0.018//15
                visible: true
                onCurrentIndexChanged: changebackroundcolor()
                delegate:
                    ItemDelegate {
                    width: backroundcolor.width
                    height: backroundcolor.height
                    font.pixelSize: mainwindow.width * 0.018//15
                    Rectangle {
                        width: backroundcolor.width
                        height: backroundcolor.height
                        color:  itemColor

                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: mainwindow.width * 0.018//15
                        }
                    }
                }

                background:Rectangle{
                    width: backroundcolor.width
                    height: backroundcolor.height
                    color:  backroundcolor.currentText
                }
            }
            Text {
                text: Translator.translate("Bargauge color", Settings.language)
                font.pixelSize: mainwindow.width * 0.018//15
            }
            Text {
                text: Translator.translate("Title text color", Settings.language)
                font.pixelSize: mainwindow.width * 0.018//15
            }
            Text {
                text: Translator.translate("Main text color", Settings.language)
                font.pixelSize: mainwindow.width * 0.018//15
            }
            // BargaugeColor
            ComboBox {
                id: bargaugecolor
                width: mainwindow.width * 0.1875
                height: mainwindow.height * 0.083
                model: ColorList{}
                font.pixelSize: mainwindow.width * 0.018//15
                visible: true
                onCurrentIndexChanged: changebargaugecolor()

                delegate:

                    ItemDelegate {
                    width: bargaugecolor.width
                    height: bargaugecolor.height
                    font.pixelSize: mainwindow.width * 0.018//15
                    Rectangle {

                        width: bargaugecolor.width
                        height: bargaugecolor.height
                        color:  itemColor

                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: mainwindow.width * 0.018//15
                        }
                    }
                }

                background:Rectangle{
                    width: bargaugecolor.width
                    height: bargaugecolor.height
                    color:  bargaugecolor.currentText
                }
            }

            //Title text

            ComboBox {

                id: titlecolor
                width: mainwindow.width * 0.1875
                height: mainwindow.height * 0.083
                model: ColorList{}
                visible: true
                font.pixelSize: mainwindow.width * 0.018//15
                onCurrentIndexChanged: changetitlecolor()

                delegate:

                    ItemDelegate {
                    width: titlecolor.width
                    height: titlecolor.height
                    font.pixelSize: mainwindow.width * 0.018//15
                    text: itemColor
                    Rectangle {

                        width: titlecolor.width
                        height: titlecolor.width
                        color:  itemColor

                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: mainwindow.width * 0.018//15
                        }
                    }
                }

                background:Rectangle{
                    width: titlecolor.width
                    height: titlecolor.height
                    color:  titlecolor.currentText
                }
            }

            //ValueText

            ComboBox {

                id: valuetext
                width: mainwindow.width * 0.1875
                height: mainwindow.height * 0.083
                model: ColorList{}
                visible: true
                font.pixelSize: mainwindow.width * 0.018//15
                onCurrentIndexChanged: changevaluetextcolor()

                delegate:

                    ItemDelegate {
                    width: valuetext.width
                    height: valuetext.height
                    font.pixelSize: mainwindow.width * 0.018//15
                    Rectangle {

                        width: valuetext.width
                        height: valuetext.height
                        color:  itemColor

                        Text {
                            text: itemColor
                            anchors.centerIn: parent
                            font.pixelSize: mainwindow.width * 0.018//15
                        }
                    }
                }

                background:Rectangle{
                    width: valuetext.width
                    height: valuetext.height
                    color:  valuetext.currentText
                }
            }
            Button {
                id: btnclosecolorselect
                width: mainwindow.width * 0.1875
                height: mainwindow.height * 0.083
                text: Translator.translate("Close menu", Settings.language)
                font.pixelSize: mainwindow.width * 0.018//15
                onClicked: {selectcolor.visible = false;}

            }
        }
    }
}
