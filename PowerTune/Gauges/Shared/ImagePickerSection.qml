import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target
    property string targetProperty: "picturesource"
    property bool showHeightControl: true
    property string title: "Image"

    function buildImagePath(fileName) {
        if (Qt.platform.os === "linux")
            return "file:///home/pi/Logo/" + fileName;
        if (Qt.platform.os === "osx")
            return "qrc:/Resources/graphics/" + fileName;
        if (Qt.platform.os === "windows")
            return "file:///c:/Logo/" + fileName;
        return "file:" + fileName;
    }

    Component.onCompleted: {
        Connect.readavailablebackrounds();
    }

    Text {
        text: root.title
        font.bold: true
        color: "white"
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root.showHeightControl && root.target && root.target.pictureheight !== undefined
        Label { text: "Height"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root.target && root.target.pictureheight !== undefined ? root.target.pictureheight : 0
            stepSize: 10
            minValue: 20
            maxValue: 2000
            onValueChanged: function(v) { if (root.target) root.target.pictureheight = v; }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        Label { text: "Source"; color: "white" }
        ComboBox {
            id: sourceBox
            Layout.fillWidth: true
            model: UI.backroundpictures
            onActivated: {
                if (!root.target)
                    return;
                var fileName = textAt(currentIndex);
                root.target[root.targetProperty] = root.buildImagePath(fileName);
            }
        }
    }
}
