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

    Process {
        id: statusProc
        command: ["nordvpn", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                root.connected = lines.some(l => l.includes("Status: Connected"))
                root.city = root.country = root.ip = root.hostname = ""
                for (const line of lines) {
                    const [key, ...rest] = line.split(":")
                    const val = rest.join(":").trim()
                    if (key.trim() === "City")     root.city     = val
                    if (key.trim() === "Country")  root.country  = val
                    if (key.trim() === "IP")       root.ip       = val
                    if (key.trim() === "Hostname") root.hostname = val
                }
            }
        }
    }

    Process {
        id: toggleProc
        command: []
        onRunningChanged: if (!running && command.length > 0) statusProc.running = true
    }

    function toggle(): void {
        toggleProc.command = connected ? ["nordvpn", "disconnect"] : ["nordvpn", "connect"]
        toggleProc.running = true
    }

    Timer { interval: 10000; repeat: true; running: true; onTriggered: statusProc.running = true }
    Component.onCompleted: statusProc.running = true
}
