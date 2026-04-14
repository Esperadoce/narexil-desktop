import "../services"
import QtQuick

Rectangle {
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color:  Theme.moduleBg
    implicitWidth: txt.implicitWidth + 20

    Text {
        id: txt
        anchors.centerIn: parent
        text: Network.displayText
        font.pixelSize: Theme.fontSize; font.family: Theme.font
        color: Network.online ? Theme.green : Theme.textInactive
    }
}
