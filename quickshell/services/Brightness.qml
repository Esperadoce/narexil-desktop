pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // DDC bus assignments: 1=OLED(HDMI-A-1), 2=DP-1, 3=HDMI-A-2
    property int oled:  50
    property int dp1:   50
    property int hdmi2: 50

    function setOled(v: int): void  { root.oled  = _clamp(v); oledTimer.restart()  }
    function setDp1(v: int): void   { root.dp1   = _clamp(v); dp1Timer.restart()   }
    function setHdmi2(v: int): void { root.hdmi2 = _clamp(v); hdmi2Timer.restart() }

    function _clamp(v: int): int { return Math.max(1, Math.min(100, v)) }

    Timer { id: oledTimer;  interval: 300; onTriggered: _apply(1, root.oled)  }
    Timer { id: dp1Timer;   interval: 300; onTriggered: _apply(2, root.dp1)   }
    Timer { id: hdmi2Timer; interval: 300; onTriggered: _apply(3, root.hdmi2) }

    function _apply(bus: int, value: int): void {
        applyProc.command = ["ddcutil", "setvcp", "10", String(value), "--bus", String(bus)]
        applyProc.running = true
    }

    Process { id: applyProc; command: [] }

    // Read initial values from eww cache
    Process {
        running: true
        command: ["bash", "-c", "cat /tmp/eww-brightness-1 2>/dev/null || echo 50"]
        stdout: StdioCollector { onStreamFinished: root.oled  = parseInt(text.trim()) || 50 }
    }
    Process {
        running: true
        command: ["bash", "-c", "cat /tmp/eww-brightness-2 2>/dev/null || echo 50"]
        stdout: StdioCollector { onStreamFinished: root.dp1   = parseInt(text.trim()) || 50 }
    }
    Process {
        running: true
        command: ["bash", "-c", "cat /tmp/eww-brightness-3 2>/dev/null || echo 50"]
        stdout: StdioCollector { onStreamFinished: root.hdmi2 = parseInt(text.trim()) || 50 }
    }
}
