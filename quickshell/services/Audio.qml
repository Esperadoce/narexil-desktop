pragma Singleton
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool   muted:     !!sink?.audio?.muted
    readonly property real   volume:    sink?.audio?.volume ?? 0
    readonly property int    volumePct: Math.round(volume * 100)

    readonly property string icon: {
        if (muted || volume === 0) return "󰖁"
        if (volume > 0.6) return "󰕾"
        if (volume > 0.2) return "󰖀"
        return "󰕿"
    }

    PwObjectTracker { objects: sink ? [sink] : [] }

    function setVolume(v: real): void {
        if (sink?.ready && sink?.audio)
            sink.audio.volume = Math.max(0, Math.min(1.5, v))
    }
    function toggleMute(): void {
        if (sink?.audio) sink.audio.muted = !sink.audio.muted
    }
    function adjustVolume(delta: real): void { setVolume(volume + delta) }
}
