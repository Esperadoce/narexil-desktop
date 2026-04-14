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

        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            Repeater {
                model: [
                    { icon: "|<",  action: "prev" },
                    { icon: Media.playing ? "||" : "|>", action: "play" },
                    { icon: ">|",  action: "next" }
                ]
                delegate: Rectangle {
                    required property var modelData
                    width: 40; height: 40; radius: 8
                    color: bh.containsMouse
                        ? Qt.rgba(0.2, 0.8, 1.0, 0.18)
                        : (modelData.action === "play" && Media.playing
                            ? Qt.rgba(0.2, 0.8, 1.0, 0.10)
                            : Qt.rgba(1,1,1,0.06))

                    Text {
                        anchors.centerIn: parent
                        text: modelData.icon
                        font.pixelSize: 14; font.family: Theme.font
                        color: modelData.action === "play" && Media.playing
                            ? Theme.cyan : Theme.textMuted
                    }
                    MouseArea {
                        id: bh; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            if (modelData.action === "prev")  Media.previous()
                            else if (modelData.action === "play") Media.playPause()
                            else Media.next()
                        }
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                text: Media.hasPlayer ? Media.displayText : "Nothing playing"
                font.pixelSize: 12; font.family: Theme.font
                color: Media.playing ? Theme.textPrimary : Theme.textDim
                elide: Text.ElideRight
            }
        }
    }
}
