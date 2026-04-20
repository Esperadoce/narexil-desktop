import "../services"
import Quickshell
import QtQuick

Rectangle {
    radius: 10
    color:  Theme.cardBg
    border.color: Theme.cardBorder
    border.width: 1
    implicitHeight: weatherRow.visible
        ? (weatherRow.y + weatherRow.height + 14)
        : (dateText.y  + dateText.height  + 14)

    SystemClock { id: clk; precision: SystemClock.Seconds }

    Text {
        id: timeText
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 14 }
        text: (clk.seconds, clk.minutes, Qt.formatDateTime(new Date(), "HH:mm:ss"))
        font.pixelSize: 42; font.family: Theme.font; font.weight: Font.Light
        color: Theme.cyan
    }

    Text {
        id: dateText
        anchors { horizontalCenter: parent.horizontalCenter; top: timeText.bottom; topMargin: 4 }
        text: (clk.seconds, Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy"))
        font.pixelSize: 12; font.family: Theme.font
        color: Theme.textMuted
    }

    Row {
        id: weatherRow
        anchors { horizontalCenter: parent.horizontalCenter; top: dateText.bottom; topMargin: 10 }
        visible: Weather.tempC !== ""
        spacing: 14

        // Icon + temp
        Row {
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: Weather.icon
                font.pixelSize: 20; font.family: "Material Symbols Rounded"
                color: Theme.textWeather
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: `${Weather.tempC}°C`
                font.pixelSize: 22; font.family: Theme.font; font.weight: Font.Light
                color: Theme.textWeather
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: 1; height: 26; color: Qt.rgba(1,1,1,0.12)
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Text {
                text: Weather.description
                font.pixelSize: 12; font.family: Theme.font
                color: Theme.textPrimary
            }
            Text {
                text: `Feels ${Weather.feelsLike}°C  ·  ${Weather.windKmph} km/h  ·  Tomorrow ${Weather.tomorrowMin}–${Weather.tomorrowMax}°C`
                font.pixelSize: 10; font.family: Theme.font
                color: Theme.textDim
            }
        }
    }
}
