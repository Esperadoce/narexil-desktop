pragma Singleton
import Quickshell
import QtQuick

Singleton {
    // Backgrounds
    readonly property color barBg:    Qt.rgba(18/255, 18/255, 18/255, 0.88)
    readonly property color panelBg:  Qt.rgba(18/255, 18/255, 18/255, 0.95)
    readonly property color cardBg:   Qt.rgba(255/255, 255/255, 255/255, 0.05)
    readonly property color moduleBg: Qt.rgba(255/255, 255/255, 255/255, 0.06)
    readonly property color hoverBg:  Qt.rgba(1, 1, 1, 0.12)

    // Borders
    readonly property color barBorder:  Qt.rgba(1, 1, 1, 0.07)
    readonly property color cardBorder: Qt.rgba(1, 1, 1, 0.10)
    readonly property color cyanBorder: Qt.rgba(0.2, 0.8, 1.0, 0.3)

    // Accents
    readonly property color cyan:   "#33ccff"
    readonly property color green:  "#00ff99"
    readonly property color orange: "#ffaa00"
    readonly property color red:    "#ff5050"

    // Text
    readonly property color textPrimary:  "#e0e0e0"
    readonly property color textMuted:    "#aaaaaa"
    readonly property color textDim:      "#666666"
    readonly property color textDimmer:   "#555555"
    readonly property color textInactive: "#444444"
    readonly property color textWeather:  "#aaddff"

    // Selection
    readonly property color selectionBg:    Qt.rgba(0.2, 0.8, 1.0, 0.18)
    readonly property color selectionColor: Qt.rgba(0.2, 0.8, 1.0, 0.30)

    // Dimensions
    readonly property int barHeight:     40
    readonly property int barMargin:     12
    readonly property int barRadius:     12
    readonly property int moduleRadius:  8
    readonly property int modulePadH:    10
    readonly property int moduleMarginV: 6

    // Font
    readonly property string font:     "Rubik"
    readonly property int    fontSize: 13
}
