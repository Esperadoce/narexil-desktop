pragma Singleton
pragma ComponentBehavior: Bound
import "../services"
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Singleton {
    id: root

    property bool shown: false
    function show(): void   { root.shown = true  }
    function hide(): void   { root.shown = false }
    function toggle(): void { root.shown = !root.shown }

    readonly property ShellScreen activeScreen: {
        const n = Hyprland.focusedMonitor?.name ?? ""
        for (let i = 0; i < Quickshell.screens.length; i++)
            if (Quickshell.screens[i].name === n) return Quickshell.screens[i]
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    }

    IpcHandler {
        target: "powermenu"
        function show(): void   { root.show() }
        function hide(): void   { root.hide() }
        function toggle(): void { root.toggle() }
    }

    PanelWindow {
        id: overlay
        screen: root.activeScreen
        visible: root.shown
        color: Qt.rgba(0, 0, 0, 0.4)

        anchors { top: true; left: true; right: true; bottom: true }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        MouseArea {
            anchors.fill: parent; z: -1
            onClicked: root.hide()
        }

        Rectangle {
            width: 220
            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            implicitHeight: col.implicitHeight + 24
            radius: 12
            color:  Theme.panelBg
            border.color: Theme.cyanBorder
            border.width: 1

            ColumnLayout {
                id: col
                anchors { fill: parent; margins: 12 }
                spacing: 6

                Repeater {
                    model: [
                        { label: "  Shutdown", cmd: ["systemctl", "poweroff"] },
                        { label: "  Reboot",   cmd: ["systemctl", "reboot"]   },
                        { label: "  Suspend",  cmd: ["systemctl", "suspend"]  },
                        { label: "  Logout",   cmd: []                        }
                    ]

                    delegate: Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        height: 40; radius: 8
                        color: hov.containsMouse ? Qt.rgba(1, 0.31, 0.31, 0.18) : Qt.rgba(1,1,1,0.06)
                        Behavior on color { ColorAnimation { duration: 120 } }

                        Text {
                            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
                            text: modelData.label
                            font.pixelSize: 13; font.family: Theme.font
                            color: hov.containsMouse ? Theme.red : Theme.textPrimary
                            Behavior on color { ColorAnimation { duration: 120 } }
                        }

                        MouseArea {
                            id: hov; anchors.fill: parent; hoverEnabled: true
                            onClicked: {
                                root.hide()
                                if (modelData.cmd.length > 0)
                                    Quickshell.execDetached(modelData.cmd)
                                else
                                    Hyprland.dispatch("exit")
                            }
                        }
                    }
                }
            }
        }

        Keys.onEscapePressed: root.hide()
    }
}
