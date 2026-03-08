import QtQuick 2.15
import QtQuick.Controls 2.15

import PowerTune.Core 1.0

Rectangle {
    id: backround1
    anchors.fill: parent

    // * Dynamic content based on ECU type
    Loader {
        anchors.fill: backround1
        id: pageLoader
        Component.onCompleted: {
            loadersource();
        }
    }

    function loadersource() {
        pageLoader.sourceComponent = analogInputsComponent
    }

    Component {
        id: analogInputsComponent
        AnalogInputs {}
    }

    Connections {
        target: Connection
        function onEcuChanged() {
            loadersource()
        }
    }
}
