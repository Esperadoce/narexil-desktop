pragma ComponentBehavior: Bound
import "../services"
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

Row {
    spacing: 4

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            required property SystemTrayItem modelData

            width:  28
            height: Theme.barHeight - Theme.moduleMarginV * 2
            radius: Theme.moduleRadius
            color:  Theme.moduleBg

            IconImage {
                anchors.centerIn: parent
                source: modelData.icon
                implicitSize: 16
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) modelData.activate()
                    else if (modelData.menu) modelData.menu.open()
                }
            }
        }
    }
}
