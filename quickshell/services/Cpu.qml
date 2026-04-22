pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int    cpuPct:  0
    property int    cpuTemp: 0
    property string ramText: "0G"

    Process {
        running: true
        command: ["bash", "-c",
            "while true; do " +
            "  cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{printf \"%d\", $2}'); " +
            "  temp=$(sensors 2>/dev/null | grep 'Tctl:' | grep -oP '\\+\\K[0-9]+'); " +
            "  ram=$(free -g | awk '/^Mem/{printf \"%.1fG\", $3}'); " +
            "  echo \"$cpu|$temp|$ram\"; " +
            "  sleep 3; " +
            "done"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.split("|")
                root.cpuPct  = parseInt(p[0]) || 0
                root.cpuTemp = parseInt(p[1]) || 0
                root.ramText = p[2]?.trim() || "0G"
            }
        }
    }
}
