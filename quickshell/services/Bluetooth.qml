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
        if (!powered)  return "󰂲"
        if (connected) return "󰂱"
        return "󰂯"
    }
    readonly property string displayText: connected ? `󰂱 ${deviceName}` : icon

    // One persistent process that loops every 3s — no restart issues
    Process {
        running: true
        command: ["bash", "-c",
            "while true; do " +
            "  p=$(bluetoothctl show 2>/dev/null | grep -c 'Powered: yes'); " +
            "  d=$(bluetoothctl devices Connected 2>/dev/null | grep -oE 'Device [A-F0-9:]+ .+' | head -1); " +
            "  echo \"$p|$d\"; " +
            "  sleep 3; " +
            "done"]
        stdout: SplitParser {
            onRead: line => {
                const sep   = line.indexOf("|")
                const p     = line.substring(0, sep).trim()
                const dev   = line.substring(sep + 1).trim()
                root.powered    = p === "1"
                root.connected  = dev.startsWith("Device ")
                root.deviceName = root.connected ? dev.split(" ").slice(2).join(" ") : ""
            }
        }
    }
}
