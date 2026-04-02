import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: root

    font.family: SettingsTheme.fontFamily
    font.pixelSize: SettingsTheme.fontControl
    implicitHeight: SettingsTheme.controlHeight
    implicitWidth: internal.computedWidth

    background: Rectangle {
        border.color: root.activeFocus ? SettingsTheme.accent : SettingsTheme.border
        border.width: root.activeFocus ? 2 : SettingsTheme.borderWidth
        color: root.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
        radius: SettingsTheme.radiusSmall

        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }
    contentItem: Text {
        bottomPadding: 4
        color: SettingsTheme.textPrimary
        elide: Text.ElideRight
        font: root.font
        leftPadding: 12
        rightPadding: root.indicator.width + 12
        text: root.displayText
        topPadding: 4
        verticalAlignment: Text.AlignVCenter
    }
    delegate: ItemDelegate {
        highlighted: root.highlightedIndex === index
        implicitHeight: SettingsTheme.controlHeight
        width: root.width

        background: Rectangle {
            color: highlighted ? SettingsTheme.accent : (index % 2 === 0 ? SettingsTheme.controlBg :
                                                                           SettingsTheme.surfaceElevated)
        }
        contentItem: Text {
            id: delegateText

            bottomPadding: 4
            color: highlighted ? SettingsTheme.textPrimary : SettingsTheme.textSecondary
            elide: Text.ElideRight
            font.family: SettingsTheme.fontFamily
            font.pixelSize: SettingsTheme.fontControl
            font.weight: root.currentIndex === index ? Font.DemiBold : Font.Normal
            leftPadding: 12
            text: root.textRole ? (Array.isArray(root.model) ? modelData[root.textRole] : model[root.textRole]) :
                                  modelData
            topPadding: 4
            verticalAlignment: Text.AlignVCenter
        }
    }
    indicator: Canvas {
        id: canvas

        contextType: "2d"
        height: 8
        width: 12
        x: root.width - width - 14
        y: root.topPadding + (root.availableHeight - height) / 2

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.moveTo(0, 0);
            ctx.lineTo(width, 0);
            ctx.lineTo(width / 2, height);
            ctx.closePath();
            ctx.fillStyle = root.pressed ? SettingsTheme.accent : SettingsTheme.textSecondary;
            ctx.fill();
        }

        Connections {
            function onPressedChanged() {
                canvas.requestPaint();
            }

            target: root
        }
    }
    popup: Popup {
        implicitHeight: Math.min(contentItem.implicitHeight + 8, 300)
        padding: 4
        width: root.width
        y: root.height + 4

        background: Rectangle {
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth
            color: SettingsTheme.surfaceElevated
            radius: SettingsTheme.radiusLarge
        }
        contentItem: ListView {
            clip: true
            currentIndex: root.highlightedIndex
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null

            ScrollIndicator.vertical: ScrollIndicator {
            }
        }
    }

    FontMetrics {
        id: fontMetrics

        font: root.font
    }

    QtObject {
        id: internal

        property real computedWidth: {
            var maxW = 0;
            if (root.model) {
                var count = root.model.length !== undefined ? root.model.length : root.count;
                for (var i = 0; i < count; ++i) {
                    var txt = "";
                    if (root.model.length !== undefined)
                        txt = root.model[i];
                    else
                        txt = root.textAt(i);
                    var w = fontMetrics.advanceWidth(txt);
                    if (w > maxW)
                        maxW = w;
                }
            }
            return Math.max(SettingsTheme.comboBoxMinWidth, maxW + 16 + 12 + 14 + 24);
        }
    }
}
