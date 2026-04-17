# QuickShell — OLED Auto-Hide Bar

## Overview

A status bar for the MSI MPG 491C OLED ultrawide (`HDMI-A-1`) that auto-hides to protect against burn-in. It slides down from the top edge when the cursor approaches the top of that monitor and hides again 2 seconds after the cursor moves away.

## Files

| File | Role |
|------|------|
| `quickshell/bar/OledBar.qml` | Auto-hide bar logic + panel window |
| `quickshell/shell.qml` | Instantiates `OledBar {}` in ShellRoot |

## Why auto-hide

OLED pixels age faster when static bright content is displayed. A persistent bar would leave a permanent burn-in mark. The bar is only visible when actively needed (cursor at top) and otherwise keeps pixels dark.

## Trigger behaviour

- A `Timer` fires every **80ms** and runs `hyprctl cursorpos`
- On result, `_evaluate()` checks:
  - Cursor X is within the OLED monitor's X range
  - Cursor Y is within `monY` to `monY + 4` (top 4px of the monitor)
- If both true → bar slides in, hide timer stops
- If cursor leaves → `hideTimer` starts (2000ms); bar slides out on expiry

## Slide animation

```qml
property real slideY: -barH
Behavior on slideY { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
onBarVisibleChanged: slideY = barVisible ? 0 : -barH
```

The `PanelWindow` is always present (`visible: oledScreen !== null`) but the inner `Rectangle` slides above the window top via `y: root.slideY`. Layer is `WlrLayer.Overlay` with `exclusiveZone: -1` so it never pushes windows down.

## Global coordinates

`hyprctl cursorpos` returns **global** Wayland coordinates. HDMI-A-1 is positioned above the two desk monitors, so its Y origin is not 0. The bar used to never trigger because the check was `cursorY <= 4` (wrong — checked against screen-local 0).

Fix: read `obj.y` from the Hyprland monitor IPC object to get the monitor's global Y offset:
```qml
const monY = obj.y ?? 0
const atTop = cursorY >= monY && cursorY <= monY + 4
```

## Hide timer guard

The timer must not restart on every 80ms poll while the cursor is away, otherwise it never fires. The guard:
```qml
} else if (barVisible && !hideTimer.running) {
    hideTimer.start()   // start once, don't restart
}
```

`restart()` was the original (broken) call — it kept resetting the 2s countdown indefinitely.

## IPC targets

| Command | Effect |
|---------|--------|
| `qs ipc call oledbar show` | Force show, cancel hide timer |
| `qs ipc call oledbar hide` | Force hide, cancel hide timer |
| `qs ipc call oledbar toggle` | Toggle |

## Bar contents

```
[ Workspaces ] [ Scratchpad ] [ Window Title ] [ Media ]   [ Weather · Clock ]   [ GPU ] [ Sysmon ] [ Tray ] [ BT ] [ Network ] [ Volume ] [ VPN ] [ Power ]
```

## Monitor detection

`oledScreen` is resolved by name match against `Quickshell.screens`:
```qml
readonly property ShellScreen oledScreen: {
    for (let i = 0; i < Quickshell.screens.length; i++) {
        if (Quickshell.screens[i].name === "HDMI-A-1")
            return Quickshell.screens[i]
    }
    return null
}
```

The bar renders only when `oledScreen !== null`.

## Known pitfalls

| Issue | Root cause | Fix |
|-------|-----------|-----|
| Bar never appeared | Cursor Y check against 0, but OLED is above desk monitors | Use `obj.y` from Hyprland IPC for global Y offset |
| Bar appeared but never hid | `hideTimer.restart()` reset 2s countdown every 80ms poll | Guard with `!hideTimer.running`, use `start()` |
| Bar not registered to IPC | `OledBar` was a `pragma Singleton` — lazily instantiated | Convert to `Scope {}`, explicitly instantiate in `shell.qml` |
