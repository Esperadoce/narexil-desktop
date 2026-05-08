import "../services"
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts

Scope {
    PanelWindow {
        id: popupWindow
        screen: {
            for (let i = 0; i < Quickshell.screens.length; i++)
                if (Quickshell.screens[i].name === "DP-1") return Quickshell.screens[i]
            return Quickshell.screens[0] ?? null
        }

        anchors { top: true; right: true }
        implicitWidth: 420
        implicitHeight: Notifications.popupModel.count > 0 ? toastCol.y + toastCol.implicitHeight + 16 : 1

        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.exclusiveZone: 0
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

        visible: Notifications.popupModel.count > 0

        Column {
            id: toastCol
            x: 8
            y: 56
            opacity: Notifications.popupModel.count > 0 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 150 } }
            width: 404
            spacing: 6

            Repeater {
                model: Notifications.popupModel

                delegate: Rectangle {
                    required property var notif

                    readonly property bool hasBody: {
                        const b = notif?.notifRef?.body ?? ""
                        return b !== "" && b !== (notif?.notifRef?.summary ?? "")
                    }
                    readonly property string imageSource: {
                        const img = notif?.notifRef?.image ?? ""
                        if (img !== "") return img.startsWith("/") ? "file://" + img : img
                        const hints = notif?.notifRef?.hints ?? {}
                        const p = hints["image-path"] ?? ""
                        if (p !== "") return p.startsWith("/") ? "file://" + p : p
                        return ""
                    }
                    readonly property bool hasImage: imageSource !== ""
                    readonly property bool hasActions: notif && notif.actionData && notif.actionData.length > 0

                    width: toastCol.width
                    radius: 10
                    clip: true
                    color: Theme.panelBg
                    border.color: {
                        if (!notif || !notif.notifRef) return Theme.cardBorder
                        return notif.notifRef.urgency === 2 ? Qt.rgba(1, 0.3, 0.3, 0.5) : Theme.cyanBorder
                    }
                    border.width: 1
                    height: 46
                        + (hasBody    ? 20 : 0)
                        + (hasImage   ? 78 : 0)
                        + (hasActions ? 42 : 0)

                    // App icon — absolutely positioned, vertically centred in the 46px header
                    IconImage {
                        id: appIcon
                        implicitSize: 16
                        source: { const i = notif?.notifRef?.appIcon ?? ""; return i.startsWith("/") ? "file://" + i : i }
                        visible: source !== ""
                        anchors { left: parent.left; leftMargin: 8; top: parent.top; topMargin: (46 - 16) / 2 }
                    }

                    // Title + dismiss — left edge at 26 (8 outer + 16 icon + 2 gap)
                    RowLayout {
                        id: headerRow
                        anchors { top: parent.top; left: parent.left; right: parent.right; leftMargin: 26; rightMargin: 10 }
                        height: 46
                        spacing: 6

                        Text {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            text: notif?.notifRef?.summary ?? notif?.notifRef?.appName ?? ""
                            font.pixelSize: 14; font.family: Theme.font; font.weight: Font.Medium
                            color: Theme.textPrimary
                            elide: Text.ElideRight
                        }
                        Text {
                            text: "×"
                            font.pixelSize: 15; font.family: Theme.font
                            color: Theme.textDim
                            Layout.alignment: Qt.AlignVCenter
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notif.dismiss()
                            }
                        }
                    }

                    // Body — same left edge as title
                    Text {
                        visible: hasBody
                        anchors { top: headerRow.bottom; left: parent.left; right: parent.right; leftMargin: 26; rightMargin: 12 }
                        height: 20
                        text: notif?.notifRef?.body ?? ""
                        font.pixelSize: 12; font.family: Theme.font
                        color: Theme.textMuted
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    // Screenshot / image
                    Rectangle {
                        visible: hasImage
                        anchors {
                            top: headerRow.bottom; topMargin: (hasBody ? 20 : 0) + 6
                            left: parent.left; right: parent.right
                            leftMargin: 26; rightMargin: 12
                        }
                        height: 66
                        radius: 6; clip: true; color: "transparent"

                        Image {
                            anchors.fill: parent
                            source: imageSource
                            fillMode: Image.PreserveAspectCrop
                            smooth: true
                            asynchronous: true
                        }
                        MouseArea {
                            anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally(imageSource)
                        }
                    }

                    // Action buttons — same left edge as title and body
                    Row {
                        visible: hasActions
                        anchors { top: headerRow.bottom; topMargin: (hasBody ? 20 : 0) + (hasImage ? 78 : 0) + 6; left: parent.left; leftMargin: 26 }
                        height: 24
                        spacing: 6

                        Repeater {
                            model: notif ? notif.actionData : []
                            delegate: Rectangle {
                                required property var modelData
                                height: 24; radius: 5
                                implicitWidth: actionLabel.implicitWidth + 14
                                color: actionMa.containsMouse ? Theme.hoverBg : Theme.moduleBg
                                Behavior on color { ColorAnimation { duration: 100 } }

                                Text {
                                    id: actionLabel
                                    anchors.centerIn: parent
                                    text: modelData.text ?? ""
                                    font.pixelSize: 11; font.family: Theme.font
                                    color: Theme.cyan
                                }
                                MouseArea {
                                    id: actionMa; anchors.fill: parent
                                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        if (modelData.id.startsWith("open-file:")) Qt.openUrlExternally("file://" + modelData.id.slice(10))
                                        notif.invokeAction(modelData.id ?? "")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
