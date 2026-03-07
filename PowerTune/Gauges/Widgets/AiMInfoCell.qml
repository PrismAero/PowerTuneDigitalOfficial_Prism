import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Shapes 1.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: root
    width: 200
    height: 90

    property string information: "AiM info cell"
    property string mainvaluename
    property double mainvalue: 0
    property double warnvaluehigh: 20000
    property double warnvaluelow: -20000
    property int decimalpoints: 2
    property string unittext: ""
    property string labeltext: ""
    property string footerText: ""
    property string customValueText: ""
    property string displayMode: "number"
    property string neutralText: "N"
    property string reverseText: "R"
    property bool showLabel: true
    property bool showUnit: true
    property bool showFooter: true
    property bool alignRight: false
    property bool configMenuEnabled: true
    property color labelColor: GaugeTheme.aimLabelGrey
    property color unitColor: GaugeTheme.aimUnitGrey
    property color valueColor: GaugeTheme.aimValueWhite
    property color borderColor: GaugeTheme.aimCellBorder
    property color bgColor: GaugeTheme.aimPanelOuter
    property string fontFamily: ""
    property string increasedecreaseident

    FontLoader {
        id: regularFont
        source: "qrc:/Resources/fonts/hyperspacerace-regular.otf"
    }
    FontLoader {
        id: condensedBoldFont
        source: "qrc:/Resources/fonts/hyperspacerace-condensedbold.otf"
    }
    FontLoader {
        id: boldFont
        source: "qrc:/Resources/fonts/hyperspacerace-bold.otf"
    }

    readonly property string _resolvedRegularFont: fontFamily !== "" ? fontFamily : regularFont.name
    readonly property string _resolvedCondensedFont: fontFamily !== "" ? fontFamily : condensedBoldFont.name
    readonly property string _resolvedBoldFont: fontFamily !== "" ? fontFamily : boldFont.name
    readonly property real _bevel: Math.max(10, Math.min(width, height) * 0.12)
    readonly property real _outerMargin: 1
    readonly property string _displayValue: {
        if (customValueText !== "")
            return customValueText;
        if (!isFinite(mainvalue))
            return "--";
        if (displayMode === "gear") {
            var gear = Math.round(mainvalue);
            if (gear === 0)
                return neutralText;
            if (gear < 0)
                return reverseText;
            return gear.toString();
        }
        return Number(mainvalue).toFixed(decimalpoints);
    }

    function _bindValue() {
        if (mainvaluename)
            mainvalue = Qt.binding(function () {
                return PropertyRouter.getValue(mainvaluename);
            });
    }

    Component.onCompleted: _bindValue()
    onMainvaluenameChanged: _bindValue()

    MouseArea {
        anchors.fill: parent
        property real _lastTapTime: 0
        onPressed: function (mouse) {
            var now = Date.now();
            if (root.configMenuEnabled && now - _lastTapTime < 360) {
                _lastTapTime = 0;
                configMenu.show(mouse.x, mouse.y);
            } else {
                _lastTapTime = now;
            }
        }
    }

    Rectangle {
        x: 0
        y: 5
        width: parent.width
        height: parent.height
        color: GaugeTheme.aimPanelShadow
        radius: 12
        opacity: 0.55
    }

    Shape {
        anchors.fill: parent
        antialiasing: true

        ShapePath {
            strokeWidth: 1
            strokeColor: root.borderColor
            fillColor: root.bgColor
            startX: root.alignRight ? root._bevel : 0
            startY: 0
            PathLine {
                x: root.alignRight ? root.width : root.width - root._bevel
                y: 0
            }
            PathLine {
                x: root.alignRight ? root.width : root.width
                y: root.alignRight ? 0 : root._bevel
            }
            PathLine {
                x: root.width
                y: root.alignRight ? root.height : root.height - root._bevel
            }
            PathLine {
                x: root.alignRight ? root._bevel : root.width - root._bevel
                y: root.height
            }
            PathLine {
                x: 0
                y: root.alignRight ? root.height - root._bevel : root.height
            }
            PathLine {
                x: 0
                y: root.alignRight ? root._bevel : 0
            }
            PathLine { x: root.alignRight ? root._bevel : 0; y: 0 }
        }
    }

    Shape {
        anchors.fill: parent
        antialiasing: true
        opacity: 0.95

        ShapePath {
            strokeWidth: 1
            strokeColor: GaugeTheme.aimPanelStrokeSoft
            fillColor: GaugeTheme.aimPanelInset
            startX: root.alignRight ? root._bevel + 8 : 8
            startY: 8
            PathLine {
                x: root.alignRight ? root.width - 8 : root.width - root._bevel - 8
                y: 8
            }
            PathLine {
                x: root.alignRight ? root.width - 8 : root.width - 8
                y: root.alignRight ? 8 : root._bevel + 8
            }
            PathLine {
                x: root.width - 8
                y: root.alignRight ? root.height - 8 : root.height - root._bevel - 8
            }
            PathLine {
                x: root.alignRight ? root._bevel + 8 : root.width - root._bevel - 8
                y: root.height - 8
            }
            PathLine {
                x: 8
                y: root.alignRight ? root.height - root._bevel - 8 : root.height - 8
            }
            PathLine {
                x: 8
                y: root.alignRight ? root._bevel + 8 : 8
            }
            PathLine { x: root.alignRight ? root._bevel + 8 : 8; y: 8 }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Math.max(26, parent.height * 0.34)
        color: "transparent"
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: GaugeTheme.aimPanelGloss
            }
            GradientStop {
                position: 0.55
                color: GaugeTheme.aimPanelGlossSoft
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
        opacity: 0.9
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: GaugeTheme.aimPanelStrokeBright
        opacity: 0.45
    }

    Item {
        id: content
        anchors.fill: parent
        anchors.leftMargin: root.alignRight ? 18 : 14
        anchors.rightMargin: root.alignRight ? 14 : 18
        anchors.topMargin: 10
        anchors.bottomMargin: 10

        Text {
            id: labelField
            anchors.top: parent.top
            anchors.left: root.alignRight ? undefined : parent.left
            anchors.right: root.alignRight ? parent.right : undefined
            width: parent.width * 0.82
            horizontalAlignment: root.alignRight ? Text.AlignRight : Text.AlignLeft
            text: root.labeltext
            font.pixelSize: Math.max(14, root.height * 0.15)
            font.family: root._resolvedCondensedFont
            font.weight: Font.DemiBold
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1.1
            color: root.labelColor
            elide: Text.ElideRight
            visible: root.showLabel && text.length > 0
        }

        Text {
            id: valueField
            anchors.top: labelField.bottom
            anchors.topMargin: Math.max(2, root.height * 0.08)
            anchors.left: root.alignRight ? undefined : parent.left
            anchors.right: root.alignRight ? parent.right : undefined
            width: parent.width
            horizontalAlignment: root.alignRight ? Text.AlignRight : Text.AlignLeft
            text: root._displayValue
            font.pixelSize: Math.max(30, root.height * (root.footerText !== "" ? 0.40 : 0.46))
            font.family: root._resolvedBoldFont
            font.weight: Font.Bold
            font.italic: false
            font.letterSpacing: 0.5
            color: root.valueColor
            elide: Text.ElideRight
        }

        Text {
            id: unitField
            anchors.top: valueField.bottom
            anchors.topMargin: -Math.max(2, root.height * 0.03)
            anchors.left: root.alignRight ? undefined : parent.left
            anchors.right: root.alignRight ? parent.right : undefined
            width: parent.width
            horizontalAlignment: root.alignRight ? Text.AlignRight : Text.AlignLeft
            text: root.unittext
            font.pixelSize: Math.max(12, root.height * 0.14)
            font.family: root._resolvedRegularFont
            font.weight: Font.Medium
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 1.6
            color: root.unitColor
            visible: root.showUnit && text.length > 0
        }

        Text {
            anchors.left: root.alignRight ? undefined : parent.left
            anchors.right: root.alignRight ? parent.right : undefined
            anchors.bottom: parent.bottom
            width: parent.width
            horizontalAlignment: root.alignRight ? Text.AlignRight : Text.AlignLeft
            text: root.footerText
            font.pixelSize: Math.max(10, root.height * 0.11)
            font.family: root._resolvedRegularFont
            font.capitalization: Font.AllUppercase
            font.letterSpacing: 0.8
            color: GaugeTheme.aimTextMuted
            visible: root.showFooter && text.length > 0
        }
    }

    Shape {
        anchors.fill: parent
        antialiasing: true
        opacity: 0
        visible: opacity > 0

        SequentialAnimation on opacity {
            running: root.mainvalue > root.warnvaluehigh || root.mainvalue < root.warnvaluelow
            loops: Animation.Infinite
            NumberAnimation {
                to: 0.9
                duration: GaugeTheme.warningFlashDuration
            }
            NumberAnimation {
                to: 0.0
                duration: GaugeTheme.warningFlashDuration
            }
        }

        ShapePath {
            strokeWidth: 2
            strokeColor: GaugeTheme.aimArcRed
            fillColor: "transparent"
            startX: root.alignRight ? root._bevel : 0
            startY: 0
            PathLine {
                x: root.alignRight ? root.width : root.width - root._bevel
                y: 0
            }
            PathLine {
                x: root.alignRight ? root.width : root.width
                y: root.alignRight ? 0 : root._bevel
            }
            PathLine {
                x: root.width
                y: root.alignRight ? root.height : root.height - root._bevel
            }
            PathLine {
                x: root.alignRight ? root._bevel : root.width - root._bevel
                y: root.height
            }
            PathLine {
                x: 0
                y: root.alignRight ? root.height - root._bevel : root.height
            }
            PathLine {
                x: 0
                y: root.alignRight ? root._bevel : 0
            }
            PathLine { x: root.alignRight ? root._bevel : 0; y: 0 }
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

                        Text {
                            text: "Datasource"
                            font.bold: true
                            font.pixelSize: 13
                            color: "#FFFFFF"
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Source:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 50
                                verticalAlignment: Text.AlignVCenter
                            }
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
                                        root.mainvalue = Qt.binding(function () {
                                            return PropertyRouter.getValue(root.mainvaluename);
                                        });
                                    }
                                }
                            }
                        }

                        Text {
                            text: "Display"
                            font.bold: true
                            font.pixelSize: 13
                            color: "#FFFFFF"
                            topPadding: 8
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Label:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            TextField {
                                width: 140
                                text: root.labeltext
                                font.pixelSize: 12
                                onTextChanged: root.labeltext = text
                            }
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Unit:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            TextField {
                                width: 140
                                text: root.unittext
                                font.pixelSize: 12
                                onTextChanged: root.unittext = text
                            }
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Decimals:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            SpinBox {
                                from: 0
                                to: 6
                                value: root.decimalpoints
                                onValueChanged: root.decimalpoints = value
                            }
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Mode:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            ComboBox {
                                width: 140
                                model: ["number", "gear"]
                                Component.onCompleted: currentIndex = Math.max(0, model.indexOf(root.displayMode))
                                onActivated: root.displayMode = model[index]
                            }
                        }
                        Switch {
                            text: "Visible"
                            checked: root.visible
                            onCheckedChanged: root.visible = checked
                        }
                        Switch {
                            text: "Show label"
                            checked: root.showLabel
                            onCheckedChanged: root.showLabel = checked
                        }
                        Switch {
                            text: "Show unit"
                            checked: root.showUnit
                            onCheckedChanged: root.showUnit = checked
                        }
                        Switch {
                            text: "Show footer"
                            checked: root.showFooter
                            onCheckedChanged: root.showFooter = checked
                        }
                        Switch {
                            text: "Right align"
                            checked: root.alignRight
                            onCheckedChanged: root.alignRight = checked
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Footer:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            TextField {
                                width: 140
                                text: root.footerText
                                font.pixelSize: 12
                                onTextChanged: root.footerText = text
                            }
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Custom:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            TextField {
                                width: 140
                                text: root.customValueText
                                font.pixelSize: 12
                                onTextChanged: root.customValueText = text
                            }
                        }

                        Text {
                            text: "Colors"
                            font.bold: true
                            font.pixelSize: 13
                            color: "#FFFFFF"
                            topPadding: 8
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Value:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            TextField {
                                width: 140
                                text: root.valueColor
                                font.pixelSize: 12
                                onEditingFinished: root.valueColor = text
                            }
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Label:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            TextField {
                                width: 140
                                text: root.labelColor
                                font.pixelSize: 12
                                onEditingFinished: root.labelColor = text
                            }
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Unit:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            TextField {
                                width: 140
                                text: root.unitColor
                                font.pixelSize: 12
                                onEditingFinished: root.unitColor = text
                            }
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Border:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            TextField {
                                width: 140
                                text: root.borderColor
                                font.pixelSize: 12
                                onEditingFinished: root.borderColor = text
                            }
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Background:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            TextField {
                                width: 140
                                text: root.bgColor
                                font.pixelSize: 12
                                onEditingFinished: root.bgColor = text
                            }
                        }

                        Text {
                            text: "Warnings"
                            font.bold: true
                            font.pixelSize: 13
                            color: "#FFFFFF"
                            topPadding: 8
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Warn High:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            SpinBox {
                                from: -99999
                                to: 99999
                                value: root.warnvaluehigh
                                editable: true
                                onValueChanged: root.warnvaluehigh = value
                            }
                        }
                        Row {
                            spacing: 4
                            Text {
                                text: "Warn Low:"
                                font.pixelSize: 12
                                color: "#CCC"
                                width: 80
                                verticalAlignment: Text.AlignVCenter
                            }
                            SpinBox {
                                from: -99999
                                to: 99999
                                value: root.warnvaluelow
                                editable: true
                                onValueChanged: root.warnvaluelow = value
                            }
                        }
                    }
                }
            }
        ]
    }
}
