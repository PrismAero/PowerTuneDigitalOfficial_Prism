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
        function onRpmChanged() { if (Engine.rpm > Settings.rpmwarn) {rpmwarn = true,warnmsg.text = "Danger to Manifold"} else rpmwarn= false }
        function onPimChanged() { if (Engine.pim > Settings.boostwarn) {boostwarn = true,warnmsg.text = "Boost " +(Engine.pim).toFixed(1)} else boostwarn= false }
        function onWatertempChanged() { if (Engine.Watertemp > Settings.waterwarn) {coolanttempwarn = true,warnmsg.text = "Coolant Temp. " + (Engine.Watertemp).toFixed(1)} else coolanttempwarn= false }
        function onKnockChanged() { if (Engine.Knock > Settings.knockwarn) {knockwarn = true,warnmsg.text = "Knock " + (Engine.Knock).toFixed(0)} else knockwarn= false }
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
        if (rpmwarn == true || boostwarn == true || coolanttempwarn == true ||knockwarn == true ) {warningSign.setSource("qrc:/qt/qml/PowerTune/Gauges/PowerTune/Gauges/Warning.qml",{ "warningtext": warnmsg.text })};
        if (rpmwarn == false && boostwarn == false && coolanttempwarn == false && knockwarn == false ){warningSign.source = ""} //Removes all warning signs
    }

}
//
