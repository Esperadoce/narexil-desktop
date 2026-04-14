pragma ComponentBehavior: Bound
import "../services"
import Quickshell
import Quickshell.Hyprland
import QtQuick

Rectangle {
    id: root
    required property ShellScreen screen

    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color:  Theme.moduleBg
    implicitWidth: row.implicitWidth + 8

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: event => {
            Hyprland.dispatch(event.angleDelta.y > 0 ? "workspace r-1" : "workspace r+1")
        }
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 0

        Repeater {
            model: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

            delegate: Rectangle {
                required property int modelData

                readonly property bool isActive: Hyprland.focusedWorkspace?.id === modelData
                readonly property bool hasWin: Hyprland.workspaces.values.some(
                    w => w.id === modelData && (w.lastIpcObject?.windows ?? 0) > 0
                )

                width:  isActive ? 34 : 26
                height: root.height
                radius: 6
                color:  isActive ? Theme.cyan : "transparent"

                Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 120 } }

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 10
                    font.family:    Theme.font
                    font.weight:    parent.isActive ? Font.Bold : Font.Normal
                    color: {
                        if (parent.isActive) return "#0a0a0a"
                        if (parent.hasWin)   return "#888888"
                        return Theme.textInactive
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch(`workspace ${modelData}`)
                }
            }
        }
    }
}
