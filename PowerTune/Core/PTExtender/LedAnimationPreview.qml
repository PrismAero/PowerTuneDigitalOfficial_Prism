import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.UI 1.0

Rectangle {
    id: root

    property color colorA: "#00ff00"
    property color colorB: "#ff0000"
    property color colorC: "#0000ff"
    property int pattern: 1
    property int param1: 1200
    property int param2: 0
    property int ledType: 3

    property color previewColor: colorA
    property real previewOpacity: 1.0
    property int elapsedMs: 0

    function lerpColor(c1, c2, t) {
        return Qt.rgba(
                    c1.r + (c2.r - c1.r) * t,
                    c1.g + (c2.g - c1.g) * t,
                    c1.b + (c2.b - c1.b) * t,
                    c1.a + (c2.a - c1.a) * t
                    );
    }

    function updatePreview() {
        const p1 = Math.max(1, param1);
        const p2 = Math.max(1, param2);

        if (pattern === 0) {
            previewColor = colorA;
            previewOpacity = 0.05;
            return;
        }
        if (pattern === 1) {
            previewColor = colorA;
            previewOpacity = 1.0;
            return;
        }
        if (pattern === 2 || pattern === 8) { // BLINK or STROBE
            const onMs = (pattern === 8) ? 40 : p1;
            const offMs = (pattern === 8) ? 40 : p2;
            const period = onMs + offMs;
            const phase = elapsedMs % period;
            previewColor = colorA;
            previewOpacity = phase < onMs ? 1.0 : 0.08;
            return;
        }
        if (pattern === 3 || pattern === 9) { // PULSE or BREATHE
            const phase = (elapsedMs % p1) / p1;
            const tri = phase < 0.5 ? (phase * 2.0) : (2.0 - phase * 2.0);
            previewColor = colorA;
            previewOpacity = pattern === 9 ? Math.pow(tri, 2.0) : tri;
            return;
        }
        if (pattern === 4) { // CHASE (single swatch approximation)
            const phase = (elapsedMs % p1) / p1;
            previewColor = colorA;
            previewOpacity = phase < 0.33 ? 1.0 : 0.12;
            return;
        }
        if (pattern === 5) { // BICOLOR_BLINK
            const period = p1 + p2;
            const phase = elapsedMs % period;
            previewColor = phase < p1 ? colorA : colorB;
            previewOpacity = 1.0;
            return;
        }
        if (pattern === 6) { // BICOLOR_PULSE
            const phase = (elapsedMs % p1) / p1;
            const t = phase < 0.5 ? phase * 2.0 : (2.0 - phase * 2.0);
            previewColor = lerpColor(colorA, colorB, t);
            previewOpacity = 1.0;
            return;
        }
        if (pattern === 7) { // TRICOLOR_CYCLE
            const segment = Math.floor((elapsedMs % (p1 * 3)) / p1);
            previewColor = segment === 0 ? colorA : (segment === 1 ? colorB : colorC);
            previewOpacity = 1.0;
            return;
        }

        previewColor = colorA;
        previewOpacity = 1.0;
    }

    width: 32
    height: 32
    radius: 6
    border.color: SettingsTheme.border
    border.width: 1
    color: root.previewColor
    opacity: root.previewOpacity

    Timer {
        interval: 40
        repeat: true
        running: true
        onTriggered: {
            root.elapsedMs += interval
            root.updatePreview()
        }
    }

    Component.onCompleted: root.updatePreview()
    onPatternChanged: root.updatePreview()
    onColorAChanged: root.updatePreview()
    onColorBChanged: root.updatePreview()
    onColorCChanged: root.updatePreview()
}
