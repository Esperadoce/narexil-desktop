import "./."
import "../services"
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
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
        target: "dashboard"
        function show(): void   { root.show() }
        function hide(): void   { root.hide() }
        function toggle(): void { root.toggle() }
    }

    PanelWindow {
        id: overlay
        screen: root.activeScreen
        visible: root.shown || slideAnim.running
        color: "transparent"

        anchors { top: true; left: true; right: true; bottom: true }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        // Click-outside to dismiss
        MouseArea {
            anchors.fill: parent; z: -1
            onClicked: root.hide()
        }

        property real slideY: root.shown ? 56 : -(panel.height + 60)
        Behavior on slideY {
            NumberAnimation { id: slideAnim; duration: 220; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: panel
            y: overlay.slideY
            width: 520
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 12
            color:  Theme.panelBg
            border.color: Theme.cyanBorder
            border.width: 1
            implicitHeight: col.implicitHeight + 16

            MouseArea { anchors.fill: parent }

            ColumnLayout {
                id: col
                anchors {
                    top: parent.top; topMargin: 8
                    left: parent.left; leftMargin: 8
                    right: parent.right; rightMargin: 8
                }
                spacing: 6

                ClockCard      { Layout.fillWidth: true }
                BrightnessCard { Layout.fillWidth: true }
                VolumeCard     { Layout.fillWidth: true }
                SystemCard     { Layout.fillWidth: true }
                MediaCard      { Layout.fillWidth: true }
                NetVpnCard     { Layout.fillWidth: true }
            }
        }

        Keys.onEscapePressed: root.hide()
    }
}
