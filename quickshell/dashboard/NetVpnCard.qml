import "../services"
import QtQuick
import QtQuick.Layouts

Rectangle {
    radius: 10
    color:  Theme.cardBg
    border.color: Theme.cardBorder
    border.width: 1
    implicitHeight: col.implicitHeight + 24

    ColumnLayout {
        id: col
        anchors { top: parent.top; topMargin: 12; left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16 }
        spacing: 10

        Text {
            text: "NETWORK"
            font.pixelSize: 10; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.5
            color: Theme.textDimmer
        }

        RowLayout {
            spacing: 12
            Layout.fillWidth: true

            // Network status
            Row {
                spacing: 6
                Text {
                    text: Network.icon
                    font.pixelSize: 14; font.family: Theme.iconFont
                    color: Network.online ? Theme.green : Theme.textInactive
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: Network.online ? Network.label : "Offline"
                    font.pixelSize: 12; font.family: Theme.font
                    color: Network.online ? Theme.textPrimary : Theme.textInactive
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item { Layout.fillWidth: true }

            // VPN row
            Row {
                spacing: 8

                Text {
                    text: NordVpn.connected ? `VPN · ${NordVpn.city}` : "VPN · Off"
                    font.pixelSize: 12; font.family: Theme.font
                    color: NordVpn.connected ? Theme.green : Theme.textDim
                    anchors.verticalCenter: parent.verticalCenter
                }

                Rectangle {
                    width: 48; height: 26; radius: 6
                    color: vpnHov.containsMouse
                        ? (NordVpn.connected ? Qt.rgba(0, 1, 0.6, 0.28) : Qt.rgba(1,1,1,0.12))
                        : (NordVpn.connected ? Qt.rgba(0, 1, 0.6, 0.18) : Qt.rgba(1,1,1,0.06))
                    border.color: NordVpn.connected ? Qt.rgba(0, 1, 0.6, 0.45) : Qt.rgba(1,1,1,0.10)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: NordVpn.connected ? "ON" : "OFF"
                        font.pixelSize: 11; font.family: Theme.font; font.weight: Font.Bold
                        color: NordVpn.connected ? Theme.green : Theme.textDimmer
                    }

                    MouseArea {
                        id: vpnHov; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NordVpn.toggle()
                    }
                }
            }
        }
    }
}
