import QtQuick 2.15

Item {
    id: root

    property var config: ({})

    ArcGauge {
        id: arc

        anchors.fill: parent
        config: root.config
    }

    ArcAlertMarker {
        active: enabled && (arc.displayValue >= Number(root.config.warningThreshold))
        anchors.fill: parent
        arcScale: root.config.arcScale !== undefined ? Number(root.config.arcScale) : 1.0
        arcWidth: root.config.arcWidth !== undefined ? Number(root.config.arcWidth) : 0.32
        centerOffsetX: root.config.arcOffsetX !== undefined ? Number(root.config.arcOffsetX) : 0
        centerOffsetY: root.config.arcOffsetY !== undefined ? Number(root.config.arcOffsetY) : 0
        enabled: root.config.warningEnabled === true || root.config.warningEnabled === "true"
        endAngle: root.config.endAngle !== undefined ? Number(root.config.endAngle) : 400
        flashEnabled: root.config.warningFlash !== undefined ? (root.config.warningFlash === true
                                                                || root.config.warningFlash === "true") : true
        flashRate: root.config.warningFlashRate !== undefined ? Number(root.config.warningFlashRate) : 200
        markerColor: root.config.warningColor !== undefined ? root.config.warningColor : "#FF0000"
        maxValue: root.config.maxValue !== undefined ? Number(root.config.maxValue) : 220
        minValue: root.config.minValue !== undefined ? Number(root.config.minValue) : 0
        startAngle: root.config.startAngle !== undefined ? Number(root.config.startAngle) : 225
        thresholdValue: root.config.warningThreshold !== undefined ? Number(root.config.warningThreshold) : maxValue
    }

    GaugeReadout {
        anchors.fill: parent
        decimals: root.config.decimals !== undefined ? Number(root.config.decimals) : 0
        offsetX: root.config.readoutOffsetX !== undefined ? Number(root.config.readoutOffsetX) : 0
        offsetY: root.config.readoutOffsetY !== undefined ? Number(root.config.readoutOffsetY) : (
                                                                root.config.valueOffsetY !== undefined ? Number(
                                                                                                             root.config.valueOffsetY) :
                                                                                                         0)
        spacing: root.config.readoutSpacing !== undefined ? Number(root.config.readoutSpacing) : -1
        stepSize: root.config.readoutStep !== undefined ? Number(root.config.readoutStep) : 10
        textColor: root.config.readoutTextColor !== undefined ? root.config.readoutTextColor : "#FFFFFF"
        unit: root.config.unit !== undefined ? root.config.unit : "MPH"
        unitOffsetX: root.config.unitOffsetX !== undefined ? Number(root.config.unitOffsetX) : 14
        unitOffsetY: root.config.unitOffsetY !== undefined ? Number(root.config.unitOffsetY) : -2
        unitScale: root.config.readoutUnitScale !== undefined ? Number(root.config.readoutUnitScale) : 0.076
        value: arc.displayValue
        valueScale: root.config.readoutValueScale !== undefined ? Number(root.config.readoutValueScale) : 0.213
    }
}
