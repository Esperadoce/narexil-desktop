pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property string currentPreset: "Flat"
    property bool   bypassed:      true

    readonly property var presets: ["Flat", "Rock", "Pop", "Bass", "Jazz", "Vocal", "Classic"]

    // Gain values per preset (10 bands: 31 63 125 250 500 1k 2k 4k 8k 16k)
    readonly property var presetGains: ({
        "Flat":    [ 0,  0,  0,  0,  0,  0,  0,  0,  0,  0],
        "Rock":    [ 4,  3,  2,  0, -1, -1,  2,  4,  4,  3],
        "Pop":     [-1,  0,  2,  3,  4,  3,  2,  1,  0, -1],
        "Bass":    [ 6,  5,  4,  2,  0, -1, -1, -1,  0,  0],
        "Jazz":    [ 2,  2,  0, -1, -1,  0,  2,  3,  3,  2],
        "Vocal":   [-3, -2,  0,  2,  4,  5,  4,  2,  1,  0],
        "Classic": [ 0,  0,  2,  3,  2,  0, -1, -1,  2,  3],
    })

    function loadPreset(name: string): void {
        root.currentPreset = name
        root.bypassed = false
        loadProc.command = ["easyeffects", "-l", name]
        loadProc.running = true
    }

    function toggleBypass(): void {
        root.bypassed = !root.bypassed
        bypassProc.command = ["easyeffects", "--bypass-toggle"]
        bypassProc.running = true
    }

    Process { id: loadProc;   running: false }
    Process { id: bypassProc; running: false }
}
