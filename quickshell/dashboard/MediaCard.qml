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
            text: "MEDIA"
            font.pixelSize: 10; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.5
            color: Theme.textDimmer
        }

        // Nothing playing
        Text {
            visible: !Media.hasPlayer
            Layout.alignment: Qt.AlignHCenter
            text: "Nothing playing"
            font.pixelSize: 12; font.family: Theme.font
            color: Theme.textDim
        }

        // Track info
        ColumnLayout {
            visible: Media.hasPlayer
            Layout.fillWidth: true
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: Media.title || "Unknown"
                font.pixelSize: 14; font.family: Theme.font; font.weight: Font.Medium
                color: Media.playing ? Theme.textPrimary : Theme.textMuted
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: Media.artist || "Unknown artist"
                font.pixelSize: 11; font.family: Theme.font
                color: Theme.textDim
                elide: Text.ElideRight
            }
        }

        // Controls
        RowLayout {
            visible: Media.hasPlayer
            Layout.fillWidth: true
            spacing: 8

            Item { Layout.fillWidth: true }

            Repeater {
                model: [
                    { icon: "󰒮", action: "prev"  },
                    { icon: Media.playIcon,  action: "play"  },
                    { icon: "󰒭", action: "next"  }
                ]
                delegate: Rectangle {
                    required property var modelData
                    readonly property bool isPlay: modelData.action === "play"
                    width: isPlay ? 48 : 36; height: isPlay ? 48 : 36; radius: isPlay ? 24 : 18
                    color: ma.containsMouse
                        ? (isPlay ? Qt.rgba(0.2, 0.8, 1.0, 0.25) : Qt.rgba(1,1,1,0.14))
                        : (isPlay ? Qt.rgba(0.2, 0.8, 1.0, 0.12) : Qt.rgba(1,1,1,0.07))

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.pixelSize: isPlay ? 22 : 16
                        font.family: "Material Symbols Rounded"
                        color: isPlay ? Theme.cyan : Theme.textMuted
                    }
                    MouseArea {
                        id: ma; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            if (modelData.action === "prev")       Media.previous()
                            else if (modelData.action === "play")  Media.playPause()
                            else                                   Media.next()
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }
        }
    }
}
