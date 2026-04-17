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

    // Persistent loop — avoids the broken Timer+restart pattern
    Process {
        running: true
        command: ["bash", "-c",
            "while true; do " +
            "  e=$(iwgetid -r 2>/dev/null); " +
            "  if [ -n \"$e\" ]; then echo \"wifi:$e\"; " +
            "  elif ip -o link show up | grep -E ': e[nt]' | grep -q 'LOWER_UP'; then echo 'eth:Ethernet'; " +
            "  else echo 'off:'; fi; " +
            "  sleep 5; " +
            "done"]
        stdout: SplitParser {
            onRead: line => {
                if (line.startsWith("wifi:")) {
                    root.online = true; root.wifi = true
                    root.label  = line.substring(5)
                } else if (line.startsWith("eth:")) {
                    root.online = true; root.wifi = false
                    root.label  = "Ethernet"
                } else {
                    root.online = false; root.wifi = false; root.label = ""
                }
            }
        }
    }
}
