# Desktop Session History

---

## 2026-04-14 — QuickShell migration (replace waybar + eww + rofi)

### New directory: `quickshell/`
Symlinked to `~/.config/quickshell`. Entry point: `shell.qml`.

#### Services (`quickshell/services/`) — pragma Singleton data layer
- `Theme.qml` — colors, dimensions, font
- `Audio.qml` — Pipewire volume/mute
- `Media.qml` — MPRIS player state
- `Gpu.qml` — nvidia-smi usage/VRAM/temp (2s)
- `Cpu.qml` — CPU %/temp/RAM (2s/5s)
- `Weather.qml` — wttr.in Lyon (30min)
- `NordVpn.qml` — nordvpn status + toggle (10s)
- `Brightness.qml` — ddcutil brightness, 300ms debounce
- `Bluetooth.qml` — bluetoothctl device (5s)
- `Network.qml` — wifi SSID / ethernet (5s)

#### Bar (`quickshell/bar/`)
- `MainBars.qml` — floating pill on DP-1 + HDMI-A-2
- `OledBar.qml` — WlrLayer.Overlay on HDMI-A-1, cursor auto-hide (80ms poll, 2s delay)
- `Workspaces.qml`, `WindowTitle.qml`, `MediaControls.qml`, `ClockWidget.qml`
- `WeatherWidget.qml`, `GpuWidget.qml`, `SysmonWidget.qml`, `VolumeWidget.qml`
- `NetworkWidget.qml`, `BluetoothWidget.qml`, `VpnWidget.qml`, `TrayWidget.qml`
- `ScratchpadWidget.qml`, `PowerWidget.qml`

#### Dashboard (`quickshell/dashboard/`) — eww replacement
- `Dashboard.qml` — full-screen overlay, slide animation, IPC: `qs ipc call dashboard toggle`
- Cards: `ClockCard`, `BrightnessCard`, `VolumeCard`, `SystemCard`, `MediaCard`, `NetVpnCard`

#### Launcher (`quickshell/launcher/`) — rofi replacement
- `Launcher.qml` — fuzzy DesktopEntries search, IPC: `qs ipc call launcher toggle`
- `PowerMenu.qml` — Shutdown/Reboot/Suspend/Logout, IPC: `qs ipc call powermenu toggle`
- `ClipboardPicker.qml` — cliphist + wl-copy, IPC: `qs ipc call clipboard show`

### Modified files
- `hypr/autostart.conf` — removed eww/waybar/oled-autohide, added `quickshell`
- `hypr/bind.conf` — `$menu` → `qs ipc call launcher toggle`, `Home` → dashboard toggle, `SHIFT+V` → clipboard

### Boot errors fixed
1. `color is not a type` → `import QtQuick` in Theme.qml
2. `ToolTip non-existent attached object` → `import QtQuick.Controls` in WeatherWidget/VpnWidget
3. `letterSpacing` → `font.letterSpacing` in ClockWidget
4. `IconImage is not a type` → `import Quickshell.Widgets` in TrayWidget/Launcher
5. `IpcHandler is not a type` → `import Quickshell.Io` in all IPC files
6. `FloatingWindow.y not assignable` → replaced with full-screen WlrLayer.Overlay PanelWindows
7. `placeholderTextColor` not in Qt 6.6 → manual Text overlay for placeholders
8. `Composite Singleton not creatable` → removed from ShellRoot (singletons auto-init on import)
9. `Media TypeError` → `Mpris.players.values` instead of `Mpris.players`

---

## 2026-04-02 — Session 21 (hypridle + hyprlock fixes)

### hypridle installed and configured
- `sudo pacman -S hypridle`
- `hypr/hypridle.conf` created:
  - 10 min idle → lock screen (`loginctl lock-session`)
  - 15 min idle → monitors off (`hyprctl dispatch dpms off`)
  - On resume → `dpms on`
  - Before sleep → lock session
- Added `exec-once = hypridle` to `autostart.conf`

### TODO: OLED brightness dimming before lock
- Add a dimming step before locking (e.g. 8 min → dim, 10 min → lock)
- Requires `wlr-randr` (`sudo pacman -S wlr-randr`)
- Command: `wlr-randr --output HDMI-A-1 --brightness 0.3`
- On resume: `wlr-randr --output HDMI-A-1 --brightness 1.0`
- Not implemented yet — install wlr-randr first

### Nanoleaf — work in progress
- 2 devices in Desk Room: **Color Wall 2** (`192.168.1.24`) and **Color Wall Light** (`192.168.1.30`)
- Both NL72K4, connected via Matter over Wi-Fi
- Goal: activity-based scenes triggered from Hyprland scripts
- Blocked: Color Wall 2 unreachable (`.24` offline), auth token pairing failed on Color Wall Light
- Next session: retry token pairing, or check Nanoleaf app for token export
