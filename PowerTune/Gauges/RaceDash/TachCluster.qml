import QtQuick

Item {
    id: root

    property var config: ({})
    readonly property var gearConfig: ({
                                           gearKey: config.gearKey !== undefined ? config.gearKey : "Gear",
                                           gearTextColor: config.gearTextColor !== undefined ? config.gearTextColor :
                                                                                               "#FFFFFF",
                                           gearFontSize: config.gearFontSize !== undefined ? Number(
                                                                                                 config.gearFontSize) :
                                                                                             160.0,
                                           suffixFontSize: config.suffixFontSize !== undefined ? Number(
                                                                                                     config.suffixFontSize) :
                                                                                                 52.505
                                       })

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
        endAngle: root.config.endAngle !== undefined ? Number(root.config.endAngle) : 56
        flashEnabled: root.config.warningFlash !== undefined ? (root.config.warningFlash === true
                                                                || root.config.warningFlash === "true") : true
        flashRate: root.config.warningFlashRate !== undefined ? Number(root.config.warningFlashRate) : 200
        markerColor: root.config.warningColor !== undefined ? root.config.warningColor : "#FF0000"
        maxValue: root.config.maxValue !== undefined ? Number(root.config.maxValue) : 15000
        minValue: root.config.minValue !== undefined ? Number(root.config.minValue) : 0
        startAngle: root.config.startAngle !== undefined ? Number(root.config.startAngle) : 225
        thresholdValue: root.config.warningThreshold !== undefined ? Number(root.config.warningThreshold) : maxValue
    }

    GearIndicator {
        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.config.gearOffsetX !== undefined ? Number(root.config.gearOffsetX) : 0
        anchors.verticalCenterOffset: root.config.gearOffsetY !== undefined ? Number(root.config.gearOffsetY) : -85
        config: root.gearConfig
        height: root.config.gearHeight !== undefined ? Number(root.config.gearHeight) : 117
        width: root.config.gearWidth !== undefined ? Number(root.config.gearWidth) : 168
    }

    GaugeReadout {
        anchors.fill: parent
        decimals: root.config.decimals !== undefined ? Number(root.config.decimals) : 0
        offsetX: root.config.readoutOffsetX !== undefined ? Number(root.config.readoutOffsetX) : 0
        offsetY: root.config.readoutOffsetY !== undefined ? Number(root.config.readoutOffsetY) : (
                                                                root.config.valueOffsetY !== undefined ? Number(
                                                                                                             root.config.valueOffsetY) :
                                                                                                         50)
        spacing: root.config.readoutSpacing !== undefined ? Number(root.config.readoutSpacing) : -2
        stepSize: root.config.readoutStep !== undefined ? Number(root.config.readoutStep) : 100
        textColor: root.config.readoutTextColor !== undefined ? root.config.readoutTextColor : "#FFFFFF"
        unit: root.config.unit !== undefined ? root.config.unit : "RPM"
        unitOffsetX: root.config.unitOffsetX !== undefined ? Number(root.config.unitOffsetX) : 34
        unitOffsetY: root.config.unitOffsetY !== undefined ? Number(root.config.unitOffsetY) : -2
        unitScale: root.config.readoutUnitScale !== undefined ? Number(root.config.readoutUnitScale) : 0.076
        value: arc.displayValue
        valueScale: root.config.readoutValueScale !== undefined ? Number(root.config.readoutValueScale) : 0.213
    }
}
