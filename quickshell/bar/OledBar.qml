pragma ComponentBehavior: Bound
import "./."
import "../services"
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import QtQuick

Scope {
    id: root

    readonly property ShellScreen oledScreen: {
        for (let i = 0; i < Quickshell.screens.length; i++) {
            if (Quickshell.screens[i].name === "HDMI-A-1")
                return Quickshell.screens[i]
        }
        return null
    }

    property bool barVisible:  false
    property bool mouseInBar:  false
    property real cursorX:     0
    property real cursorY:     0

    // Animated Y offset: 0 = visible (flush top), negative = hidden above
    readonly property int barH: Theme.barHeight + 4
    property real slideY: -barH
    Behavior on slideY { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    onBarVisibleChanged: slideY = barVisible ? 0 : -barH

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.barVisible = false
    }

    Process {
        id: cursorProc
        command: ["hyprctl", "cursorpos"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",")
                if (parts.length === 2) {
                    root.cursorX = parseFloat(parts[0]) || 0
                    root.cursorY = parseFloat(parts[1]) || 0
                }
                root._evaluate()
            }
        }
    }

    Timer {
        interval: 80; repeat: true; running: root.oledScreen !== null
        onTriggered: cursorProc.running = true
    }

    function _evaluate(): void {
        if (!oledScreen) return
        const mon = Hyprland.monitors.values.find(m => m.name === "HDMI-A-1")
        if (!mon) return
        const obj = mon.lastIpcObject
        if (!obj) return
        const monX = obj.x ?? 0
        const monY = obj.y ?? 0
        const inCorner = cursorX >= monX && cursorX <= monX + 100 && cursorY >= monY && cursorY <= monY + 4
        if (inCorner) {
            barVisible = true
            hideTimer.stop()
        } else if (barVisible && !mouseInBar && !hideTimer.running) {
            hideTimer.start()
        }
    }

    PanelWindow {
        id: bar
        screen: root.oledScreen
        visible: root.oledScreen !== null

        anchors { top: true; left: true; right: true }
        implicitHeight: root.barVisible ? root.barH : 0
        Behavior on implicitHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        // Pill slides from y=0 (visible) to y=-barH (hidden above window top)
        Rectangle {
            x: 0
            y: root.slideY
            width:  parent.width
            height: root.barH
            topLeftRadius:     0
            topRightRadius:    0
            bottomLeftRadius:  Theme.barRadius
            bottomRightRadius: Theme.barRadius
            color:  Theme.barBg
            border.color: Theme.barBorder
            border.width: 1

            HoverHandler {
                id: barHover
                onHoveredChanged: {
                    root.mouseInBar = hovered
                    if (hovered) hideTimer.stop()
                }
            }

            Row {
                anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
                spacing: 4
                Workspaces  { screen: bar.screen }
                ScratchpadWidget {}
                WindowTitle { verticalAlignment: Text.AlignVCenter; height: Theme.barHeight - Theme.moduleMarginV * 2 }
                MediaControls {}
            }

            Row {
                anchors { centerIn: parent }
                spacing: 8
                WeatherWidget {}
                ClockWidget {}
            }

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

    IpcHandler {
        target: "oledbar"
        function show(): void   { root.barVisible = true;  hideTimer.stop()  }
        function hide(): void   { root.barVisible = false; hideTimer.stop()  }
        function toggle(): void { root.barVisible = !root.barVisible }
    }
}
