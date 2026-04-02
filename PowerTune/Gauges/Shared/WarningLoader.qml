import QtQuick

Rectangle {
    id: loadersource

    property bool rpmwarn: false

    function setloadersource() {
        if (rpmwarn) {
            warningSign.setSource(Qt.resolvedUrl("Warning.qml"), {
                                      "warningtext": warnmsg.text
                                  });
        } else {
            warningSign.source = "";
        }
    }

    anchors.fill: parent
    color: "transparent"

    Loader {
        id: warningSign

        anchors.fill: parent
        source: ""
    }

    Text {
        id: warnmsg

        text: ""
        visible: false

        onTextChanged: loadersource.setloadersource()
    }

    Connections {
        function onRpmChanged() {
            if (Engine.rpm > Settings.rpmwarn) {
                rpmwarn = true;
                warnmsg.text = "Danger to Manifold";
            } else {
                rpmwarn = false;
            }
        }

        target: Engine
    }

    Connections {
        function onRpmwarnChanged() {
            loadersource.setloadersource();
        }

        target: loadersource
    }
}
