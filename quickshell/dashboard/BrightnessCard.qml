import "../services"
import QtQuick
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

        BrightRow {
            label: "ALL"
            value: Math.round((Brightness.oled + Brightness.dp1 + Brightness.hdmi2) / 3)
            onChanged: v => { Brightness.setOled(v); Brightness.setDp1(v); Brightness.setHdmi2(v) }
        }
        BrightRow { label: "OLED"; value: Brightness.oled;  onChanged: v => Brightness.setOled(v)  }
        BrightRow { label: "DP-1"; value: Brightness.dp1;   onChanged: v => Brightness.setDp1(v)   }
        BrightRow { label: "HDMI"; value: Brightness.hdmi2; onChanged: v => Brightness.setHdmi2(v) }
    }

    component BrightRow: RowLayout {
        id: brightRow
        required property string label
        required property int    value
        signal changed(int v)
        spacing: 8

        Text {
            text: label; Layout.preferredWidth: 36
            font.pixelSize: 11; font.family: Theme.font
            color: Theme.textMuted
        }

        Item {
            id: slItem
            Layout.fillWidth: true
            height: 20

            property bool dragging: false
            property real dragFrac: 0
            property real displayFrac: dragging ? dragFrac : (brightRow.value - 1) / 99.0

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: 4; radius: 2
                color: Qt.rgba(1,1,1,0.12)
                Rectangle { width: slItem.displayFrac * parent.width; height: 4; radius: 2; color: Theme.cyan }
            }

            Rectangle {
                x: slItem.displayFrac * (slItem.width - width)
                anchors.verticalCenter: parent.verticalCenter
                width: 14; height: 14; radius: 7; color: "white"
            }

            MouseArea {
                anchors.fill: parent
                onPressed: mouse => {
                    slItem.dragging = true
                    slItem.dragFrac = Math.max(0, Math.min(1, mouse.x / slItem.width))
                    brightRow.changed(Math.round(1 + slItem.dragFrac * 99))
                }
                onPositionChanged: mouse => {
                    if (!pressed) return
                    slItem.dragFrac = Math.max(0, Math.min(1, mouse.x / slItem.width))
                    brightRow.changed(Math.round(1 + slItem.dragFrac * 99))
                }
                onReleased: slItem.dragging = false
            }
        }

        Text {
            text: `${brightRow.value}%`; Layout.preferredWidth: 32
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
                        onClicked: brightRow.changed(Math.max(1, Math.min(100, brightRow.value + (modelData === "+" ? 5 : -5))))
                    }
                }
            }
        }
    }
}
