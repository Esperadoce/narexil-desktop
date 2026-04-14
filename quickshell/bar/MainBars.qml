import "./."
import "../services"
import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    // All screens except OLED
    readonly property var mainScreens: {
        const result = []
        for (let i = 0; i < Quickshell.screens.length; i++) {
            const s = Quickshell.screens[i]
            if (s.name !== "HDMI-A-1") result.push(s)
        }
        return result
    }

    Variants {
        model: root.mainScreens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors { top: true; left: true; right: true }
            implicitHeight: Theme.barHeight + Theme.barMargin
            color: "transparent"
            margins {
                top:   0
                left:  0
                right: 0
            }

            // Floating pill
            Rectangle {
                anchors {
                    top: parent.top; topMargin: Theme.barMargin
                    left: parent.left; leftMargin: Theme.barMargin
                    right: parent.right; rightMargin: Theme.barMargin
                    bottom: parent.bottom
                }
                radius: Theme.barRadius
                color:  Theme.barBg
                border.color: Theme.barBorder
                border.width: 1

                // Left section
                Row {
                    id: leftSection
                    anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                    spacing: 4

                    Workspaces { screen: bar.screen }
                    ScratchpadWidget {}
                    WindowTitle { verticalAlignment: Text.AlignVCenter; height: Theme.barHeight - Theme.moduleMarginV * 2 }
                    MediaControls {}
                }

                // Center section
                Row {
                    anchors { centerIn: parent }
                    spacing: 8

                    WeatherWidget {}
                    ClockWidget {}
                }

                // Right section
                Row {
                    anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                    spacing: 4

                    GpuWidget {}
                    SysmonWidget {}
                    TrayWidget {}
                    BluetoothWidget {}
                    NetworkWidget {}
                    VolumeWidget {}
                    VpnWidget {}
                    PowerWidget {}
                }
            }
        }
    }
}
