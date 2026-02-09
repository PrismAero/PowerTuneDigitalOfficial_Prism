import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges 1.0
import PowerTune.Utils 1.0

Item {
    id: picture
    height: pictureheight
    width : pictureheight
    property string information: "gauge image"
    property string picturesource
    property int pictureheight
    //property int picturewidth
    property string increasedecreaseident
    
    // * Double-tap detection properties
    property int touchCounter: 0
    property real lastTouchTime: 0
    
    Drag.active: true
    Component.onCompleted: togglemousearea();

    Connections{
        target: UI
        function onDraggableChanged() { togglemousearea(); }
    }

    Image {
        anchors.fill: parent
        id: mypicture
        fillMode: Image.PreserveAspectFit
        source:  picturesource
    }
    // MouseArea {
    //     id: touchArea
    //     anchors.fill: parent
    //     drag.target: parent
    //     enabled: false
    //     onDoubleClicked: {
    //         changesize.visible = true;
    //         Connect.readavailablebackrounds();
    //     }
    // }

    MouseArea {
        id: touchArea
        anchors.fill: parent
        drag.target: parent
        enabled: false
        z: 100  // * Higher z-order to receive events over dashboard background
        onPressed: function(mouse) {
            touchCounter++;
            if (touchCounter == 1) {
                lastTouchTime = Date.now();
                timerDoubleClick.restart();
            } else if (touchCounter == 2) {
                var currentTime = Date.now();
                if (currentTime - lastTouchTime <= 500) { // Double-tap detected within 500 ms
                    console.log("Picture double-tap detected at", mouse.x, mouse.y);
                }
                touchCounter = 0;
                timerDoubleClick.stop();
                changesize.visible = true;
                Connect.readavailablebackrounds();
            }
        }
        Component.onCompleted: {
            toggledecimal();
            toggledecimal2();
            // * Check initial draggable state since gauge may be created after edit mode is enabled
            togglemousearea();
        }
    }
    Timer {
        id: timerDoubleClick
        interval: 500
        running: false
        repeat: false
        onTriggered: {
            touchCounter = 0; // Reset counter if time interval exceeds 500 ms
        }
    }

    Rectangle{
        id : changesize
        color: "darkgrey"
        visible: false
        width : 200
        height : 150
        x: 0
        y: 0
        z: 201         //ensure the Menu is always in the foreground
        Drag.active: true
        onVisibleChanged: {
            changesize.x= -picture.x;
            changesize.y= -picture.y;
        }
        MouseArea {
            anchors.fill: parent
            drag.target: parent
            enabled: true
        }

        Grid { width: parent.width
            height:parent.height
            rows: 4
            columns: 1
            rowSpacing :5
            Grid {
                rows: 1
                columns: 3
                rowSpacing :5
                RoundButton{text: "-"
                    width: changesize.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasePicture"}
                    onReleased: {timer.running = false;}
                    onClicked: {pictureheight--}
                }
                Text{id: sizeTxt
                    text: pictureheight
                    font.pixelSize: 15
                    width: changesize.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: pictureheight = sizeTxt.text
                }
                RoundButton{ text: "+"
                    width: changesize.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasePicture"}
                    onReleased: {timer.running = false;}
                    onClicked: {pictureheight++}
                }
            }
            ComboBox {
                id: pictureSelector
                width: 200
                height: 40
                font.pixelSize: 15
                model: UI.backroundpictures
                currentIndex: 0
                onCurrentIndexChanged: {
                    // * Use platform-aware path for images
                    var selectedFile = pictureSelector.textAt(pictureSelector.currentIndex);
                    if (Qt.platform.os === "linux") {
                        picturesource = "file:///home/pi/Logo/" + selectedFile;
                    } else if (Qt.platform.os === "osx") {
                        picturesource = "qrc:/Resources/graphics/" + selectedFile;
                    } else if (Qt.platform.os === "windows") {
                        picturesource = "file:///c:/Logo/" + selectedFile;
                    } else {
                        picturesource = "file:" + selectedFile;
                    }
                    mypicture.source = picturesource;
                }
                delegate: ItemDelegate {
                    width: pictureSelector.width
                    text: pictureSelector.textRole ? (Array.isArray(pictureSelector.model) ? modelData[pictureSelector.textRole] : model[pictureSelector.textRole]) : modelData
                    font.weight: pictureSelector.currentIndex === index ? Font.DemiBold : Font.Normal
                    font.family: pictureSelector.font.family
                    font.pixelSize: pictureSelector.font.pixelSize
                    highlighted: pictureSelector.highlightedIndex === index
                    hoverEnabled: pictureSelector.hoverEnabled
                }
            }
            RoundButton{
                width: parent.width
                text: Translator.translate("Delete image", Settings.language)
                font.pixelSize: 15
                onClicked: picture.destroy();
            }
            RoundButton{
                width: parent.width
                text: Translator.translate("Close", Settings.language)
                onClicked: changesize.visible = false;
            }
        }
    }

    Item {
        Timer {
            id: timer
            interval: 50; running: false; repeat: true
            onTriggered: {increaseDecrease()}
        }

        Text { id: time }
    }
    function togglemousearea()
    {
    //    console.log("toggle" + UI.draggable);
        if (UI.draggable === 1)
        {
            touchArea.enabled = true;
        }
        else
            touchArea.enabled = false;
    }
    
    // * Placeholder functions for decimal formatting (not used by Picture)
    function toggledecimal() {
        // ! Picture doesn't have decimal display fields, this is a no-op
    }
    
    function toggledecimal2() {
        // ! Picture doesn't have decimal display fields, this is a no-op
    }
    function increaseDecrease()
    {
        //console.log("ident "+ increasedecreaseident);
        switch(increasedecreaseident)
        {

        case "increasePicture": {
            pictureheight++;
            //picturewidth++;
            break;
        }
        case "decreasePicture": {
            pictureheight--;
            //picturewidth--;
            break;
        }
        }
    }
}
