import "../services"
import "../launcher"
import Quickshell
import QtQuick

Rectangle {
    id: root
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color:  ma.containsMouse ? Qt.rgba(1, 0.31, 0.31, 0.15) : Theme.moduleBg
    implicitWidth: 36

    Behavior on color { ColorAnimation { duration: 150 } }

    Text {
        anchors.centerIn: parent
        text: "⏻"
        font.pixelSize: 14; font.family: Theme.font
        color: ma.containsMouse ? Theme.red : Theme.textInactive
        Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onClicked: PowerMenu.show()
    }
}
