import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: root
    width: 250
    height: 130

    property string information: "AiM sensor label"
    property string mainvaluename: ""
    property real value: 0
    property int decimalpoints: 2
    property string labeltext: "Water Temp"
    property string unittext: "F\u00B0"
    property string customValueText: ""
    property bool configMenuEnabled: true
    property string increasedecreaseident

    readonly property string _displayValue: {
        if (customValueText !== "") return customValueText;
        if (!isFinite(value)) return "--";
        return Number(value).toFixed(decimalpoints);
    }

    FontLoader { id: lightFont; source: "qrc:/Resources/fonts/hyperspacerace-light.otf" }
    FontLoader { id: regularFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }

    function _bindValue() {
        if (mainvaluename)
            value = Qt.binding(function() { return PropertyRouter.getValue(mainvaluename); });
    }

    Component.onCompleted: _bindValue()
    onMainvaluenameChanged: _bindValue()

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

    Column {
        anchors.fill: parent
        anchors.rightMargin: root.width * 0.02

        Text {
            width: parent.width
            text: root.labeltext
            font.family: lightFont.name
            font.pixelSize: root.height * 0.28
            font.italic: true
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignRight
            elide: Text.ElideRight
        }

        Text {
            width: parent.width
            text: root._displayValue
            font.family: regularFont.name
            font.pixelSize: root.height * 0.44
            font.italic: true
            font.letterSpacing: -root.height * 0.018
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignLeft

            layer.enabled: true
            layer.effect: Item {
                property var source
            }
        }

        Text {
            width: parent.width
            text: root.unittext
            font.family: regularFont.name
            font.pixelSize: root.height * 0.22
            font.italic: true
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignRight
        }
    }

    Accessible.role: Accessible.Indicator
    Accessible.name: root.labeltext || root.information
    Accessible.description: root._displayValue

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

                        Text { text: "Sensor Label"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Source:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
                            ComboBox {
                                width: 190
                                model: DatasourceService.allSources
                                textRole: "titlename"
                                font.pixelSize: 12
                                Component.onCompleted: {
                                    for (var i = 0; i < model.count; ++i) {
                                        if (DatasourceService.allSources.get(i).sourcename === root.mainvaluename) {
                                            currentIndex = i; break;
                                        }
                                    }
                                }
                                onCurrentIndexChanged: {
                                    if (currentIndex >= 0)
                                        root.mainvaluename = DatasourceService.allSources.get(currentIndex).sourcename;
                                }
                            }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Label:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
                            TextField { width: 190; text: root.labeltext; font.pixelSize: 12; onTextChanged: root.labeltext = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Unit:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
                            TextField { width: 190; text: root.unittext; font.pixelSize: 12; onTextChanged: root.unittext = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Decimals:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
                            SpinBox { from: 0; to: 6; value: root.decimalpoints; onValueChanged: root.decimalpoints = value }
                        }
                        Switch { text: "Visible"; checked: root.visible; onCheckedChanged: root.visible = checked }
                    }
                }
            }
        ]
    }
}
