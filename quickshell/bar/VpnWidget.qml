import "../services"
import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color:  Theme.moduleBg
    implicitWidth: txt.implicitWidth + 20

    ToolTip.visible: ma.containsMouse && NordVpn.connected
    ToolTip.text:    NordVpn.tooltipText
    ToolTip.delay:   500

    Text {
        id: txt
        anchors.centerIn: parent
        text: NordVpn.displayText
        font.pixelSize: Theme.fontSize; font.family: Theme.font
        color: NordVpn.connected ? Theme.green : Theme.textInactive
    }

    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true; onClicked: NordVpn.toggle() }
}
