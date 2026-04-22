# QuickShell — System Tray Context Menus

## Overview

Tray icons in the main bar now expose their native context menu on right-click (and on left-click for menu-only items), with hover feedback on the icon cell. Middle-click triggers `secondaryActivate()`.

## Files

| File | Role |
|------|------|
| `quickshell/bar/TrayWidget.qml` | Repeater over `SystemTray.items`, click dispatch, `QsMenuAnchor` |
| `quickshell/shell.qml` | Declares `//@ pragma UseQApplication` — required for platform menus |

## Click dispatch

| Button | Condition | Action |
|--------|-----------|--------|
| Left | `hasMenu && onlyMenu` | Open menu via `QsMenuAnchor` |
| Left | otherwise | `modelData.activate()` |
| Middle | always | `modelData.secondaryActivate()` |
| Right | `hasMenu` | Open menu via `QsMenuAnchor` |

`onlyMenu` covers indicator applets (Qlipper-style) that have no meaningful default action — clicking them should show the menu, not no-op.

## QsMenuAnchor wiring

One shared `QsMenuAnchor` lives at the `Row` level. On each click that needs a menu, the widget reassigns `menu`, `anchor.item`, and `anchor.edges`, then calls `open()`:

```qml
QsMenuAnchor { id: menuAnchor }

// inside the delegate MouseArea onClicked
menuAnchor.menu = item.modelData.menu
menuAnchor.anchor.item = item
menuAnchor.anchor.edges = Edges.Bottom
menuAnchor.open()
```

`SystemTrayItem.menu` is a `QsMenuHandle` — calling `.open()` on it directly does nothing. It must flow through a `QsMenuAnchor` to be rendered as a platform menu.

## Hover feedback

| Signal | Property change | Animation |
|--------|-----------------|-----------|
| `MouseArea.hoverEnabled: true` + `containsMouse` | Rectangle `color: Theme.hoverBg` | `ColorAnimation { 120ms }` |
| `containsMouse` | `IconImage.scale: 1.12` | `NumberAnimation { 120ms OutCubic }` |
| hover | `cursorShape: Qt.PointingHandCursor` | — |

## Layout

```
[ icon ] [ icon ] [ icon ]
   28px each, radius 8, hoverBg on hover

         ↓ right-click
   ┌───────────────┐
   │ Show window   │
   │ Settings…     │
   │ ───────────── │
   │ Quit          │
   └───────────────┘
        ← anchored at Edges.Bottom of the icon cell
```

## QApplication mode

Platform menus (`QsMenuAnchor.open()`) require QuickShell to be launched in QApplication mode. This is opt-in via:

```qml
//@ pragma UseQApplication
```

at the top of `shell.qml`. Without it, the first call fails with:

```
ERROR: Cannot call QsMenuAnchor.open() as quickshell was not started in QApplication mode.
```

Adding the pragma requires a **full restart** (`pkill quickshell && quickshell &`) — `--reload` alone is insufficient because the Qt application object is already constructed.

## Known pitfalls

| Issue | Root cause | Fix |
|-------|-----------|-----|
| Right-click did nothing | `modelData.menu.open()` on a `QsMenuHandle` is a no-op; handles must be displayed through a `QsMenuAnchor` | Add shared `QsMenuAnchor`, assign `menu` + `anchor.item` + `anchor.edges`, then `open()` |
| `QsMenuAnchor.open()` errored at runtime | QuickShell not in QApplication mode | Add `//@ pragma UseQApplication` to `shell.qml` and restart (not reload) |
| Menu-only tray items appeared inert on left-click | Logic only called `activate()` without checking `onlyMenu` | Branch on `hasMenu && onlyMenu` → open menu instead |
| No visible hover feedback on tray icons | `MouseArea` defaulted to `hoverEnabled: false`, `containsMouse` never updated | Set `hoverEnabled: true`, bind color/scale to `containsMouse` |
