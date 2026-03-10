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
        currentBrightness = val
        Connect.setSreenbrightness(val)
        AppSettings.writebrightnessettings(val)
    }

    function adjustBrightness(delta) {
        var step = isDdc ? 25 : 50
        var min = isDdc ? 0 : 25
        var max = isDdc ? 75 : 250
        var next = currentBrightness + (delta * step)
        applyBrightness(Math.max(min, Math.min(max, next)))
    }

    function handleDigitalBrightness() {
        if (custom.maxBrightnessOnBoot !== 1) return
        var inputs = [digitalInput1, digitalInput2, digitalInput3, digitalInput4,
                      digitalInput5, digitalInput6, digitalInput7, digitalInput8]
        var current = inputs[custom.digiValue]
        if (current === 1)
            applyBrightness(0)
        else if (current === 0)
            applyBrightness(isDdc ? 60 : 235)
    }

    Component.onCompleted: {
        popUpLoader.enabled = AppSettings.getValue("ui/brightnessPopupEnabled", true)
        settingsLoaded = true
        popUpLoader.sourceComponent = Qt.createComponent("BrightnessPopUp.qml")
        custom.executeOnBootAction()
        handleDigitalBrightness()
    }

    Connections {
        target: UI
        function onBrightnessChanged() {
            brightness.value = UI.Brightness
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
                applyBrightness(isDdc ? 75 : 250)
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
        popUpLoader.visible = true
    }

    Loader {
        id: popUpLoader
        visible: false
        anchors.right: parent.right
        width: window.width * 0.15
        onEnabledChanged: if (settingsLoaded) AppSettings.setValue("ui/brightnessPopupEnabled", enabled)
        Component.onCompleted: {
            if (popUpLoader.enabled)
                visible = true
        }
    }

    Drawer {
        id: drawerpopup
        width: window.width
        height: 0.5 * window.height
        edge: Qt.TopEdge
        background: Rectangle {
            color: "grey"
            opacity: 0.8
            Rectangle {
                x: parent.width - 3
                width: 1
                height: parent.height
                color: "black"
            }
        }

        Grid {
            id: row1
            rows: 2
            columns: 1
            topPadding: window.width / 40
            spacing: window.width / 30
            anchors.top: drawerpopup.top
            anchors.left: parent.left

            Button {
                id: btntripreset
                text: "Trip Reset"
                font.family: SettingsTheme.fontFamily
                font.bold: true
                width: window.width / 13
                height: window.width / 13
                font.pixelSize: window.width / 100
                onClicked: Calculations.resettrip()
                background: Rectangle {
                    radius: window.width / 10
                    opacity: enabled ? 1 : 0.3
                    color: btntripreset.down ? "darkgrey" : "grey"
                    border.color: btntripreset.down ? "grey" : "darkgrey"
                    border.width: window.width / 200
                }
            }

            Button {
                id: btnshutdown
                text: "Shutdown"
                font.family: SettingsTheme.fontFamily
                font.bold: true
                width: window.width / 13
                height: window.width / 13
                font.pixelSize: window.width / 100
                onClicked: Connect.shutdown()
                background: Rectangle {
                    radius: window.width / 10
                    opacity: enabled ? 1 : 0.3
                    color: btnshutdown.down ? "darkred" : "red"
                    border.color: btnshutdown.down ? "red" : "darkred"
                    border.width: window.width / 200
                }
            }
        }

        Grid {
            id: row4
            rows: 2
            columns: 1
            topPadding: window.width / 40
            spacing: window.width / 30
            anchors.top: drawerpopup.top
            anchors.right: parent.right

            Row {
                Button {
                    id: plusBrightness
                    font.family: SettingsTheme.fontFamily
                    font.bold: true
                    width: window.width / 13
                    height: window.width / 13
                    font.pixelSize: window.width / 30
                    onClicked: adjustBrightness(1)
                    background: Rectangle {
                        radius: window.width / 10
                        opacity: enabled ? 1 : 0.3
                        color: plusBrightness.down ? "darkgrey" : "grey"
                        border.color: plusBrightness.down ? "grey" : "darkgrey"
                        border.width: window.width / 200
                    }
                    Image {
                        source: "qrc:/Resources/graphics/brightnessIncrease.png"
                        width: plusBrightness.width
                        height: plusBrightness.height
                        anchors.centerIn: plusBrightness
                    }
                }
            }

            Row {
                Button {
                    id: minusBrightness
                    font.family: SettingsTheme.fontFamily
                    font.bold: true
                    width: window.width / 13
                    height: window.width / 13
                    font.pixelSize: window.width / 30
                    onClicked: adjustBrightness(-1)
                    background: Rectangle {
                        radius: window.width / 10
                        opacity: enabled ? 1 : 0.3
                        color: minusBrightness.down ? "darkgrey" : "grey"
                        border.color: minusBrightness.down ? "grey" : "darkgrey"
                        border.width: window.width / 200
                    }
                    Image {
                        source: "qrc:/Resources/graphics/brightnessDecrease.png"
                        width: minusBrightness.width
                        height: minusBrightness.height
                        anchors.centerIn: minusBrightness
                    }
                }
            }
        }

        Grid {
            id: row3
            columns: 1
            spacing: window.width / 160
            anchors.top: drawerpopup.top
            anchors.topMargin: drawerpopup.height / 30
            anchors.horizontalCenter: parent.horizontalCenter

            Row {
                spacing: 12

                Image {
                    height: window.height / 15
                    width: height
                    source: "qrc:/Resources/graphics/brightness.png"
                    anchors.verticalCenter: parent.verticalCenter
                }

                Slider {
                    id: brightness
                    width: window.width / 3
                    height: window.height / 15
                    stepSize: 5
                    from: isDdc ? 0 : 20
                    to: isDdc ? 100 : 255
                    value: UI.Brightness
                    onMoved: applyBrightness(value)
                }
            }

            Row {
                Rectangle {
                    id: switchRectangle
                    width: window.width / 4
                    height: window.width / 15
                    color: "transparent"
                    Text {
                        id: switchText
                        text: "Brightness Pop Up at Boot"
                        anchors.centerIn: parent
                        color: "black"
                        font.family: SettingsTheme.fontFamily
                        font.bold: true
                        font.pixelSize: window.width / 70
                    }
                }

                Switch {
                    id: disablePopUp
                    checked: popUpLoader.enabled
                    font.family: SettingsTheme.fontFamily
                    font.bold: true
                    width: window.width / 7
                    height: window.width / 15
                    font.pixelSize: window.width / 70
                    onToggled: {
                        popUpLoader.enabled = checked
                        popUpLoader.visible = false
                    }
                    contentItem: Text {
                        leftPadding: disablePopUp.indicator.width + disablePopUp.spacing
                        text: disablePopUp.checked ? "On" : "Off"
                        font: disablePopUp.font
                        opacity: enabled ? 1.0 : 0.3
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
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
            var item = window.activeFocusItem
            if (item
                && item.hasOwnProperty("text")
                && item.hasOwnProperty("cursorPosition")
                && item.hasOwnProperty("inputMethodHints")
                && !item.hasOwnProperty("currentIndex")
                && (!item.hasOwnProperty("readOnly") || !item.readOnly)) {
                prismKeyboard.show(item)
            } else {
                if (prismKeyboard.visible)
                    prismKeyboard.hide()
            }
        }
    }
}
