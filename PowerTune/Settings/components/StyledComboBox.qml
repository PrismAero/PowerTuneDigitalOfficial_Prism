import QtQuick 2.15
import QtQuick.Controls 2.15

// * StyledComboBox - Dark themed dropdown with proper sizing

ComboBox {
    id: root

    width: 280
    height: 44
    font.pixelSize: 20
    font.family: "Lato"

    background: Rectangle {
        color: root.pressed ? "#3D3D3D" : "#2D2D2D"
        radius: 8
        border.color: root.activeFocus ? "#009688" : "#3D3D3D"
        border.width: root.activeFocus ? 2 : 1

        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    contentItem: Text {
        leftPadding: 12
        rightPadding: root.indicator.width + 12
        text: root.displayText
        font: root.font
        color: "#FFFFFF"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Canvas {
        id: canvas
        x: root.width - width - 12
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
            ctx.fillStyle = root.pressed ? "#009688" : "#B0B0B0"
            ctx.fill()
        }
    }

    delegate: ItemDelegate {
        width: root.width
        height: 44

        contentItem: Text {
            text: root.textRole ? (Array.isArray(root.model) ? modelData[root.textRole] : model[root.textRole]) : modelData
            color: highlighted ? "#FFFFFF" : "#B0B0B0"
            font.pixelSize: 20
            font.family: "Lato"
            font.weight: root.currentIndex === index ? Font.DemiBold : Font.Normal
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            color: highlighted ? "#009688" : (index % 2 === 0 ? "#2D2D2D" : "#252525")
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
            color: "#1E1E1E"
            radius: 8
            border.color: "#3D3D3D"
            border.width: 1
        }
    }
}
