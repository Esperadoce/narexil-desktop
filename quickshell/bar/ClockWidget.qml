import "../services"
import Quickshell
import QtQuick

Rectangle {
    height: Theme.barHeight - Theme.moduleMarginV * 2
    radius: Theme.moduleRadius
    color:  Qt.rgba(0.2, 0.8, 1.0, 0.10)
    border.color: Qt.rgba(0.2, 0.8, 1.0, 0.20)
    border.width: 1
    implicitWidth: clockText.implicitWidth + 20

    SystemClock { id: clk; precision: SystemClock.Minutes }

    Text {
        id: clockText
        anchors.centerIn: parent
        text: Qt.formatDateTime(clk.now, "HH:mm · ddd dd MMM yyyy")
        font.pixelSize: Theme.fontSize
        font.family:    Theme.font
        font.weight:    Font.DemiBold
        color: Theme.textPrimary
        font.letterSpacing: 0.5
    }
}
