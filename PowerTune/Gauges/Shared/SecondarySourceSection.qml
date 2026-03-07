import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Utils 1.0

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target

    Text {
        text: "Secondary Source"
        font.bold: true
        color: "white"
    }

    DatasourceComboBox {
        id: sourceBox
        Layout.fillWidth: true
        datasourceModel: DatasourceService.allSources
        Component.onCompleted: {
            if (root.target && root.target.secvaluename !== undefined)
                selectBySourceName(root.target.secvaluename);
        }
    }

    Button {
        text: "Apply Secondary Source"
        Layout.fillWidth: true
        onClicked: {
            if (!root.target)
                return;
            var selected = sourceBox.selectedItem();
            if (!selected)
                return;

            var sourceName = selected.sourcename;
            if (root.target.secvaluename !== undefined)
                root.target.secvaluename = sourceName;
            if (root.target.secvalue !== undefined) {
                root.target.secvalue = Qt.binding(function() {
                    return PropertyRouter.getValue(sourceName);
                });
            }
        }
    }
}
