pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool   powered:    false
    property bool   connected:  false
    property string deviceName: ""

    readonly property string icon: {
        if (!powered)   return "󰂲"
        if (connected)  return "󰂱"
        return "󰂯"
    }
    readonly property string displayText: connected ? `󰂱 ${deviceName}` : icon
    readonly property color  iconColor:   connected ? "#33ccff" : "#444444"

    Process {
        id: btProc
        command: ["bash", "-c",
            "bluetoothctl show 2>/dev/null | grep 'Powered:'; " +
            "bluetoothctl devices Connected 2>/dev/null | grep -oE 'Device [A-F0-9:]+ .+' | head -1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                root.powered   = lines.some(l => l.includes("Powered: yes"))
                const devLine  = lines.find(l => l.startsWith("Device "))
                root.connected = !!devLine
                root.deviceName = devLine ? devLine.split(" ").slice(2).join(" ") : ""
            }
        }
    }

    Timer { interval: 5000; repeat: true; running: true; onTriggered: btProc.running = true }
    Component.onCompleted: btProc.running = true
}
