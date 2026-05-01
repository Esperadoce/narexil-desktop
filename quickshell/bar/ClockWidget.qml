import "../services"
import Quickshell
import QtQuick

Rectangle {
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color:  Theme.moduleBg
    border.color: Theme.barBorder
    border.width: 1
    implicitWidth: row.implicitWidth + 20

    SystemClock { id: clk; precision: SystemClock.Minutes }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 0

        Text {
            text: (clk.minutes, clk.hours, Qt.formatDateTime(new Date(), "HH:mm"))
            font.pixelSize: Theme.fontSize; font.family: Theme.font
            font.weight: Font.DemiBold; font.letterSpacing: 0.5
            color: Theme.textPrimary
        }
        Text {
            text: " · "
            font.pixelSize: Theme.fontSize; font.family: Theme.font
            color: Theme.textDim
        }
        Text {
            id: dateTxt
            text: (clk.minutes, Qt.formatDateTime(new Date(), "ddd dd MMM yyyy"))
            font.pixelSize: Theme.fontSize; font.family: Theme.font
            font.letterSpacing: 0.5
            color: CalendarState.shown ? Theme.cyan : Theme.textMuted
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    // Click target over the date portion only
    MouseArea {
        anchors { top: parent.top; bottom: parent.bottom; right: parent.right; rightMargin: 10 }
        width: dateTxt.implicitWidth + 8
        cursorShape: Qt.PointingHandCursor
        onClicked: CalendarState.toggle()
    }
}
