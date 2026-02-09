import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: view
    anchors.fill: parent
    color: "grey"
    Grid {
        rows: 15
        columns: 4
        spacing: view.width/ 30
    Text {
        text: Flags.Flag1 + " AC SW   "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag2 + " PS SW   "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag3 + " N  SW   "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag4 + " Cranking"
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag5 + " CLSD/THL"
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag6 + " AC Relay"
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag7 + " Fuel Rel"
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag8 + " VTC SOL "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag9 + " FAN Hi  "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag10 + " FAN Low "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag11 + " P/Reg Va"
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag12 + " WG Sol  "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag13 + " IAC Sol "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag14 + " EGR Sol "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag15 + " LH Bank "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: Flags.Flag16 + " RH Bank "
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "RPM     " + Engine.rpm
        font.pixelSize: view.width/ 55
    }
    Text {
        text:"RPM Ref " //+ Engine.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "MAF V.  " + Engine.MAF1V
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "RH MAFV " + Engine.MAF2V
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "Water T " + Engine.Watertemp
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "LH 02 V " + Engine.O2volt
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "RH 02 V " + Engine.O2volt_2
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "Speed   " + Vehicle.speed
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "Batt V  " + Engine.BatteryV
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "TPS  V  " + Engine.TPS
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "Fuel T  " + Engine.Fueltemp
        font.pixelSize: view.width/ 55
    }

    Text {
        text: "IAT     " + Engine.Intaketemp
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "EGT V   " //+ Engine.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "Inj T L " + Engine.Inj
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "IGN T   " //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "AAC Val " //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "A/F LH  " //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "A/F RH  " //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "A/F LH S" //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "A/F RH S" //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "M/R FC M" //+ Dashboard.
        font.pixelSize: view.width/ 55
    }		Text {
        text: "Inj T RH" //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "WG %    " //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "MAP Volt" //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "MAF gm/s" //+ Dashboard.
        font.pixelSize: view.width/ 55
    }		Text {
        text: "Evap V  " //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "ABS Pr.V" //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
    Text {
        text: "FPCMF/PV" //+ Dashboard.
        font.pixelSize: view.width/ 55
    }
}
}
