import "../services"
import Quickshell
import QtQuick
import QtQuick.Controls

Rectangle {
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color: ma.containsMouse ? Theme.hoverBg : Theme.moduleBg
    Behavior on color { ColorAnimation { duration: 150 } }
    implicitWidth: txt.implicitWidth + 20

    ToolTip.visible: ma.containsMouse && Network.online
    ToolTip.text:    Network.label
    ToolTip.delay:   500

    Text {
        id: txt
        anchors.centerIn: parent
        text: Network.displayText
        font.pixelSize: Theme.fontSize; font.family: Theme.font
        color: Network.online ? Theme.green : Theme.textInactive
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Quickshell.execDetached(["kcmshell6", "kcm_networkmanagement"])
    }
}
