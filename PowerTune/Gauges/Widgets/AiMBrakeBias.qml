import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: root
    width: 443
    height: 165

    property string information: "AiM brake bias"
    property string brakeBiasSource: "BrakeBias"
    property real brakeBiasValue: 0.5
    property string titleText: "BRAKE BIAS"
    property string leftLabel: "RWD"
    property string rightLabel: "FWD"
    property bool configMenuEnabled: true
    property string increasedecreaseident

    readonly property real _barHeight: root.height * 0.267
    readonly property real _barY: root.height * 0.55
    readonly property real _markerX: biasBar.x + biasBar.width * root.brakeBiasValue

    FontLoader { id: titleFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }
    FontLoader { id: labelFont; source: "qrc:/Resources/fonts/hyperspacerace-regular.otf" }

    function _bindValue() {
        if (brakeBiasSource)
            brakeBiasValue = Qt.binding(function() { return PropertyRouter.getValue(brakeBiasSource); });
    }

    Component.onCompleted: _bindValue()
    onBrakeBiasSourceChanged: _bindValue()

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

    Text {
        id: titleLabel
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        text: root.titleText
        font.family: titleFont.name
        font.pixelSize: root.height * 0.29
        font.italic: true
        color: "#FFFFFF"
        horizontalAlignment: Text.AlignHCenter
    }

    Text {
        id: leftText
        anchors.left: biasBar.left
        anchors.bottom: biasBar.top
        anchors.bottomMargin: root.height * 0.02
        text: root.leftLabel
        font.family: labelFont.name
        font.pixelSize: root.height * 0.21
        color: "#FFFFFF"
    }

    Text {
        id: rightText
        anchors.right: biasBar.right
        anchors.bottom: biasBar.top
        anchors.bottomMargin: root.height * 0.02
        text: root.rightLabel
        font.family: labelFont.name
        font.pixelSize: root.height * 0.21
        color: "#FFFFFF"
        horizontalAlignment: Text.AlignRight
    }

    Rectangle {
        id: biasBar
        anchors.horizontalCenter: parent.horizontalCenter
        y: root._barY
        width: root.width
        height: root._barHeight
        radius: height * 0.098
        clip: true

        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: "#FF7C09" }
            GradientStop { position: 0.5; color: "#1ED033" }
            GradientStop { position: 1.0; color: "#FF7C09" }
        }
    }

    Item {
        id: marker
        x: root._markerX - width / 2
        y: biasBar.y - height * 0.05
        width: 14
        height: biasBar.height + root.height * 0.30

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 3
            height: parent.height
            color: "#FFFFFF"
        }

        Canvas {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: 14
            height: 10
            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.fillStyle = "#FFFFFF";
                ctx.beginPath();
                ctx.moveTo(width / 2, height);
                ctx.lineTo(0, 0);
                ctx.lineTo(width, 0);
                ctx.closePath();
                ctx.fill();
            }
        }
    }

    Accessible.role: Accessible.Indicator
    Accessible.name: root.titleText || root.information
    Accessible.description: (root.brakeBiasValue * 100).toFixed(0) + "%"

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

                        Text { text: "Brake Bias"; font.bold: true; font.pixelSize: 13; color: "#FFFFFF" }
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
                                        if (DatasourceService.allSources.get(i).sourcename === root.brakeBiasSource) {
                                            currentIndex = i; break;
                                        }
                                    }
                                }
                                onCurrentIndexChanged: {
                                    if (currentIndex >= 0)
                                        root.brakeBiasSource = DatasourceService.allSources.get(currentIndex).sourcename;
                                }
                            }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Title:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
                            TextField { width: 190; text: root.titleText; font.pixelSize: 12; onTextChanged: root.titleText = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Left:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
                            TextField { width: 190; text: root.leftLabel; font.pixelSize: 12; onTextChanged: root.leftLabel = text }
                        }
                        Row {
                            spacing: 4
                            Text { text: "Right:"; font.pixelSize: 12; color: "#CCC"; width: 60 }
                            TextField { width: 190; text: root.rightLabel; font.pixelSize: 12; onTextChanged: root.rightLabel = text }
                        }
                        Switch { text: "Visible"; checked: root.visible; onCheckedChanged: root.visible = checked }
                    }
                }
            }
        ]
    }
}
