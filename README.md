# dotfiles

Personal configuration, managed with [chezmoi](https://chezmoi.io).
macOS is the primary target; Fedora is supported for the shell and editor.

## Install

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply jlargs64
```

That clones this repo, installs packages, writes every config, and generates the
theme wallpapers.

**One manual step remains on macOS.** yabai and skhd cannot start until you
grant Accessibility permission:

1. System Settings > Privacy & Security > Accessibility
2. Add and enable `/opt/homebrew/bin/yabai` and `/opt/homebrew/bin/skhd`
3. `yabai --start-service && skhd --start-service`

See [docs/window-management.md](docs/window-management.md).

## What is in here

| Area | Config | Docs |
|---|---|---|
| Terminal | Ghostty + Zellij | [docs/zellij.md](docs/zellij.md) |
| Editor | Neovim (LazyVim) | |
| Shell | zsh + starship + mise | |
| Theming | Ghostty, Zellij, Neovim, SketchyBar, borders, wallpaper | [docs/theme-system.md](docs/theme-system.md) |
| Desktop | yabai, skhd, SketchyBar, JankyBorders | [docs/window-management.md](docs/window-management.md) |

## Theming

`theme-set <name>` restyles the terminal, editor, status bar, window borders and
wallpaper together. Most of it repaints without restarting anything.

```sh
theme-list                  # catppuccin-mocha, kanagawa-wave, retro-82
theme-set retro-82
theme-next                  # or shift + alt - t
```

Every app reads its colors through one symlink, `~/.config/theme/current`.
Switching repoints that symlink and pokes each app to re-read. Full explanation,
including how to add a theme, in [docs/theme-system.md](docs/theme-system.md).

## Window management

yabai tiles windows inside **native macOS Spaces**. The yabai scripting addition
is deliberately not used, so **SIP is never disabled**. Tiling, resizing and
focus all work without it; switching Spaces stays native (`ctrl + <number>`).

`alt` focuses, `shift + alt` moves. Full keymap in
[docs/window-management.md](docs/window-management.md).

## Layout of this repo

```
dot_config/
  ghostty/      terminal
  zellij/       multiplexer  (themes/current.kdl is a symlink)
  nvim/         LazyVim      (lua/plugins/theme.lua is a symlink)
  theme/        the theme switcher and theme definitions
  yabai/        tiling WM
  skhd/         hotkeys
  sketchybar/   status bar
  borders/      focused-window border
  raycast/      script commands
dot_local/bin/  symlinks putting theme-* on PATH
docs/           the long-form documentation
```

## Working on it

```sh
chezmoi edit ~/.config/yabai/yabairc   # edit the source, not the target
chezmoi diff                           # what would change
chezmoi apply                          # apply it
chezmoi add ~/.config/some/file        # track a file edited in place
chezmoi cd                             # shell in the source repo
```

Two kinds of files are deliberately untracked, both noted in `.chezmoiignore`:
runtime state (`~/.config/theme/current`) and generated artifacts (theme
wallpapers, ~3 MB). `run_onchange_after_setup-theme.sh.tmpl` recreates both.

One binary is excluded on purpose:
`~/.config/sketchybar/helpers/open_centered`, a compiled Mach-O helper with no
source here. Four bar items lose their click action without it; see
`dot_config/sketchybar/helpers/README.md`.
