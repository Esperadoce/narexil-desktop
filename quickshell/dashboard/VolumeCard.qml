import "../services"
import QtQuick
import QtQuick.Controls
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

            Slider {
                id: volSlider
                Layout.fillWidth: true
                from: 0; to: 150
                value: Audio.volumePct
                onMoved: Audio.setVolume(value / 100)

                background: Rectangle {
                    x: volSlider.leftPadding; y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                    width: volSlider.availableWidth; height: 4; radius: 2
                    color: Qt.rgba(1,1,1,0.12)
                    Rectangle { width: volSlider.visualPosition * parent.width; height: parent.height; radius: 2; color: Theme.cyan }
                }
                handle: Rectangle {
                    x: volSlider.leftPadding + volSlider.visualPosition * (volSlider.availableWidth - width)
                    y: volSlider.topPadding + volSlider.availableHeight / 2 - height / 2
                    width: 14; height: 14; radius: 7; color: "white"
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
