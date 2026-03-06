import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: root
    x: 0
    y: 0
    height: dashWindow ? dashWindow.height * 0.41 : 200
    width: dashWindow ? dashWindow.width * 0.625 : 500
    color: "darkgrey"
    z: 200
    visible: false

    property Item gaugeParent
    property Item dashWindow

    signal panelClosed()

    MouseArea {
        id: touchAreacolorselect
        anchors.fill: parent
        drag.target: root
    }

    function changeframeclolor() {
        if (!gaugeParent) return;
        for (var i = 0; i < gaugeParent.children.length; ++i) {
            if (gaugeParent.children[i].information === "Square gauge") {
                gaugeParent.children[i].framecolor = colorselect.textAt(colorselect.currentIndex);
                gaugeParent.children[i].set();
            }
        }
    }

    function changetitlebarclolor() {
        if (!gaugeParent) return;
        for (var i = 0; i < gaugeParent.children.length; ++i) {
            if (gaugeParent.children[i].information === "Square gauge") {
                gaugeParent.children[i].resettitlecolor = colorselect.textAt(colorselecttitlebar.currentIndex);
                gaugeParent.children[i].set();
            }
        }
    }

    function changebackroundcolor() {
        if (!gaugeParent) return;
        for (var i = 0; i < gaugeParent.children.length; ++i) {
            if (gaugeParent.children[i].information === "Square gauge") {
                gaugeParent.children[i].resetbackroundcolor = backroundcolor.textAt(backroundcolor.currentIndex);
                gaugeParent.children[i].set();
            }
        }
    }

    function changebargaugecolor() {
        if (!gaugeParent) return;
        for (var i = 0; i < gaugeParent.children.length; ++i) {
            if (gaugeParent.children[i].information === "Square gauge") {
                gaugeParent.children[i].barcolor = bargaugecolor.textAt(bargaugecolor.currentIndex);
                gaugeParent.children[i].set();
            }
        }
    }

    function changetitlecolor() {
        if (!gaugeParent) return;
        for (var i = 0; i < gaugeParent.children.length; ++i) {
            if (gaugeParent.children[i].information === "Square gauge") {
                gaugeParent.children[i].titletextcolor = titlecolor.textAt(titlecolor.currentIndex);
                gaugeParent.children[i].set();
            }
        }
    }

    function changevaluetextcolor() {
        if (!gaugeParent) return;
        for (var i = 0; i < gaugeParent.children.length; ++i) {
            if (gaugeParent.children[i].information === "Square gauge") {
                gaugeParent.children[i].textcolor = valuetext.textAt(valuetext.currentIndex);
                gaugeParent.children[i].set();
            }
        }
    }

    Grid {
        rows: 5
        columns: 3
        anchors.centerIn: parent
        spacing: 5

        Text {
            text: Translator.translate("Frame color", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
        }
        Text {
            text: Translator.translate("Titlebar color", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
        }
        Text {
            text: Translator.translate("Background color", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
        }

        ComboBox {
            id: colorselect
            width: dashWindow ? dashWindow.width * 0.1875 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            model: ColorList {}
            visible: true
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            onCurrentIndexChanged: changeframeclolor()
            delegate: ItemDelegate {
                id: itemDelegate2
                width: colorselect.width
                height: colorselect.height
                font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                Rectangle {
                    width: colorselect.width
                    height: colorselect.height
                    color: itemColor
                    Text {
                        text: itemColor
                        anchors.centerIn: parent
                        font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                    }
                }
            }
            background: Rectangle {
                width: colorselect.width
                height: colorselect.height
                color: colorselect.currentText
            }
        }

        ComboBox {
            id: colorselecttitlebar
            width: dashWindow ? dashWindow.width * 0.1875 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            model: ColorList {}
            visible: true
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            onCurrentIndexChanged: changetitlebarclolor()
            delegate: ItemDelegate {
                id: itemDelegate3
                font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                width: colorselecttitlebar.width
                height: colorselecttitlebar.height
                Rectangle {
                    width: colorselecttitlebar.width
                    height: colorselecttitlebar.height
                    color: itemColor
                    Text {
                        text: itemColor
                        anchors.centerIn: parent
                        font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                    }
                }
            }
            background: Rectangle {
                width: colorselecttitlebar.width
                height: colorselecttitlebar.height
                color: colorselecttitlebar.currentText
            }
        }

        ComboBox {
            id: backroundcolor
            width: dashWindow ? dashWindow.width * 0.1875 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            model: ColorList {}
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            visible: true
            onCurrentIndexChanged: changebackroundcolor()
            delegate: ItemDelegate {
                width: backroundcolor.width
                height: backroundcolor.height
                font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                Rectangle {
                    width: backroundcolor.width
                    height: backroundcolor.height
                    color: itemColor
                    Text {
                        text: itemColor
                        anchors.centerIn: parent
                        font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                    }
                }
            }
            background: Rectangle {
                width: backroundcolor.width
                height: backroundcolor.height
                color: backroundcolor.currentText
            }
        }

        Text {
            text: Translator.translate("Bargauge color", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
        }
        Text {
            text: Translator.translate("Title text color", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
        }
        Text {
            text: Translator.translate("Main text color", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
        }

        ComboBox {
            id: bargaugecolor
            width: dashWindow ? dashWindow.width * 0.1875 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            model: ColorList {}
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            visible: true
            onCurrentIndexChanged: changebargaugecolor()
            delegate: ItemDelegate {
                width: bargaugecolor.width
                height: bargaugecolor.height
                font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                Rectangle {
                    width: bargaugecolor.width
                    height: bargaugecolor.height
                    color: itemColor
                    Text {
                        text: itemColor
                        anchors.centerIn: parent
                        font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                    }
                }
            }
            background: Rectangle {
                width: bargaugecolor.width
                height: bargaugecolor.height
                color: bargaugecolor.currentText
            }
        }

        ComboBox {
            id: titlecolor
            width: dashWindow ? dashWindow.width * 0.1875 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            model: ColorList {}
            visible: true
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            onCurrentIndexChanged: changetitlecolor()
            delegate: ItemDelegate {
                width: titlecolor.width
                height: titlecolor.height
                font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                text: itemColor
                Rectangle {
                    width: titlecolor.width
                    height: titlecolor.width
                    color: itemColor
                    Text {
                        text: itemColor
                        anchors.centerIn: parent
                        font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                    }
                }
            }
            background: Rectangle {
                width: titlecolor.width
                height: titlecolor.height
                color: titlecolor.currentText
            }
        }

        ComboBox {
            id: valuetext
            width: dashWindow ? dashWindow.width * 0.1875 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            model: ColorList {}
            visible: true
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            onCurrentIndexChanged: changevaluetextcolor()
            delegate: ItemDelegate {
                width: valuetext.width
                height: valuetext.height
                font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                Rectangle {
                    width: valuetext.width
                    height: valuetext.height
                    color: itemColor
                    Text {
                        text: itemColor
                        anchors.centerIn: parent
                        font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
                    }
                }
            }
            background: Rectangle {
                width: valuetext.width
                height: valuetext.height
                color: valuetext.currentText
            }
        }

        Button {
            id: btnclosecolorselect
            width: dashWindow ? dashWindow.width * 0.1875 : 150
            height: dashWindow ? dashWindow.height * 0.083 : 40
            text: Translator.translate("Close menu", Settings.language)
            font.pixelSize: dashWindow ? dashWindow.width * 0.018 : 15
            onClicked: {
                root.visible = false;
                root.panelClosed();
            }
        }
    }
}
