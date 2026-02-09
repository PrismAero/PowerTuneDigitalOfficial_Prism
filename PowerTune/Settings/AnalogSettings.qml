import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.0
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
        // * Load appropriate ECU-specific component
        switch (Dashboard.ecu) {
            case "0":
            case "1":
                pageLoader.sourceComponent = analogInputsComponent
                break
            case "2":
                pageLoader.sourceComponent = consultRegsComponent
                break
            case "3":
            case "4":
                pageLoader.sourceComponent = obdPidsComponent
                break
            default:
                pageLoader.sourceComponent = analogInputsComponent
        }
    }

    // * Component definitions for each ECU type
    Component {
        id: analogInputsComponent
        AnalogInputs {}
    }

    Component {
        id: consultRegsComponent
        ConsultRegs {}
    }

    Component {
        id: obdPidsComponent
        OBDPIDS {}
    }

    Connections {
        target: Dashboard
        function onEcuChanged() {
            loadersource()
        }
    }
}
