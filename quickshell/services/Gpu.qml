pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property int usage:       0
    property int vramUsedMb:  0
    property int vramTotalMb: 0
    property int temp:        0

    readonly property string usageText: `${usage}%`
    readonly property string vramText:  `${(vramUsedMb / 1024).toFixed(1)}G`
    readonly property string tempText:  `${temp}°`

    Process {
        running: true
        command: ["bash", "-c",
            "while true; do " +
            "  nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu " +
            "    --format=csv,noheader,nounits 2>/dev/null || echo '0, 0, 0, 0'; " +
            "  sleep 2; " +
            "done"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.split(",").map(s => parseInt(s.trim()))
                if (p.length >= 4) {
                    root.usage       = p[0] || 0
                    root.vramUsedMb  = p[1] || 0
                    root.vramTotalMb = p[2] || 0
                    root.temp        = p[3] || 0
                }
            }
        }
    }
}
