import "./."
import "../services"
import Quickshell
import QtQuick

Item {
    id: content
    required property var screen

    Row {
        anchors { left: parent.left; leftMargin: 8; verticalCenter: parent.verticalCenter }
        spacing: 4
        Workspaces    { screen: content.screen }
        ScratchpadWidget {}
        WindowTitle   { verticalAlignment: Text.AlignVCenter; height: Theme.barHeight - Theme.moduleMarginV * 2 }
        MediaControls {}
    }

    Row {
        anchors { centerIn: parent }
        spacing: 8
        WeatherWidget {}
        ClockWidget   {}
    }

    // Right section — three visual clusters
    Row {
        anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
        spacing: Theme.groupSpacing

        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            GpuWidget    {}
            SysmonWidget {}
        }
        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            TrayWidget      {}
            BluetoothWidget {}
            NetworkWidget   {}
        }
        Row {
            spacing: 4
            anchors.verticalCenter: parent.verticalCenter
            VolumeWidget {}
            VpnWidget    {}
            PowerWidget  {}
        }
    }
}
