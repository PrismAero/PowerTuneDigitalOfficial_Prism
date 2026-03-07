import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    id: root
    Layout.fillWidth: true
    spacing: 6

    property Item target

    function _has(name) {
        return root.target && root.target[name] !== undefined;
    }

    function _setEither(primary, fallback, value) {
        if (!root.target)
            return;
        if (root._has(primary))
            root.target[primary] = value;
        else if (root._has(fallback))
            root.target[fallback] = value;
    }

    Text {
        text: "Ticks"
        font.bold: true
        color: "white"
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("tickcount") || root._has("tickmarksteps")
        Label { text: "Major Count"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root._has("tickcount") ? root.target.tickcount : (root._has("tickmarksteps") ? root.target.tickmarksteps : 0)
            stepSize: 1
            minValue: 1
            onValueChanged: function(v) { root._setEither("tickcount", "tickmarksteps", Math.round(v)); }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        visible: root._has("minortickcount") || root._has("minortickmarksteps")
        Label { text: "Minor Count"; color: "white" }
        NumericStepper {
            Layout.fillWidth: true
            value: root._has("minortickcount") ? root.target.minortickcount : (root._has("minortickmarksteps") ? root.target.minortickmarksteps : 0)
            stepSize: 1
            minValue: 0
            onValueChanged: function(v) { root._setEither("minortickcount", "minortickmarksteps", Math.round(v)); }
        }
    }

    Repeater {
        model: [
            { label: "Major Height", prop: "tickmarkheight" },
            { label: "Major Width", prop: "tickmarkwidth" },
            { label: "Minor Height", prop: "minortickmarkheight" },
            { label: "Minor Width", prop: "minortickmarkwidth" },
            { label: "Major Inset", prop: "tickmarkinset" },
            { label: "Minor Inset", prop: "minortickmarkinset" }
        ]
        delegate: RowLayout {
            Layout.fillWidth: true
            property var entry: modelData
            visible: root.target && entry && entry.prop && root.target[entry.prop] !== undefined

            Label { text: entry.label; color: "white" }
            NumericStepper {
                Layout.fillWidth: true
                value: root.target && entry && entry.prop ? root.target[entry.prop] : 0
                stepSize: 1
                onValueChanged: function(v) { if (root.target && entry && entry.prop) root.target[entry.prop] = v; }
            }
        }
    }

    Repeater {
        model: [
            { label: "Tick Active", prop: "activetickmarkcolor" },
            { label: "Tick Inactive", prop: "inactivetickmarkcolor" },
            { label: "Minor Active", prop: "activeminortickmarkcolor" },
            { label: "Minor Inactive", prop: "inactiveminortickmarkcolor" },
            { label: "Tick Color", prop: "tickColor" }
        ]
        delegate: RowLayout {
            Layout.fillWidth: true
            property var entry: modelData
            visible: root.target && entry && entry.prop && root.target[entry.prop] !== undefined

            Label { text: entry.label; color: "white" }
            ColorComboBox {
                Layout.fillWidth: true
                Component.onCompleted: {
                    if (root.target && entry && entry.prop)
                        selectByName(root.target[entry.prop]);
                }
                onCurrentIndexChanged: {
                    if (!root.target || !entry || !entry.prop)
                        return;
                    var c = selectedColor();
                    if (c !== "")
                        root.target[entry.prop] = c;
                }
            }
        }
    }
}
