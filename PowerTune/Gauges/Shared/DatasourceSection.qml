import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import PowerTune.Utils 1.0

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target
    property string sourceProperty: "mainvaluename"

    Text {
        text: "Data Source"
        font.bold: true
        color: "white"
    }

    DatasourceComboBox {
        id: sourceBox
        Layout.fillWidth: true
        datasourceModel: DatasourceService.allSources
        Component.onCompleted: {
            if (root.target && root.target[root.sourceProperty] !== undefined)
                selectBySourceName(root.target[root.sourceProperty]);
        }
    }

    Button {
        text: "Apply Source"
        Layout.fillWidth: true
        onClicked: {
            if (!root.target)
                return;

            var selected = sourceBox.selectedItem();
            if (!selected)
                return;

            var sourceName = selected.sourcename;
            root.target[root.sourceProperty] = sourceName;

            if (root.target.mainvalue !== undefined) {
                root.target.mainvalue = Qt.binding(function() {
                    return PropertyRouter.getValue(sourceName);
                });
            } else if (root.target.gearValue !== undefined) {
                root.target.gearValue = Qt.binding(function() {
                    return PropertyRouter.getValue(sourceName);
                });
            }

            if (root.target.checkdatasource !== undefined)
                root.target.checkdatasource();
            if (root.target.bind !== undefined)
                root.target.bind();
        }
    }
}
