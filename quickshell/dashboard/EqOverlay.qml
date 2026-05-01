import "./."
import "../services"
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    id: root

    property bool shown: false

    function show(): void   { root.shown = true  }
    function hide(): void   { root.shown = false }
    function toggle(): void { root.shown = !root.shown }

    IpcHandler {
        target: "eq"
        function show(): void   { root.show() }
        function hide(): void   { root.hide() }
        function toggle(): void { root.toggle() }
    }

    PanelWindow {
        id: overlay
        screen: Shell.activeScreen
        visible: root.shown || slideAnim.running
        color: "transparent"

        anchors { top: true; left: true; right: true; bottom: true }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        MouseArea {
            anchors.fill: parent; z: -1
            onClicked: root.hide()
        }

        property real slideY: root.shown ? 56 : -(panel.height + 60)
        Behavior on slideY {
            NumberAnimation { id: slideAnim; duration: 240; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: panel
            y: overlay.slideY
            width: 520
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 14
            color:  Theme.panelBg
            border.color: Theme.cyanBorder
            border.width: 1
            implicitHeight: card.implicitHeight + 16

            MouseArea { anchors.fill: parent }

            EqCard {
                id: card
                anchors { top: parent.top; topMargin: 8; left: parent.left; leftMargin: 8; right: parent.right; rightMargin: 8 }
            }
        }

        Keys.onEscapePressed: root.hide()
    }
}
