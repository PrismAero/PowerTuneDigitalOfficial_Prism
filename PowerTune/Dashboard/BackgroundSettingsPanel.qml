import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    width: dashWindow ? dashWindow.width * 0.25 : 200
    height: dashWindow ? dashWindow.height * 0.625 : 300
    color: "darkgrey"
    x: 0
    y: 0
    z: 200
    visible: false

    property Item dashWindow
    property alias rpmStyleIndex: rpmstyleselector.currentIndex
    property alias extraIndex: extraSelector.currentIndex

    signal rpmSourceChanged(string source)
    signal backgroundImageChanged(string path)
    signal backgroundColorChanged(color c)
    signal extraChanged(int index)
    signal panelClosed

    MouseArea {
        id: touchArearpmbackroundselector
        anchors.fill: parent
        drag.target: root
    }

    function selectRpmStyle() {
        switch (rpmstyleselector.currentIndex) {
        case 0:
            rpmSourceChanged("");
            break;
        case 1:
            rpmSourceChanged("qrc:/qt/qml/PowerTune/Gauges/Styles/PowerTune/Gauges/Styles/RPMBarStyle1.qml");
            break;
        case 2:
            rpmSourceChanged("qrc:/qt/qml/PowerTune/Gauges/Styles/PowerTune/Gauges/Styles/RPMBarStyle2.qml");
            break;
        case 3:
            rpmSourceChanged("qrc:/qt/qml/PowerTune/Gauges/Styles/PowerTune/Gauges/Styles/RPMBarStyle3.qml");
            break;
        case 4:
            rpmSourceChanged("qrc:/qt/qml/PowerTune/Gauges/Widgets/PowerTune/Gauges/Widgets/RPMBar.qml");
            break;
        }
    }

    function selectExtra() {
        switch (extraSelector.currentIndex) {
        case 0:
            extraChanged(0);
            break;
        case 1:
            extraChanged(1);
            break;
        }
    }

    function updatePicList(currentSource) {
        for (var i = 0; i < backroundSelector.count; ++i) {
            if (currentSource == "file:" + backroundSelector.textAt(i)) {
                backroundSelector.currentIndex = i;
                return;
            }
        }
    }

    Grid {
        rows: 10
        columns: 1
        rowSpacing: 5

        Text {
            text: Translator.translate("RPM2", Settings.language) + " " + Translator.translate("Style", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.025 : 20
            font.bold: true
        }
        ComboBox {
            id: rpmstyleselector
            width: dashWindow ? dashWindow.width * 0.25 : 200
            height: dashWindow ? dashWindow.height * 0.083 : 40
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            model: [Translator.translate("None", Settings.language), Translator.translate("Style", Settings.language) + " 1", Translator.translate("Style", Settings.language) + " 2", Translator.translate("Style", Settings.language) + " 3", Translator.translate("Style", Settings.language) + " 4"]
            onCurrentIndexChanged: selectRpmStyle()
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
            font.pixelSize: dashWindow ? dashWindow.width * 0.025 : 20
            font.bold: true
        }
        ComboBox {
            id: backroundSelector
            width: dashWindow ? dashWindow.width * 0.25 : 200
            height: dashWindow ? dashWindow.height * 0.083 : 40
            font.pixelSize: dashWindow ? dashWindow.width * 0.015 : 12
            model: UI.backroundpictures
            currentIndex: 0
            onCurrentIndexChanged: {
                var selectedFile = backroundSelector.textAt(backroundSelector.currentIndex);
                var path;
                if (Qt.platform.os === "linux") {
                    path = "file:///home/pi/Logo/" + selectedFile;
                } else if (Qt.platform.os === "osx") {
                    path = "qrc:/Resources/graphics/" + selectedFile;
                } else if (Qt.platform.os === "windows") {
                    path = "file:///c:/Logo/" + selectedFile;
                } else {
                    path = "file:" + selectedFile;
                }
                backgroundImageChanged(path);
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
            font.pixelSize: dashWindow ? dashWindow.width * 0.025 : 20
            font.bold: true
        }
        ComboBox {
            id: mainbackroundcolorselect
            width: dashWindow ? dashWindow.width * 0.25 : 200
            height: dashWindow ? dashWindow.height * 0.083 : 40
            model: ColorList {}
            visible: true
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            delegate: ItemDelegate {
                id: itemDelegate
                width: mainbackroundcolorselect.width
                height: mainbackroundcolorselect.height
                font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                Rectangle {
                    id: backroundcolorcbxcolor
                    width: mainbackroundcolorselect.width
                    height: mainbackroundcolorselect.height
                    color: itemColor
                    Text {
                        text: itemColor
                        anchors.centerIn: parent
                        font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                    }
                }
            }
            onCurrentIndexChanged: {
                backgroundColorChanged(mainbackroundcolorselect.textAt(mainbackroundcolorselect.currentIndex));
            }
        }

        Text {
            text: "Extra "
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            font.bold: true
        }
        ComboBox {
            id: extraSelector
            width: dashWindow ? dashWindow.width * 0.25 : 200
            height: dashWindow ? dashWindow.height * 0.083 : 40
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            model: [Translator.translate(Translator.translate("None", Settings.language), Settings.language), "PFC Sensors"]
            onCurrentIndexChanged: selectExtra()
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
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            width: dashWindow ? dashWindow.width * 0.25 : 200
            height: dashWindow ? dashWindow.height * 0.083 : 40
            onClicked: {
                root.visible = false;
                root.panelClosed();
            }
        }
    }

    function syncBackgroundColor(currentColor) {
        for (var i = 1; i < mainbackroundcolorselect.model.count; ++i) {
            if (Qt.colorEqual(currentColor, mainbackroundcolorselect.textAt(i))) {
                mainbackroundcolorselect.currentIndex = i;
                return;
            }
        }
    }
}
