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

                BarContent {
                    anchors.fill: parent
                    screen: bar.screen
                }
            }
        }
    }
}
