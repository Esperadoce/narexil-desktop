pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool enabled:    false

    property int usage:      0
    property int vramUsedMb: 0
    property int vramTotalMb: 0
    property int temp:       0

    readonly property string usageText: `${usage}%`
    readonly property string vramText:  `${(vramUsedMb / 1024).toFixed(1)}G`
    readonly property string tempText:  `${temp}°`

    Process {
        id: gpuProc
        command: ["nvidia-smi",
            "--query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu",
            "--format=csv,noheader,nounits"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(",").map(s => parseInt(s.trim()))
                if (parts.length >= 4) {
                    root.usage      = parts[0] || 0
                    root.vramUsedMb = parts[1] || 0
                    root.vramTotalMb = parts[2] || 0
                    root.temp       = parts[3] || 0
                }
            }
        }
    }

    Timer { interval: 2000; repeat: true; running: enabled; onTriggered: gpuProc.running = true }
    Component.onCompleted: if (enabled) gpuProc.running = true
}
