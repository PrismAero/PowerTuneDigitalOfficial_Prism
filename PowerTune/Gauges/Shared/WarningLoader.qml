import QtQuick 2.15

Rectangle {
    id: loadersource
    anchors.fill: parent
    color:"transparent"

    property bool rpmwarn
    property bool boostwarn
    property bool coolanttempwarn
    property bool knockwarn
    //property var warnmsg : "hello"

    Loader {
        anchors.fill:parent

        id: warningSign
        source: ""
    }
    Text {
        id: warnmsg
        text:"test"
        visible: false
        onTextChanged: {loadersource.setloadersource()}
    }
    Connections{
        target: Engine
        function onRpmChanged() {
            if (Engine.rpm > Settings.rpmwarn) {
                rpmwarn = true
                warnmsg.text = "Danger to Manifold"
            } else {
                rpmwarn = false
            }
        }
        function onPimChanged() { updateBoostWarning() }
        function onBoostpresChanged() { updateBoostWarning() }
        function onWatertempChanged() {
            if (Engine.Watertemp > Settings.waterwarn) {
                coolanttempwarn = true
                warnmsg.text = "Coolant Temp. " + (Engine.Watertemp).toFixed(1)
            } else {
                coolanttempwarn = false
            }
        }
        function onKnockChanged() {
            if (Engine.Knock > Settings.knockwarn) {
                knockwarn = true
                warnmsg.text = "Knock " + (Engine.Knock).toFixed(0)
            } else {
                knockwarn = false
            }
        }
    }

    Connections{
        target: loadersource
        function onRpmwarnChanged() { loadersource.setloadersource() }
        function onBoostwarnChanged() { loadersource.setloadersource() }
        function onCoolanttempwarnChanged() { loadersource.setloadersource() }
        function onKnockwarnChanged() { loadersource.setloadersource() }
    }


    function setloadersource()
    {
        if (rpmwarn || boostwarn || coolanttempwarn || knockwarn) {
            warningSign.setSource(Qt.resolvedUrl("Warning.qml"), { "warningtext": warnmsg.text })
        }
        if (!rpmwarn && !boostwarn && !coolanttempwarn && !knockwarn)
            warningSign.source = "" //Removes all warning signs
    }

    function updateBoostWarning() {
        var boost = Engine.BoostPres
        if (boost === undefined || boost === null)
            boost = Engine.pim
        if (boost > Settings.boostwarn) {
            boostwarn = true
            warnmsg.text = "Boost " + Number(boost).toFixed(1)
        } else {
            boostwarn = false
        }
    }

}
//
