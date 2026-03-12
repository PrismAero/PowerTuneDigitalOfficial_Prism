import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string selectedKey: ""
    property string filterMode: "all"
    property string categoryFilter: ""
    property string searchText: ""

    signal sensorSelected(string key, string displayName, string unit)

    Layout.fillWidth: true
    implicitHeight: 420
    color: SettingsTheme.surface
    radius: SettingsTheme.radiusLarge
    border.color: SettingsTheme.border
    border.width: SettingsTheme.borderWidth

    ListModel {
        id: filteredModel
    }

    function refresh() {
        filteredModel.clear();
        var activeOnly = (filterMode === "active");
        var catFilter = (filterMode === "category") ? categoryFilter : "";
        var sensors = SensorRegistry.getSensorsByCategory(catFilter, activeOnly);

        for (var i = 0; i < sensors.length; i++) {
            var s = sensors[i];
            if (searchText.length > 0) {
                var lc = searchText.toLowerCase();
                if (s.displayName.toLowerCase().indexOf(lc) < 0 && s.key.toLowerCase().indexOf(lc) < 0)
                    continue;
            }
            filteredModel.append({
                sensorKey: s.key,
                displayName: s.displayName,
                category: s.category,
                unit: s.unit ? s.unit : "",
                active: s.active
            });
        }
    }

    Component.onCompleted: refresh()

    Connections {
        target: SensorRegistry
        function onSensorsChanged() {
            root.refresh();
        }
    }

    onFilterModeChanged: refresh()
    onCategoryFilterChanged: refresh()
    onSearchTextChanged: refresh()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SettingsTheme.sectionPadding
        spacing: SettingsTheme.contentSpacing

        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            StyledButton {
                text: "All"
                primary: root.filterMode === "all"
                implicitWidth: 60
                onClicked: root.filterMode = "all"
            }
            StyledButton {
                text: "Active"
                primary: root.filterMode === "active"
                implicitWidth: 70
                onClicked: root.filterMode = "active"
            }
            StyledButton {
                text: "Category"
                primary: root.filterMode === "category"
                implicitWidth: 90
                onClicked: {
                    root.filterMode = "category";
                    if (root.categoryFilter === "")
                        root.categoryFilter = SensorRegistry.availableCategories[0] || "";
                }
            }
        }

        StyledTextField {
            Layout.fillWidth: true
            placeholderText: "Search sensors..."
            text: root.searchText
            onTextChanged: root.searchText = text
            inputMethodHints: Qt.ImhNoPredictiveText
        }

        Flow {
            Layout.fillWidth: true
            spacing: 4
            visible: root.filterMode === "category"

            Repeater {
                model: SensorRegistry.availableCategories

                StyledButton {
                    text: modelData
                    primary: root.categoryFilter === modelData
                    implicitWidth: Math.max(60, implicitContentWidth + 16)
                    implicitHeight: 28
                    font.pixelSize: SettingsTheme.fontCaption
                    onClicked: root.categoryFilter = modelData
                }
            }
        }

        ListView {
            id: sensorList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: filteredModel

            section.property: "category"
            section.delegate: Rectangle {
                width: sensorList.width
                height: 28
                color: SettingsTheme.surfaceElevated
                radius: 4

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    leftPadding: 8
                    text: section
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.Bold
                    font.family: SettingsTheme.fontFamily
                    color: SettingsTheme.accent
                }
            }

            delegate: Rectangle {
                id: delegateRoot
                width: sensorList.width
                height: 38
                radius: SettingsTheme.radiusSmall
                color: {
                    if (model.sensorKey === root.selectedKey)
                        return SettingsTheme.accent;
                    if (delegateArea.containsMouse)
                        return SettingsTheme.surfacePressed;
                    return index % 2 === 0 ? SettingsTheme.controlBg : SettingsTheme.surfaceElevated;
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Rectangle {
                        width: SettingsTheme.statusDotSize
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        color: model.active ? SettingsTheme.success : SettingsTheme.textDisabled
                    }

                    Text {
                        Layout.fillWidth: true
                        text: model.displayName
                        font.pixelSize: SettingsTheme.fontControl
                        font.family: SettingsTheme.fontFamily
                        font.weight: model.sensorKey === root.selectedKey ? Font.Bold : Font.Normal
                        color: SettingsTheme.textPrimary
                        elide: Text.ElideRight
                    }

                    Text {
                        text: model.unit
                        font.pixelSize: SettingsTheme.fontCaption
                        font.family: SettingsTheme.fontFamily
                        color: SettingsTheme.textSecondary
                        visible: model.unit.length > 0
                    }
                }

                MouseArea {
                    id: delegateArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.selectedKey = model.sensorKey;
                        root.sensorSelected(model.sensorKey, model.displayName, model.unit);
                    }
                }
            }

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AlwaysOn
                minimumSize: 0.1
            }

            Text {
                anchors.centerIn: parent
                visible: filteredModel.count === 0
                text: root.filterMode === "active" ? "No active sensors" : "No sensors found"
                font.pixelSize: SettingsTheme.fontLabel
                font.family: SettingsTheme.fontFamily
                color: SettingsTheme.textDisabled
            }
        }
    }
}
