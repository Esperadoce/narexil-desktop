pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property bool   enabled: false

    property int    cpuPct:  0
    property int    cpuTemp: 0
    property string ramText: "0G"

    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{printf \"%d\", $2}'"]
        stdout: StdioCollector { onStreamFinished: root.cpuPct = parseInt(text.trim()) || 0 }
    }

    Process {
        id: tempProc
        command: ["bash", "-c",
            "sensors 2>/dev/null | grep 'Tctl:' | grep -oP '\\+\\K[0-9]+'"]
        stdout: StdioCollector { onStreamFinished: root.cpuTemp = parseInt(text.trim()) || 0 }
    }

    Process {
        id: ramProc
        command: ["bash", "-c", "free -g | awk '/^Mem/{printf \"%.1fG\", $3}'"]
        stdout: StdioCollector { onStreamFinished: root.ramText = text.trim() || "0G" }
    }

    Timer {
        interval: 2000; repeat: true; running: enabled
        onTriggered: { cpuProc.running = true; tempProc.running = true }
    }
    Timer { interval: 5000; repeat: true; running: enabled; onTriggered: ramProc.running = true }

    Component.onCompleted: {
        if (!enabled) return
        cpuProc.running  = true
        tempProc.running = true
        ramProc.running  = true
    }
}
