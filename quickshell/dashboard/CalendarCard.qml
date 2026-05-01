import "../services"
import Quickshell
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card
    radius: 10
    color:  Theme.cardBg
    border.color: Theme.cardBorder
    border.width: 1
    implicitWidth:  224
    implicitHeight: navRow.height + calGrid.implicitHeight + 32

    SystemClock { id: clk; precision: SystemClock.Minutes }

    readonly property int todayYear:  (clk.hours, new Date().getFullYear())
    readonly property int todayMonth: (clk.hours, new Date().getMonth())
    readonly property int todayDay:   (clk.hours, new Date().getDate())

    property int viewYear:  todayYear
    property int viewMonth: todayMonth

    readonly property int daysInView: new Date(viewYear, viewMonth + 1, 0).getDate()
    readonly property int firstWeekday: {
        const d = new Date(viewYear, viewMonth, 1).getDay()
        return (d + 6) % 7  // 0 = Mon … 6 = Sun
    }

    // Exact cell width — nav row and grid share the same inner width so columns align
    readonly property real innerW: card.width - 24   // 12px margin each side
    readonly property real cellW:  innerW / 7

    readonly property var monthNames: [
        "JANUARY","FEBRUARY","MARCH","APRIL","MAY","JUNE",
        "JULY","AUGUST","SEPTEMBER","OCTOBER","NOVEMBER","DECEMBER"
    ]

    // Navigation row — same left/right margins as calGrid
    RowLayout {
        id: navRow
        anchors { top: parent.top; topMargin: 12; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }

        Rectangle {
            width: 22; height: 22; radius: 5
            color: prevHov.containsMouse ? Qt.rgba(1,1,1,0.08) : "transparent"
            Text {
                anchors.centerIn: parent
                text: "󰅁"; font.pixelSize: 13; font.family: Theme.iconFont
                color: prevHov.containsMouse ? Theme.textMuted : Theme.textDim
            }
            MouseArea {
                id: prevHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: { if (viewMonth === 0) { viewMonth = 11; viewYear-- } else viewMonth-- }
            }
        }

        Text {
            Layout.fillWidth: true
            text: monthNames[viewMonth] + " " + viewYear
            font.pixelSize: 9; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.2
            color: Theme.textMuted; horizontalAlignment: Text.AlignHCenter
        }

        Rectangle {
            width: 22; height: 22; radius: 5
            color: nextHov.containsMouse ? Qt.rgba(1,1,1,0.08) : "transparent"
            Text {
                anchors.centerIn: parent
                text: "󰅂"; font.pixelSize: 13; font.family: Theme.iconFont
                color: nextHov.containsMouse ? Theme.textMuted : Theme.textDim
            }
            MouseArea {
                id: nextHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                onClicked: { if (viewMonth === 11) { viewMonth = 0; viewYear++ } else viewMonth++ }
            }
        }
    }

    // Single Grid: same left anchor as navRow → columns stay aligned with nav width
    Grid {
        id: calGrid
        anchors { top: navRow.bottom; topMargin: 8; left: parent.left; leftMargin: 12 }
        columns: 7
        columnSpacing: 0
        rowSpacing: 0

        // Day-of-week headers
        Repeater {
            model: ["Mo","Tu","We","Th","Fr","Sa","Su"]
            delegate: Item {
                width: card.cellW; height: 18
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 9; font.family: Theme.font; font.weight: Font.Bold
                    color: Theme.textInactive
                }
            }
        }

        // 42 day cells (6 rows × 7 columns)
        Repeater {
            model: 42
            delegate: Item {
                width: card.cellW; height: 28

                readonly property int cellIdx: index - card.firstWeekday
                readonly property int day:     cellIdx + 1
                readonly property bool inMonth: cellIdx >= 0 && cellIdx < card.daysInView
                readonly property bool isToday: inMonth
                    && viewYear  === card.todayYear
                    && viewMonth === card.todayMonth
                    && day       === card.todayDay

                Rectangle {
                    width: 22; height: 22
                    anchors.centerIn: parent; radius: 11
                    color: isToday ? Theme.cyan : "transparent"
                }
                Text {
                    anchors.centerIn: parent
                    text: inMonth ? day : ""
                    font.pixelSize: 11; font.family: Theme.font
                    font.weight: isToday ? Font.Bold : Font.Normal
                    color: isToday ? "#0a0a0a" : (inMonth ? Theme.textMuted : "transparent")
                }
            }
        }
    }
}
