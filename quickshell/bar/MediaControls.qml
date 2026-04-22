import "../services"
import QtQuick
import QtQuick.Layouts

Row {
    id: root
    spacing: 0
    visible: Media.hasPlayer && Media.title !== ""

    // Prev button
    Rectangle {
        width: 32; height: barModH
        radius: 0
        // left pill end
        topLeftRadius: Theme.moduleRadius; bottomLeftRadius: Theme.moduleRadius
        color: Theme.moduleBg

        Text {
            anchors.centerIn: parent
            text: "󰒮"
            font.pixelSize: 13; font.family: "Material Symbols Rounded"
            color: hov.containsMouse ? Theme.textPrimary : Theme.textDimmer
        }
        MouseArea { id: hov; anchors.fill: parent; hoverEnabled: true; onClicked: Media.previous() }
    }

    // Info
    Rectangle {
        width: Math.min(mediaLabel.implicitWidth + 24, 200)
        height: barModH
        color: Theme.moduleBg

        Text {
            id: mediaLabel
            anchors.centerIn: parent
            text: Media.displayText
            font.pixelSize: Theme.fontSize; font.family: Theme.font
            color: Media.playing ? Theme.cyan : "#888888"
            elide: Text.ElideRight
            width: parent.width - 24
            horizontalAlignment: Text.AlignHCenter
        }

        MouseArea { anchors.fill: parent; onClicked: Media.playPause() }
    }

    // Next button
    Rectangle {
        width: 32; height: barModH
        // right pill end
        topRightRadius: Theme.moduleRadius; bottomRightRadius: Theme.moduleRadius
        color: Theme.moduleBg

        Text {
            anchors.centerIn: parent
            text: "󰒭"
            font.pixelSize: 13; font.family: "Material Symbols Rounded"
            color: hov2.containsMouse ? Theme.textPrimary : Theme.textDimmer
        }
        MouseArea { id: hov2; anchors.fill: parent; hoverEnabled: true; onClicked: Media.next() }
    }

    property int barModH: Theme.barHeight - Theme.moduleMarginV * 2
}
