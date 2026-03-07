import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: mytextlabel
    height: mytext.implicitHeight
    width: mytext.implicitWidth
    property string information: "Text label gauge"
    property string displaytext: ""
    property string fonttype: GaugeTheme.fontFamily
    property int fontsize: 16
    property string textcolor: GaugeTheme.textPrimary
    property string datasourcename: ""
    property bool fontbold: false
    property int decimalpoints: 0
    property string increasedecreaseident
    property double warnvaluehigh: 20000
    property double warnvaluelow: -20000
    property string resettextcolor: GaugeTheme.textPrimary

    Drag.active: true

    GaugeMouseHandler {
        id: mouseHandler
        dragTarget: mytextlabel
        onConfigRequested: function(mx, my) { configMenu.show(mx, my); }
    }

    Text {
        id: mytext
        text: displaytext
        font.family: fonttype
        font.pointSize: fontsize
        font.bold: fontbold
        color: textcolor
        anchors.centerIn: parent
        onTextChanged: warningindication.warn()
    }

    SequentialAnimation {
        id: anim
        loops: Animation.Infinite
        running: false
        PropertyAnimation {
            target: mytext
            property: "color"
            from: "darkred"
            to: "orange"
            duration: 700
        }
    }

    function checkdatasource() {
        if (datasourcename === "")
            return;
        displaytext = Qt.binding(function() {
            var value = PropertyRouter.getValue(datasourcename);
            if (decimalpoints >= 0 && decimalpoints < 4 && typeof value === "number")
                return value.toFixed(decimalpoints);
            return value;
        });
    }

    Item {
        id: warningindication
        function warn() {
            if (Number(mytext.text) > warnvaluehigh || Number(mytext.text) < warnvaluelow) {
                anim.running = true;
            } else {
                anim.running = false;
                mytext.color = resettextcolor;
            }
        }
    }

    Component.onCompleted: checkdatasource()

    GaugeConfigMenu {
        id: configMenu
        target: mytextlabel
        onDeleteRequested: mytextlabel.destroy()

        DatasourceSection { target: mytextlabel; sourceProperty: "datasourcename" }
        LabelSection { target: mytextlabel }
        RangeSection { target: mytextlabel }
        FontSettingsSection {
            target: mytextlabel
            fontBindings: [
                { label: "Text", fontProp: "fonttype", sizeProp: "fontsize" }
            ]
        }
        ColorsSection {
            target: mytextlabel
            colorBindings: [
                { label: "Text", prop: "textcolor" }
            ]
        }
    }
}
