import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import com.powertune 1.0
import PowerTune.Core 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0
import Prism.Keyboard 1.0

ApplicationWindow {
    id: window

    property int currentBrightness: isDdc ? 50 : 175
    property int digitalInput1: Digital ? Digital.EXDigitalInput1 : 0
    property int digitalInput2: Digital ? Digital.EXDigitalInput2 : 0
    property int digitalInput3: Digital ? Digital.EXDigitalInput3 : 0
    property int digitalInput4: Digital ? Digital.EXDigitalInput4 : 0
    property int digitalInput5: Digital ? Digital.EXDigitalInput5 : 0
    property int digitalInput6: Digital ? Digital.EXDigitalInput6 : 0
    property int digitalInput7: Digital ? Digital.EXDigitalInput7 : 0
    property int digitalInput8: Digital ? Digital.EXDigitalInput8 : 0
    readonly property bool isDdc: Connect.hasDdcBrightness
    property bool settingsLoaded: false

    function adjustBrightness(delta) {
        var step = isDdc ? 25 : 50;
        var min = isDdc ? 0 : 25;
        var max = isDdc ? 75 : 250;
        var next = currentBrightness + (delta * step);
        applyBrightness(Math.max(min, Math.min(max, next)));
    }

    function applyBrightness(val) {
        currentBrightness = val;
        Connect.setSreenbrightness(val);
        AppSettings.writebrightnessettings(val);
    }

    function handleDigitalBrightness() {
        if (custom.maxBrightnessOnBoot !== 1)
            return;
        var inputs = [digitalInput1, digitalInput2, digitalInput3, digitalInput4, digitalInput5, digitalInput6,
                      digitalInput7, digitalInput8];
        var current = inputs[custom.digiValue];
        if (current === 1)
            applyBrightness(0);
        else if (current === 0)
            applyBrightness(isDdc ? 60 : 235);
    }

    function showBrightnessPopup() {
        popUpLoader.visible = true;
    }

    color: "black"
    height: 720
    minimumHeight: 720
    minimumWidth: 1600
    title: qsTr("PowerTune ") + Connection.Platform
    visible: true
    width: 1600

    Component.onCompleted: {
        popUpLoader.enabled = AppSettings.getValue("ui/brightnessPopupEnabled", true);
        settingsLoaded = true;
        popUpLoader.sourceComponent = Qt.createComponent("BrightnessPopUp.qml");
        custom.executeOnBootAction();
        handleDigitalBrightness();
    }
    onDigitalInput1Changed: handleDigitalBrightness()
    onDigitalInput2Changed: handleDigitalBrightness()
    onDigitalInput3Changed: handleDigitalBrightness()
    onDigitalInput4Changed: handleDigitalBrightness()
    onDigitalInput5Changed: handleDigitalBrightness()
    onDigitalInput6Changed: handleDigitalBrightness()
    onDigitalInput7Changed: handleDigitalBrightness()
    onDigitalInput8Changed: handleDigitalBrightness()

    Timer {
        interval: 1200
        running: true

        onTriggered: {
            if (custom.maxBrightnessOnBoot === 1)
                applyBrightness(isDdc ? 75 : 250);
        }
    }

    SwipeView {
        id: dashView

        anchors.bottomMargin: prismKeyboard.visibleHeight
        anchors.fill: parent
        currentIndex: 0
        interactive: UI.draggable === 0

        Loader {
            id: firstPageLoader

            source: Qt.resolvedUrl("Intro.qml")
        }

        Loader {
            id: secondPageLoader

            active: UI.Visibledashes > 1
            source: ""
        }

        Loader {
            id: thirdPageLoader

            active: UI.Visibledashes > 2
            source: ""
        }

        Loader {
            id: fourthPageLoader

            active: UI.Visibledashes > 3
            source: ""
        }

        Item {
            id: lastPage

            SettingsManager {
            }
        }
    }

    ExBoardAnalog {
        id: custom

        visible: false
    }

    Loader {
        id: popUpLoader

        anchors.right: parent.right
        visible: false
        width: window.width * 0.15

        Component.onCompleted: {
            if (popUpLoader.enabled)
                visible = true;
        }
        onEnabledChanged: if (settingsLoaded)
                              AppSettings.setValue("ui/brightnessPopupEnabled", enabled)
    }

    PageIndicator {
        id: indicator

        anchors.bottom: dashView.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        count: dashView.count
        currentIndex: dashView.currentIndex
    }

    PrismKeyboard {
        id: prismKeyboard

        parent: Overlay.overlay
    }

    Connections {
        function onActiveFocusItemChanged() {
            var item = window.activeFocusItem;
            if (item && item.hasOwnProperty("text") && item.hasOwnProperty("cursorPosition") && item.hasOwnProperty(
                        "inputMethodHints") && !item.hasOwnProperty("currentIndex") && (!item.hasOwnProperty(
                                                                                            "readOnly") ||
                                                                                        !item.readOnly)) {
                prismKeyboard.show(item);
            } else {
                if (prismKeyboard.visible)
                    prismKeyboard.hide();
            }
        }

        target: window
    }
}
