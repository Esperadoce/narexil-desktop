import "../services"
import QtQuick

Rectangle {
    id: root
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color:  Theme.moduleBg
    implicitWidth: txt.implicitWidth + 20

    Text {
        id: txt
        anchors.centerIn: parent
        text: `${Audio.icon} ${Audio.volumePct}%`
        font.pixelSize: Theme.fontSize; font.family: Theme.font
        color: Audio.muted ? Theme.textInactive : Theme.cyan
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) Audio.toggleMute()
            else Quickshell.execDetached(["pavucontrol"])
        }
        onWheel: event => Audio.adjustVolume(event.angleDelta.y > 0 ? 0.05 : -0.05)
    }
}
