import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: statepicture
    height: pictureheight
    width: pictureheight
    property string information: "State GIF"
    property string statepicturesourceoff: ""
    property string statepicturesourceon: ""
    property int pictureheight: 120
    property int picturewidth: 120
    property string increasedecreaseident
    property string mainvaluename: ""
    property double triggervalue: 0
    property double triggeroffvalue: 0

    Drag.active: true
    property double _mainValue: 0

    AnimatedImage {
        anchors.fill: parent
        id: statepictureoff
        playing: true
        fillMode: Image.PreserveAspectFit
        source: statepicturesourceoff
        visible: !statepictureon.visible
    }

    AnimatedImage {
        anchors.fill: parent
        id: statepictureon
        playing: true
        fillMode: Image.PreserveAspectFit
        source: statepicturesourceon
        visible: {
            if (triggeroffvalue <= triggervalue)
                return _mainValue >= triggervalue;
            return _mainValue >= triggervalue && _mainValue <= triggeroffvalue;
        }
    }

    function bind() {
        if (mainvaluename === "")
            return;
        _mainValue = Qt.binding(function() { return PropertyRouter.getValue(mainvaluename); });
    }

    Component.onCompleted: bind()

    GaugeMouseHandler {
        id: mouseHandler
        dragTarget: statepicture
        onConfigRequested: function(mx, my) { configMenu.show(mx, my); }
    }

    GaugeConfigMenu {
        id: configMenu
        target: statepicture
        onDeleteRequested: statepicture.destroy()

        DatasourceSection { target: statepicture }
        SizeSection { target: statepicture }
        ImagePickerSection {
            target: statepicture
            targetProperty: "statepicturesourceoff"
            showHeightControl: false
            title: "GIF OFF"
        }
        ImagePickerSection {
            target: statepicture
            targetProperty: "statepicturesourceon"
            showHeightControl: false
            title: "GIF ON"
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            Text { text: "Triggers"; font.bold: true; color: "white" }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "On At"; color: "white" }
                NumericStepper {
                    Layout.fillWidth: true
                    value: statepicture.triggervalue
                    stepSize: 1
                    onValueChanged: function(v) { statepicture.triggervalue = v; }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Off At"; color: "white" }
                NumericStepper {
                    Layout.fillWidth: true
                    value: statepicture.triggeroffvalue
                    stepSize: 1
                    onValueChanged: function(v) { statepicture.triggeroffvalue = v; }
                }
            }
        }
    }
}
