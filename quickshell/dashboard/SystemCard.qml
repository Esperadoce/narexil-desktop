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
            text: "SYSTEM"
            font.pixelSize: 10; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.5
            color: Theme.textDimmer
        }

        RowLayout {
            Layout.fillWidth: true

            Repeater {
                model: [
                    { val: `${Cpu.cpuPct}%`,  key: "CPU"  },
                    { val: `${Cpu.cpuTemp}°`, key: "CPU°" },
                    { val: Cpu.ramText,        key: "RAM"  },
                    { val: Gpu.usageText,      key: "GPU"  },
                    { val: Gpu.vramText,       key: "VRAM" }
                ]

                delegate: ColumnLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.val
                        font.pixelSize: 18; font.family: Theme.font; font.weight: Font.Medium
                        color: Theme.textPrimary
                    }
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: modelData.key
                        font.pixelSize: 10; font.family: Theme.font
                        color: Theme.textDimmer
                    }
                }
            }
        }
    }
}
