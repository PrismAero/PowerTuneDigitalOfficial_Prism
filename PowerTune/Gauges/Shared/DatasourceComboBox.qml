import QtQuick 2.15
import QtQuick.Controls 2.15

ComboBox {
    id: root
    font.pixelSize: 14
    textRole: "titlename"

    property var datasourceModel

    model: datasourceModel

    delegate: ItemDelegate {
        width: root.width
        text: root.textRole
              ? (Array.isArray(root.model) ? modelData[root.textRole] : model[root.textRole])
              : modelData
        font.weight: root.currentIndex === index ? Font.DemiBold : Font.Normal
        font.family: root.font.family
        font.pixelSize: root.font.pixelSize
        highlighted: root.highlightedIndex === index
        hoverEnabled: root.hoverEnabled
    }

    function selectBySourceName(sourceName) {
        if (!datasourceModel) return;
        for (var i = 0; i < datasourceModel.count; ++i) {
            if (datasourceModel.get(i).sourcename === sourceName) {
                currentIndex = i;
                return;
            }
        }
    }

    function selectedItem() {
        if (!datasourceModel || currentIndex < 0 || currentIndex >= datasourceModel.count)
            return null;
        return datasourceModel.get(currentIndex);
    }
}
