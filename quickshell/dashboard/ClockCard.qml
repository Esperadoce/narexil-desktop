import "../services"
import Quickshell
import QtQuick

Rectangle {
    radius: 10
    color:  Theme.cardBg
    border.color: Theme.cardBorder
    border.width: 1
    implicitHeight: weatherRow.visible
        ? (weatherRow.y + weatherRow.height + 16)
        : (dateText.y  + dateText.height  + 16)

    // Subtle cyan gradient tint at top
    Rectangle {
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: parent.implicitHeight * 0.6
        radius: parent.radius
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.2, 0.8, 1.0, 0.05) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    SystemClock { id: clk; precision: SystemClock.Seconds }

    Text {
        id: timeText
        anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 16 }
        text: (clk.seconds, clk.minutes, Qt.formatDateTime(new Date(), "HH:mm:ss"))
        font.pixelSize: 46; font.family: Theme.font; font.weight: Font.Light
        color: Theme.cyan
        layer.enabled: true
    }

    Text {
        id: dateText
        anchors { horizontalCenter: parent.horizontalCenter; top: timeText.bottom; topMargin: 4 }
        text: (clk.seconds, Qt.formatDateTime(new Date(), "dddd, d MMMM yyyy"))
        font.pixelSize: 12; font.family: Theme.font
        color: Theme.textMuted
    }

    // Divider
    Rectangle {
        id: divider
        visible: weatherRow.visible
        anchors { horizontalCenter: parent.horizontalCenter; top: dateText.bottom; topMargin: 12 }
        width: parent.width * 0.6; height: 1
        color: Qt.rgba(1, 1, 1, 0.08)
    }

    Row {
        id: weatherRow
        anchors { horizontalCenter: parent.horizontalCenter; top: divider.bottom; topMargin: 10 }
        visible: Weather.tempC !== ""
        spacing: 14

        Row {
            spacing: 6
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: Weather.icon
                font.pixelSize: 22; font.family: Theme.iconFont
                color: Theme.textWeather
                anchors.verticalCenter: parent.verticalCenter
            }
            Text {
                text: `${Weather.tempC}°C`
                font.pixelSize: 24; font.family: Theme.font; font.weight: Font.Light
                color: Theme.textWeather
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Rectangle {
            width: 1; height: 28; color: Qt.rgba(1, 1, 1, 0.10)
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                text: Weather.description
                font.pixelSize: 12; font.family: Theme.font
                color: Theme.textPrimary
            }
            Text {
                text: `Feels ${Weather.feelsLike}°C  ·  ${Weather.windKmph} km/h  ·  ↑${Weather.tomorrowMax}° ↓${Weather.tomorrowMin}°`
                font.pixelSize: 10; font.family: Theme.font
                color: Theme.textDim
            }
        }
    }
}
