import "../services"
import Quickshell.Hyprland
import QtQuick

Text {
    readonly property string raw: Hyprland.focusedToplevel?.title ?? ""
    text: raw.length > 60 ? raw.substring(0, 60) + "…" : raw

    font.pixelSize: 12
    font.family: Theme.font
    color: Theme.textDim
    verticalAlignment: Text.AlignVCenter
    elide: Text.ElideRight
}
