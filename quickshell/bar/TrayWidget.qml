pragma ComponentBehavior: Bound
import "../services"
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import QtQuick

Row {
    id: root
    spacing: 4

    QsMenuAnchor {
        id: menuAnchor
    }

    Repeater {
        model: SystemTray.items

        delegate: Rectangle {
            id: item
            required property SystemTrayItem modelData

            width:  28
            height: Theme.barHeight - Theme.moduleMarginV * 2
            radius: Theme.moduleRadius
            color:  hoverArea.containsMouse ? Theme.hoverBg : Theme.moduleBg

            Behavior on color {
                ColorAnimation { duration: 120 }
            }

            IconImage {
                id: icon
                anchors.centerIn: parent
                source: item.modelData.icon
                implicitSize: 16
                scale: hoverArea.containsMouse ? 1.12 : 1.0

                Behavior on scale {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }
            }

            MouseArea {
                id: hoverArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton) {
                        if (item.modelData.hasMenu && !item.modelData.onlyMenu) {
                            item.modelData.activate()
                        } else if (item.modelData.hasMenu) {
                            menuAnchor.menu = item.modelData.menu
                            menuAnchor.anchor.item = item
                            menuAnchor.anchor.edges = Edges.Bottom
                            menuAnchor.open()
                        } else {
                            item.modelData.activate()
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        item.modelData.secondaryActivate()
                    } else if (mouse.button === Qt.RightButton && item.modelData.hasMenu) {
                        menuAnchor.menu = item.modelData.menu
                        menuAnchor.anchor.item = item
                        menuAnchor.anchor.edges = Edges.Bottom
                        menuAnchor.open()
                    }
                }
            }
        }
    }
}
