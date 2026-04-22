# QuickShell — IPC & Keybinds

## Overview

QuickShell exposes an IPC socket so external processes (Hyprland keybinds, scripts) can call into the running shell. Each component registers an `IpcHandler` with a target name and exposes functions.

## How IPC works

```
qs -p <shell-path> ipc call <target> <function> [args...]
```

The `-p` flag is **required** when the shell is not at `~/.config/quickshell`. Without it, `qs` looks at the default path and finds nothing.

The shell path for this config:
```
/home/esperadoce/Source/narexil-desktop/quickshell
```

Defined as `$qs` in `hypr/bind.conf`:
```
$qs = qs -p /home/esperadoce/Source/narexil-desktop/quickshell
```

## All IPC targets

| Target | Function | Effect |
|--------|----------|--------|
| `launcher` | `show` | Open app launcher |
| `launcher` | `hide` | Close app launcher |
| `launcher` | `toggle` | Toggle app launcher |
| `clipboard` | `toggle` | Toggle clipboard picker |
| `dashboard` | `toggle` | Toggle dashboard |
| `oledbar` | `show` | Force show OLED bar |
| `oledbar` | `hide` | Force hide OLED bar |
| `oledbar` | `toggle` | Toggle OLED bar |

> **Avoid `clipboard show`** — `qs ipc call clipboard show` is misparse by the CLI as `qs ipc show clipboard`. Use `toggle` instead.

## Keybinds (`hypr/bind.conf`)

```
$qs   = qs -p /home/esperadoce/Source/narexil-desktop/quickshell
$menu = $qs ipc call launcher toggle

bind = $mainMod, R,          exec, $menu
bind = $mainMod SHIFT, V,    exec, $qs ipc call clipboard toggle
bind = $mainMod, Home,       exec, $qs ipc call dashboard toggle
```

## IpcHandler registration

Each component must:
1. Be a `Scope {}` (not `pragma Singleton`) — singletons are lazily instantiated and may not register their IPC handler
2. Be explicitly instantiated in `shell.qml`

```qml
// shell.qml
ShellRoot {
    MainBars {}
    OledBar {}
    Dashboard {}
    Launcher {}
    ClipboardPicker {}
}
```

Example handler inside a component:
```qml
IpcHandler {
    target: "launcher"
    function show(): void   { root.show() }
    function hide(): void   { root.hide() }
    function toggle(): void { root.toggle() }
}
```

## Known pitfalls

| Issue | Root cause | Fix |
|-------|-----------|-----|
| IPC calls silently do nothing | Missing `-p` flag — `qs` looks at wrong path | Always use `qs -p <path> ipc call ...` |
| `clipboard show` not found | CLI parses `show` as a subcommand, not a function arg | Use `toggle` |
| Targets not registered | `pragma Singleton` types are lazy — IpcHandler never runs | Convert to `Scope {}` + instantiate in `shell.qml` |
