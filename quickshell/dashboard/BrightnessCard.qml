import "../services"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    radius: 10
    color:  Theme.cardBg
    border.color: Theme.cardBorder
    border.width: 1
    implicitHeight: col.implicitHeight + 24

    ColumnLayout {
        id: col
        anchors { top: parent.top; topMargin: 12; left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16 }
        spacing: 10

        Text {
            text: "BRIGHTNESS"
            font.pixelSize: 10; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.5
            color: Theme.textDimmer
        }

        BrightRow { label: "OLED"; value: Brightness.oled;  onChanged: v => Brightness.setOled(v)  }
        BrightRow { label: "DP-1"; value: Brightness.dp1;   onChanged: v => Brightness.setDp1(v)   }
        BrightRow { label: "HDMI"; value: Brightness.hdmi2; onChanged: v => Brightness.setHdmi2(v) }
    }

    component BrightRow: RowLayout {
        required property string label
        required property int    value
        signal changed(int v)

        spacing: 8

        Text {
            text: label; Layout.preferredWidth: 36
            font.pixelSize: 11; font.family: Theme.font
            color: Theme.textMuted
        }

        Slider {
            id: sl
            Layout.fillWidth: true
            from: 1; to: 100
            value: parent.value
            onMoved: parent.changed(Math.round(value))

            background: Rectangle {
                x: sl.leftPadding; y: sl.topPadding + sl.availableHeight / 2 - height / 2
                width: sl.availableWidth; height: 4; radius: 2
                color: Qt.rgba(1,1,1,0.12)
                Rectangle { width: sl.visualPosition * parent.width; height: parent.height; radius: 2; color: Theme.cyan }
            }
            handle: Rectangle {
                x: sl.leftPadding + sl.visualPosition * (sl.availableWidth - width)
                y: sl.topPadding + sl.availableHeight / 2 - height / 2
                width: 14; height: 14; radius: 7
                color: "white"
            }
        }

        Text {
            text: `${parent.value}%`; Layout.preferredWidth: 32
            font.pixelSize: 11; font.family: Theme.font
            color: Theme.textMuted; horizontalAlignment: Text.AlignRight
        }

        Row {
            spacing: 4
            Repeater {
                model: ["-", "+"]
                delegate: Rectangle {
                    required property string modelData
                    width: 22; height: 22; radius: 6
                    color: btnHov.containsMouse ? Qt.rgba(1,1,1,0.12) : Qt.rgba(1,1,1,0.06)
                    Text {
                        anchors.centerIn: parent
                        text: modelData; font.pixelSize: 13; font.family: Theme.font
                        color: Theme.textMuted
                    }
                    MouseArea {
                        id: btnHov; anchors.fill: parent; hoverEnabled: true
                        onClicked: {
                            // Walk up to find BrightRow and call changed
                            const row = parent.parent.parent.parent
                            row.changed(Math.max(1, Math.min(100, row.value + (modelData === "+" ? 5 : -5))))
                        }
                    }
                }
            }
        }
    }
}
