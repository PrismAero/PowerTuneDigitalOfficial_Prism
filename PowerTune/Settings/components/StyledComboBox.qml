import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: root

    implicitWidth: internal.computedWidth
    implicitHeight: Math.max(SettingsTheme.controlHeight, fontMetrics.height + 24)
    font.pixelSize: SettingsTheme.fontControl
    font.family: SettingsTheme.fontFamily

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
                    if (w > maxW) maxW = w;
                }
            }
            return Math.max(SettingsTheme.comboBoxMinWidth, maxW + 16 + 12 + 14 + 24);
        }
    }

    background: Rectangle {
        color: root.pressed ? SettingsTheme.surfacePressed : SettingsTheme.controlBg
        radius: SettingsTheme.radiusSmall
        border.color: root.activeFocus ? SettingsTheme.accent : SettingsTheme.border
        border.width: root.activeFocus ? 2 : SettingsTheme.borderWidth

        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    contentItem: Text {
        leftPadding: 16
        rightPadding: root.indicator.width + 16
        topPadding: 10
        bottomPadding: 10
        text: root.displayText
        font: root.font
        color: SettingsTheme.textPrimary
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Canvas {
        id: canvas
        x: root.width - width - 14
        y: root.topPadding + (root.availableHeight - height) / 2
        width: 12
        height: 8
        contextType: "2d"

        Connections {
            target: root
            function onPressedChanged() { canvas.requestPaint() }
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.moveTo(0, 0)
            ctx.lineTo(width, 0)
            ctx.lineTo(width / 2, height)
            ctx.closePath()
            ctx.fillStyle = root.pressed ? SettingsTheme.accent : SettingsTheme.textSecondary
            ctx.fill()
        }
    }

    delegate: ItemDelegate {
        width: root.width
        implicitHeight: delegateText.implicitHeight + 16

        contentItem: Text {
            id: delegateText
            text: root.textRole ? (Array.isArray(root.model) ? modelData[root.textRole] : model[root.textRole]) : modelData
            color: highlighted ? SettingsTheme.textPrimary : SettingsTheme.textSecondary
            font.pixelSize: SettingsTheme.fontControl
            font.family: SettingsTheme.fontFamily
            font.weight: root.currentIndex === index ? Font.DemiBold : Font.Normal
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
            leftPadding: 16
            topPadding: 8
            bottomPadding: 8
        }

        background: Rectangle {
            color: highlighted ? SettingsTheme.accent : (index % 2 === 0 ? SettingsTheme.controlBg : SettingsTheme.surfaceElevated)
        }

        highlighted: root.highlightedIndex === index
    }

    popup: Popup {
        y: root.height + 4
        width: root.width
        implicitHeight: Math.min(contentItem.implicitHeight + 8, 300)
        padding: 4

        contentItem: ListView {
            clip: true
            implicitHeight: contentHeight
            model: root.popup.visible ? root.delegateModel : null
            currentIndex: root.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }

        background: Rectangle {
            color: SettingsTheme.surfaceElevated
            radius: SettingsTheme.radiusLarge
            border.color: SettingsTheme.border
            border.width: SettingsTheme.borderWidth
        }
    }
}
