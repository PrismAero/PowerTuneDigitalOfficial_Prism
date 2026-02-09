import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: widget
    width: 250
    height: 120
    color: visible && UI.Visibledashes >= index ? "#1E1E1E" : "transparent"
    radius: 8
    border.color: visible && UI.Visibledashes >= index ? "#3D3D3D" : "transparent"
    border.width: 1
    visible: UI.Visibledashes >= index
    opacity: visible ? 1 : 0

    Behavior on opacity { NumberAnimation { duration: 200 } }

    property alias currentIndex: cbox.currentIndex
    property int index
    property var linkedLoader

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        visible: UI.Visibledashes >= index

        Text {
            text: "Dash " + index
            font.pixelSize: 20
            font.weight: Font.DemiBold
            font.family: "Lato"
            color: "#009688"
        }

        ComboBox {
            id: cbox
            Layout.fillWidth: true
            height: 44
            font.pixelSize: 18
            font.family: "Lato"
            model: [
                "Main Dash", "GPS", "Laptimer", "PowerFC Sensors",
                "User Dash 1", "User Dash 2", "User Dash 3",
                "G-Force", "Mediaplayer", "Screen Toggle",
                "Drag Timer", "CAN monitor"
            ]

            onCurrentIndexChanged: {
                if (visible) linkedLoader.source = dashselector.getDashByIndex(currentIndex)
            }
            onVisibleChanged: {
                if (visible) linkedLoader.source = dashselector.getDashByIndex(currentIndex)
            }

            background: Rectangle {
                color: cbox.pressed ? "#3D3D3D" : "#2D2D2D"
                radius: 8
                border.color: cbox.activeFocus ? "#009688" : "#3D3D3D"
                border.width: 1
            }

            contentItem: Text {
                leftPadding: 12
                rightPadding: cbox.indicator.width + 12
                text: cbox.displayText
                font: cbox.font
                color: "#FFFFFF"
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }

            indicator: Canvas {
                id: canvas
                x: cbox.width - width - 12
                y: cbox.topPadding + (cbox.availableHeight - height) / 2
                width: 12
                height: 8
                contextType: "2d"

                Connections {
                    target: cbox
                    function onPressedChanged() { canvas.requestPaint() }
                }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.reset()
                    ctx.moveTo(0, 0)
                    ctx.lineTo(width, 0)
                    ctx.lineTo(width / 2, height)
                    ctx.closePath()
                    ctx.fillStyle = cbox.pressed ? "#009688" : "#B0B0B0"
                    ctx.fill()
                }
            }

            delegate: ItemDelegate {
                width: cbox.width
                height: 40

                contentItem: Text {
                    text: modelData
                    color: highlighted ? "#FFFFFF" : "#B0B0B0"
                    font.pixelSize: 18
                    font.family: "Lato"
                    font.weight: cbox.currentIndex === index ? Font.DemiBold : Font.Normal
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: highlighted ? "#009688" : (index % 2 === 0 ? "#2D2D2D" : "#252525")
                }

                highlighted: cbox.highlightedIndex === index
            }

            popup: Popup {
                y: cbox.height + 4
                width: cbox.width
                implicitHeight: Math.min(contentItem.implicitHeight + 8, 300)
                padding: 4

                contentItem: ListView {
                    clip: true
                    implicitHeight: contentHeight
                    model: cbox.popup.visible ? cbox.delegateModel : null
                    currentIndex: cbox.highlightedIndex
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
    }
}
