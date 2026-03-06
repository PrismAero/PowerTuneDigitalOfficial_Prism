pragma Singleton
import QtQuick 2.15
import Qt.labs.settings 1.0

QtObject {
    id: theme

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
}
