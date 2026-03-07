import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges.Shared 1.0
import PowerTune.Utils 1.0

Item {
    id: picture
    height: pictureheight
    width: pictureheight
    property string information: "gauge image"
    property string picturesource: ""
    property int pictureheight: 120
    property string increasedecreaseident

    Drag.active: true

    Image {
        anchors.fill: parent
        id: mypicture
        fillMode: Image.PreserveAspectFit
        source: picturesource
    }

    GaugeMouseHandler {
        id: mouseHandler
        dragTarget: picture
        onConfigRequested: function(mx, my) { configMenu.show(mx, my); }
    }

    GaugeConfigMenu {
        id: configMenu
        target: picture
        onDeleteRequested: picture.destroy()

        SizeSection { target: picture }
        ImagePickerSection {
            target: picture
            targetProperty: "picturesource"
            showHeightControl: false
            title: "Image"
        }
    }
}
