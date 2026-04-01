# narexil-desktop

Hyprland desktop config for a 3-monitor CachyOS setup with NVIDIA GPU.
Includes Waybar, an Eww on-demand dashboard, Rofi, Mako, Hypridle/Hyprlock, and a full set of scripts.

## Philosophy

Hyprland for window management, KDE for system tools. Bluetooth, auth dialogs, file picker, wallet — all KDE. No redundant apps.

The one exception: both **Kitty** (default) and **Konsole** are installed. Konsole is kept because it uses significantly less VRAM than Kitty.

---

## What's included

| Component | Description |
|-----------|-------------|
| **Waybar** | Persistent bar on DP-1/HDMI-A-2, auto-hide overlay on OLED |
| **Eww dashboard** | On-demand panel on `SUPER+HOME` — brightness, volume, stats, media, VPN |
| **Mako** | Notifications |
| **Hypridle** | Idle daemon — lock at 10min, DPMS off at 15min |
| **Hyprlock** | Lock screen with blurred screenshot, OLED-safe (solid black) |
| **Rofi** | App launcher, clipboard picker, power menu |
| **awww** | Per-monitor animated wallpaper daemon |
| **Scripts** | Weather, NordVPN, media controls, GPU/VRAM, scratchpad, French correction |

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
paru -S hyprland uwsm waybar hypridle

# Dashboard
paru -S eww
sudo pacman -S ddcutil

# Launcher + notifications
paru -S rofi-wayland rofi-calc
sudo pacman -S mako

# Wallpaper + clipboard
paru -S awww-git cliphist
sudo pacman -S wl-clipboard

# Script dependencies
sudo pacman -S playerctl jq curl

# Fonts
sudo pacman -S noto-fonts
paru -S ttf-nerd-fonts-symbols

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
ln -sf ~/Source/narexil-desktop/waybar ~/.config/waybar
ln -sf ~/Source/narexil-desktop/rofi ~/.config/rofi
ln -sf ~/Source/narexil-desktop/mako ~/.config/mako
ln -sf ~/Source/narexil-desktop/eww ~/.config/eww

# 3. Source hypr configs
# Add to ~/.config/hypr/hyprland.conf:
# source = ~/Source/narexil-desktop/hypr/autostart.conf
# source = ~/Source/narexil-desktop/hypr/bind.conf
# source = ~/Source/narexil-desktop/hypr/monitors.conf
# source = ~/Source/narexil-desktop/hypr/rules.conf

# 4. Make scripts executable
chmod +x ~/Source/narexil-desktop/waybar/scripts/*
chmod +x ~/Source/narexil-desktop/hypr/scripts/*
chmod +x ~/Source/narexil-desktop/eww/scripts/*

# 5. Add wallpapers to ~/Pictures/Wallpapers/
#    berserk.png → DP-1 | summer.jpeg → HDMI-A-2 | HDMI-A-1 uses solid black
```

---

## Eww dashboard

`SUPER+HOME` opens the panel on whichever monitor your cursor is on. Press again to close. Slides in/out from the top.

**Sections:** Clock · Brightness (DDC/CI, all 3 monitors) · Volume · CPU/RAM/GPU/VRAM · Media controls · Network + NordVPN toggle

**Brightness:** Controlled via `ddcutil` over DDC/CI. A background daemon caches values every 5s so reads are instant. Slider writes are debounced per I2C bus to avoid flooding DDC.

If your monitors use different I2C buses, run `ddcutil detect` and update `eww/scripts/brightness-daemon.sh` + the bus numbers in `eww/eww.yuck`.

---

---

## OLED burn-in prevention

`HDMI-A-1` is an OLED panel. The wallpaper is solid black and the lock screen shows no content on that monitor — black OLED pixels are fully off, which prevents burn-in from static elements.

---

## OLED auto-hide bar

The bar on `HDMI-A-1` hides by default. Move your cursor to the **top edge** of that monitor to reveal it.

`waybar/scripts/oled-autohide.sh` polls cursor position every 80ms and sends `SIGUSR1` to the waybar PID to show/hide. The bar uses `layer: overlay` + `exclusive-zone: -1` so it floats above windows without pushing them.

To disable: remove the `oled-autohide.sh` line from `hypr/autostart.conf` and change the bar layer/exclusive-zone in `waybar/config-oled.jsonc`.

---

## Adapting to your setup

Find your monitor names with `hyprctl monitors`, then update:

| File | What to change |
|------|----------------|
| `waybar/config-main.jsonc` | `"output": ["DP-1", "HDMI-A-2"]` |
| `waybar/config-oled.jsonc` | `"output": ["HDMI-A-1"]` |
| `waybar/scripts/oled-autohide.sh` | `MONITOR="HDMI-A-1"` |
| `eww/scripts/brightness-daemon.sh` | I2C bus numbers |
| `hypr/monitors.conf` | Resolution, position, scale |
| `hypr/autostart.conf` | `awww img -o <output>` wallpaper lines |

---

## Keybinds

| Keybind | Action |
|---------|--------|
| `Super+Home` | Toggle Eww dashboard |
| `Super+B` | Open Vivaldi |
| `Super+L` | Lock screen |
| `Super+R` | Rofi launcher |
| `Super+Shift+V` | Clipboard history |
| `Super+Alt+F` | French text correction |
| `Super+Z` | Zoom cycle (1× → 1.5× → 2.5× → 4×) |
| `Super+Shift+Z` | Reset zoom |
| `Super+S` | Toggle scratchpad |
| `Super+Shift+S` | Move window to scratchpad |
| `Print` | Screenshot full screen |
| `Shift+Print` | Screenshot region |
| `Super+Print` | Screenshot active window |
| `XF86Tools` | Open Cider |

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

## TODO

### Done
- [x] Waybar — persistent bar on DP-1/HDMI-A-2, auto-hide overlay on OLED
- [x] OLED auto-hide daemon (cursor-triggered, 80ms poll)
- [x] Eww on-demand dashboard (SUPER+HOME, opens on cursor's monitor)
- [x] Brightness control via DDC/CI for all 3 monitors (debounced, cached)
- [x] Volume control in dashboard
- [x] CPU / RAM / GPU / VRAM stats in dashboard
- [x] Media controls in dashboard (playerctl)
- [x] NordVPN status + toggle in dashboard
- [x] Hypridle — lock at 10min, DPMS off at 15min
- [x] Hyprlock — per-monitor layout, OLED solid black
- [x] French text correction (Ollama + mistral-nemo)
- [x] Screenshot with mako thumbnail notification
- [x] Zoom cycle (Super+Z)
- [x] Scratchpad indicator in Waybar
- [x] Clipboard history (cliphist + rofi)
- [x] SUPER+B → Vivaldi

### Planned
- [ ] Hypridle dimming — gradually dim monitors before locking instead of hard-locking
- [ ] Night light — `hyprsunset` auto color temperature by time of day (good for OLED)
- [ ] Do Not Disturb toggle in eww dashboard (mako `makoctl mode`)
- [ ] Clipboard image preview — cliphist image entries with swayimg preview
- [ ] Per-app volume in eww dashboard
- [ ] Workspace overview — `hyprexpo` plugin

### Future concepts
- [ ] AI-powered daily summary — TODO list + calendar exposed via MCP, Claude summarizes the day on demand and surfaces it in the eww dashboard or a mako notification
- [ ] Window border accent — per-window gradient borders matching `#33ccff → #00ff99`
- [ ] Plymouth boot animation — themed to match the desktop colors
- [ ] Rofi power menu redesign — visual upgrade to match the rest of the setup
- [ ] Mic mute toggle — quick keybind + mako OSD feedback
- [ ] Disk usage in eww dashboard
- [ ] App window rules — floating KDE dialogs, pavucontrol, picture-in-picture video
- [ ] `Super+E` → file manager keybind
- [ ] Quick note scratchpad — persistent note file in a toggled terminal
