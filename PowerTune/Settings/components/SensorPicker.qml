import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    property string categoryFilter: ""
    property bool expanded: false
    property string filterMode: "active"
    property string searchText: ""
    property string selectedKey: ""

    signal sensorSelected(string key, string displayName, string unit)

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

    function selectedDisplayName() {
        if (selectedKey === "")
            return "None";
        var name = SensorRegistry.getDisplayName(selectedKey);
        return name ? name : selectedKey;
    }

    function selectedUnit() {
        if (selectedKey === "")
            return "";
        return SensorRegistry.getUnit(selectedKey) || "";
    }

    Layout.fillWidth: true
    border.color: SettingsTheme.border
    border.width: SettingsTheme.borderWidth
    color: SettingsTheme.surface
    implicitHeight: expanded ? 460 : collapsedRow.implicitHeight + (SettingsTheme.sectionPadding * 2)
    radius: SettingsTheme.radiusLarge

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 150
            easing.type: Easing.OutQuad
        }
    }

    Component.onCompleted: {
        if (expanded)
            refresh();
    }
    onCategoryFilterChanged: {
        if (expanded)
            refresh();
    }
    onExpandedChanged: {
        if (expanded)
            refresh();
    }
    onFilterModeChanged: {
        if (expanded)
            refresh();
    }
    onSearchTextChanged: {
        if (expanded)
            refresh();
    }

    ListModel {
        id: filteredModel
    }

    Timer {
        id: sensorsChangedDebounce
        interval: 50
        repeat: false
        onTriggered: {
            if (root.expanded)
                root.refresh()
        }
    }

    Connections {
        function onSensorsChanged() {
            if (root.expanded)
                sensorsChangedDebounce.restart();
        }

        target: SensorRegistry
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: SettingsTheme.sectionPadding
        spacing: SettingsTheme.contentSpacing

        RowLayout {
            id: collapsedRow

            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                color: root.selectedKey !== "" ? SettingsTheme.success : SettingsTheme.textDisabled
                height: SettingsTheme.statusDotSize
                radius: SettingsTheme.statusDotSize / 2
                width: SettingsTheme.statusDotSize
            }

            Text {
                Layout.fillWidth: true
                color: root.selectedKey !== "" ? SettingsTheme.textPrimary : SettingsTheme.textDisabled
                elide: Text.ElideRight
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontControl
                font.weight: Font.DemiBold
                text: root.selectedDisplayName()
            }

            Text {
                color: SettingsTheme.textSecondary
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontCaption
                text: root.selectedUnit()
                visible: text.length > 0
            }

            StyledButton {
                implicitHeight: 30
                implicitWidth: 80
                primary: root.expanded
                text: root.expanded ? "Done" : "Change"

                onClicked: root.expanded = !root.expanded
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: root.expanded

            StyledButton {
                implicitWidth: 60
                primary: root.filterMode === "all"
                text: "All"

                onClicked: root.filterMode = "all"
            }

            StyledButton {
                implicitWidth: 70
                primary: root.filterMode === "active"
                text: "Active"

                onClicked: root.filterMode = "active"
            }

            StyledButton {
                implicitWidth: 90
                primary: root.filterMode === "category"
                text: "Category"

                onClicked: {
                    root.filterMode = "category";
                    if (root.categoryFilter === "")
                        root.categoryFilter = SensorRegistry.availableCategories[0] || "";
                }
            }
        }

        StyledTextField {
            Layout.fillWidth: true
            inputMethodHints: Qt.ImhNoPredictiveText
            placeholderText: "Search sensors..."
            text: root.searchText
            visible: root.expanded

            onTextChanged: root.searchText = text
        }

        Flow {
            Layout.fillWidth: true
            spacing: 4
            visible: root.expanded && root.filterMode === "category"

            Repeater {
                model: SensorRegistry.availableCategories

                StyledButton {
                    font.pixelSize: SettingsTheme.fontCaption
                    implicitHeight: 28
                    implicitWidth: Math.max(60, implicitContentWidth + 16)
                    primary: root.categoryFilter === modelData
                    text: modelData

                    onClicked: root.categoryFilter = modelData
                }
            }
        }

        ListView {
            id: sensorList

            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            model: filteredModel
            section.property: "category"
            visible: root.expanded

            ScrollBar.vertical: ScrollBar {
                minimumSize: 0.1
                policy: ScrollBar.AlwaysOn
            }
            delegate: Rectangle {
                id: delegateRoot

                color: {
                    if (model.sensorKey === root.selectedKey)
                        return SettingsTheme.accent;
                    if (delegateArea.containsMouse)
                        return SettingsTheme.surfacePressed;
                    return index % 2 === 0 ? SettingsTheme.controlBg : SettingsTheme.surfaceElevated;
                }
                height: 38
                radius: SettingsTheme.radiusSmall
                width: sensorList.width

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Rectangle {
                        color: model.active ? SettingsTheme.success : SettingsTheme.textDisabled
                        height: SettingsTheme.statusDotSize
                        radius: SettingsTheme.statusDotSize / 2
                        width: SettingsTheme.statusDotSize
                    }

                    Text {
                        Layout.fillWidth: true
                        color: SettingsTheme.textPrimary
                        elide: Text.ElideRight
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontControl
                        font.weight: model.sensorKey === root.selectedKey ? Font.Bold : Font.Normal
                        text: model.displayName
                    }

                    Text {
                        color: SettingsTheme.textSecondary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontCaption
                        text: model.unit
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
                        root.expanded = false;
                    }
                }
            }
            section.delegate: Rectangle {
                color: SettingsTheme.surfaceElevated
                height: 28
                radius: 4
                width: sensorList.width

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    color: SettingsTheme.accent
                    font.family: SettingsTheme.fontFamily
                    font.pixelSize: SettingsTheme.fontCaption
                    font.weight: Font.Bold
                    leftPadding: 8
                    text: section
                }
            }

            Text {
                anchors.centerIn: parent
                color: SettingsTheme.textDisabled
                font.family: SettingsTheme.fontFamily
                font.pixelSize: SettingsTheme.fontLabel
                text: root.filterMode === "active" ? "No active sensors" : "No sensors found"
                visible: filteredModel.count === 0
            }
        }
    }
}
