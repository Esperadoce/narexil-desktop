import "../services"
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: eqCard
    radius: 10
    color:  Theme.cardBg
    border.color: Theme.cardBorder
    border.width: 1
    implicitHeight: col.implicitHeight + 24

    readonly property var bandLabels: ["31","63","125","250","500","1k","2k","4k","8k","16k"]
    readonly property real maxGain:   6.0
    readonly property real barAreaH:  80
    readonly property real barMaxH:   32    // max px per direction from center

    ColumnLayout {
        id: col
        anchors { top: parent.top; topMargin: 12; left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 16 }
        spacing: 12

        // Header row
        RowLayout {
            Layout.fillWidth: true
            Text {
                text: "EQUALIZER"
                font.pixelSize: 10; font.family: Theme.font; font.weight: Font.Bold; font.letterSpacing: 1.5
                color: Theme.textDimmer
            }
            Item { Layout.fillWidth: true }

            // Active / Bypass toggle
            Rectangle {
                id: bypassBtn
                width: 64; height: 24; radius: 6
                color: !Eq.bypassed
                    ? Qt.rgba(0, 1, 0.6, bypassHov.containsMouse ? 0.30 : 0.20)
                    : Qt.rgba(1, 1, 1,   bypassHov.containsMouse ? 0.12 : 0.06)
                border.color: !Eq.bypassed ? Qt.rgba(0, 1, 0.6, 0.50) : Qt.rgba(1, 1, 1, 0.15)
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }

                Row {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: !Eq.bypassed ? "󰓃" : "󰓄"
                        font.pixelSize: 11; font.family: Theme.iconFont
                        color: !Eq.bypassed ? Theme.green : Theme.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: !Eq.bypassed ? "ACTIVE" : "BYPASS"
                        font.pixelSize: 9; font.family: Theme.font; font.weight: Font.Bold
                        color: !Eq.bypassed ? Theme.green : Theme.textDim
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: bypassHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: Eq.toggleBypass()
                }
            }
        }

        // EQ bar visualizer
        Row {
            id: barRow
            Layout.fillWidth: true
            spacing: 0

            Repeater {
                model: 10
                delegate: Item {
                    width: barRow.width / 10
                    height: eqCard.barAreaH

                    readonly property real gain: {
                        const preset = Eq.currentPreset || "Flat"
                        const g = eqCard.maxGain  // reference parent explicitly to ensure binding
                        const bands = Eq.presetGains[preset]
                        return bands ? bands[index] : 0
                    }
                    readonly property real centerY: (eqCard.barAreaH - 12) / 2
                    readonly property real barH: Math.abs(gain) / eqCard.maxGain * eqCard.barMaxH
                    readonly property bool boosted: gain > 0

                    // Center zero line
                    Rectangle {
                        width: parent.width - 6; height: 1
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: parent.centerY
                        color: Qt.rgba(1, 1, 1, 0.10)
                    }

                    // Bar
                    Rectangle {
                        id: bar
                        width: Math.max(4, parent.width - 10)
                        height: Math.max(3, barH)
                        anchors.horizontalCenter: parent.horizontalCenter
                        y: boosted ? (centerY - barH) : centerY
                        radius: 2
                        color: gain === 0 ? Qt.rgba(1,1,1,0.15)
                             : boosted    ? Theme.cyan
                             :              Theme.red
                        Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on y      { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                        Behavior on color  { ColorAnimation  { duration: 220 } }
                    }

                    // Gain label (shown when non-zero)
                    Text {
                        anchors { horizontalCenter: parent.horizontalCenter }
                        y: boosted ? (centerY - barH - 13) : (centerY + barH + 2)
                        visible: gain !== 0
                        text: (gain > 0 ? "+" : "") + gain
                        font.pixelSize: 8; font.family: Theme.font
                        color: boosted ? Theme.cyan : Theme.red
                        Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    }

                    // Frequency label
                    Text {
                        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom }
                        text: eqCard.bandLabels[index]
                        font.pixelSize: 8; font.family: Theme.font
                        color: Theme.textInactive
                    }
                }
            }
        }

        // Preset grid: 2 rows × 4 cols
        GridLayout {
            columns: 4
            Layout.fillWidth: true
            columnSpacing: 6
            rowSpacing: 6

            Repeater {
                model: Eq.presets
                delegate: Rectangle {
                    required property string modelData
                    readonly property bool active: Eq.currentPreset === modelData
                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 6
                    color: active
                        ? Qt.rgba(0.2, 0.8, 1.0, presetHov.containsMouse ? 0.24 : 0.15)
                        : Qt.rgba(1, 1, 1, presetHov.containsMouse ? 0.10 : 0.05)
                    border.color: active ? Qt.rgba(0.2, 0.8, 1.0, 0.50) : Qt.rgba(1,1,1,0.10)
                    border.width: 1
                    Behavior on color { ColorAnimation { duration: 120 } }

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        font.pixelSize: 12; font.family: Theme.font
                        font.weight: active ? Font.Medium : Font.Normal
                        color: active ? Theme.cyan : Theme.textDim
                    }
                    MouseArea {
                        id: presetHov; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: Eq.loadPreset(modelData)
                    }
                }
            }
        }
    }
}
