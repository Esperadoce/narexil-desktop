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
    implicitWidth: Math.max(row.implicitWidth + 8, 32)

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
        spacing: 2

        Repeater {
            model: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

            delegate: Item {
                required property int modelData

                readonly property bool isActive: Hyprland.focusedWorkspace?.id === modelData
                readonly property bool hasWin: Hyprland.workspaces.values.some(
                    w => w.id === modelData && (w.lastIpcObject?.windows ?? 0) > 0
                )
                readonly property bool visible2: isActive || hasWin

                visible: visible2
                width:   visible2 ? pill.width : 0
                height:  root.height

                Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                Rectangle {
                    id: pill
                    width:  isActive ? 32 : 20
                    height: root.height
                    radius: 6
                    color:  isActive ? "transparent" : (hov.containsMouse ? Qt.rgba(1,1,1,0.10) : Qt.rgba(1,1,1,0.05))

                    Behavior on width { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 120 } }

                    // Gradient fill for active workspace
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        visible: isActive
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Theme.cyan }
                            GradientStop { position: 1.0; color: Theme.green }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 10
                        font.family:    Theme.font
                        font.weight:    isActive ? Font.Bold : Font.Normal
                        color: isActive ? "#0a0a0a" : (hasWin ? Theme.textMuted : Theme.textDimmer)
                    }

                    MouseArea {
                        id: hov
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch(`workspace ${modelData}`)
                    }
                }
            }
        }
    }
}
