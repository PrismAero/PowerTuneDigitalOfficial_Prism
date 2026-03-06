import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    width: dashWindow.width * 0.24
    height: dashWindow.height * 0.83
    color: "darkgrey"
    z: 200
    visible: false
    x: 590
    y: 0

    property Item gaugeParent
    property Item dashWindow
    property int dashIndex: 0

    signal menuClosed
    signal saveRequested
    signal exportCSVRequested
    signal exportJSONRequested
    signal importFileRequested(string filename)
    signal backgroundSettingsRequested
    signal colorSettingsRequested
    signal clearRequested

    MouseArea {
        id: touchAreasquaregaugemenu
        anchors.fill: parent
        drag.target: root
    }

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
            if (dashWindow && dashWindow.width == 1600) {
                cbx_sources.font.pixelSize = 18;
            }
        }
    }

    ComboBox {
        id: loadfileselect
        font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
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

    Grid {
        rows: 8
        columns: 2
        x: 0
        y: 45
        topPadding: 8
        width: parent.width
        height: parent.height
        layoutDirection: "RightToLeft"
        rowSpacing: 3
        spacing: (parent.width + parent.height) * 0.005

        Button {
            id: btnaddSquare
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Square", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                var ds = DatasourceService.allSources.get(cbx_sources.currentIndex);
                GaugeFactory.createGauge("Square gauge", gaugeParent, {
                    "width": 266,
                    "height": 119,
                    "x": 0,
                    "y": 240,
                    "maxvalue": 248,
                    "decimalpoints": ds.decimalpoints,
                    "mainunit": ds.defaultsymbol,
                    "title": ds.titlename,
                    "vertgaugevisible": false,
                    "horigaugevisible": true,
                    "secvaluevisible": false,
                    "mainvaluename": ds.sourcename,
                    "secvaluename": ds.sourcename,
                    "warnvaluehigh": 10000,
                    "warnvaluelow": -20000,
                    "framecolor": "lightsteelblue",
                    "resetbackroundcolor": "black",
                    "resettitlecolor": "lightsteelblue",
                    "titletextcolor": "white",
                    "textcolor": "white",
                    "barcolor": "blue",
                    "titlefontsize": 25,
                    "mainfontsize": 40,
                    "decimalpoints2": ds.decimalpoints2,
                    "textFonttype": "Lato",
                    "valueFonttype": "Lato"
                });
                root.visible = false;
                root.menuClosed();
            }
        }
        Button {
            id: btnaddBar
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Bar", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                var dsBar = DatasourceService.allSources.get(cbx_sources.currentIndex);
                GaugeFactory.createGauge("Bar gauge", gaugeParent, {
                    "width": 320,
                    "height": 80,
                    "x": 10,
                    "y": 0,
                    "minvalue": 0,
                    "maxvalue": 8000,
                    "decimalpoints": dsBar.decimalpoints,
                    "gaugename": dsBar.titlename,
                    "mainvaluename": dsBar.sourcename,
                    "warnvaluehigh": 1000,
                    "warnvaluelow": 0
                });
                root.visible = false;
                root.menuClosed();
            }
        }
        Button {
            id: btnaddRound
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Round", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                var dsRound = DatasourceService.allSources.get(cbx_sources.currentIndex);
                GaugeFactory.createGauge("Round gauge", gaugeParent, {
                    "width": 400,
                    "height": 400,
                    "x": 20,
                    "y": 20,
                    "mainvaluename": dsRound.sourcename,
                    "maxvalue": dsRound.maxvalue,
                    "minvalue": 0,
                    "warnvaluehigh": dsRound.maxvalue,
                    "warnvaluelow": -1000,
                    "startangle": -145,
                    "endangle": 90,
                    "redareastart": dsRound.maxvalue,
                    "divider": dsRound.divisor,
                    "tickmarksteps": dsRound.stepsize,
                    "minortickmarksteps": 1,
                    "setlabelsteps": dsRound.stepsize,
                    "decimalpoints": dsRound.decimalpoints,
                    "needleinset": 2,
                    "setlabelinset": 38,
                    "setminortickmarkinset": 3,
                    "setmajortickmarkinset": 3,
                    "minortickmarkheight": 8,
                    "minortickmarkwidth": 3,
                    "tickmarkheight": 15,
                    "tickmarkwidth": 5,
                    "trailhighboarder": 0.50,
                    "trailmidboarder": 0.40,
                    "traillowboarder": 0.33,
                    "trailbottomboarder": 0.25,
                    "labelfontsize": 20,
                    "needleTipWidth": 5,
                    "needleLength": 93,
                    "needleBaseWidth": 8,
                    "redareainset": 0,
                    "redareawidth": 0,
                    "needlecolor": "red",
                    "needlecolor2": "darkred",
                    "backroundcolor": "aliceblue",
                    "warningcolor": "red",
                    "minortickmarkcoloractive": "grey",
                    "minortickmarkcolorinactive": "darkgrey",
                    "majortickmarkcoloractive": "darkgrey",
                    "majortickmarkcolorinactive": "black",
                    "labelcoloractive": "grey",
                    "labelcolorinactive": "black",
                    "outerneedlecolortrailsave": "dodgerblue",
                    "middleneedlecortrailsave": "deepskyblue",
                    "lowerneedlecolortrailsave": "lightskyblue",
                    "innerneedlecolortrailsave": "transparent",
                    "outerneedlecolortrail": "dodgerblue",
                    "middleneedlecortrail": "deepskyblue",
                    "lowerneedlecolortrail": "lightskyblue",
                    "innerneedlecolortrail": "transparent",
                    "needlevisible": true,
                    "ringvisible": true,
                    "needlecentervisisble": true,
                    "labelfont": "Lato",
                    "desctextx": 30,
                    "desctexty": 50,
                    "desctextfontsize": 10,
                    "desctextfontbold": false,
                    "desctextfonttype": "Lato",
                    "desctextdisplaytext": dsRound.titlename,
                    "desctextdisplaytextcolor": "red"
                });
                root.visible = false;
                root.menuClosed();
            }
        }
        Button {
            id: btnaddText
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Text", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                GaugeFactory.createGauge("Text label gauge", gaugeParent, {
                    "x": 100,
                    "y": 50,
                    "displaytext": "Textelement",
                    "fonttype": "Lato",
                    "fontsize": 15,
                    "textcolor": "red",
                    "resettextcolor": "red",
                    "datasourcename": "",
                    "fontbold": true,
                    "decimalpoints": 0,
                    "warnvaluehigh": 20000,
                    "warnvaluelow": -20000
                });
                root.visible = false;
                root.menuClosed();
            }
        }
        Button {
            id: btnaddPicture
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Image", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                GaugeFactory.createGauge("gauge image", gaugeParent, {
                    "x": 10,
                    "y": 10,
                    "pictureheight": 100,
                    "picturesource": "qrc:/Resources/graphics/slectImage.png"
                });
                root.visible = false;
                root.menuClosed();
            }
        }
        Button {
            id: btnaddStatePicture
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("State", Settings.language) + " " + Translator.translate("Image", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                GaugeFactory.createGauge("State gauge", gaugeParent, {
                    "x": 10,
                    "y": 10,
                    "pictureheight": 100,
                    "mainvaluename": "speed",
                    "triggervalue": 1,
                    "statepicturesourceoff": "qrc:/Resources/graphics/selectStateImage.png",
                    "statepicturesourceon": "qrc:/Resources/graphics/selectStateImage.png"
                });
                root.visible = false;
                root.menuClosed();
            }
        }
        Button {
            id: btnaddStateGIF
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("State", Settings.language) + " " + Translator.translate("GIF", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                GaugeFactory.createGauge("State GIF", gaugeParent, {
                    "x": 10,
                    "y": 10,
                    "pictureheight": 100,
                    "mainvaluename": "speed",
                    "triggervalue": 1,
                    "statepicturesourceoff": "qrc:/Resources/graphics/StateGIF.gif",
                    "statepicturesourceon": "qrc:/Resources/graphics/StateGIF.gif",
                    "triggeroffvalue": 0
                });
                root.visible = false;
                root.menuClosed();
            }
        }

        Button {
            id: btnopencolorselect
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Colors", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                root.visible = false;
                root.colorSettingsRequested();
            }
        }
        Button {
            id: btnclear
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Clear", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                root.visible = false;
                root.clearRequested();
            }
        }

        Button {
            id: loadfromfile
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Import", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                Connect.readavailabledashfiles();
                showImportMode();
                root.saveRequested();
            }
        }
        Button {
            id: savetofile
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Export", Settings.language) + " CSV"
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                root.visible = false;
                root.exportCSVRequested();
            }
        }
        Button {
            id: savetofileJSON
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Export", Settings.language) + " JSON"
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                root.visible = false;
                root.exportJSONRequested();
            }
        }
        Button {
            id: btncancelload
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Cancel", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            visible: false
            onClicked: {
                showNormalMode();
                root.visible = false;
                root.menuClosed();
            }
        }
        Button {
            id: btnload
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Load", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            visible: false
            onClicked: {
                showNormalMode();
                root.visible = false;
                root.importFileRequested(loadfileselect.textAt(loadfileselect.currentIndex));
            }
        }
        Button {
            id: btnbackround
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Background", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            onClicked: {
                root.visible = false;
                root.backgroundSettingsRequested();
            }
        }

        Button {
            id: btnsave
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Save", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            highlighted: true
            onClicked: {
                root.visible = false;
                root.saveRequested();
                root.menuClosed();
            }
        }

        Button {
            id: btncancel
            width: dashWindow ? dashWindow.width * 0.118 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Close", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            highlighted: true
            onClicked: {
                root.visible = false;
                root.menuClosed();
            }
        }
    }

    function showImportMode() {
        btnaddRound.visible = false;
        btnaddText.visible = false;
        btnaddPicture.visible = false;
        btnaddStatePicture.visible = false;
        btnaddStateGIF.visible = false;
        btnaddBar.visible = false;
        btnaddSquare.visible = false;
        btnopencolorselect.visible = false;
        btnclear.visible = false;
        loadfromfile.visible = false;
        savetofile.visible = false;
        savetofileJSON.visible = false;
        btnbackround.visible = false;
        btnsave.visible = false;
        btncancel.visible = false;
        cbx_sources.visible = false;

        btncancelload.visible = true;
        loadfileselect.visible = true;
        btnload.visible = true;
    }

    function showNormalMode() {
        btnaddRound.visible = true;
        btnaddText.visible = true;
        btnaddPicture.visible = true;
        btnaddStatePicture.visible = true;
        btnaddStateGIF.visible = true;
        btnaddBar.visible = true;
        btnaddSquare.visible = true;
        btnopencolorselect.visible = true;
        btnclear.visible = true;
        loadfromfile.visible = true;
        savetofile.visible = true;
        savetofileJSON.visible = true;
        btnbackround.visible = true;
        btnsave.visible = true;
        btncancel.visible = true;
        cbx_sources.visible = true;

        btncancelload.visible = false;
        loadfileselect.visible = false;
        btnload.visible = false;
    }

    onVisibleChanged: {
        if (visible)
            showNormalMode();
    }
}
