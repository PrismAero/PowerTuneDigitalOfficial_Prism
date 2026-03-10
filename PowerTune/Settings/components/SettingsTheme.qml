pragma Singleton
import QtQuick 2.15

QtObject {
    // -- Background hierarchy --
    readonly property color background: "#161718"
    readonly property color surface: "#1E1F21"
    readonly property color surfaceElevated: "#272829"
    readonly property color surfacePressed: "#2A2B2E"
    readonly property color controlBg: "#2F3032"

    // -- Text --
    readonly property color textPrimary: "#ECEDEF"
    readonly property color textSecondary: "#8B8D93"
    readonly property color textPlaceholder: "#787A82"
    readonly property color textDisabled: "#505258"

    // -- Borders --
    readonly property color border: "#3A3B3E"

    // -- Accent --
    readonly property color accent: "#009688"
    readonly property color accentPressed: "#00796B"

    // -- Semantic status --
    readonly property color success: "#4CAF50"
    readonly property color warning: "#FF9800"
    readonly property color error: "#F44336"
    readonly property color errorPressed: "#C62828"

    // -- Special purpose --
    readonly property color consoleBg: "#111213"
    readonly property color consoleText: "#4CAF50"

    // -- Spacing --
    readonly property int pageMargin: 16
    readonly property int sectionSpacing: 16
    readonly property int sectionPadding: 12
    readonly property int contentSpacing: 10
    readonly property int controlGap: 16
    readonly property int labelWidth: 180
    readonly property int tabBarHeight: 56
    readonly property int tabPaddingH: 16

    // -- Typography --
    readonly property string fontFamily: "Lato"
    readonly property string fontFamilyMono: "JetBrains Mono"
    readonly property int fontSectionTitle: 20
    readonly property int fontLabel: 18
    readonly property int fontControl: 18
    readonly property int fontTab: 18
    readonly property int fontStatus: 16
    readonly property int fontCaption: 14

    // -- Control sizes --
    readonly property int controlHeight: 48
    readonly property int buttonMinWidth: 100
    readonly property int textFieldMinWidth: 120
    readonly property int comboBoxMinWidth: 100
    readonly property int switchTrackWidth: 52
    readonly property int switchTrackHeight: 28
    readonly property int switchKnobSize: 22
    readonly property int checkBoxSize: 28
    readonly property int statusDotSize: 12

    // -- Border and radius --
    readonly property int radiusSmall: 6
    readonly property int radiusLarge: 8
    readonly property int borderWidth: 1
}
