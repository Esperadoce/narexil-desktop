import "./."
import "../services"
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

Scope {
    IpcHandler {
        target: "calendar"
        function show():   void { CalendarState.show()   }
        function hide():   void { CalendarState.hide()   }
        function toggle(): void { CalendarState.toggle() }
    }

    PanelWindow {
        id: overlay
        screen: Shell.activeScreen
        visible: CalendarState.shown || slideAnim.running
        color: "transparent"

        anchors { top: true; left: true; right: true; bottom: true }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        MouseArea {
            anchors.fill: parent; z: -1
            onClicked: CalendarState.hide()
        }

        property real slideY: CalendarState.shown ? 56 : -(panel.height + 60)
        Behavior on slideY {
            NumberAnimation { id: slideAnim; duration: 240; easing.type: Easing.OutCubic }
        }

        Rectangle {
            id: panel
            y: overlay.slideY
            width: 320
            anchors.horizontalCenter: parent.horizontalCenter
            radius: 14
            color:  Theme.panelBg
            border.color: Theme.cyanBorder
            border.width: 1
            implicitHeight: card.implicitHeight + 16

            MouseArea { anchors.fill: parent }

            CalendarCard {
                id: card
                anchors { top: parent.top; topMargin: 8; left: parent.left; leftMargin: 8; right: parent.right; rightMargin: 8 }
            }
        }

        Keys.onEscapePressed: CalendarState.hide()
    }
}
