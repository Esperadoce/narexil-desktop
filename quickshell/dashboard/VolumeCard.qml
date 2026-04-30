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

        RowLayout {
            Text {
                text: "VOLUME"
                font.pixelSize: 10; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.5
                color: Theme.textDimmer
            }
            Item { Layout.fillWidth: true }
            Text {
                text: Audio.icon
                font.pixelSize: 14; font.family: Theme.iconFont
                color: Audio.muted ? Theme.textInactive : Theme.cyan
            }
        }

        RowLayout {
            spacing: 10
            Layout.fillWidth: true

            Item {
                id: volSlItem
                Layout.fillWidth: true
                height: 22

                property bool dragging: false
                property real dragFrac: 0
                property real displayFrac: dragging ? dragFrac : Audio.volumePct / 150.0

                // Track
                Rectangle {
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width; height: 6; radius: 3
                    color: Qt.rgba(1, 1, 1, 0.08)

                    // Fill
                    Rectangle {
                        width: volSlItem.displayFrac * parent.width
                        height: parent.height; radius: parent.radius
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: Audio.muted ? Theme.textInactive : Theme.cyan }
                            GradientStop { position: 1.0; color: Audio.muted ? Theme.textInactive : Theme.green }
                        }
                    }
                }

                // Thumb
                Rectangle {
                    x: volSlItem.displayFrac * (volSlItem.width - width)
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16; height: 16; radius: 8
                    color: "white"
                    layer.enabled: true
                    layer.effect: null
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
                text: `${Audio.volumePct}%`
                Layout.preferredWidth: 38
                font.pixelSize: 12; font.family: Theme.font
                color: Theme.textMuted; horizontalAlignment: Text.AlignRight
            }

            Row {
                spacing: 4
                Repeater {
                    model: ["-", "+"]
                    delegate: Rectangle {
                        required property string modelData
                        width: 24; height: 24; radius: 6
                        color: bh.containsMouse ? Theme.hoverBg : Qt.rgba(1, 1, 1, 0.06)
                        Behavior on color { ColorAnimation { duration: 100 } }
                        Text {
                            anchors.centerIn: parent
                            text: modelData; font.pixelSize: 14; font.family: Theme.font
                            color: Theme.textMuted
                        }
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
