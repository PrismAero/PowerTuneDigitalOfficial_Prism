import QtQuick 2.15

Rectangle {
    id: loadersource

    property bool boostwarn: false
    property bool coolanttempwarn: false
    property bool knockwarn: false
    property bool rpmwarn: false

    function setloadersource() {
        if (rpmwarn || boostwarn || coolanttempwarn || knockwarn) {
            warningSign.setSource(Qt.resolvedUrl("Warning.qml"), {
                                      "warningtext": warnmsg.text
                                  });
        }
        if (!rpmwarn && !boostwarn && !coolanttempwarn && !knockwarn) {
            warningSign.source = "";
        }
    }

    function updateBoostWarning() {
        var boost = Engine.BoostPres;
        if (boost === undefined || boost === null)
            boost = Engine.pim;
        if (boost > Settings.boostwarn) {
            boostwarn = true;
            warnmsg.text = "Boost " + Number(boost).toFixed(1);
        } else {
            boostwarn = false;
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
        function onKnockChanged() {
            if (Engine.Knock > Settings.knockwarn) {
                knockwarn = true;
                warnmsg.text = "Knock " + Engine.Knock.toFixed(0);
            } else {
                knockwarn = false;
            }
        }

        function onPimChanged() {
            updateBoostWarning();
        }

        function onRpmChanged() {
            if (Engine.rpm > Settings.rpmwarn) {
                rpmwarn = true;
                warnmsg.text = "Danger to Manifold";
            } else {
                rpmwarn = false;
            }
        }

        function onWatertempChanged() {
            if (Engine.Watertemp > Settings.waterwarn) {
                coolanttempwarn = true;
                warnmsg.text = "Coolant Temp. " + Engine.Watertemp.toFixed(1);
            } else {
                coolanttempwarn = false;
            }
        }

        target: Engine
    }

    Connections {
        function onBoostwarnChanged() {
            loadersource.setloadersource();
        }

        function onCoolanttempwarnChanged() {
            loadersource.setloadersource();
        }

        function onKnockwarnChanged() {
            loadersource.setloadersource();
        }

        function onRpmwarnChanged() {
            loadersource.setloadersource();
        }

        target: loadersource
    }
}
