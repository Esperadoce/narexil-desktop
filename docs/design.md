# narexil-desktop — Design Document

## Stack

| Tool     | Role                          |
|----------|-------------------------------|
| Waybar   | Top bar, tray, workspaces     |
| hyprpaper | Per-screen wallpaper         |

---

## Screens

| Monitor   | Type         | Bar        | Wallpaper       |
|-----------|--------------|------------|-----------------|
| HDMI-A-1  | MSI OLED UW  | Auto-hide  | `#000000` (black) |
| DP-1      | Dell 1440p   | Persistent | Configurable    |
| HDMI-A-2  | Dell 1440p   | Persistent | Configurable    |

---

## Bar Layout

```
[ Workspaces ]  [ Window Title ]       [ Tray ] [ Net ] [ Vol ] [ Clock ] [ Power ]
```

- Position: top
- Height: 36px
- OLED (HDMI-A-1): `auto-hide: 2000` + `exclusive-zone: -1` + `layer: overlay`
- Non-OLED: `exclusive-zone: 36` + `layer: top`

---

## Styling

- **Accent gradient**: `#33ccff` → `#00ff99`
- **Background**: `rgba(26, 26, 26, 0.85)` — dark translucent
- **Border**: 1px bottom accent line
- **Rounding**: 0px on bar edges, 8px on pills (workspaces, tray icons)
- **Font**: Rubik 13px (UI), Material Symbols Rounded (icons)
- **Accent border**: bottom 1px gradient via CSS box-shadow trick

---

## Modules

| Module                  | Config key              | Notes                        |
|-------------------------|-------------------------|------------------------------|
| Hyprland workspaces     | `hyprland/workspaces`   | Active pill wider, accent color |
| Active window title     | `hyprland/window`       | Center, truncated            |
| System tray             | `tray`                  | Proton Pass, etc.            |
| Network                 | `network`               | Icon + SSID or "Ethernet"    |
| Volume                  | `wireplumber`           | Icon + percent, scroll to adjust |
| Clock                   | `clock`                 | `HH:mm` format               |
| Power                   | `custom/power`          | `systemctl poweroff` on click |

---

## File Structure

```
narexil-desktop/           (~/.config/waybar symlink)
├── config.jsonc           # bar definitions (array of 2 bar configs)
├── style.css              # all styling
└── docs/
    └── design.md
```

Waybar reads `~/.config/waybar/config.jsonc` and `~/.config/waybar/style.css` automatically.

---

## Multi-bar Strategy

Waybar supports multiple bar definitions in a single `config.jsonc` as a JSON array.
Two entries:

1. **`bar-oled`** — targets `HDMI-A-1`, `auto-hide: 2000`, `layer: overlay`
2. **`bar-main`** — targets `DP-1` and `HDMI-A-2`, persistent, `layer: top`

Both share the same modules and style — only visibility behavior differs.

---

## Wallpaper (hyprpaper)

Managed by hyprpaper, configured in `~/.config/hypr/hyprpaper.conf`:
- HDMI-A-1 → solid black (`#000000` via a 1x1 black PNG or `swaybg` fallback)
- DP-1 / HDMI-A-2 → user-defined image path

hyprpaper is added to Hyprland autostart in `~/.config/hypr/autostart.conf`.

---

## Build Order

1. Scaffold + initial commit
2. `config.jsonc` — both bars, all modules
3. `style.css` — full styling
4. Wallpaper setup
5. Wire into Hyprland autostart
