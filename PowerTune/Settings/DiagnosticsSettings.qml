import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import PowerTune.Settings 1.0
import PowerTune.UI 1.0

SettingsPage {
    id: root

    Component.onCompleted: {
        Diagnostics.activate()
        Diagnostics.setPageVisible(true)
    }
    Component.onDestruction: Diagnostics.setPageVisible(false)

    DiagSystemInfoSection {
        id: topRow
    }

    DiagSensorLogSection {
        Layout.fillWidth: true
        Layout.preferredHeight: root.height - (SettingsTheme.pageMargin * 2) - topRow.height
                                - SettingsTheme.sectionSpacing
    }

    DiagAnalogSection {}
    DiagDigitalSection {}
    DiagExpanderSection {}
    DiagCanSection {}
    DiagDfiSerialSection {}
}
