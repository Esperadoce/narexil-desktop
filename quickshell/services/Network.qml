pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool   online: false
    property bool   wifi:   false
    property string label:  ""

    readonly property string icon: {
        if (!online) return "󰖪"
        return wifi ? "󰖩" : "󰈀"
    }
    readonly property string displayText: online ? `${icon} ${label}` : "󰖪"

    Process {
        id: netProc
        command: ["bash", "-c",
            "essid=$(iwgetid -r 2>/dev/null); " +
            "if [ -n \"$essid\" ]; then echo \"wifi:$essid\"; " +
            "elif ip link show | grep -qE 'state UP.*ether'; then echo 'eth:Ethernet'; " +
            "else echo 'off:'; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const t = text.trim()
                if (t.startsWith("wifi:")) {
                    root.online = true; root.wifi = true
                    root.label  = t.substring(5)
                } else if (t.startsWith("eth:")) {
                    root.online = true; root.wifi = false
                    root.label  = "Ethernet"
                } else {
                    root.online = false; root.wifi = false; root.label = ""
                }
            }
        }
    }

    Timer { interval: 5000; repeat: true; running: true; onTriggered: netProc.running = true }
    Component.onCompleted: netProc.running = true
}
