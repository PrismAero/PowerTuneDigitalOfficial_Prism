import QtQuick 2.15
import QtQuick.Controls 2.15
import com.powertune 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0

Rectangle {
    id: popUp1
    color: "grey"
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    function dismiss() {
        if (popUp1.parent)
            popUp1.parent.visible = false;
    }

    onVisibleChanged: {
        if (visible)
            dismissTimer.restart();
    }

    Grid {
        id: buttonRow
        width: parent.width
        height: parent.height * 0.8
        topPadding: parent.width * 0.6
        rows: 2
        columns: 1
        layoutDirection: "RightToLeft"
        spacing: popUp1.width / 12

        Button {
            id: brightnessLow
            text: "Night"
            font.family: SettingsTheme.fontFamily
            font.bold: true
            width: popUp1.width / 1.2
            height: popUp1.width / 1.2
            font.pixelSize: popUp1.width / 7.5
            onClicked: {
                var val = Connect.hasDdcBrightness ? 10 : 25;
                Connect.setSreenbrightness(val);
                AppSettings.writebrightnessettings(val);
                dismiss();
            }
            background: Rectangle {
                radius: popUp1.width / 1.2
                opacity: enabled ? 1 : 0.3
                color: brightnessLow.down ? "darkgrey" : "grey"
                border.color: brightnessLow.down ? "grey" : "darkgrey"
                border.width: popUp1.width / 1.5
            }
        }

        Button {
            id: brightnessHigh
            text: "Day"
            font.family: SettingsTheme.fontFamily
            font.bold: true
            width: popUp1.width / 1.2
            height: popUp1.width / 1.2
            font.pixelSize: popUp1.width / 7.5
            onClicked: {
                var val = Connect.hasDdcBrightness ? 75 : 255;
                Connect.setSreenbrightness(val);
                AppSettings.writebrightnessettings(val);
                dismiss();
            }
            background: Rectangle {
                radius: popUp1.width / 1.2
                opacity: enabled ? 1 : 0.3
                color: brightnessHigh.down ? "darkgrey" : "grey"
                border.color: brightnessHigh.down ? "grey" : "darkgrey"
                border.width: popUp1.width / 1.5
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
