import "../services"
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts

Scope {
    id: root

    property bool shown:   false
    property var  entries: []
    property int  selectedIdx: 0

    function show(): void {
        searchInput.text = ""
        selectedIdx = 0
        loadProc.running = true
        root.shown = true
        Qt.callLater(() => searchInput.forceActiveFocus())
    }
    function hide(): void { root.shown = false; entries = [] }

    readonly property var filtered: {
        const q = searchInput.text.toLowerCase()
        return q ? entries.filter(e => e.toLowerCase().includes(q)) : entries
    }

    readonly property ShellScreen activeScreen: {
        const n = Hyprland.focusedMonitor?.name ?? ""
        for (let i = 0; i < Quickshell.screens.length; i++)
            if (Quickshell.screens[i].name === n) return Quickshell.screens[i]
        return Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    }

    Process {
        id: loadProc
        command: ["cliphist", "list"]
        stdout: StdioCollector {
            onStreamFinished: root.entries = text.trim().split("\n").filter(l => l.length > 0)
        }
    }

    Process {
        id: pasteProc
        command: []
    }

    function select(entry: string): void {
        const id = entry.split("\t")[0]
        pasteProc.command = ["bash", "-c",
            `printf '%s\t' ${JSON.stringify(id)} | cliphist decode | wl-copy`]
        pasteProc.running = true
        hide()
    }

    IpcHandler {
        target: "clipboard"
        function show(): void   { root.show() }
        function toggle(): void { if (root.shown) root.hide(); else root.show() }
    }

    PanelWindow {
        id: overlay
        screen: root.activeScreen
        visible: root.shown
        color: Qt.rgba(0, 0, 0, 0.5)

        anchors { top: true; left: true; right: true; bottom: true }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusiveZone: -1
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        MouseArea {
            anchors.fill: parent; z: -1
            onClicked: root.hide()
        }

        Rectangle {
            width: 520
            height: 540
            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            radius: 12
            color:  Theme.panelBg
            border.color: Theme.cyanBorder
            border.width: 1

            ColumnLayout {
                id: innerCol
                anchors { fill: parent; margins: 12 }
                spacing: 8

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
                            text: "Search clipboard…"
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
                            verticalAlignment: TextInput.AlignVCenter
                            focus: overlay.visible
                            onTextChanged: root.selectedIdx = 0
                            Keys.onEscapePressed:  root.hide()
                            Keys.onUpPressed:   { root.selectedIdx = Math.max(0, root.selectedIdx - 1); listView.positionViewAtIndex(root.selectedIdx, ListView.EnsureVisible) }
                            Keys.onDownPressed: { root.selectedIdx = Math.min(root.filtered.length - 1, root.selectedIdx + 1); listView.positionViewAtIndex(root.selectedIdx, ListView.EnsureVisible) }
                            Keys.onReturnPressed:  { if (root.filtered[root.selectedIdx]) root.select(root.filtered[root.selectedIdx]) }
                        }
                    }
                }

                ListView {
                    id: listView
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true

                    WheelHandler {
                        onWheel: event => {
                            listView.contentY = Math.max(0,
                                Math.min(listView.contentHeight - listView.height,
                                    listView.contentY - event.angleDelta.y * 1.5))
                        }
                    }
                        model: root.filtered
                        currentIndex: root.selectedIdx

                        delegate: Rectangle {
                            required property string modelData
                            required property int    index
                            width: listView.width; height: 40; radius: 8
                            color: index === root.selectedIdx
                                ? Qt.rgba(0.2, 0.8, 1.0, 0.18)
                                : (hov.containsMouse ? Qt.rgba(1,1,1,0.06) : "transparent")

                            Text {
                                anchors { left: parent.left; leftMargin: 14; right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
                                text: (modelData.split("\t").slice(1).join("\t") || modelData).substring(0, 80)
                                font.pixelSize: 12; font.family: Theme.font
                                color: index === root.selectedIdx ? Theme.cyan : Theme.textPrimary
                                elide: Text.ElideRight
                            }

                            MouseArea {
                                id: hov; anchors.fill: parent; hoverEnabled: true
                                acceptedButtons: Qt.LeftButton
                                onClicked: root.select(modelData)
                                onEntered: root.selectedIdx = index
                            }
                        }
                    }
                }
        }
    }
}
