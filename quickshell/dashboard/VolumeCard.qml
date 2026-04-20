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
            text: "VOLUME"
            font.pixelSize: 10; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.5
            color: Theme.textDimmer
        }

        RowLayout {
            spacing: 8
            Layout.fillWidth: true

            Item {
                id: volSlItem
                Layout.fillWidth: true
                height: 20

                property bool dragging: false
                property real dragFrac: 0
                property real displayFrac: dragging ? dragFrac : Audio.volumePct / 150.0

                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width; height: 4; radius: 2
                    color: Qt.rgba(1,1,1,0.12)
                    Rectangle { width: volSlItem.displayFrac * parent.width; height: 4; radius: 2; color: Theme.cyan }
                }

                Rectangle {
                    x: volSlItem.displayFrac * (volSlItem.width - width)
                    anchors.verticalCenter: parent.verticalCenter
                    width: 14; height: 14; radius: 7; color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onPressed: mouse => {
                        volSlItem.dragging = true
                        volSlItem.dragFrac = Math.max(0, Math.min(1, mouse.x / volSlItem.width))
                        Audio.setVolume(volSlItem.dragFrac * 1.5)
                    }
                    onPositionChanged: mouse => {
                        if (!pressed) return
                        volSlItem.dragFrac = Math.max(0, Math.min(1, mouse.x / volSlItem.width))
                        Audio.setVolume(volSlItem.dragFrac * 1.5)
                    }
                    onReleased: volSlItem.dragging = false
                }
            }

            Text {
                text: `${Audio.volumePct}%`; Layout.preferredWidth: 36
                font.pixelSize: 12; font.family: Theme.font
                color: Theme.textMuted; horizontalAlignment: Text.AlignRight
            }

            Row {
                spacing: 4
                Repeater {
                    model: ["-", "+"]
                    delegate: Rectangle {
                        required property string modelData
                        width: 22; height: 22; radius: 6
                        color: bh.containsMouse ? Qt.rgba(1,1,1,0.12) : Qt.rgba(1,1,1,0.06)
                        Text { anchors.centerIn: parent; text: modelData; font.pixelSize: 13; color: Theme.textMuted }
                        MouseArea {
                            id: bh; anchors.fill: parent; hoverEnabled: true
                            onClicked: Audio.adjustVolume(modelData === "+" ? 0.05 : -0.05)
                        }
                    }
                }
            }
        }
    }
}
