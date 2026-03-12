import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import com.powertune 1.0
import PowerTune.Core 1.0
import PowerTune.UI 1.0
import PowerTune.Utils 1.0
import Prism.Keyboard 1.0

ApplicationWindow {
    id: window
    visible: true
    property bool settingsLoaded: false

    width: 1600
    height: 720
    minimumWidth: 1600
    minimumHeight: 720
    title: qsTr("PowerTune ") + Connection.Platform
    color: "black"

    readonly property bool isDdc: Connect.hasDdcBrightness
    property int currentBrightness: isDdc ? 50 : 175

    property int digitalInput1: Digital ? Digital.EXDigitalInput1 : 0
    property int digitalInput2: Digital ? Digital.EXDigitalInput2 : 0
    property int digitalInput3: Digital ? Digital.EXDigitalInput3 : 0
    property int digitalInput4: Digital ? Digital.EXDigitalInput4 : 0
    property int digitalInput5: Digital ? Digital.EXDigitalInput5 : 0
    property int digitalInput6: Digital ? Digital.EXDigitalInput6 : 0
    property int digitalInput7: Digital ? Digital.EXDigitalInput7 : 0
    property int digitalInput8: Digital ? Digital.EXDigitalInput8 : 0

    function applyBrightness(val) {
        currentBrightness = val;
        Connect.setSreenbrightness(val);
        AppSettings.writebrightnessettings(val);
    }

    function adjustBrightness(delta) {
        var step = isDdc ? 25 : 50;
        var min = isDdc ? 0 : 25;
        var max = isDdc ? 75 : 250;
        var next = currentBrightness + (delta * step);
        applyBrightness(Math.max(min, Math.min(max, next)));
    }

    function handleDigitalBrightness() {
        if (custom.maxBrightnessOnBoot !== 1)
            return;
        var inputs = [digitalInput1, digitalInput2, digitalInput3, digitalInput4, digitalInput5, digitalInput6, digitalInput7, digitalInput8];
        var current = inputs[custom.digiValue];
        if (current === 1)
            applyBrightness(0);
        else if (current === 0)
            applyBrightness(isDdc ? 60 : 235);
    }

    Component.onCompleted: {
        popUpLoader.enabled = AppSettings.getValue("ui/brightnessPopupEnabled", true);
        settingsLoaded = true;
        popUpLoader.sourceComponent = Qt.createComponent("BrightnessPopUp.qml");
        custom.executeOnBootAction();
        handleDigitalBrightness();
    }

    Connections {
        target: UI
        function onBrightnessChanged() {
            brightness.value = UI.Brightness;
        }
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
        currentIndex: 0
        interactive: UI.draggable === 0
        anchors.fill: parent
        anchors.bottomMargin: prismKeyboard.visibleHeight

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
            SettingsManager {}
        }
    }

    ExBoardAnalog {
        id: custom
        visible: false
    }

    function showBrightnessPopup() {
        popUpLoader.visible = true;
    }

    Loader {
        id: popUpLoader
        visible: false
        anchors.right: parent.right
        width: window.width * 0.15
        onEnabledChanged: if (settingsLoaded)
            AppSettings.setValue("ui/brightnessPopupEnabled", enabled)
        Component.onCompleted: {
            if (popUpLoader.enabled)
                visible = true;
        }
    }

    Drawer {
        id: drawerpopup
        width: window.width
        height: 0.5 * window.height
        edge: Qt.TopEdge
        background: Rectangle {
            color: SettingsTheme.surface
            opacity: 0.95
            radius: SettingsTheme.radiusLarge
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: SettingsTheme.pageMargin
            spacing: SettingsTheme.sectionSpacing

            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                spacing: SettingsTheme.contentSpacing

                StyledButton {
                    text: "Trip Reset"
                    onClicked: Calculations.resettrip()
                    implicitWidth: 100
                }

                StyledButton {
                    text: "Shutdown"
                    danger: true
                    onClicked: Connect.shutdown()
                    implicitWidth: 100
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: SettingsTheme.contentSpacing

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    Image {
                        height: 32
                        width: 32
                        source: "qrc:/Resources/graphics/brightness.png"
                    }

                    Slider {
                        id: brightness
                        Layout.preferredWidth: window.width / 3
                        Layout.preferredHeight: 36
                        stepSize: 5
                        from: isDdc ? 0 : 20
                        to: isDdc ? 100 : 255
                        value: UI.Brightness
                        onMoved: applyBrightness(value)
                    }
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: SettingsTheme.controlGap

                    Text {
                        text: "Brightness Pop Up at Boot"
                        color: SettingsTheme.textPrimary
                        font.family: SettingsTheme.fontFamily
                        font.pixelSize: SettingsTheme.fontLabel
                    }

                    StyledSwitch {
                        id: disablePopUp
                        checked: popUpLoader.enabled
                        onCheckedChanged: {
                            popUpLoader.enabled = checked;
                            popUpLoader.visible = false;
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                spacing: SettingsTheme.contentSpacing

                StyledButton {
                    text: "+"
                    onClicked: adjustBrightness(1)
                    implicitWidth: 48
                    implicitHeight: 48
                }
                StyledButton {
                    text: "-"
                    onClicked: adjustBrightness(-1)
                    implicitWidth: 48
                    implicitHeight: 48
                }
            }
        }
    }

    PageIndicator {
        id: indicator
        count: dashView.count
        currentIndex: dashView.currentIndex
        anchors.bottom: dashView.bottom
        anchors.horizontalCenter: parent.horizontalCenter
    }

    PrismKeyboard {
        id: prismKeyboard
        parent: Overlay.overlay
    }

    Connections {
        target: window
        function onActiveFocusItemChanged() {
            var item = window.activeFocusItem;
            if (item && item.hasOwnProperty("text") && item.hasOwnProperty("cursorPosition") && item.hasOwnProperty("inputMethodHints") && !item.hasOwnProperty("currentIndex") && (!item.hasOwnProperty("readOnly") || !item.readOnly)) {
                prismKeyboard.show(item);
            } else {
                if (prismKeyboard.visible)
                    prismKeyboard.hide();
            }
        }
    }
}
