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

    property bool showUnlockAnimation: false
    color: "black"
    height: 720
    minimumHeight: 720
    minimumWidth: 1600
    title: qsTr("PowerTune ") + Connection.Platform
    visible: true
    width: 1600

    Component.onCompleted: {
        if (popUpLoader.active)
            popUpLoader.visible = true;
    }

    SwipeView {
        id: dashView

        anchors.bottomMargin: prismKeyboard.visibleHeight
        anchors.fill: parent
        currentIndex: 0
        interactive: UI.draggable === 0 && DashboardLock.swipeAllowed

        Loader {
            id: firstPageLoader

            source: "qrc:/qt/qml/PrismPT/Dashboard/PowerTune/Dashboard/RaceDash.qml"
        }

        Item {
            id: lastPage

            SettingsManager {
            }
        }
    }

    Loader {
        id: secondPageLoader

        active: source !== ""
        source: ""
    }

    Loader {
        id: thirdPageLoader

        active: source !== ""
        source: ""
    }

    Loader {
        id: fourthPageLoader

        active: source !== ""
        source: ""
    }

    Loader {
        id: popUpLoader

        active: ScreenControl.shouldShowPopupOnStartup()
        anchors.right: parent.right
        source: active ? Qt.resolvedUrl("BrightnessPopUp.qml") : ""
        visible: false
        width: window.width * 0.15

        onItemChanged: {
            if (item)
                visible = true;
        }
    }

    PageIndicator {
        id: indicator

        anchors.bottom: dashView.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        count: dashView.count
        currentIndex: dashView.currentIndex
        visible: !DashboardLock.lockoutEnabled || DashboardLock.sessionUnlocked
    }

    PrismKeyboard {
        id: prismKeyboard

        parent: Overlay.overlay
    }

    Rectangle {
        anchors.fill: parent
        color: "#28000000"
        visible: DashboardLock.lockoutEnabled && (DashboardLock.unlocking || showUnlockAnimation)
        z: 20

        Item {
            anchors.centerIn: parent
            height: 312
            opacity: showUnlockAnimation ? 1.0 : 0.98
            scale: showUnlockAnimation ? 1.0 : 0.97
            width: 280

            Behavior on opacity {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutQuad
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: 260
                    easing.type: Easing.OutBack
                }
            }

            Rectangle {
                anchors.fill: parent
                border.color: showUnlockAnimation ? "#66A5D6A7" : "#334FC3F7"
                border.width: 1
                color: "#B0101010"
                radius: 28
            }

            Canvas {
                id: unlockProgressCanvas

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 28
                height: 168
                width: 168

                onPaint: {
                    var ctx = getContext("2d");
                    var lineWidth = 10;
                    var radius = (width - lineWidth) / 2;
                    var cx = width / 2;
                    var cy = height / 2;
                    var startAngle = -Math.PI / 2;
                    var progress = showUnlockAnimation ? 1 : (DashboardLock.holdProgressPercent / 100);

                    ctx.reset();
                    ctx.lineCap = "round";

                    ctx.beginPath();
                    ctx.strokeStyle = "rgba(255,255,255,0.18)";
                    ctx.lineWidth = lineWidth;
                    ctx.arc(cx, cy, radius, 0, Math.PI * 2, false);
                    ctx.stroke();

                    ctx.beginPath();
                    ctx.strokeStyle = showUnlockAnimation ? "#4CAF50" : "#4FC3F7";
                    ctx.lineWidth = lineWidth;
                    ctx.arc(cx, cy, radius, startAngle, startAngle + (Math.PI * 2 * progress), false);
                    ctx.stroke();
                }

                Connections {
                    function onHoldProgressPercentChanged() {
                        unlockProgressCanvas.requestPaint();
                    }

                    function onUnlockingChanged() {
                        unlockProgressCanvas.requestPaint();
                    }

                    target: DashboardLock
                }

                Connections {
                    function onShowUnlockAnimationChanged() {
                        unlockProgressCanvas.requestPaint();
                    }

                    target: window
                }

                onVisibleChanged: requestPaint()
            }

            MaterialIcon {
                anchors.centerIn: unlockProgressCanvas
                icon: showUnlockAnimation ? "lock_open" : "lock"
                iconColor: showUnlockAnimation ? "#4CAF50" : "white"
                iconSize: 38
            }

            Text {
                id: unlockTitle

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: unlockProgressCanvas.bottom
                anchors.topMargin: 20
                color: "white"
                font.family: SettingsTheme.fontFamily
                font.pixelSize: 22
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                text: showUnlockAnimation ? "Unlocked" : "Unlocking Dashboard"
                width: parent.width - 32
            }

            Text {
                id: unlockSubtitle

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: unlockTitle.bottom
                anchors.topMargin: 8
                color: showUnlockAnimation ? "#C8E6C9" : "#CFD8DC"
                font.family: SettingsTheme.fontFamily
                font.pixelSize: 15
                horizontalAlignment: Text.AlignHCenter
                text: showUnlockAnimation ? "Settings available until reboot" : "Hold either bottom corner"
                width: parent.width - 32
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: unlockSubtitle.bottom
                anchors.topMargin: 4
                color: showUnlockAnimation ? "#A5D6A7" : "#90CAF9"
                font.family: SettingsTheme.fontFamily
                font.pixelSize: 13
                horizontalAlignment: Text.AlignHCenter
                text: showUnlockAnimation ? "Swipe access restored" : (DashboardLock.holdProgressPercent + "% complete")
                width: parent.width - 32
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: "transparent"
        height: 120
        visible: DashboardLock.lockoutEnabled && !DashboardLock.sessionUnlocked
        width: 120
        z: 21

        MouseArea {
            anchors.fill: parent
            onCanceled: DashboardLock.cancelUnlockHold()
            onPressed: DashboardLock.beginUnlockHold()
            onReleased: DashboardLock.cancelUnlockHold()
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        color: "transparent"
        height: 120
        visible: DashboardLock.lockoutEnabled && !DashboardLock.sessionUnlocked
        width: 120
        z: 21

        MouseArea {
            anchors.fill: parent
            onCanceled: DashboardLock.cancelUnlockHold()
            onPressed: DashboardLock.beginUnlockHold()
            onReleased: DashboardLock.cancelUnlockHold()
        }
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

    Connections {
        function onSwipeAllowedChanged(allowed) {
            if (!allowed && dashView.currentIndex === dashView.count - 1)
                dashView.currentIndex = 0;
        }

        function onSessionUnlockedChanged(unlocked) {
            if (unlocked && DashboardLock.lockoutEnabled) {
                showUnlockAnimation = true;
                unlockAnimationTimer.restart();
            }
        }

        target: DashboardLock
    }

    Timer {
        id: unlockAnimationTimer

        interval: 1600
        repeat: false

        onTriggered: showUnlockAnimation = false
    }

    Loader {
        id: bootSplashLoader

        active: true
        anchors.fill: parent
        source: Qt.resolvedUrl("BootSplash.qml")
        z: 100

        Connections {
            function onFinished() {
                bootSplashLoader.visible = false;
                bootSplashLoader.source = "";
                bootSplashLoader.active = false;
            }

            target: bootSplashLoader.item
        }
    }
}
