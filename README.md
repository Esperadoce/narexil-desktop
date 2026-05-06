# narexil-desktop

Hyprland desktop config for a 3-monitor CachyOS setup with NVIDIA GPU.
Bar, launcher, clipboard picker, dashboard, and notifications are all handled by **QuickShell** (QML). Idle/lock via Hypridle/Hyprlock.

## Philosophy

Hyprland for window management, KDE for system tools. Bluetooth, auth dialogs, file picker, wallet — all KDE. No redundant apps.

The one exception: both **Kitty** (default) and **Konsole** are installed. Konsole is kept because it uses significantly less VRAM than Kitty.

---

## What's included

| Component | Description |
|-----------|-------------|
| **QuickShell bar** | Persistent floating pill bar on DP-1/HDMI-A-2, auto-hide overlay on OLED |
| **QuickShell dashboard** | On-demand panel on `SUPER+HOME` — brightness, volume, stats, media, weather |
| **QuickShell launcher** | `SUPER+R` — app launcher with dedupe by id |
| **QuickShell clipboard picker** | `SUPER+SHIFT+V` — cliphist-backed clipboard history |
| **System tray** | Right-click any tray icon for its context menu (hover feedback) |
| **QuickShell notifications** | Native DBus notification server + popup/center |
| **Hypridle** | Idle daemon — lock at 10min, DPMS off at 15min |
| **Hyprlock** | Lock screen with blurred screenshot, OLED-safe (solid black) |
| **awww** | Per-monitor animated wallpaper daemon |
| **Scripts** | Zoom cycle, French text correction |

---

## Monitor layout

| Output | Screen | Bar |
|--------|--------|-----|
| `DP-1` | Dell S2721DS 2560×1440 (main) | Persistent |
| `HDMI-A-2` | Dell S2721DS 2560×1440 (secondary) | Persistent |
| `HDMI-A-1` | MSI MPG 491C OLED 5120×1440 (above desk) | Auto-hide overlay |

---

## Requirements

```bash
# Core
paru -S hyprland uwsm hypridle hyprlock

# Shell (bar, launcher, dashboard, clipboard)
paru -S quickshell

# Wallpaper + clipboard
paru -S awww-git cliphist
sudo pacman -S wl-clipboard

# Brightness (DDC/CI for external monitors)
sudo pacman -S ddcutil

# Script dependencies
sudo pacman -S playerctl jq curl grimblast

# Fonts
sudo pacman -S noto-fonts ttf-rubik
paru -S ttf-material-symbols-variable-git

# Optional
paru -S nordvpn-bin ollama
ollama pull mistral-nemo   # for French correction
```

---

## Setup

```bash
# 1. Clone
git clone https://github.com/Esperadoce/narexil-desktop ~/Source/narexil-desktop

# 2. Symlink configs
ln -sf ~/Source/narexil-desktop/quickshell ~/.config/quickshell

# 3. Source hypr configs
# Add to ~/.config/hypr/hyprland.conf:
# source = ~/Source/narexil-desktop/hypr/autostart.conf
# source = ~/Source/narexil-desktop/hypr/bind.conf
# source = ~/Source/narexil-desktop/hypr/monitors.conf
# source = ~/Source/narexil-desktop/hypr/rules.conf

# 4. Make scripts executable
chmod +x ~/Source/narexil-desktop/hypr/scripts/*

# 5. Add wallpapers to ~/Pictures/Wallpapers/
#    berserk.png → DP-1 | summer.jpeg → HDMI-A-2 | HDMI-A-1 uses solid black

# 6. Start QuickShell
quickshell &
```

No build step — edit any QML file and run `pkill quickshell && quickshell &`, or for pure QML tweaks just `qs ipc call quickshell reload` where supported.

---

## QuickShell dashboard

`SUPER+HOME` opens the panel on whichever monitor your cursor is on. Press again to close.

**Sections:** Clock · Weather · Brightness (DDC/CI, all 3 monitors) · Volume · CPU/RAM/GPU/VRAM · Media controls · Network · Bluetooth · NordVPN

**Brightness:** Controlled via `ddcutil` over DDC/CI. If your monitors use different I2C buses, run `ddcutil detect` and update the bus numbers in the relevant QuickShell service.

---

## OLED burn-in prevention

`HDMI-A-1` is an OLED panel. The wallpaper is solid black and the lock screen shows no content on that monitor — black OLED pixels are fully off, which prevents burn-in from static elements.

---

## OLED auto-hide bar

The bar on `HDMI-A-1` hides by default. Move your cursor to the **top edge** of that monitor to reveal it; once visible, hovering over the bar keeps it open.

Implementation lives in `quickshell/bar/OledBar.qml` — polls `hyprctl cursorpos` every 80ms, shows when cursor Y ≤ 4px inside the OLED's X range, hides 2000ms after the cursor leaves.

IPC control: `qs ipc call oledbar {show,hide,toggle}`.

---

## Adapting to your setup

Find your monitor names with `hyprctl monitors`, then update:

| File | What to change |
|------|----------------|
| `quickshell/bar/MainBars.qml` | `s.name !== "HDMI-A-1"` exclusion filter |
| `quickshell/bar/OledBar.qml` | `"HDMI-A-1"` screen name references |
| `hypr/autostart.conf` | `awww img -o <output>` wallpaper lines |
| `hypr/monitors.conf` | Resolution, position, scale |

---

## Keybinds

| Keybind | Action |
|---------|--------|
| `Super+Q` | Kitty terminal |
| `Super+E` | Dolphin file manager |
| `Super+B` | Vivaldi |
| `Super+R` | QuickShell launcher |
| `Super+Shift+V` | QuickShell clipboard picker |
| `Super+Home` | QuickShell dashboard |
| `Super+L` | Hyprlock |
| `Super+X` | Kill active window |
| `Super+Shift+X` | Force-kill active (SIGKILL by PID) |
| `Super+V` | Toggle floating |
| `Super+F` | Fullscreen (hides bar) |
| `Super+Shift+F` | Maximize (keeps bar/gaps) |
| `Super+S` | Toggle scratchpad |
| `Super+Shift+S` | Move window to scratchpad |
| `Super+Alt+F` | French text correction |
| `Super+Z` | Zoom cycle (1× → 1.5× → 2.5× → 4×) |
| `Super+Shift+Z` | Reset zoom |
| `Print` | Screenshot full screen |
| `Shift+Print` | Screenshot region |
| `Super+Print` | Screenshot active window |
| `XF86Tools` | Cider |

IPC commands (scriptable):

```bash
qs ipc call oledbar toggle
qs ipc call dashboard toggle
qs ipc call launcher toggle
qs ipc call clipboard toggle
```

---

## HDR

Enabled globally via `render { enable_hdr = true }` in `hypr/general.conf`. Hyprland applies HDR to all outputs — no per-monitor toggle. Remove the line and `hyprctl reload` to disable.

---

## French text correction

1. Select French text in any app
2. Press `Super+Alt+F`
3. Ollama + mistral-nemo corrects grammar/spelling
4. Result is copied to clipboard — paste with `Ctrl+V`

---

## Versions

- **v1.0** — initial Waybar + Eww + Rofi setup (historical, see tag `v1.0`)
- **v2.0** — full QuickShell migration (bar, dashboard, launcher, clipboard picker) + tray context menus
- **v2.0.1** — removed dead Waybar/Eww/Rofi configs and scripts

---

## TODO

### Planned
- [ ] Hypridle dimming — gradually dim monitors before locking instead of hard-locking
- [ ] Night light — `hyprsunset` auto color temperature by time of day (good for OLED)
- [ ] Do Not Disturb toggle in dashboard (mako `makoctl mode`)
- [ ] Clipboard image preview — cliphist image entries with inline preview
- [ ] Per-app volume in dashboard
- [ ] Workspace overview — `hyprexpo` plugin

### Known rough edges
- [ ] Weather hardcoded to Lyon — breaks silently when travelling
- [ ] NordVPN toggle has no "connecting..." feedback
- [ ] No consistent cursor theme across Hyprland + KDE apps

### Future concepts
- [ ] AI-powered daily summary — TODO list + calendar exposed via MCP, Claude summarizes the day on demand
- [ ] Window border accent — per-window gradient borders matching `#33ccff → #00ff99`
- [ ] Plymouth boot animation — themed to match the desktop colors
- [ ] Mic mute toggle — quick keybind + mako OSD feedback
- [ ] Disk usage in dashboard
- [ ] Quick note scratchpad — persistent note file in a toggled terminal
