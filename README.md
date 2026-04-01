# narexil-desktop

Hyprland desktop configuration — Waybar, Rofi, wallpapers, scripts, and keybinds.
Built for a 3-monitor setup on CachyOS with an NVIDIA GPU and Hyprland via UWSM.

## Philosophy

This setup runs Hyprland but leans heavily on KDE for system tools. The goal is to avoid having two different apps that do the same thing — KDE is already installed, so wherever there's a KDE tool that works, it's used instead of pulling in something new.

This means Bluetooth, file management, authentication dialogs, wallet/keychain, settings panels — all KDE. No separate Bluetooth manager, no separate file picker, no duplicate auth agents.

The one deliberate exception is the terminal: both **Kitty** and **Konsole** are installed. Kitty is the default and used for most things. Konsole is kept for specific use cases where lower VRAM usage matters — it's significantly lighter on GPU memory than Kitty.

---

## What's included

| Component | Description |
|-----------|-------------|
| **Waybar** | Split configs: persistent bar on DP-1/HDMI-A-2, auto-hide overlay on OLED |
| **Rofi** | App launcher, run, calculator, file browser — themed to match the bar |
| **Clipboard** | cliphist + wl-clipboard, picker on `Super+Shift+V` |
| **Wallpapers** | awww (animated wallpaper daemon), per-monitor |
| **Scripts** | Weather, NordVPN, grouped media controls (prev/play/next pill), GPU/VRAM, scratchpad indicator, power menu, French correction |
| **Notifications** | mako — dark theme matching waybar, urgency levels, Papirus icons |
| **Hyprland config** | Autostart, keybinds, monitor layout, window rules |

---

## Monitor layout

| Output | Screen | Bar |
|--------|--------|-----|
| `DP-1` | Dell S2721DS 2560×1440 (main) | Persistent |
| `HDMI-A-2` | Dell S2721DS 2560×1440 (secondary) | Persistent |
| `HDMI-A-1` | MSI MPG 491C OLED 3840×1080 (above desk) | Auto-hide overlay |

If your outputs have different names, see [Adapting to your setup](#adapting-to-your-setup).

---

## Requirements

Install these before setting up:

```bash
# Core
paru -S waybar hyprland uwsm rofi-wayland rofi-calc

# Wallpapers
paru -S awww-git

# Clipboard
sudo pacman -S wl-clipboard
paru -S cliphist

# Scripts dependencies
sudo pacman -S playerctl jq curl

# Notifications
sudo pacman -S mako

# NVIDIA GPU modules (gpu.sh + vram.sh)
# requires nvidia-utils (usually already installed with NVIDIA drivers)

# French correction (optional — needs Ollama + mistral-nemo)
paru -S ollama
ollama pull mistral-nemo

# NordVPN (optional)
paru -S nordvpn-bin

# Fonts
sudo pacman -S ttf-fira-sans
paru -S ttf-nerd-fonts-symbols   # or any Nerd Font
```

---

## Setup

### 1. Clone the repo

```bash
git clone https://github.com/Esperadoce/narexil-desktop ~/Source/narexil-desktop
```

### 2. Link config directories

```bash
# Waybar
ln -sf ~/Source/narexil-desktop/waybar ~/.config/waybar

# Rofi
ln -sf ~/Source/narexil-desktop/rofi ~/.config/rofi

# Mako (notifications)
ln -sf ~/Source/narexil-desktop/mako ~/.config/mako
```

### 3. Copy Hyprland config files

The `hypr/` folder contains partial configs meant to be sourced from your main `hyprland.conf`. Either copy them or add `source` lines:

```ini
# In ~/.config/hypr/hyprland.conf
source = ~/Source/narexil-desktop/hypr/autostart.conf
source = ~/Source/narexil-desktop/hypr/bind.conf
source = ~/Source/narexil-desktop/hypr/monitors.conf
source = ~/Source/narexil-desktop/hypr/rules.conf
```

Or copy them directly to `~/.config/hypr/` if you prefer standalone files.

### 4. Add your wallpapers

Place wallpaper images in `~/Pictures/Wallpapers/`. The autostart config expects:
- `berserk.png` → DP-1
- `summer.jpeg` → HDMI-A-2
- HDMI-A-1 uses solid black (`0x000000`) for OLED burn-in prevention

Change the filenames in `hypr/autostart.conf` to match your own images.

### 5. Make scripts executable

```bash
chmod +x ~/Source/narexil-desktop/waybar/scripts/*
chmod +x ~/Source/narexil-desktop/hypr/scripts/*
```

### 6. Restart Hyprland

Log out and back in (or run `hyprctl reload` for partial changes).

---

## Auto-hide bar (OLED monitor)

The bar on `HDMI-A-1` is hidden by default and reveals itself when you move the cursor to the **top edge** of that monitor.

### How it works

`waybar/scripts/oled-autohide.sh` is a background daemon that:
1. Starts hidden — sends `SIGUSR1` to the OLED waybar instance 1.5s after boot to hide it
2. Polls cursor position every 80ms using `hyprctl cursorpos`
3. **Shows** the bar when `cursor Y ≤ 4px` and cursor is within the OLED monitor's X range
4. **Hides** it again 2000ms after the cursor leaves the top zone
5. Uses a lockfile (`/tmp/oled-autohide.lock`) so only one instance runs at a time

The OLED bar uses `"layer": "overlay"` and `"exclusive-zone": -1` so it floats above windows without pushing them down.

### Disabling auto-hide

**Option A — make the OLED bar persistent (like the other monitors):**

Edit `waybar/config-oled.jsonc` and change:
```jsonc
// FROM (auto-hide overlay):
"layer": "overlay",
"exclusive-zone": -1,

// TO (persistent, reserves space):
"layer": "top",
"exclusive-zone": 52,
```

Then remove the autohide script from autostart — in `hypr/autostart.conf`, delete:
```ini
exec-once = ~/.config/waybar/scripts/oled-autohide.sh
```

**Option B — remove the OLED bar entirely:**

Remove these two lines from `hypr/autostart.conf`:
```ini
exec-once = waybar --config ~/.config/waybar/config-oled.jsonc --style ~/.config/waybar/style.css
exec-once = ~/.config/waybar/scripts/oled-autohide.sh
```

### Changing the hide delay

Edit `waybar/scripts/oled-autohide.sh`, line 15:
```bash
HIDE_DELAY=2000  # ms before hiding after cursor leaves the top zone
```

Set to `0` to hide immediately, or a larger value to keep it visible longer.

---

## Adapting to your setup

### Different monitor names

All monitor-specific config is in a few places. Find your output names with `hyprctl monitors`.

| File | What to change |
|------|----------------|
| `waybar/config-main.jsonc` | `"output": ["DP-1", "HDMI-A-2"]` |
| `waybar/config-oled.jsonc` | `"output": ["HDMI-A-1"]` |
| `waybar/scripts/oled-autohide.sh` | `MONITOR="HDMI-A-1"` |
| `hypr/autostart.conf` | `awww img -o <output>` lines |
| `hypr/monitors.conf` | Monitor resolution/position/scale |

### Single monitor (no OLED)

Only launch the main bar. In `hypr/autostart.conf`, keep only:
```ini
exec-once = waybar --config ~/.config/waybar/config-main.jsonc --style ~/.config/waybar/style.css
```
Remove the `config-oled` and `oled-autohide.sh` lines.

### Two monitors (no OLED)

Add your second monitor to `config-main.jsonc`'s output array:
```jsonc
"output": ["DP-1", "HDMI-A-2", "your-third-output"]
```

---

## Keybinds (highlights)

| Keybind | Action |
|---------|--------|
| `Super+R` | Rofi app launcher |
| `Super+Shift+V` | Clipboard history picker |
| `Super+Alt+F` | French text correction (select text first) |
| `Super+Z` | Zoom cycle: 1x → 1.5x → 2.5x → 4x |
| `Super+Shift+Z` | Reset zoom to 1x |
| `Super+S` | Toggle scratchpad |
| `Super+Shift+S` | Move window to scratchpad |
| `Print` | Screenshot full screen (with mako thumbnail) |
| `Shift+Print` | Screenshot region (with mako thumbnail) |
| `Super+Print` | Screenshot active window (with mako thumbnail) |
| `XF86Tools` | Open Cider (Apple Music) |

---

## HDR

HDR is enabled globally via `render { enable_hdr = true }` in `hypr/general.conf`. Hyprland does not support per-monitor HDR — it applies to all outputs. Toggle by removing that line and running `hyprctl reload`.

---

## Optional: French text correction

Requires Ollama with `mistral-nemo`.

1. Select any French text in any app
2. Press `Super+Alt+F`
3. The script sends the selection to mistral-nemo via Ollama and corrects grammar/spelling
4. The corrected text is copied to your clipboard — paste it manually with `Ctrl+V`
