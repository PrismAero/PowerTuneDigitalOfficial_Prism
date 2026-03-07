import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: root
    width: 160
    height: 280
    clip: false

    property string information: "AiM gear indicator"
    property string mainvaluename
    property int gearValue: 0
    property double warnvaluehigh: 20000
    property double warnvaluelow: -20000
    property color textColor: GaugeTheme.aimGearColor
    property string fontFamily: ""
    property real fontSizeMultiplier: 1.0
    property string increasedecreaseident

    FontLoader { id: condensedHeavyFont; source: "qrc:/Resources/fonts/hyperspacerace-condensedheavy.otf" }

    readonly property string _gearText: {
        if (gearValue === 0) return "N";
        if (gearValue < 0) return "R";
        return gearValue.toString();
    }

    readonly property string _resolvedFont: fontFamily !== "" ? fontFamily : condensedHeavyFont.name

    Component.onCompleted: {
        if (mainvaluename)
            gearValue = Qt.binding(function() { return PropertyRouter.getValue(mainvaluename); });
    }

    MouseArea {
        anchors.fill: parent
        property real _lastPress: 0
        onPressed: function(mouse) {
            var now = Date.now();
            if (now - _lastPress < 500) {
                configMenu.show(mouse.x, mouse.y);
                _lastPress = 0;
            } else {
                _lastPress = now;
            }
        }
    }

    Text {
        id: gearShadow
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: 3
        anchors.verticalCenterOffset: 3
        text: root._gearText
        font.family: root._resolvedFont
        font.pixelSize: root.height * 0.70 * root.fontSizeMultiplier
        font.weight: Font.Black
        color: Qt.rgba(0, 0, 0, 0.45)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Text {
        id: gearDisplay
        anchors.centerIn: parent
        text: root._gearText
        font.family: root._resolvedFont
        font.pixelSize: root.height * 0.70 * root.fontSizeMultiplier
        font.weight: Font.Black
        color: root.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Accessible.role: Accessible.Indicator
    Accessible.name: "AiM Gear Indicator"
    Accessible.description: root._gearText

    GaugeConfigMenu {
        id: configMenu
        target: root
        sections: [
            QtObject {
                property Component component: Component {
                    Column {
                        property Item target
                        spacing: 6
                        width: parent ? parent.width : 260

                        Text { text: "Datasource"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
                        Row {
                            spacing: 4
                            Text { text: "Gear:"; font.pixelSize: 12; color: "#CCC"; width: 50; verticalAlignment: Text.AlignVCenter }
                            ComboBox {
                                width: 190
                                model: DatasourceService.allSources
                                textRole: "titlename"
                                font.pixelSize: 12
                                Component.onCompleted: {
                                    for (var i = 0; i < model.count; ++i)
                                        if (DatasourceService.allSources.get(i).sourcename === root.mainvaluename)
                                            currentIndex = i;
                                }
                                onCurrentIndexChanged: {
                                    if (currentIndex >= 0) {
                                        root.mainvaluename = DatasourceService.allSources.get(currentIndex).sourcename;
                                        root.gearValue = Qt.binding(function() { return PropertyRouter.getValue(root.mainvaluename); });
                                    }
                                }
                            }
                        }

                        Text { text: "Colors"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF"; topPadding: 8 }
                        Row {
                            spacing: 4
                            Text { text: "Gear Color:"; font.pixelSize: 12; color: "#CCC"; width: 80; verticalAlignment: Text.AlignVCenter }
                            TextField { width: 140; text: root.textColor; font.pixelSize: 12; onEditingFinished: root.textColor = text }
                        }
                    }
                }
            }
        ]
    }
}
