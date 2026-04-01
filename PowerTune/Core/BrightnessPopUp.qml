import QtQuick 2.15
import QtQuick.Controls 2.15
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: popUp1

    function dismiss() {
        if (popUp1.parent) {
            popUp1.parent.visible = false;
            if (popUp1.parent.parent && popUp1.parent.parent.hasOwnProperty("brightnessPopupDismissed"))
                popUp1.parent.parent.brightnessPopupDismissed = true;
            if (popUp1.parent.hasOwnProperty("active"))
                popUp1.parent.active = false;
        }
    }

    color: "grey"
    height: parent ? parent.height : 0
    width: parent ? parent.width : 0

    onVisibleChanged: {
        if (visible)
            dismissTimer.restart();
    }

    Grid {
        id: buttonRow

        columns: 1
        height: parent.height * 0.8
        layoutDirection: "RightToLeft"
        rows: 2
        spacing: popUp1.width / 12
        topPadding: parent.width * 0.6
        width: parent.width

        Button {
            id: brightnessLow

            font.bold: true
            font.family: SettingsTheme.fontFamily
            font.pixelSize: popUp1.width / 7.5
            height: popUp1.width / 1.2
            text: "Night"
            width: popUp1.width / 1.2

            background: Rectangle {
                border.color: brightnessLow.down ? "grey" : "darkgrey"
                border.width: popUp1.width / 1.5
                color: brightnessLow.down ? "darkgrey" : "grey"
                opacity: enabled ? 1 : 0.3
                radius: popUp1.width / 1.2
            }

            onClicked: {
                ScreenControl.applyNightPreset();
                dismiss();
            }
        }

        Button {
            id: brightnessHigh

            font.bold: true
            font.family: SettingsTheme.fontFamily
            font.pixelSize: popUp1.width / 7.5
            height: popUp1.width / 1.2
            text: "Day"
            width: popUp1.width / 1.2

            background: Rectangle {
                border.color: brightnessHigh.down ? "grey" : "darkgrey"
                border.width: popUp1.width / 1.5
                color: brightnessHigh.down ? "darkgrey" : "grey"
                opacity: enabled ? 1 : 0.3
                radius: popUp1.width / 1.2
            }

            onClicked: {
                ScreenControl.applyDayPreset();
                dismiss();
            }
        }
    }

    Timer {
        id: dismissTimer

        interval: 8000
        running: true

        onTriggered: dismiss()
    }
}
