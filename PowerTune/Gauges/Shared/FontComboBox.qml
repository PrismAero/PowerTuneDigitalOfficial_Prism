import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: root
    font.pixelSize: 14

    model: Qt.fontFamilies()

    delegate: ItemDelegate {
        width: root.width
        text: modelData
        font.family: modelData
        font.pixelSize: root.font.pixelSize
        highlighted: root.highlightedIndex === index
    }

    function selectByName(family) {
        var families = Qt.fontFamilies();
        for (var i = 0; i < families.length; ++i) {
            if (families[i] === family) {
                currentIndex = i;
                return;
            }
        }
    }
}
