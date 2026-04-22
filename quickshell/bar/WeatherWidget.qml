import "../services"
import QtQuick
import QtQuick.Controls

Rectangle {
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color:  Theme.moduleBg
    implicitWidth: txt.implicitWidth + 20
    visible: Weather.displayText !== "…"

    ToolTip.visible: ma.containsMouse
    ToolTip.text:    Weather.tooltipText
    ToolTip.delay:   500

    Text {
        id: txt
        anchors.centerIn: parent
        text: Weather.displayText
        font.pixelSize: Theme.fontSize
        font.family:    Theme.font
        color: Theme.textWeather
    }

    MouseArea { id: ma; anchors.fill: parent; hoverEnabled: true }
}
