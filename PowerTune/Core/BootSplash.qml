import QtQuick 2.15
import QtMultimedia

Rectangle {
    id: splash

    signal finished

    anchors.fill: parent
    color: "black"

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
                fadeOut.start();
            }
        }

        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.StoppedState
                    && mediaStatus === MediaPlayer.EndOfMedia) {
                fadeOut.start();
            }
        }
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

    Component.onCompleted: mediaPlayer.play()
}
