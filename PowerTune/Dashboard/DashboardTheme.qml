pragma Singleton
import QtQuick 2.15

QtObject {
    // Dashboard theming intentionally separate from Settings/UI theme.
    readonly property color panelBackground: "#3a3a3a"
    readonly property color panelBorder: "#5a5a5a"
    readonly property color panelText: "#FFFFFF"
    readonly property int panelRadius: 6
}
