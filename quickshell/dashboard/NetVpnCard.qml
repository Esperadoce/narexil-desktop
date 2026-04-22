import "../services"
import QtQuick
import QtQuick.Layouts

Rectangle {
    radius: 10
    color:  Theme.cardBg
    border.color: Theme.cardBorder
    border.width: 1
    implicitHeight: 52

    RowLayout {
        anchors { fill: parent; leftMargin: 16; rightMargin: 16 }
        spacing: 8

        // Network
        Text {
            text: Network.displayText
            font.pixelSize: 13; font.family: Theme.font
            color: Network.online ? Theme.green : Theme.textInactive
        }

        Item { Layout.fillWidth: true }

        // VPN label
        Text {
            text: NordVpn.connected ? `VPN: ${NordVpn.city}` : "VPN: Off"
            font.pixelSize: 13; font.family: Theme.font
            color: NordVpn.connected ? Theme.green : Theme.textDim
        }

        // VPN toggle button
        Rectangle {
            width: 44; height: 26; radius: 6
            color: NordVpn.connected
                ? Qt.rgba(0, 1, 0.6, 0.20)
                : Qt.rgba(1, 1, 1, 0.06)
            border.color: NordVpn.connected ? Qt.rgba(0, 1, 0.6, 0.4) : "transparent"
            border.width: 1

            Text {
                anchors.centerIn: parent
                text: NordVpn.connected ? "ON" : "OFF"
                font.pixelSize: 11; font.family: Theme.font; font.weight: Font.Bold
                color: NordVpn.connected ? Theme.green : Theme.textDimmer
            }

            MouseArea { anchors.fill: parent; onClicked: NordVpn.toggle() }
        }
    }
}
