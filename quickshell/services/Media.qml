pragma Singleton
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property MprisPlayer player: {
        const players = Mpris.players.values ?? []
        for (const p of players) {
            if (p.playbackState === MprisPlaybackState.Playing) return p
        }
        for (const p of players) {
            if (p.playbackState === MprisPlaybackState.Paused) return p
        }
        return players.length > 0 ? players[0] : null
    }

    readonly property bool hasPlayer: !!player
    readonly property bool playing:   player?.playbackState === MprisPlaybackState.Playing
    readonly property string title:     player?.trackTitle  ?? ""
    readonly property string artist:    player?.trackArtist ?? ""
    readonly property string playIcon:  playing ? "󰏤" : "󰐊"

    readonly property string displayText: {
        if (!hasPlayer || !title) return ""
        const full = artist ? `${artist} — ${title}` : title
        return full.length > 30 ? full.substring(0, 30) + "…" : full
    }

    function playPause(): void { player?.togglePlaying() }
    function next(): void      { player?.next() }
    function previous(): void  { player?.previous() }
}
