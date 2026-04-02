// Copyright (c) 2026 Kai Wyborny. All rights reserved.
// Self-contained theme singleton for Prism.Keyboard module.
// Color palette derived from PowerTune's SettingsTheme for a consistent dark UI.
// All colors use neutral grays (no blue/purple tint).
// This file has no external dependencies so the module remains portable.
pragma Singleton
import QtQuick

QtObject {

    // -- Accent --
    readonly property color accent: "#009688"
    readonly property color accentPressed: "#00796B"
    // -- Background hierarchy (neutral grays, matching SettingsTheme) --
    readonly property color background: "#161718"

    // -- Borders --
    readonly property color border: "#3A3B3E"
    readonly property color borderStrong: "#505155"
    readonly property int borderWidth: 1
    readonly property int colorAnimationDuration: 80
    readonly property color controlBg: "#2F3032"

    // -- Sizing --
    readonly property int controlHeight: 48

    // -- Destructive / error --
    readonly property color error: "#F44336"
    readonly property color errorPressed: "#C62828"
    readonly property int fontAction: 14

    // -- Typography --
    readonly property string fontFamily: "Lato"
    readonly property int fontKey: 18
    readonly property int fontKeyLarge: 22
    readonly property int fontPreview: 16
    readonly property int keySpacing: 6

    // -- Animation --
    readonly property int pressAnimationDuration: 80
    readonly property real pressScale: 0.95
    readonly property int previewBarHeight: 32

    // -- Preview bar --
    readonly property color previewBg: "#1A1B1D"
    readonly property int radiusLarge: 8
    readonly property int radiusSmall: 6
    readonly property int scaleAnimationDuration: 60
    readonly property color surface: "#1E1F21"
    readonly property color surfaceElevated: "#272829"
    readonly property color surfacePressed: "#333436"
    readonly property color textDisabled: "#505258"
    readonly property color textOnAccent: "#FFFFFF"

    // -- Text --
    readonly property color textPrimary: "#ECEDEF"
    readonly property color textSecondary: "#8B8D93"
}
