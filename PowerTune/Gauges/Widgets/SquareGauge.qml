import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0
import Qt.labs.settings 1.0

Rectangle {
    id: gauge
    width: parent.width * 0.3125
    height: parent.height * (200 / parent.height)
    border.color: framecolor
    border.width: 2
    color: resetbackroundcolor

    property string information: "Square gauge"
    property string mainvaluename
    property string secvaluename
    property alias title: gaugetextfield.text
    property alias mainunit: mainvalueunittextfield.text
    property alias vertgaugevisible: vertBar.visible
    property alias horigaugevisible: horizBar.visible
    property alias horizgaugevisible: horizBar.visible
    property alias secvaluevisible: secondaryvaluetextfield.visible
    property alias secvalue: placeholder2.text
    property alias mainvalue: placeholder.text
    property double maxvalue: 100
    property alias titlecolor: titlebar.color
    property alias titlefontsize: gaugetextfield.font.pixelSize
    property alias mainfontsize: mainvaluetextfield.font.pixelSize
    property string resettitlecolor: GaugeTheme.bgPanel
    property string resetbackroundcolor: GaugeTheme.bgPanel
    property string framecolor: GaugeTheme.borderColor
    property string titletextcolor: GaugeTheme.textPrimary
    property string textcolor: GaugeTheme.textSecondary
    property string barcolor: GaugeTheme.arcFill
    property int decimalpoints: 0
    property int decimalpoints2: 0
    property double warnvaluehigh: 20000
    property double warnvaluelow: -20000
    property string textFonttype: GaugeTheme.fontFamily
    property string valueFonttype: GaugeTheme.fontFamilyMono
    property real peakval: 0
    property string increasedecreaseident

    property double gaugeScaleOffset
    property double scaleValue: gaugeSettings.scaleValueStored
    property double offsetValueMultiply: gaugeSettings.offsetValueMultiplyStored
    property double offsetValueDivide: gaugeSettings.offsetValueDivideStored

    Settings {
        id: gaugeSettings
        property double scaleValueStored
        property double offsetValueMultiplyStored
        property double offsetValueDivideStored
    }

    Drag.active: true

    Text { id: placeholder; visible: false }
    Text { id: placeholder2; visible: false }

    GaugeMouseHandler {
        id: mouseHandler
        dragTarget: gauge
        onConfigRequested: function(mx, my) { configMenu.show(mx, my); }
    }

    function _mainNumeric() {
        var v = Number(placeholder.text);
        return isNaN(v) ? 0 : v;
    }

    function _secNumeric() {
        var v = Number(placeholder2.text);
        return isNaN(v) ? 0 : v;
    }

    function _normalized(v) {
        if (maxvalue <= 0)
            return 0;
        return Math.max(0, Math.min(1, v / maxvalue));
    }

    Rectangle {
        id: titlebar
        width: parent.width - 4
        height: parent.height / 4
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 2
        anchors.leftMargin: 2
        color: resettitlecolor

        Text {
            id: gaugetextfield
            anchors.centerIn: parent
            font.pixelSize: 23
            font.bold: true
            font.family: textFonttype
            color: titletextcolor
            text: ""
        }
    }

    Text {
        id: mainvaluetextfield
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 50
        font.family: valueFonttype
        color: "white"
        text: {
            var v = _mainNumeric();
            return decimalpoints > 0 ? v.toFixed(decimalpoints) : v;
        }
    }

    Text {
        id: mainvalueunittextfield
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: mainvaluetextfield.font.pixelSize / 1.8
        font.family: textFonttype
        font.bold: true
        color: textcolor
        text: ""
    }

    Text {
        id: secondaryvaluetextfield
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        font.pixelSize: 28
        font.family: valueFonttype
        color: textcolor
        text: {
            var v = _secNumeric();
            return decimalpoints2 > 0 ? v.toFixed(decimalpoints2) : v;
        }
    }

    Rectangle {
        id: vertBar
        anchors.left: parent.left
        anchors.leftMargin: 6
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        width: 10
        height: parent.height * 0.66
        color: "#202020"
        radius: 2

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height * _normalized(_mainNumeric())
            color: barcolor
            radius: 2
        }
    }

    Rectangle {
        id: horizBar
        anchors.left: vertBar.right
        anchors.leftMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        height: 8
        color: "#202020"
        radius: 2

        Rectangle {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width * _normalized(_mainNumeric())
            color: barcolor
            radius: 2
        }
    }

    SequentialAnimation on titlebar.color {
        running: _mainNumeric() > warnvaluehigh || _mainNumeric() < warnvaluelow
        loops: Animation.Infinite
        ColorAnimation { from: "darkred"; to: "red"; duration: 500 }
        ColorAnimation { from: "red"; to: "darkred"; duration: 500 }
    }

    function set() {
        toggledecimal();
        toggledecimal2();
    }

    function toggledecimal() {
        if (mainvaluename === "")
            return;
        placeholder.text = Qt.binding(function() { return PropertyRouter.getValue(mainvaluename); });
    }

    function toggledecimal2() {
        if (secvaluename === "")
            return;
        placeholder2.text = Qt.binding(function() { return PropertyRouter.getValue(secvaluename); });
    }

    Component.onCompleted: set()

    GaugeConfigMenu {
        id: configMenu
        target: gauge
        onDeleteRequested: gauge.destroy()

        DatasourceSection { target: gauge }
        SecondarySourceSection { target: gauge }
        RangeSection { target: gauge }
        SizeSection { target: gauge }
        FontSettingsSection {
            target: gauge
            fontBindings: [
                { label: "Title Font", fontProp: "textFonttype", sizeProp: "titlefontsize" },
                { label: "Value Font", fontProp: "valueFonttype", sizeProp: "mainfontsize" }
            ]
        }
        UnitSymbolSection { target: gauge }
        VisibilityTogglesSection {
            target: gauge
            toggleBindings: [
                { label: "Secondary Value", prop: "secvaluevisible" },
                { label: "Vertical Gauge", prop: "vertgaugevisible" },
                { label: "Horizontal Gauge", prop: "horizgaugevisible" }
            ]
        }
        ColorsSection {
            target: gauge
            colorBindings: [
                { label: "Frame", prop: "framecolor" },
                { label: "Background", prop: "resetbackroundcolor" },
                { label: "Title Bar", prop: "resettitlecolor" },
                { label: "Title Text", prop: "titletextcolor" },
                { label: "Text", prop: "textcolor" },
                { label: "Bar", prop: "barcolor" }
            ]
        }
    }
}
