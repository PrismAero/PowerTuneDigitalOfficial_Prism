import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: root
    textRole: "colorname"
    font.pixelSize: 14

    model: ListModel {
        id: colorModel
        ListElement { colorname: "aliceblue" }
        ListElement { colorname: "antiquewhite" }
        ListElement { colorname: "aqua" }
        ListElement { colorname: "aquamarine" }
        ListElement { colorname: "azure" }
        ListElement { colorname: "beige" }
        ListElement { colorname: "bisque" }
        ListElement { colorname: "black" }
        ListElement { colorname: "blanchedalmond" }
        ListElement { colorname: "blue" }
        ListElement { colorname: "blueviolet" }
        ListElement { colorname: "brown" }
        ListElement { colorname: "burlywood" }
        ListElement { colorname: "cadetblue" }
        ListElement { colorname: "chartreuse" }
        ListElement { colorname: "chocolate" }
        ListElement { colorname: "coral" }
        ListElement { colorname: "cornflowerblue" }
        ListElement { colorname: "cornsilk" }
        ListElement { colorname: "crimson" }
        ListElement { colorname: "cyan" }
        ListElement { colorname: "darkblue" }
        ListElement { colorname: "darkcyan" }
        ListElement { colorname: "darkgoldenrod" }
        ListElement { colorname: "darkgray" }
        ListElement { colorname: "darkgreen" }
        ListElement { colorname: "darkkhaki" }
        ListElement { colorname: "darkmagenta" }
        ListElement { colorname: "darkolivegreen" }
        ListElement { colorname: "darkorange" }
        ListElement { colorname: "darkorchid" }
        ListElement { colorname: "darkred" }
        ListElement { colorname: "darksalmon" }
        ListElement { colorname: "darkseagreen" }
        ListElement { colorname: "darkslateblue" }
        ListElement { colorname: "darkslategray" }
        ListElement { colorname: "darkturquoise" }
        ListElement { colorname: "darkviolet" }
        ListElement { colorname: "deeppink" }
        ListElement { colorname: "deepskyblue" }
        ListElement { colorname: "dimgray" }
        ListElement { colorname: "dodgerblue" }
        ListElement { colorname: "firebrick" }
        ListElement { colorname: "floralwhite" }
        ListElement { colorname: "forestgreen" }
        ListElement { colorname: "fuchsia" }
        ListElement { colorname: "gainsboro" }
        ListElement { colorname: "ghostwhite" }
        ListElement { colorname: "gold" }
        ListElement { colorname: "goldenrod" }
        ListElement { colorname: "gray" }
        ListElement { colorname: "green" }
        ListElement { colorname: "greenyellow" }
        ListElement { colorname: "honeydew" }
        ListElement { colorname: "hotpink" }
        ListElement { colorname: "indianred" }
        ListElement { colorname: "indigo" }
        ListElement { colorname: "ivory" }
        ListElement { colorname: "khaki" }
        ListElement { colorname: "lavender" }
        ListElement { colorname: "lavenderblush" }
        ListElement { colorname: "lawngreen" }
        ListElement { colorname: "lemonchiffon" }
        ListElement { colorname: "lightblue" }
        ListElement { colorname: "lightcoral" }
        ListElement { colorname: "lightcyan" }
        ListElement { colorname: "lightgoldenrodyellow" }
        ListElement { colorname: "lightgray" }
        ListElement { colorname: "lightgreen" }
        ListElement { colorname: "lightpink" }
        ListElement { colorname: "lightsalmon" }
        ListElement { colorname: "lightseagreen" }
        ListElement { colorname: "lightskyblue" }
        ListElement { colorname: "lightslategray" }
        ListElement { colorname: "lightsteelblue" }
        ListElement { colorname: "lightyellow" }
        ListElement { colorname: "lime" }
        ListElement { colorname: "limegreen" }
        ListElement { colorname: "linen" }
        ListElement { colorname: "magenta" }
        ListElement { colorname: "maroon" }
        ListElement { colorname: "mediumaquamarine" }
        ListElement { colorname: "mediumblue" }
        ListElement { colorname: "mediumorchid" }
        ListElement { colorname: "mediumpurple" }
        ListElement { colorname: "mediumseagreen" }
        ListElement { colorname: "mediumslateblue" }
        ListElement { colorname: "mediumspringgreen" }
        ListElement { colorname: "mediumturquoise" }
        ListElement { colorname: "mediumvioletred" }
        ListElement { colorname: "midnightblue" }
        ListElement { colorname: "mintcream" }
        ListElement { colorname: "mistyrose" }
        ListElement { colorname: "moccasin" }
        ListElement { colorname: "navajowhite" }
        ListElement { colorname: "navy" }
        ListElement { colorname: "oldlace" }
        ListElement { colorname: "olive" }
        ListElement { colorname: "olivedrab" }
        ListElement { colorname: "orange" }
        ListElement { colorname: "orangered" }
        ListElement { colorname: "orchid" }
        ListElement { colorname: "palegoldenrod" }
        ListElement { colorname: "palegreen" }
        ListElement { colorname: "paleturquoise" }
        ListElement { colorname: "palevioletred" }
        ListElement { colorname: "papayawhip" }
        ListElement { colorname: "peachpuff" }
        ListElement { colorname: "peru" }
        ListElement { colorname: "pink" }
        ListElement { colorname: "plum" }
        ListElement { colorname: "powderblue" }
        ListElement { colorname: "purple" }
        ListElement { colorname: "red" }
        ListElement { colorname: "rosybrown" }
        ListElement { colorname: "royalblue" }
        ListElement { colorname: "saddlebrown" }
        ListElement { colorname: "salmon" }
        ListElement { colorname: "sandybrown" }
        ListElement { colorname: "seagreen" }
        ListElement { colorname: "seashell" }
        ListElement { colorname: "sienna" }
        ListElement { colorname: "silver" }
        ListElement { colorname: "skyblue" }
        ListElement { colorname: "slateblue" }
        ListElement { colorname: "slategray" }
        ListElement { colorname: "snow" }
        ListElement { colorname: "springgreen" }
        ListElement { colorname: "steelblue" }
        ListElement { colorname: "tan" }
        ListElement { colorname: "teal" }
        ListElement { colorname: "thistle" }
        ListElement { colorname: "tomato" }
        ListElement { colorname: "transparent" }
        ListElement { colorname: "turquoise" }
        ListElement { colorname: "violet" }
        ListElement { colorname: "wheat" }
        ListElement { colorname: "white" }
        ListElement { colorname: "whitesmoke" }
        ListElement { colorname: "yellow" }
        ListElement { colorname: "yellowgreen" }
    }

    delegate: ItemDelegate {
        width: root.width
        contentItem: Row {
            spacing: 8
            Rectangle {
                width: 16; height: 16
                color: colorname
                border.color: "#333"
                border.width: 1
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: colorname
                font: root.font
                verticalAlignment: Text.AlignVCenter
            }
        }
        highlighted: root.highlightedIndex === index
    }

    function selectByName(name) {
        for (var i = 0; i < colorModel.count; ++i) {
            if (colorModel.get(i).colorname === name) {
                currentIndex = i;
                return;
            }
        }
    }

    function selectedColor() {
        if (currentIndex >= 0 && currentIndex < colorModel.count)
            return colorModel.get(currentIndex).colorname;
        return "";
    }
}
