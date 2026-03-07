pragma Singleton
import QtQuick 2.15

QtObject {
    readonly property color background: "#121212"
    readonly property color surface: "#1E1E1E"
    readonly property color surfaceElevated: "#2D2D2D"
    readonly property color accent: "#009688"
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textSecondary: "#B0B0B0"
    readonly property color border: "#3D3D3D"
    readonly property color success: "#4CAF50"
    readonly property color warning: "#FF9800"
    readonly property color error: "#F44336"

    readonly property int fontHeader: 28
    readonly property int fontBody: 22
    readonly property int fontCaption: 16
    readonly property int controlHeight: 44
    readonly property int controlWidth: 280
    readonly property int radius: 8
}
