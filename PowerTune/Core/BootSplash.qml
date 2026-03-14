import QtQuick 2.15
import QtMultimedia

Rectangle {
    id: splash

    signal finished

    anchors.fill: parent
    color: "black"
    property bool finishStarted: false

    function beginFinish() {
        if (finishStarted)
            return;
        finishStarted = true;
        finishTimer.stop();
        fadeOut.start();
    }

    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        anchors.rightMargin: -5
        fillMode: VideoOutput.PreserveAspectCrop
        clip: true
    }

    MediaPlayer {
        id: mediaPlayer
        videoOutput: videoOutput
        source: "file:///home/pi/bootsplash.mp4"

        onMediaStatusChanged: {
            if (mediaStatus === MediaPlayer.InvalidMedia
                    || mediaStatus === MediaPlayer.NoMedia) {
                splash.beginFinish();
            } else if ((mediaStatus === MediaPlayer.LoadedMedia
                        || mediaStatus === MediaPlayer.BufferedMedia)
                       && duration > 0) {
                finishTimer.interval = duration + 500;
                finishTimer.restart();
            }
        }

        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.StoppedState
                    && mediaStatus === MediaPlayer.EndOfMedia) {
                splash.beginFinish();
            }
        }

        onPositionChanged: {
            if (duration > 0 && position >= duration - 120)
                splash.beginFinish();
        }
    }

    Timer {
        id: finishTimer
        interval: 8000
        repeat: false

        onTriggered: splash.beginFinish()
    }

    OpacityAnimator {
        id: fadeOut
        target: splash
        from: 1.0
        to: 0.0
        duration: 300
        easing.type: Easing.InQuad

        onFinished: splash.finished()
    }

    Component.onCompleted: {
        finishTimer.start();
        mediaPlayer.play();
    }
}
