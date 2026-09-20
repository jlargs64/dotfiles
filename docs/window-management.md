# Window management

Tiling windows on top of **native macOS Spaces**, without touching SIP.

| Component | Role |
|---|---|
| [yabai](https://github.com/koekeishiya/yabai) | tiles windows inside each Space |
| [skhd](https://github.com/koekeishiya/skhd) | hotkeys that drive yabai |
| [SketchyBar](https://github.com/FelixKratz/SketchyBar) | status bar, incl. Space indicators |
| [JankyBorders](https://github.com/FelixKratz/JankyBorders) | border on the focused window |

Colors for the bar and the borders come from the [theme
system](theme-system.md); neither has hardcoded colors.

## The SIP decision

yabai has an optional **scripting addition** that injects into Dock.app. It
requires partially disabling System Integrity Protection. **This setup does not
use it**, and nothing here asks you to run `csrutil`.

What still works without it — the things you actually use:

- tiling, splitting, resizing, rebalancing, rotating layouts
- focusing windows by direction
- floating and zoom-fullscreen toggles
- window rules
- signals that keep SketchyBar in sync

What you give up:

- creating and destroying Spaces from yabai (use Mission Control)
- moving a window to another Space from yabai (drag it, or use the native
  keyboard shortcut)
- `yabai -m space --focus` (use `ctrl + <number>`)

That trade is the point of the setup: macOS keeps owning Spaces, yabai only
arranges windows inside one.

## Setup on a new machine

`chezmoi apply` writes the configs and the Homebrew script installs the
binaries, but **macOS will not let either daemon run until you grant
Accessibility permission by hand.**

1. System Settings > Privacy & Security > Accessibility
2. Add and enable both:
   - `/opt/homebrew/bin/yabai`
   - `/opt/homebrew/bin/skhd`
3. Start everything:

   ```sh
   yabai --start-service
   skhd --start-service
   brew services start borders
   brew services start sketchybar
   ```

If a service refuses to start, the reason is in its log:

```sh
tail /tmp/yabai_$USER.err.log
tail /tmp/skhd_$USER.err.log
```

`could not access accessibility features! abort..` means step 2 was skipped, or
the binary was upgraded and macOS invalidated the old grant — remove the entry
and re-add it.

## Keybindings

`alt` focuses and queries. `shift + alt` moves and mutates.

### Focus

| Binding | Action |
|---|---|
| `alt - h / j / k / l` | focus window west / south / north / east |

### Move and resize

| Binding | Action |
|---|---|
| `shift + alt - h / j / k / l` | warp window in that direction |
| `ctrl + alt - h / l` | shrink / grow horizontally |
| `ctrl + alt - j / k` | grow / shrink vertically |

### Layout

| Binding | Action |
|---|---|
| `alt - e` | balance the tree |
| `alt - s` | toggle the space between **bsp** (tiled) and **stack** |
| `alt - [` / `alt - ]` | focus previous / next window in the stack |
| `shift + alt - s` | next new window **stacks** onto this one |
| `shift + alt - e` / `shift + alt - d` | next new window splits **right** / **below** |
| `alt - r` | rotate layout 90° |
| `alt - t` | toggle float, centered on a 4×4 grid |
| `alt - f` | zoom to fullscreen (within the tile tree) |
| `shift + alt - f` | native macOS fullscreen |
| `alt - m` | toggle split direction |

### Mouse

| Gesture | Action |
|---|---|
| `alt` + left-drag | move window |
| `alt` + right-drag | resize window |

### Other

| Binding | Action |
|---|---|
| `shift + alt - t` | cycle the desktop theme |
| `shift + alt - r` | restart yabai and reload SketchyBar |
| `ctrl - <number>` | switch Space (**native macOS**, see below) |

`ctrl + <number>` is not a skhd binding — it is macOS's own shortcut, and it is
off by default for Spaces past the first few. Enable it in
System Settings > Keyboard > Keyboard Shortcuts > Mission Control.

## Moving windows between Spaces

yabai cannot do this without the scripting addition. Both commands *look* like
they work and do not:

```sh
yabai -m space --focus 1          # returns 0, focus does not change
yabai -m window <id> --space 1    # "could not locate the window to act on!"
```

That is tested behaviour on this machine, not a guess. So use the native macOS
mechanisms — all of these work today:

| How | What to do |
|---|---|
| **Drag + `ctrl`+arrow** | Start dragging the window's title bar, then press `ctrl+←` / `ctrl+→` while still holding. The window travels with you. Fastest method. |
| **Drag to screen edge** | Drag the window to the left or right edge and hold. `workspaces-edge-delay` is set to `0.05`, so it flips almost instantly. |
| **Mission Control** | Drag the window to the top of the screen, then drop it on a desktop thumbnail. |
| **Pin an app** | Right-click its Dock icon > Options > Assign To > Desktop N. Per-app, not per-window. |

Switching Spaces without moving anything is `ctrl+1`..`ctrl+4`, or
`ctrl+←`/`ctrl+→`. All of those shortcuts are already enabled here; if they ever
stop working, re-check System Settings > Keyboard > Keyboard Shortcuts >
Mission Control.

## Layout configuration

`~/.config/yabai/yabairc`, in full:

- **bsp** layout, new windows open as `second_child`, no auto-balance
- 8px gaps and padding, **48px at the top** to clear the bar
  (SketchyBar is 38px tall with a 4px y_offset)
- focus does not follow the mouse, in either direction
- `window_border off` — JankyBorders draws the border instead
- never tiled: System Settings, System Information, Activity Monitor,
  Calculator, Archive Utility, Finder copy dialogs, 1Password, Raycast

To stop yabai managing another app, add a rule and restart:

```sh
yabai -m rule --add app="^App Name$" manage=off   # try it live
# then add the same line to ~/.config/yabai/yabairc to persist it
chezmoi add ~/.config/yabai/yabairc
```

## Space indicators in the bar

The bar shows Spaces 1–5 with the app icons of the windows on each. The focused
Space is drawn in the theme's `ACCENT`, the rest in `MUTED`.

Two event sources keep it current:

- `yabai_window_change` — a custom SketchyBar event, triggered by the signals in
  `yabairc` on window create / destroy / focus and on space change.
- `space_change` — SketchyBar's own built-in event for native Space switches.

`plugins/space.sh` asks yabai which Space has focus, and falls back to
SketchyBar's `$SELECTED` when yabai is not running. So the bar stays correct even
with yabai stopped or lacking permission — it just loses the app icons.

Clicking a Space runs `plugins/space_click.sh`, which tries
`yabai -m space --focus` (fails without the scripting addition) and falls back to
synthesizing the native `ctrl + <number>` keystroke.

## Desktop feel

`run_once_after_macos-defaults.sh.tmpl` sets four per-user `defaults` keys.
None need sudo, and each is reversible with `defaults delete`.

| Key | Value | Why |
|---|---|---|
| `com.apple.dock expose-animation-duration` | `0.1` | Space-switch slide, halved from the 0.2s default. The main fix for swipes feeling floaty. |
| `com.apple.dock workspaces-edge-delay` | `0.05` | Hover time before a drag at the screen edge flips Space, down from ~0.75s. |
| `com.apple.dock mru-spaces` | `false` | Stops macOS reordering Spaces by recent use. **Required** — yabai and the bar's Space indicators both assume Space N stays Space N. |
| `NSGlobalDomain NSWindowResizeTime` | `0.001` | Instant AppKit window resize. |

If switching Spaces still feels floaty at 0.1s, the stronger option is
System Settings > Accessibility > Display > **Reduce Motion**, which replaces
the slide with a near-instant crossfade. It is left off by default because it
flattens animations system-wide, not just for Spaces.

To go back to stock:

```sh
defaults delete com.apple.dock expose-animation-duration
defaults delete com.apple.dock workspaces-edge-delay
killall Dock
```

## History: what this replaced

This machine previously ran **paneru** with per-Space virtual workspaces, and
**AeroSpace** with SwipeAeroSpace before that. Both are removed. Their configs
were preserved at:

```
~/.config/wm-removed-backup-2026-09-20/
├── .aerospace.toml
├── .paneru.toml
├── aerospace-swipe/
├── aerospace.sh          (sketchybar plugin)
├── paneru.sh             (sketchybar plugin)
├── paneru_events.sh      (sketchybar plugin)
├── paneru-state/
└── com.github.karinushka.paneru.plist
```

That directory is outside this repo and is not managed by chezmoi. Delete it
once you are confident the yabai setup sticks.

The old `paneru.sh` bar plugin rendered *virtual* workspaces within one macOS
Space, and was replaced by `space.sh`, which renders real macOS Spaces.
