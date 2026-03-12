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
        anchors.fill: parent
        enabled: root.config.warningEnabled === true || root.config.warningEnabled === "true"
        active: enabled && (arc.displayValue >= Number(root.config.warningThreshold))
        flashEnabled: root.config.warningFlash !== undefined ? (root.config.warningFlash === true || root.config.warningFlash === "true") : true
        flashRate: root.config.warningFlashRate !== undefined ? Number(root.config.warningFlashRate) : 200
        minValue: root.config.minValue !== undefined ? Number(root.config.minValue) : 0
        maxValue: root.config.maxValue !== undefined ? Number(root.config.maxValue) : 200
        thresholdValue: root.config.warningThreshold !== undefined ? Number(root.config.warningThreshold) : maxValue
        startAngle: root.config.startAngle !== undefined ? Number(root.config.startAngle) : 225
        endAngle: root.config.endAngle !== undefined ? Number(root.config.endAngle) : 315
        arcWidth: root.config.arcWidth !== undefined ? Number(root.config.arcWidth) : 0.285
        arcScale: root.config.arcScale !== undefined ? Number(root.config.arcScale) : 0.945
        centerOffsetX: root.config.arcOffsetX !== undefined ? Number(root.config.arcOffsetX) : 5
        centerOffsetY: root.config.arcOffsetY !== undefined ? Number(root.config.arcOffsetY) : 0
        markerColor: root.config.warningColor !== undefined ? root.config.warningColor : "#FF0000"
    }

    GaugeReadout {
        anchors.fill: parent
        value: arc.displayValue
        decimals: root.config.decimals !== undefined ? Number(root.config.decimals) : 0
        unit: root.config.unit !== undefined ? root.config.unit : "MPH"
        stepSize: root.config.readoutStep !== undefined ? Number(root.config.readoutStep) : 1
        textColor: root.config.readoutTextColor !== undefined ? root.config.readoutTextColor : "#FFFFFF"
        valueScale: root.config.readoutValueScale !== undefined ? Number(root.config.readoutValueScale) : 0.213
        unitScale: root.config.readoutUnitScale !== undefined ? Number(root.config.readoutUnitScale) : 0.076
        offsetX: root.config.readoutOffsetX !== undefined ? Number(root.config.readoutOffsetX) : 0
        offsetY: root.config.readoutOffsetY !== undefined ? Number(root.config.readoutOffsetY) : (root.config.valueOffsetY !== undefined ? Number(root.config.valueOffsetY) : 62)
        unitOffsetX: root.config.unitOffsetX !== undefined ? Number(root.config.unitOffsetX) : 14
        unitOffsetY: root.config.unitOffsetY !== undefined ? Number(root.config.unitOffsetY) : -2
        spacing: root.config.readoutSpacing !== undefined ? Number(root.config.readoutSpacing) : -1
    }
}
