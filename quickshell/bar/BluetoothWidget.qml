import "../services"
import Quickshell
import QtQuick

Rectangle {
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    visible: Bluetooth.powered
    color: ma.containsMouse ? Theme.hoverBg : Theme.moduleBg
    Behavior on color { ColorAnimation { duration: 150 } }
    implicitWidth: txt.implicitWidth + 20

    Text {
        id: txt
        anchors.centerIn: parent
        text: Bluetooth.displayText
        font.pixelSize: Theme.fontSize; font.family: Theme.font
        color: Bluetooth.connected ? Theme.cyan : (Bluetooth.powered ? Theme.textMuted : Theme.textInactive)
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["kcmshell6", "kcm_bluetooth"])
    }
}
