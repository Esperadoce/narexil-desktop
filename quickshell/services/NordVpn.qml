pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool   connected: false
    property string city:      ""
    property string country:   ""
    property string ip:        ""
    property string hostname:  ""

    readonly property string icon:        connected ? "󰒃" : "󰦝"
    readonly property string displayText: connected ? `󰒃 ${city}` : "󰦝"
    readonly property string tooltipText: connected
        ? `Country: ${country}\nCity: ${city}\nIP: ${ip}\nHost: ${hostname}`
        : "Disconnected"

    // Persistent status loop
    Process {
        running: true
        command: ["bash", "-c",
            "while true; do " +
            "  nordvpn status 2>/dev/null || echo 'Status: Disconnected'; " +
            "  echo '---END---'; " +
            "  sleep 10; " +
            "done"]
        stdout: SplitParser {
            property string _buf: ""
            onRead: line => {
                if (line.trim() === "---END---") {
                    const lines = _buf.split("\n")
                    root.connected = lines.some(l => l.includes("Status: Connected"))
                    root.city = root.country = root.ip = root.hostname = ""
                    for (const l of lines) {
                        const sep = l.indexOf(":")
                        if (sep < 0) continue
                        const key = l.substring(0, sep).trim()
                        const val = l.substring(sep + 1).trim()
                        if (key === "City")     root.city     = val
                        if (key === "Country")  root.country  = val
                        if (key === "IP")       root.ip       = val
                        if (key === "Hostname") root.hostname = val
                    }
                    _buf = ""
                } else {
                    _buf += line + "\n"
                }
            }
        }
    }

    // One-shot toggle — state picks up on next loop iteration
    Process {
        id: toggleProc
        command: []
    }

    function toggle(): void {
        toggleProc.command = connected ? ["nordvpn", "disconnect"] : ["nordvpn", "connect"]
        toggleProc.running = true
    }
}
