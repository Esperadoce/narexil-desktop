import "../services"
import QtQuick
import QtQuick.Layouts

Rectangle {
    radius: 10
    color:  Theme.cardBg
    border.color: Theme.cardBorder
    border.width: 1
    implicitHeight: col.implicitHeight + 24

    component MetricRow: RowLayout {
        id: mrow
        required property string icon
        required property string label
        required property real   frac
        required property string val
        property bool            showBar:  true
        property string          extra:    ""
        property color           valColor: Theme.textPrimary
        spacing: 8
        Layout.fillWidth: true

        Text {
            text: mrow.icon
            font.pixelSize: 13; font.family: Theme.iconFont
            color: mrow.valColor
            Layout.preferredWidth: 18
        }
        Text {
            text: mrow.label
            font.pixelSize: 11; font.family: Theme.font
            color: Theme.textMuted
            Layout.preferredWidth: 36
        }

        // Progress bar
        Item {
            Layout.fillWidth: true
            height: 5

            Rectangle {
                anchors.fill: parent; radius: 2.5
                color: mrow.showBar ? Qt.rgba(1, 1, 1, 0.08) : "transparent"
            }
            Rectangle {
                visible: mrow.showBar
                width: parent.width * Math.max(0, Math.min(1, mrow.frac))
                height: parent.height; radius: 2.5
                color: mrow.frac >= 0.9 ? Theme.red
                     : mrow.frac >= 0.7 ? Theme.orange
                     : "transparent"

                Rectangle {
                    visible: mrow.frac < 0.7
                    anchors.fill: parent; radius: parent.radius
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Theme.cyan }
                        GradientStop { position: 1.0; color: Theme.green }
                    }
                }
            }
        }

        Text {
            text: mrow.val
            font.pixelSize: 12; font.family: Theme.font; font.weight: Font.Medium
            color: mrow.valColor
            Layout.preferredWidth: 42
            horizontalAlignment: Text.AlignRight
        }
        Text {
            visible: mrow.extra !== ""
            text: mrow.extra
            font.pixelSize: 11; font.family: Theme.font
            color: Theme.textDim
            Layout.preferredWidth: 36
        }
    }

    ColumnLayout {
        id: col
        anchors { top: parent.top; topMargin: 12; left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16 }
        spacing: 10

        Text {
            text: "SYSTEM"
            font.pixelSize: 10; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.5
            color: Theme.textDimmer
        }

        MetricRow {
            icon:     "󱤓"
            label:    "CPU"
            frac:     Cpu.cpuPct / 100
            val:      `${Cpu.cpuPct}%`
            extra:    `${Cpu.cpuTemp}°C`
            valColor: Cpu.cpuPct >= 90 ? Theme.red : Cpu.cpuPct >= 70 ? Theme.orange : Theme.textPrimary
        }
        MetricRow {
            icon:     "󰢮"
            label:    "GPU"
            frac:     Gpu.usage / 100
            val:      `${Gpu.usage}%`
            extra:    `${Gpu.temp}°C`
            valColor: Gpu.usage >= 90 ? Theme.red : Gpu.usage >= 70 ? Theme.orange : Theme.textPrimary
        }
        MetricRow {
            icon:     "󰍛"
            label:    "RAM"
            frac:     0
            showBar:  false
            val:      Cpu.ramText
            valColor: Theme.textPrimary
        }
        MetricRow {
            icon:     "󰾲"
            label:    "VRAM"
            frac:     Gpu.vramTotalMb > 0 ? Gpu.vramUsedMb / Gpu.vramTotalMb : 0
            val:      `${(Gpu.vramUsedMb / 1024).toFixed(1)}G`
            extra:    `/ ${(Gpu.vramTotalMb / 1024).toFixed(0)}G`
            valColor: Theme.textPrimary
        }
    }
}
