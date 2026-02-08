import QtQuick 2.15

Rectangle {
    id: intro
    anchors.fill : parent
    color: "black"
    Image {
        width: parent.width
        height: parent.height
        fillMode: Image.PreserveAspectFit
        source: "file:///home/pi/Logo/Logo.png"
    }
}
