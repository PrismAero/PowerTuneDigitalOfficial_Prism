import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.Gauges 1.0
import PowerTune.Utils 1.0
Item {
    id: statepicture
    height: pictureheight
    width : pictureheight
    property string information: "State gauge"
    property string statepicturesourceoff
    property string statepicturesourceon
    property int pictureheight//: 480 * 0.25
    property int picturewidth//: 800 * 0.2
    property string increasedecreaseident
    property string mainvaluename
    property double triggervalue : 0
    
    // * Double-tap detection properties
    property int touchCounter: 0
    property real lastTouchTime: 0
    
    Drag.active: true
    x: 200
    y: 200
    DatasourcesList{id: powertunedatasource}
    Component.onCompleted: {togglemousearea();
                            bind();
                            }


    Connections{
        target: UI
        function onDraggableChanged() { togglemousearea(); }
        function onBackroundpicturesChanged() { updatppiclist(); }
    }

    Image {
        anchors.fill: parent
        id: statepictureoff
        fillMode: Image.PreserveAspectFit
        source:  statepicturesourceoff
        visible: true
    }
    Image {
        anchors.fill: parent
        id: statepictureon
        fillMode: Image.PreserveAspectFit
        source:  statepicturesourceon
        visible: false
    }
    Text {
        id: mainvaluetextfield
        visible: false
        onTextChanged: {
            warningindication.warn();
        }
    }
    // MouseArea {
    //     id: touchArea
    //     anchors.fill: parent
    //     drag.target: parent
    //     enabled: false
    //     onDoubleClicked: {
    //         changesize.visible = true;
    //         Connect.readavailablebackrounds();
    //         changesize.x= -statepicture.x;
    //         changesize.y= -statepicture.y;
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
                    console.log("StatePicture double-tap detected at", mouse.x, mouse.y);
                }
                touchCounter = 0;
                timerDoubleClick.stop();
                changesize.visible = true;
                Connect.readavailablebackrounds();
                changesize.x= -statepicture.x;
                changesize.y= -statepicture.y;
            }
        }
        Component.onCompleted: {
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
        width : 800 * 0.2875//230 Taking the resolution from the 7" and dividing it by (230/screenWidth)
        height : 480 * 0.667//320 Taking the resolution from the 7" and dividing it by (230/screenHeight)
        x: statepicture.x
        y: statepicture.y
        Drag.active: true
        MouseArea {
            anchors.fill: parent
            drag.target: parent
            enabled: true
        }
        Grid {
            width: parent.width
            height: parent.height
            rows: 7
            columns: 1
            rowSpacing :5
            Grid {
                rows: 1
                columns: 3
                width: parent.width
                rowSpacing: 5

                RoundButton{text: "-"
                    width: changesize.width / 3.2
                    font.pixelSize: 800 * (15 / 800)
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "decreasePicture"}
                    onReleased: {timer.running = false;}
                    onClicked: {pictureheight-- && picturewidth--}
                }
                Text{id: sizeTxt
                    text: pictureheight
                    font.pixelSize: 800 * (15 / 800)
                    width: changesize.width /3.2
                    horizontalAlignment: Text.AlignHCenter
                    onTextChanged: {pictureheight = sizeTxt.text}
                }
                RoundButton{ text: "+"
                    font.pixelSize: 800 * (15 / 800)
                    width: changesize.width /3.2
                    onPressAndHold: {timer.running = true;
                        increasedecreaseident = "increasePicture"}
                    onReleased: {timer.running = false;}
                    onClicked: {pictureheight++ && picturewidth++}
                }
            }
            Grid {
                id: valueGrid
                rows: 4
                columns: 2
                spacing :5
            Text{
                text: Translator.translate("Image", Settings.language) + " " + Translator.translate("OFF", Settings.language)
                font.pixelSize: 800 * (12 / 800)

            }

            ComboBox {
                id: pictureSelectoroff
                width: 800 * 0.175 //140
                height: 480 * 0.083 //40
                font.pixelSize: 800 * (12 / 800) //12 being the font size. 800 being 7" screen width
                model: UI.backroundpictures
                currentIndex: 0
                onCurrentIndexChanged: {
                    // * Use platform-aware path for images
                    var selectedFile = pictureSelectoroff.textAt(pictureSelectoroff.currentIndex);
                    if (Qt.platform.os === "linux") {
                        statepicturesourceoff = "file:///home/pi/Logo/" + selectedFile;
                    } else if (Qt.platform.os === "osx") {
                        statepicturesourceoff = "qrc:/Resources/graphics/" + selectedFile;
                    } else if (Qt.platform.os === "windows") {
                        statepicturesourceoff = "file:///c:/Logo/" + selectedFile;
                    } else {
                        statepicturesourceoff = "file:" + selectedFile;
                    }
                    statepictureoff.source = statepicturesourceoff;
                }
                delegate: ItemDelegate {
                    width: pictureSelectoroff.width
                    text: pictureSelectoroff.textRole ? (Array.isArray(pictureSelectoroff.model) ? modelData[pictureSelectoroff.textRole] : model[pictureSelectoroff.textRole]) : modelData
                    font.weight: pictureSelectoroff.currentIndex === index ? Font.DemiBold : Font.Normal
                    font.family: pictureSelectoroff.font.family
                    font.pixelSize: pictureSelectoroff.font.pixelSize
                    highlighted: pictureSelectoroff.highlightedIndex === index
                    hoverEnabled: pictureSelectoroff.hoverEnabled
                }
            }
            Text{
                text: Translator.translate("Image", Settings.language) + " " + Translator.translate("ON", Settings.language)
                font.pixelSize: 800 * (12 / 800)
            }
            ComboBox {
                id: pictureSelectoron
                width: 800 * 0.175 //140
                height: 480 * 0.083 //40
                font.pixelSize: 800 * (12 / 800)
                model: UI.backroundpictures
                currentIndex: 0
                onCurrentIndexChanged: {
                    // * Use platform-aware path for images
                    var selectedFile = pictureSelectoron.textAt(pictureSelectoron.currentIndex);
                    if (Qt.platform.os === "linux") {
                        statepicturesourceon = "file:///home/pi/Logo/" + selectedFile;
                    } else if (Qt.platform.os === "osx") {
                        statepicturesourceon = "qrc:/Resources/graphics/" + selectedFile;
                    } else if (Qt.platform.os === "windows") {
                        statepicturesourceon = "file:///c:/Logo/" + selectedFile;
                    } else {
                        statepicturesourceon = "file:" + selectedFile;
                    }
                    statepictureon.source = statepicturesourceon;
                }



                delegate: ItemDelegate {
                    width: pictureSelectoron.width
                    text: pictureSelectoron.textRole ? (Array.isArray(pictureSelector.model) ? modelData[pictureSelector.textRole] : model[pictureSelector.textRole]) : modelData
                    font.weight: pictureSelectoron.currentIndex === index ? Font.DemiBold : Font.Normal
                    font.family: pictureSelectoron.font.family
                    font.pixelSize: pictureSelectoron.font.pixelSize
                    highlighted: pictureSelectoron.highlightedIndex === index
                    hoverEnabled: pictureSelectoron.hoverEnabled
                }
            }
            Text{
                text: Translator.translate("Source", Settings.language)
                font.pixelSize: 800 * (12 / 800)
            }
            ComboBox {
                id: cbxMain
                textRole: "titlename"
                model: powertunedatasource
                width: 800 * 0.175 //140
                height: 480 * 0.083 //40
                font.pixelSize: 800 * (12 / 800)
                Component.onCompleted: {for(var i = 0; i < cbxMain.model.count; ++i) if (powertunedatasource.get(i).sourcename === mainvaluename)cbxMain.currentIndex = i,bind()}
                onCurrentIndexChanged: bind();
                delegate: ItemDelegate{
                    width: cbxMain.width
                    font.pixelSize: cbxMain.font.pixelSize
                    text: cbxMain.textRole ? (Array.isArray(cbxMain.model) ? modelData[cbxMain.textRole] : model[cbxMain.textRole]) : modelData
                    font.weight: cbxMain.currentIndex === index ? Font.DemiBold : Font.Normal
                    font.family: cbxMain.font.family
                    highlighted: cbxMain.highlightedIndex === index
                    hoverEnabled: cbxMain.hoverEnabled
                }
            }
            Text{
                text: Translator.translate("Trigger", Settings.language)
                font.pixelSize: 800 * (12 / 800)
            }
            TextField {
                id: triggeronvalue
                width: 800 * 0.175 //140
                height: 480 * 0.083 //40
                text: triggervalue
                //onTextChanged: triggervalue = triggeronvalue.text
                font.pixelSize: 800 * (12 / 800)
            }
            }
            RoundButton{
                width: parent.width
                text: Translator.translate("Delete image", Settings.language)
                font.pixelSize: 800 * (15 / 800)
                onClicked: statepicture.destroy();
            }
            RoundButton{
                width: parent.width
                text: Translator.translate("Close", Settings.language)
                font.pixelSize: 800 * (15 / 800)
                onClicked: {
                    triggervalue = triggeronvalue.text;
                    mainvaluename = powertunedatasource.get(cbxMain.currentIndex).sourcename;
                    changesize.visible = false;
            }
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
    Item {
        id: warningindication
        function warn()
        {
          //  //console.log("warning" +mainvaluetextfield.text);
          //  //console.log("Trigger" +mainvaluetextfield.text);
            if (mainvaluetextfield.text >= triggervalue ){statepictureoff.visible = false,statepictureon.visible = true}
            if (mainvaluetextfield.text < triggervalue ){statepictureoff.visible = true,statepictureon.visible = false}
//            else {statepictureoff.visible = true,statepictureon.visible = false};

        }
    }
    function togglemousearea()
    {
    //    //console.log("toggle" + UI.draggable);
        if (UI.draggable === 1)
        {
            touchArea.enabled = true;
        }
        else
            touchArea.enabled = false;
    }
    function increaseDecrease()
    {
        ////console.log("ident "+ increasedecreaseident);
        switch(increasedecreaseident)
        {

        case "increasePicture": {
            pictureheight++;
            picturewidth++;
            break;
        }
        case "decreasePicture": {
            pictureheight--;
            picturewidth--;
            break;
        }
        }
    }
    function bind()
    {
        mainvaluetextfield.text = Qt.binding(function(){return PropertyRouter.getValue(mainvaluename)});
    }

    // These functions update the Picture sources in the ComboBoxes
    function updatppiclist()
    {
                    for(var i = 0; i < pictureSelectoron.count; ++i) //
                    if (statepicturesourceon === "file:///home/pi/Logo/" + pictureSelectoron.textAt(i))
                    pictureSelectoron.currentIndex = i
                    updatppiclistoff()
    }
    function updatppiclistoff()
    {
                    for(var i = 0; i < pictureSelectoroff.count; ++i) //
                    if (statepicturesourceoff === "file:///home/pi/Logo/" + pictureSelectoroff.textAt(i))
                    pictureSelectoroff.currentIndex = i
    }
}
