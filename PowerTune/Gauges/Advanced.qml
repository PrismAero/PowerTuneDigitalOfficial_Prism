import QtQuick 2.15
import Qt5Compat.GraphicalEffects



Rectangle {
    width: parent.width
    height: parent.height
    color: "black"


    Column {
        spacing: 2
        anchors.left: parent.left
        Text {
            color: "yellow"
            text: "PIM kgcm2 " + Engine.Intakepress
        }
        Text {
            color: "yellow"
            text: "PIM V " + Engine.PressureV
        }
        Text {
            color: "yellow"
            text: "Thro V " + Engine.ThrottleV

        }
        Text {
            color: "yellow"
            text: "Pri Inj "+ Engine.Primaryinp

        }
        Text {
            color: "yellow"
            text: "Fuelc " + Engine.Fuelc

        }
        Text {
            color: "yellow"
            text: "Lead Ign " + Engine.Leadingign

        }
        Text {
            color: "yellow"
            text: "Trailingign " + Engine.Trailingign

        }
        Text {
            color: "yellow"
            text: "Fueltemp " + Engine.Fueltemp

        }
        Text {
            color: "yellow"
            text: "Moilp " + Engine.Moilp

        }
        Text {
            color: "yellow"
            text: "Boosttp %" + Engine.Boosttp

        }
        Text {
            color: "yellow"
            text: "Boostwg %" +Engine.Boostwg

        }
        Text {
            color: "yellow"
            text:"Watertemp " + Engine.Watertemp

        }

        Text {
            color: "yellow"
            text: "Intaketemp " + Engine.Intaketemp

        }

        Text {
            color: "yellow"
            text: "Knock " + Engine.Knock

        }

        Text {
            color: "yellow"
            text: "Batt V " + Engine.BatteryV

        }
        Text {
            color: "yellow"
            text: "Iscvduty " + Engine.Iscvduty

        }

        Text {
            color: "yellow"
            text: "O2volt " + Engine.O2volt

        }

        Text {
            color: "yellow"
            text: "na1 " + PropertyRouter.getValue("na1")

        }

        Text {
            color: "yellow"
            text: "Secinjpulse " + Engine.Secinjpulse

        }
        Text {
            color: "yellow"
            text: "na2 " + PropertyRouter.getValue("na2")

        }
}

//Sensor Info

    Column {
        spacing: 2
        anchors.centerIn: parent
        Text {
            color: "yellow"
            text: "Boost " + Engine.pim
             }
        Text {
            color: "yellow"
            text: "VTA1 V " + PropertyRouter.getValue("vta1")
        }
        Text {
            color: "yellow"
            text: "VTA2 V " + PropertyRouter.getValue("vta2")

        }
        Text {
            color: "yellow"
            text: "Oil pump V "+ PropertyRouter.getValue("vmop")

        }
        Text {
            color: "yellow"
            text: "Water Temp. " + Engine.Watertemp

        }
        Text {
            color: "yellow"
            text: "Air Temp. " + Engine.Intaketemp

        }
        Text {
            color: "yellow"
            text: "Fuel Temp. " + Engine.Fueltemp

        }
        Text {
            color: "yellow"
            text: "O2S " + Engine.O2volt

        }
}
        // Sensor Bit Flags
        Column {
            spacing: 2
            anchors.right: parent.right

        Text {
            color: "yellow"
            text: Flags.Flag1 +" "+ Flags.FlagString1

        }
        Text {
            color: "yellow"
            text: Flags.Flag2 +" "+ Flags.FlagString2

        }
        Text {
            color: "yellow"
            text: Flags.Flag3 +" "+ Flags.FlagString3

        }
        Text {
            color: "yellow"
            text: Flags.Flag4 +" "+ Flags.FlagString4

        }

        Text {
            color: "yellow"
            text: Flags.Flag5 +" "+ Flags.FlagString5

        }

        Text {
            color: "yellow"
            text: Flags.Flag6 +" "+ Flags.FlagString6

        }

        Text {
            color: "yellow"
            text: Flags.Flag7 +" "+ Flags.FlagString7

        }

        Text {
            color: "yellow"
            text: Flags.Flag8 +" "+ Flags.FlagString8

        }

        Text {
            color: "yellow"
            text: Flags.Flag9 +" "+ Flags.FlagString9

        }

        Text {
            color: "yellow"
            text: Flags.Flag10 +" "+ Flags.FlagString10

        }

        Text {
            color: "yellow"
            text: Flags.Flag11 +" "+ Flags.FlagString11

        }

        Text {
            color: "yellow"
            text: Flags.Flag12 +" "+ Flags.FlagString12

        }

        Text {
            color: "yellow"
            text: Flags.Flag13 +" "+ Flags.FlagString13

        }

        Text {
            color: "yellow"
            text: Flags.Flag14 +" "+ Flags.FlagString14

        }

        Text {
            color: "yellow"
            text: Flags.Flag15 +" "+ Flags.FlagString15

        }

        Text {
            color: "yellow"
            text: Flags.Flag16 +" "+ Flags.FlagString16

        }

}
}


