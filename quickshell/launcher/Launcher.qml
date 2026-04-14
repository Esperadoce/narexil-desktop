pragma Singleton
pragma ComponentBehavior: Bound
import "./."
import "../services"
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Singleton {
    id: root

    property bool shown: false
    property int  selectedIdx: 0

    function show(): void {
        root.shown = true
        Qt.callLater(() => searchInput.forceActiveFocus())
    }
    function hide(): void {
        root.shown = false
        searchInput.text = ""
        selectedIdx = 0
    }
    function toggle(): void { if (root.shown) hide(); else show() }

    readonly property ShellScreen activeScreen: {
        const n = Hyprland.focusedMonitor?.name ?? ""
        for (let i = 0; i < Quickshell.screens.length; i++)
            if (Quickshell.screens[i].name === n) return Quickshell.screens[i]
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    }

    readonly property var allApps: DesktopEntries.applications.values
        .filter(a => a.name && !a.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))

    readonly property var filteredApps: {
        const q = searchInput.text.toLowerCase().trim()
        if (!q) return allApps.slice(0, 50)
        return allApps
            .filter(a =>
                a.name.toLowerCase().includes(q) ||
                (a.genericName ?? "").toLowerCase().includes(q))
            .slice(0, 50)
    }

    onFilteredAppsChanged: selectedIdx = 0

    function launch(idx: int): void {
        const app = filteredApps[idx]
        if (app) { app.launch(); hide() }
    }

    IpcHandler {
        target: "launcher"
        function show(): void   { root.show() }
        function hide(): void   { root.hide() }
        function toggle(): void { root.toggle() }
    }

    PanelWindow {
        id: overlay
        screen: root.activeScreen
        visible: root.shown
        color: Qt.rgba(0, 0, 0, 0.5)

        anchors { top: true; left: true; right: true; bottom: true }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        MouseArea {
            anchors.fill: parent; z: -1
            onClicked: root.hide()
        }

        Rectangle {
            id: panel
            width: 520
            implicitHeight: innerCol.implicitHeight + 24
            anchors {
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            radius: 12
            color:  Theme.panelBg
            border.color: Theme.cyanBorder
            border.width: 1

            ColumnLayout {
                id: innerCol
                anchors { top: parent.top; topMargin: 12; left: parent.left; leftMargin: 12; right: parent.right; rightMargin: 12 }
                spacing: 8

                // Search bar
                Rectangle {
                    Layout.fillWidth: true
                    height: 42; radius: 8
                    color: Qt.rgba(1,1,1,0.08)
                    border.color: searchInput.activeFocus ? Theme.cyan : Qt.rgba(1,1,1,0.12)
                    border.width: 1

                    Item {
                        anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                        height: 24

                        Text {
                            anchors.fill: parent
                            text: "Search apps…"
                            font.pixelSize: 14; font.family: Theme.font
                            color: Theme.textInactive
                            verticalAlignment: Text.AlignVCenter
                            visible: !searchInput.text
                        }

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            color: Theme.textPrimary
                            font.pixelSize: 14; font.family: Theme.font
                            selectionColor: Qt.rgba(0.2, 0.8, 1.0, 0.3)
                            verticalAlignment: TextInput.AlignVCenter
                            focus: overlay.visible
                            onTextChanged: root.selectedIdx = 0

                            Keys.onEscapePressed: root.hide()
                            Keys.onUpPressed:    root.selectedIdx = Math.max(0, root.selectedIdx - 1)
                            Keys.onDownPressed:  root.selectedIdx = Math.min(root.filteredApps.length - 1, root.selectedIdx + 1)
                            Keys.onReturnPressed: root.launch(root.selectedIdx)
                        }
                    }
                }

                // App list
                ListView {
                    id: appList
                    Layout.fillWidth: true
                    implicitHeight: Math.min(contentHeight, 480)
                    clip: true
                    model: root.filteredApps
                    currentIndex: root.selectedIdx
                    onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.EnsureVisible)

                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        width: appList.width; height: 48; radius: 8
                        color: index === root.selectedIdx
                            ? Qt.rgba(0.2, 0.8, 1.0, 0.18)
                            : (hov.containsMouse ? Qt.rgba(1,1,1,0.06) : "transparent")

                        Row {
                            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                            spacing: 12

                            IconImage {
                                source: modelData.icon ?? ""
                                implicitSize: 24
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Column {
                                spacing: 2; anchors.verticalCenter: parent.verticalCenter
                                Text {
                                    text: modelData.name
                                    font.pixelSize: 13; font.family: Theme.font
                                    color: index === root.selectedIdx ? Theme.cyan : Theme.textPrimary
                                }
                                Text {
                                    visible: !!(modelData.genericName)
                                    text: modelData.genericName ?? ""
                                    font.pixelSize: 10; font.family: Theme.font
                                    color: Theme.textDim
                                }
                            }
                        }

                        MouseArea {
                            id: hov; anchors.fill: parent; hoverEnabled: true
                            onClicked: root.launch(index)
                            onEntered: root.selectedIdx = index
                        }
                    }
                }
            }
        }
    }
}
