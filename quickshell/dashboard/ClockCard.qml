import "../services"
import Quickshell
import QtQuick

Rectangle {
    radius: 10
    color:  Theme.cardBg
    border.color: Theme.cardBorder
    border.width: 1
    implicitHeight: 80

    SystemClock { id: clk; precision: SystemClock.Seconds }

    Text {
        id: timeText
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 16 }
        text: Qt.formatDateTime(clk.now, "HH:mm:ss")
        font.pixelSize: 42; font.family: Theme.font; font.weight: Font.Light
        color: Theme.cyan
    }

    Text {
        anchors { horizontalCenter: parent.horizontalCenter; top: timeText.bottom; topMargin: 4 }
        text: Qt.formatDateTime(clk.now, "dddd, d MMMM yyyy")
        font.pixelSize: 12; font.family: Theme.font
        color: Theme.textMuted
    }
}
