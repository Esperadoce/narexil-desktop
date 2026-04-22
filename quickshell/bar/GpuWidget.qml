import "../services"
import QtQuick

Row {
    spacing: 4

    // GPU util
    Rectangle {
        height: Theme.barHeight - Theme.moduleMarginV * 2
        radius: Theme.moduleRadius
        color:  Theme.moduleBg
        implicitWidth: gpuTxt.implicitWidth + 20

        Text {
            id: gpuTxt
            anchors.centerIn: parent
            text: ` ${Gpu.usageText}`
            font.pixelSize: Theme.fontSize; font.family: Theme.font
            color: Gpu.usage >= 90 ? Theme.red
                 : Gpu.usage >= 70 ? Theme.orange
                 : Theme.textMuted
        }
    }

    // VRAM
    Rectangle {
        height: Theme.barHeight - Theme.moduleMarginV * 2
        radius: Theme.moduleRadius
        color:  Theme.moduleBg
        implicitWidth: vramTxt.implicitWidth + 20

        Text {
            id: vramTxt
            anchors.centerIn: parent
            text: ` ${Gpu.vramText}`
            font.pixelSize: Theme.fontSize; font.family: Theme.font
            color: Theme.textMuted
        }
    }
}
