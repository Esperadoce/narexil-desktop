import "../services"
import Quickshell
import Quickshell.Hyprland
import QtQuick

Rectangle {
    id: root

    readonly property int count: {
        const sp = Hyprland.workspaces.values.find(w => w.name === "special:magic")
        return sp?.lastIpcObject?.windows ?? 0
    }

    visible: count > 0
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color:  Theme.moduleBg
    implicitWidth: txt.implicitWidth + 20

    Text {
        id: txt
        anchors.centerIn: parent
        text: `󱂬  ${root.count}`
        font.pixelSize: Theme.fontSize; font.family: Theme.font
        color: Theme.orange
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Hyprland.dispatch("togglespecialworkspace magic")
    }
}
