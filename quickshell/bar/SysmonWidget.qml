import "../services"
import QtQuick

Rectangle {
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color:  Theme.moduleBg
    implicitWidth: row.implicitWidth + 20

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 6

        // CPU
        Text {
            text: "󱤓"
            font.pixelSize: 13; font.family: Theme.iconFont
            color: Cpu.cpuPct >= 90 ? Theme.red
                 : Cpu.cpuPct >= 70 ? Theme.orange
                 : Theme.textDim
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: `${Cpu.cpuPct}%`
            font.pixelSize: Theme.fontSize; font.family: Theme.font
            color: Cpu.cpuPct >= 90 ? Theme.red
                 : Cpu.cpuPct >= 70 ? Theme.orange
                 : Theme.textMuted
            anchors.verticalCenter: parent.verticalCenter
        }

        // Separator
        Rectangle {
            width: 1; height: 14
            color: Qt.rgba(1, 1, 1, 0.15)
            anchors.verticalCenter: parent.verticalCenter
        }

        // RAM
        Text {
            text: "󰍛"
            font.pixelSize: 12; font.family: Theme.iconFont
            color: Theme.textDim
            anchors.verticalCenter: parent.verticalCenter
        }
        Text {
            text: Cpu.ramText
            font.pixelSize: Theme.fontSize; font.family: Theme.font
            color: Theme.textMuted
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
