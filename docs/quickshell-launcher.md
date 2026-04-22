# QuickShell — App Launcher

## Overview

Fuzzy application launcher triggered by `Super+R`. Searches installed `.desktop` entries, shows icons, and launches the selected app.

## Files

| File | Role |
|------|------|
| `quickshell/launcher/Launcher.qml` | Main launcher component |
| `quickshell/shell.qml` | Instantiates `Launcher {}` in ShellRoot |

## Keybind

```
bind = $mainMod, R, exec, $qs ipc call launcher toggle
# $qs = qs -p /home/esperadoce/Source/narexil-desktop/quickshell
```

## IPC targets

| Command | Effect |
|---------|--------|
| `qs ipc call launcher show` | Open launcher |
| `qs ipc call launcher hide` | Close launcher |
| `qs ipc call launcher toggle` | Toggle open/close |

## Behaviour

- Opens as a fullscreen overlay (`WlrLayer.Overlay`) on the **currently focused monitor**
- Clicking outside the panel closes it
- `Escape` closes it
- Search is live — filters by app name and generic name
- Up/Down arrows navigate the list; `Enter` launches
- Mouse hover highlights an entry; click launches it

## App list

- Source: `DesktopEntries.applications.values` (Quickshell built-in)
- Filtered: excludes `noDisplay = true` entries, sorted alphabetically
- Capped at 50 results per query to keep the list fast

## Icons

Icons are resolved via `Quickshell.iconPath(modelData.icon)` which maps XDG icon names to full file paths. Without this call, QML treats icon names as relative paths and shows nothing.

## Launch method

```qml
app.execute()   // correct — DesktopEntry method confirmed in quickshell-core.qmltypes
// NOT app.launch() — that method does not exist on DesktopEntry
```

## Layout

```
┌─────────────────────────────────┐
│  [ Search apps…               ] │  ← TextInput, 42px tall
│                                 │
│  ● Firefox                      │  ← 48px rows, icon + name + genericName
│  ● Vivaldi                      │
│  ● ...                          │
│                                 │
└─────────────────────────────────┘
  520px wide, height auto (max 480px list)
```

## Known pitfalls

| Issue | Root cause | Fix |
|-------|-----------|-----|
| Clicking did nothing silently | `app.launch()` does not exist on `DesktopEntry` | Use `app.execute()` |
| Clicking did nothing silently | `pragma ComponentBehavior: Bound` blocked delegate access to `root` | Remove the pragma |
| Icons missing | `modelData.icon` used directly as `source` | Wrap with `Quickshell.iconPath()` |
| Scroll too slow/fast | WheelHandler multiplier | Adjust `angleDelta.y * 1.5` |
