import QtQuick 2.15



Item {
    id: shiftlightssetting
    width:parent.width * 0.75
    height:parent.height * 0.75
    //Setting Position to align with the RPM 1 Bar
    x: parent.width * 0.33
    property  int rpmwarn1: Settings.rpmStage1
    property  int rpmwarn2: Settings.rpmStage2
    property  int rpmwarn3: Settings.rpmStage3
    property  int rpmwarn4: Settings.rpmStage4
    Connections{
        target: Settings
        function onRpmStage1Changed() { rpmwarn1 = Settings.rpmStage1 }
        function onRpmStage2Changed() { rpmwarn2 = Settings.rpmStage2 }
        function onRpmStage3Changed() { rpmwarn3 = Settings.rpmStage3 }
        function onRpmStage4Changed() { rpmwarn4 = Settings.rpmStage4 }
    }
    Connections{
        target: Engine
        function onRpmChanged() {
            if (Engine.rpm > rpmwarn1) {led1.source = "qrc:/Resources/graphics/ledgreen.png",led8.source = "qrc:/Resources/graphics/ledgreen.png"};
            if (Engine.rpm > rpmwarn2) {led2.source = "qrc:/Resources/graphics/ledgreen.png",led7.source = "qrc:/Resources/graphics/ledgreen.png"};
            if (Engine.rpm > rpmwarn3) {led3.source = "qrc:/Resources/graphics/ledyellow.png",led6.source = "qrc:/Resources/graphics/ledyellow.png"};
            if (Engine.rpm > rpmwarn4) {led4.source = "qrc:/Resources/graphics/ledred.png",led5.source = "qrc:/Resources/graphics/ledred.png"};
            if (Engine.rpm < rpmwarn1) {led1.source = "qrc:/Resources/graphics/ledoff.png",led8.source = "qrc:/Resources/graphics/ledoff.png"};
            if (Engine.rpm < rpmwarn2) {led2.source = "qrc:/Resources/graphics/ledoff.png",led7.source = "qrc:/Resources/graphics/ledoff.png"};
            if (Engine.rpm < rpmwarn3) {led3.source = "qrc:/Resources/graphics/ledoff.png",led6.source = "qrc:/Resources/graphics/ledoff.png"};
            if (Engine.rpm < rpmwarn4) {led4.source = "qrc:/Resources/graphics/ledoff.png",led5.source = "qrc:/Resources/graphics/ledoff.png"};
        }

    }

        Row {
            spacing: parent.width / 40
            topPadding: 3
            Image {
                id : led1
                height: shiftlightssetting.width * 0.043 //shiftlightssetting.width/22.85
                width: shiftlightssetting.width * 0.043 //35
                source: "qrc:/Resources/graphics/ledoff.png"
            }
            Image {
                id : led2
                height: shiftlightssetting.width * 0.043
                width: shiftlightssetting.width * 0.043
                source: "qrc:/Resources/graphics/ledoff.png"
            }
            Image {
                id : led3
                height: shiftlightssetting.width * 0.043
                width: shiftlightssetting.width * 0.043
                source: "qrc:/Resources/graphics/ledoff.png"
            }
            Image {
                id : led4
                height: shiftlightssetting.width * 0.043
                width: shiftlightssetting.width * 0.043
                source: "qrc:/Resources/graphics/ledoff.png"
            }
            Image {
                id : led5
                height: shiftlightssetting.width * 0.043
                width: shiftlightssetting.width * 0.043
                source: "qrc:/Resources/graphics/ledoff.png"
            }
            Image {
                id : led6
                height: shiftlightssetting.width * 0.043
                width: shiftlightssetting.width * 0.043
                source: "qrc:/Resources/graphics/ledoff.png"
            }
            Image {
                id : led7
                height: shiftlightssetting.width * 0.043
                width: shiftlightssetting.width * 0.043
                source: "qrc:/Resources/graphics/ledoff.png"
            }
            Image {
                id : led8
                height: shiftlightssetting.width * 0.043
                width: shiftlightssetting.width * 0.043
                source: "qrc:/Resources/graphics/ledoff.png"
            }

        }
    }

