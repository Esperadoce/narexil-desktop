# QuickShell — Clipboard Picker

## Overview

Clipboard history picker backed by `cliphist`. Shows recent clipboard entries, lets you search and select one to copy it back to the clipboard via `wl-copy`.

## Files

| File | Role |
|------|------|
| `quickshell/launcher/ClipboardPicker.qml` | Main clipboard picker component |
| `quickshell/shell.qml` | Instantiates `ClipboardPicker {}` in ShellRoot |

## Dependencies

| Tool | Purpose |
|------|---------|
| `cliphist` | Stores clipboard history; `cliphist list` enumerates entries, `cliphist decode` decodes a selected entry |
| `wl-copy` (wl-clipboard) | Copies decoded content to the Wayland clipboard |

## Keybind

```
bind = $mainMod SHIFT, V, exec, $qs ipc call clipboard toggle
# $qs = qs -p /home/esperadoce/Source/narexil-desktop/quickshell
```

## IPC targets

| Command | Effect |
|---------|--------|
| `qs ipc call clipboard toggle` | Toggle open/close |
| `qs ipc call clipboard show` | Open (avoid — parsed as `qs ipc show clipboard` by the CLI) |

> **Note:** use `toggle` not `show` — `qs ipc call clipboard show` is misparse by the qs CLI as a subcommand.

## Behaviour

- Opens as a fullscreen overlay (`WlrLayer.Overlay`) on the focused monitor
- Loads clipboard entries on open via `cliphist list`
- Search filters entries live (case-insensitive substring match)
- Up/Down arrows or mouse hover navigates; `Enter` or click selects
- Selecting an entry runs: `printf '%s' <entry> | cliphist decode | wl-copy` then closes the picker
- `Escape` or clicking outside closes without selecting

## Entry display

`cliphist list` output format: `<id>\t<content preview>`

The picker strips the numeric ID prefix:
```js
modelData.split("\t").slice(1).join("\t") || modelData
```
Truncated to 80 characters for display.

## Select pipeline

```qml
function select(entry: string): void {
    pasteProc.command = ["bash", "-c",
        `printf '%s' ${JSON.stringify(entry)} | cliphist decode | wl-copy`]
    pasteProc.running = true
    hide()
}
```

`JSON.stringify` safely escapes special characters in the entry string before passing it to the shell.

## Layout

```
┌─────────────────────────────────┐
│  [ Search clipboard…          ] │  ← TextInput, 42px tall
│                                 │
│  Copied text entry 1            │  ← 40px rows
│  Copied text entry 2            │
│  ...                            │
│                                 │
└─────────────────────────────────┘
  520×540px fixed, centered on screen
```

## Known pitfalls

| Issue | Root cause | Fix |
|-------|-----------|-----|
| Entries showed only numbers | Display used wrong split — kept ID, dropped content | Use `.split("\t").slice(1).join("\t")` |
| Clicking did nothing | `pragma ComponentBehavior: Bound` blocked `root.select(modelData)` | Remove the pragma |
| `show` IPC not working | `qs ipc call clipboard show` parsed as `qs ipc show clipboard` | Use `toggle` instead |
