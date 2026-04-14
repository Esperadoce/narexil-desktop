import "../services"
import QtQuick

Row {
    spacing: 4

    // CPU
    Rectangle {
        height: Theme.barHeight - Theme.moduleMarginV * 2
        radius: Theme.moduleRadius
        color:  Theme.moduleBg
        implicitWidth: cpuTxt.implicitWidth + 20

        Text {
            id: cpuTxt
            anchors.centerIn: parent
            text: ` ${Cpu.cpuPct}%`
            font.pixelSize: Theme.fontSize; font.family: Theme.font
            color: Cpu.cpuPct >= 90 ? Theme.red
                 : Cpu.cpuPct >= 70 ? Theme.orange
                 : Theme.textMuted
        }
    }

    // RAM
    Rectangle {
        height: Theme.barHeight - Theme.moduleMarginV * 2
        radius: Theme.moduleRadius
        color:  Theme.moduleBg
        implicitWidth: ramTxt.implicitWidth + 20

        Text {
            id: ramTxt
            anchors.centerIn: parent
            text: ` ${Cpu.ramText}`
            font.pixelSize: Theme.fontSize; font.family: Theme.font
            color: Theme.textMuted
        }
    }
}
