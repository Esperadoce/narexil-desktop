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
        spacing: 8

        RowLayout {
            Text {
                text: "BRIGHTNESS"
                font.pixelSize: 10; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.5
                color: Theme.textDimmer
            }
            Item { Layout.fillWidth: true }
            Text {
                text: "󰃞"
                font.pixelSize: 14; font.family: Theme.iconFont
                color: Theme.textDim
            }
        }

        BrightRow { label: "ALL";  icon: "󰹑"; value: Math.round((Brightness.oled + Brightness.dp1 + Brightness.hdmi2) / 3); onChanged: v => { Brightness.setOled(v); Brightness.setDp1(v); Brightness.setHdmi2(v) } }
        BrightRow { label: "OLED"; icon: "󰹐"; value: Brightness.oled;  onChanged: v => Brightness.setOled(v)  }
        BrightRow { label: "DP-1"; icon: "󰍹"; value: Brightness.dp1;   onChanged: v => Brightness.setDp1(v)   }
        BrightRow { label: "HDMI"; icon: "󰍹"; value: Brightness.hdmi2; onChanged: v => Brightness.setHdmi2(v) }
    }

    component BrightRow: RowLayout {
        id: brightRow
        required property string label
        required property string icon
        required property int    value
        signal changed(int v)
        spacing: 8
        Layout.fillWidth: true

        Text {
            text: brightRow.icon
            font.pixelSize: 12; font.family: Theme.iconFont
            color: Theme.textDim
            Layout.preferredWidth: 16
        }
        Text {
            text: brightRow.label
            Layout.preferredWidth: 36
            font.pixelSize: 11; font.family: Theme.font
            color: Theme.textMuted
        }

        Item {
            id: slItem
            Layout.fillWidth: true
            height: 22

            property bool dragging: false
            property real dragFrac: 0
            property real displayFrac: dragging ? dragFrac : (brightRow.value - 1) / 99.0

            Rectangle {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width; height: 6; radius: 3
                color: Qt.rgba(1, 1, 1, 0.08)

                Rectangle {
                    width: slItem.displayFrac * parent.width
                    height: parent.height; radius: parent.radius
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: "#ffcc44" }
                        GradientStop { position: 1.0; color: "#ffee88" }
                    }
                }
            }

            Rectangle {
                x: slItem.displayFrac * (slItem.width - width)
                anchors.verticalCenter: parent.verticalCenter
                width: 16; height: 16; radius: 8; color: "white"
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
            text: `${brightRow.value}%`
            Layout.preferredWidth: 32
            font.pixelSize: 11; font.family: Theme.font
            color: Theme.textMuted; horizontalAlignment: Text.AlignRight
        }

        Row {
            spacing: 4
            Repeater {
                model: ["-", "+"]
                delegate: Rectangle {
                    required property string modelData
                    width: 24; height: 24; radius: 6
                    color: btnHov.containsMouse ? Theme.hoverBg : Qt.rgba(1, 1, 1, 0.06)
                    Behavior on color { ColorAnimation { duration: 100 } }
                    Text {
                        anchors.centerIn: parent
                        text: modelData; font.pixelSize: 14; font.family: Theme.font
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
