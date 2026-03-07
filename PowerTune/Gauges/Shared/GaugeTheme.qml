pragma Singleton
import QtQuick 2.15
import Qt.labs.settings 1.0

Item {
    id: theme
    visible: false
    width: 0
    height: 0

    property bool highContrast: _settings.highContrast

    Settings {
        id: _settings
        category: "GaugeTheme"
        property bool highContrast: false
    }

    function setHighContrast(enabled) {
        _settings.highContrast = enabled;
        theme.highContrast = enabled;
    }

    readonly property color bgPrimary: "#000000"
    readonly property color bgSecondary: highContrast ? "#000000" : "#1A1A1A"
    readonly property color bgPanel: highContrast ? "#111111" : "#0D0D0D"

    readonly property color arcTrack: highContrast ? "#333333" : "#222222"
    readonly property color arcFill: highContrast ? "#FFFF00" : "#88FF00"
    readonly property color arcDanger: "#FF0000"
    readonly property color arcWarning: highContrast ? "#FFFF00" : "#FF8800"

    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: highContrast ? "#CCCCCC" : "#888888"
    readonly property color textAccent: highContrast ? "#FFFFFF" : "#01E6DE"
    readonly property color textDim: highContrast ? "#999999" : "#555555"

    readonly property color needlePrimary: highContrast ? "#FFFFFF" : "#FF6600"
    readonly property color needleSecondary: highContrast ? "#CCCCCC" : "#CC3300"
    readonly property color needleGlow: highContrast ? Qt.rgba(1, 1, 1, 0.25) : Qt.rgba(1, 0.4, 0, 0.25)

    readonly property color warningColor: "#FF0000"
    readonly property color warningFlashA: highContrast ? "#FFFF00" : "#FF0000"
    readonly property color warningFlashB: highContrast ? "#000000" : "#330000"
    readonly property real warningFlashDuration: highContrast ? 150 : 250

    readonly property int borderWidth: highContrast ? 2 : 1
    readonly property color borderColor: highContrast ? "#FFFFFF" : "#333333"

    readonly property real fontSizeMultiplier: highContrast ? 1.15 : 1.0
    readonly property real labelFontFactor: 0.06
    readonly property real valueFontFactor: 0.35
    readonly property real unitFontFactor: 0.09

    readonly property string fontFamily: "Lato"
    readonly property string fontFamilyMono: "Roboto Mono"

    readonly property color menuBg: "#2A2A2A"
    readonly property color menuText: "#FFFFFF"
    readonly property color menuAccent: highContrast ? "#FFFF00" : "#01E6DE"
    readonly property color menuBorder: highContrast ? "#FFFFFF" : "#444444"

    readonly property string accessibleRoleGauge: "Indicator"

    readonly property color aimArcGreen: "#BBFF00"
    readonly property color aimArcYellowGreen: "#DDFF00"
    readonly property color aimArcYellow: "#FFCC00"
    readonly property color aimArcRed: "#FF2200"
    readonly property color aimArcTrack: "#2A2A2A"
    readonly property color aimGearColor: "#FFFFFF"
    readonly property color aimCellBorder: "#3A3A3A"
    readonly property color aimLabelGrey: "#999999"
    readonly property color aimUnitGrey: "#888888"
    readonly property color aimDimTick: "#555555"
    readonly property color aimBezelColor: "#222222"
    readonly property color aimNeedle: "#FFFFFF"
    readonly property color aimNeedleGlow: Qt.rgba(1, 1, 1, 0.15)
    readonly property color aimStatusGood: "#00FF00"
    readonly property color aimStatusWarning: "#FFAA00"
    readonly property color aimStatusBad: "#FF0000"
    readonly property color aimStatusBarBg: "#0A0A0A"
    readonly property color aimStatusBarText: "#BBBBBB"
    readonly property color aimPanelOuter: "#141414"
    readonly property color aimPanelInner: "#050505"
    readonly property color aimPanelInset: "#0B0B0B"
    readonly property color aimPanelGloss: Qt.rgba(1, 1, 1, 0.08)
    readonly property color aimPanelGlossSoft: Qt.rgba(1, 1, 1, 0.03)
    readonly property color aimPanelShadow: Qt.rgba(0, 0, 0, 0.65)
    readonly property color aimPanelStrokeBright: "#585858"
    readonly property color aimPanelStrokeSoft: "#242424"
    readonly property color aimSeparator: "#303030"
    readonly property color aimGaugeFaceOuter: "#0D0D0D"
    readonly property color aimGaugeFaceInner: "#010101"
    readonly property color aimGaugeInnerRing: "#1A1A1A"
    readonly property color aimGaugeSpecular: Qt.rgba(1, 1, 1, 0.07)
    readonly property color aimGaugeSpecularSoft: Qt.rgba(1, 1, 1, 0.02)
    readonly property color aimGaugeShadow: Qt.rgba(0, 0, 0, 0.72)
    readonly property color aimValueWhite: "#F7F7F7"
    readonly property color aimTextStrong: "#E7E7E7"
    readonly property color aimTextMuted: "#777777"
    readonly property color aimCyan: "#26D8F4"
    readonly property color aimLime: "#D9F500"
    readonly property color aimTrackName: "#8E8E8E"
    readonly property color aimBottomStrip: "#101010"
    readonly property color aimBottomStripEdge: "#1E1E1E"
    readonly property color aimBottomStripGlow: Qt.rgba(1, 1, 1, 0.04)
}
