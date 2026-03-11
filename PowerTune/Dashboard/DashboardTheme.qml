pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property int dashboardWidth: 1600
    readonly property int dashboardHeight: 720

    readonly property string backgroundAsset: "qrc:/Resources/graphics/Racedash_AiM.png"

    readonly property color backgroundColor: "#0C0C0C"

    readonly property string fontFamily: "Hyperspace Race"

    readonly property real shiftPillWidth: 75
    readonly property real shiftPillHeight: 30
    readonly property real shiftPillGap: 10
    readonly property real shiftPillRadius: 40
    readonly property int shiftPillCount: 11
    readonly property var shiftPillColors: [
        "#1ED033", "#1ED033", "#1ED033",
        "#F1E83C", "#F1E83C",
        "#FF0909",
        "#F1E83C", "#F1E83C",
        "#1ED033", "#1ED033", "#1ED033"
    ]

    readonly property color tachArcColorStart: "#E88A1A"
    readonly property color tachArcColorEnd: "#C45A00"
    readonly property color speedArcColorStart: "#AA1111"
    readonly property color speedArcColorEnd: "#880000"
    readonly property color arcBgColor: "#151518"

    readonly property real arcValueFontSize: 122.511
    readonly property real arcUnitFontSize: 43.754
    readonly property real gearFontSize: 140.013
    readonly property real gearSuffixFontSize: 52.505

    readonly property real sensorLabelFontSize: 40
    readonly property real sensorValueFontSize: 68
    readonly property real sensorValueTracking: -2.72
    readonly property real sensorUnitFontSize: 32

    readonly property real statusRowFontSize: 32
    readonly property color statusActiveColor: "#1ED033"
    readonly property color statusOffColor: "#FF0909"

    readonly property real brakeBiasTitleFontSize: 40
    readonly property real brakeBiasLabelFontSize: 32

    readonly property real bottomBarFontSize: 24
    readonly property real bottomBarTracking: -0.96
    readonly property real bottomBarStatusLightSize: 16

    readonly property color textColor: "#FFFFFF"
    readonly property color textShadowColor: "#40000000"
    readonly property real textShadowOffset: 4
    readonly property real textShadowRadius: 4

    readonly property real defaultShiftX: 337
    readonly property real defaultShiftY: 37
    readonly property real defaultTachX: 515.936
    readonly property real defaultTachY: 90.001
    readonly property real defaultTachSize: 575.051
    readonly property real defaultSpeedX: 1022.751
    readonly property real defaultSpeedY: 167.751
    readonly property real defaultSpeedSize: 503.17
    readonly property real defaultWaterTempX: 66
    readonly property real defaultWaterTempY: 62
    readonly property real defaultOilPressureX: 66
    readonly property real defaultOilPressureY: 250
    readonly property real defaultStatusRow0X: 66
    readonly property real defaultStatusRow0Y: 409
    readonly property real defaultStatusRow1X: 66
    readonly property real defaultStatusRow1Y: 472
    readonly property real defaultBrakeBiasX: 62
    readonly property real defaultBrakeBiasY: 570
    readonly property real defaultBottomBarX: 0
    readonly property real defaultBottomBarY: 680
}
