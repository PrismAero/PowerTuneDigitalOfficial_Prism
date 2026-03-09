import QtQuick

Item {
    id: root

    property real rpmValue: 0
    property real rpmMax: 10000
    property real shiftPoint: 0.75
    property int pillCount: 11
    property string activationPattern: "center-out"

    width: 925
    height: 30

    readonly property real _pillWidth: 75
    readonly property real _pillGap: 10
    readonly property real _pillRadius: 40

    readonly property var _pillColors: {
        var colors = [];
        var n = pillCount;
        var greenZone = Math.floor(n * 0.27);
        var yellowZone = Math.floor(n * 0.18);
        for (var i = 0; i < n; i++) {
            if (i < greenZone || i >= n - greenZone)
                colors.push("#1ED033");
            else if (i < greenZone + yellowZone || i >= n - greenZone - yellowZone)
                colors.push("#F1E83C");
            else
                colors.push("#FF0909");
        }
        return colors;
    }

    readonly property var _activationOrder: {
        var order = [];
        var n = pillCount;
        if (activationPattern === "left-to-right") {
            for (var i = 0; i < n; i++)
                order.push(i);
        } else if (activationPattern === "right-to-left") {
            for (var i = n - 1; i >= 0; i--)
                order.push(i);
        } else if (activationPattern === "alternating") {
            var lo = 0, hi = n - 1;
            while (lo <= hi) {
                order.push(lo++);
                if (lo <= hi)
                    order.push(hi--);
            }
        } else {
            var mid = Math.floor(n / 2);
            for (var step = 0; step < n; step++) {
                if (step === 0) {
                    order.push(mid);
                } else {
                    var above = mid + step;
                    var below = mid - step;
                    if (below >= 0)
                        order.push(below);
                    if (above < n)
                        order.push(above);
                }
            }
        }
        return order;
    }

    readonly property int _activeLights: {
        var ratio = rpmValue / Math.max(rpmMax, 1);
        var startRatio = shiftPoint * 0.7;
        if (ratio < startRatio)
            return 0;
        var normalized = (ratio - startRatio) / (1.0 - startRatio);
        return Math.min(pillCount, Math.ceil(normalized * pillCount));
    }

    function _isLit(index) {
        for (var i = 0; i < _activeLights; i++) {
            if (_activationOrder[i] === index)
                return true;
        }
        return false;
    }

    Row {
        anchors.centerIn: parent
        spacing: root._pillGap

        Repeater {
            model: root.pillCount

            Rectangle {
                width: root._pillWidth
                height: 30
                radius: root._pillRadius
                color: root._isLit(index) ? root._pillColors[index] : "#222222"

                Behavior on color {
                    ColorAnimation {
                        duration: 60
                    }
                }
            }
        }
    }
}
