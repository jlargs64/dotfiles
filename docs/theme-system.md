# Theme system

One command restyles the whole desktop. `theme-set retro-82` changes Ghostty,
Zellij, Neovim, SketchyBar, JankyBorders and the wallpaper together, and most of
it repaints without restarting anything.

This is [Omarchy](https://omarchy.org)'s mechanism ported to macOS.

## The mechanism

Every app reads its colors from a fixed path, `~/.config/theme/current`. That
path is a **symlink**. Switching themes repoints the symlink and pokes each app
to re-read its config.

```
~/.config/theme/
├── bin/
│   ├── theme-set            switch to a named theme
│   ├── theme-list           print available themes, alphabetically
│   ├── theme-next           cycle to the next theme, wrapping
│   ├── theme-wallpaper      render a wallpaper from a theme's palette
│   └── theme-raycast-sync   regenerate the Raycast dropdown from theme-list
│
├── current -> themes/retro-82      ← THE symlink. Everything reads through it.
│
└── themes/<name>/
    ├── ghostty       Ghostty config fragment
    ├── zellij.kdl    a `themes { current { ... } }` block
    ├── neovim.lua    a LazyVim plugin spec
    ├── colors.sh     the palette, as shell exports
    ├── borders       JankyBorders settings
    └── wallpaper.jpg 5120x2880, generated (not committed)
```

The indirection is the whole trick: no app knows a theme's name. Each one points
at `current/<its file>` forever, and only the symlink moves.

## Adding a theme

1. `mkdir ~/.config/theme/themes/<name>`
2. Copy the six files from an existing theme and edit them. `colors.sh` must
   export `BG FG ACCENT ACCENT2 MUTED RED GREEN YELLOW BLUE MAGENTA CYAN`
   as bare hex (no `#`, no `0x`), plus `THEME_NAME` and `NVIM_COLORSCHEME`.
3. `theme-set <name>` — the wallpaper is generated on first use.
4. `theme-raycast-sync` to add it to the Raycast dropdown.
5. `chezmoi add ~/.config/theme/themes/<name>`

`NVIM_COLORSCHEME` must be a name Neovim can pass to `:colorscheme`, which is
not always the plugin's name — see the table below.

## What `theme-set` actually does

1. Validates the theme exists (lists the available ones on error).
2. Repoints `~/.config/theme/current`.
3. Sources the new `colors.sh`.
4. `sketchybar --reload`.
5. `borders active_color=0xff$ACCENT inactive_color=0xff$MUTED`.
6. `touch ~/.config/zellij/config.kdl` — nudges Zellij's config watcher.
7. Finds every running Neovim server socket and sends
   `<Cmd>colorscheme $NVIM_COLORSCHEME<CR>` to each.
8. Sets the wallpaper via System Events, generating it first if missing.
9. Asks Ghostty to reload by sending it `cmd+shift+,`.

Steps 4 through 9 are all best-effort: a missing or stopped app is skipped, never
fatal.

## What reloads live, and what does not

| App | Behaviour |
|---|---|
| SketchyBar | live |
| JankyBorders | live |
| Wallpaper | live |
| Zellij | live — a running session repaints in place |
| Neovim | live in every running instance, via `--remote-send` |
| Ghostty | needs `cmd+shift+,`; `theme-set` sends it, but see below |

Ghostty is the one that can need a keypress. `theme-set` activates it and sends
`cmd+shift+,` via AppleScript, which requires Automation permission
(System Settings > Privacy & Security > Automation). The first switch pops that
prompt and **blocks until you answer it**. If the keystroke does not land,
`theme-set` prints `cmd+shift+, in Ghostty` and you press it yourself. Terminals
are never killed.

## The themes

### catppuccin-mocha, kanagawa-wave

Upstream everywhere — the Ghostty built-in theme, the official Zellij theme
copied from zellij's repo, the upstream Neovim plugin. Nothing hand-rolled.

### retro-82

Custom. 1982 arcade CRT: near-black phosphor background, amber primary, hot
magenta and electric cyan accents, desaturated enough to read for eight hours.

16-slot base16 palette:

```
00 0b0a0f  01 15121c  02 221c2e  03 3a3148
04 6b5a80  05 f2c66d  06 fff0c0  07 ffffff
08 ff4f6d  09 ff9f43  0A f2c66d  0B 7bff7b
0C 3ef1ff  0D 4fa8ff  0E ff59f0  0F c98cff
```

Everything is derived from those 16 values:

- **Ghostty** — ANSI 8..15 are the canonical slots verbatim; ANSI 0..7 are the
  same hues darkened 15% so bold text separates from normal text.
- **Zellij** — the simple `fg`/`bg`/named-color theme format.
- **Neovim** — `mini.base16` fed the palette directly. Because `mini.base16`
  does not register a colorscheme name, the setup call lives in a tiny local
  plugin, `themes/retro-82/nvim-retro82/colors/retro82.lua`, which sets
  `vim.g.colors_name = "retro82"` afterwards so `:colorscheme retro82` works.
- **Wallpaper** — a `0b0a0f → 221c2e` gradient with every 4th row darkened 35%,
  for faint scanlines.

## Per-app wiring

Each app was wired once. None of it needs touching again.

**Ghostty** (`~/.config/ghostty/config`) ends with a managed block:

```
config-file = ?~/.config/theme/current/ghostty
```

The leading `?` makes the include optional, so Ghostty still starts if the theme
directory is missing. Keys the theme system owns (`font-family`, `font-size`,
padding, titlebar style) are set in that block; earlier definitions of those keys
were commented out and prefixed `# [theme-system] was:`.

**Zellij** — `config.kdl` sets `theme "current"`, and
`~/.config/zellij/themes/current.kdl` is a symlink into the theme directory.

**Neovim** — `~/.config/nvim/lua/plugins/theme.lua` is a symlink to
`current/neovim.lua`. The previous `colorscheme.lua` (catppuccin-frappe) was
removed; it survives at `~/.config/nvim/lua/plugins/colorscheme.lua.bak` and in
this repo's git history.

**Neovim, part two** — `~/.config/nvim/lua/plugins/theme-plugins.lua` is a
plain tracked file (not a symlink) that declares all three colorschemes with
`lazy = true`. Without it, lazy.nvim would only ever see the plugins of the
*active* theme, which means `lazy-lock.json` churns on every switch and the
first switch to a theme has to clone its plugin. The active theme's spec
re-declares the same repo with `lazy = false` and a priority; lazy.nvim merges
the two.

**SketchyBar** — `sketchybarrc` sources the theme palette on its first line, and
`~/.config/sketchybar/colors.sh` derives every variable the bar and its plugins
already used (`PILL_BG`, `ACCENT_WORKSPACE`, `GREY`, …) from `BG`/`FG`/`ACCENT`/
`MUTED`. Plugins were not rewritten; they keep reading the same variable names.

**borders** — `bordersrc` sources the palette and sets `active_color` from
`ACCENT`, `inactive_color` from `MUTED`.

## Keybindings

| Where | Binding | Action |
|---|---|---|
| skhd | `shift + alt - t` | `theme-next` |
| Raycast | "Set Theme" | dropdown of all themes |
| Ghostty | `cmd + shift + ,` | reload config |

The Raycast dropdown is generated, not hand-maintained — run
`theme-raycast-sync` after adding a theme.

## Gotchas worth knowing

**Ghostty theme names are exact.** `theme = catppuccin-mocha` silently fails
with a "not found" dialog; the real name is `Catppuccin Mocha`. Check with
`ghostty +list-themes`.

**`g:colors_name` does not always match `NVIM_COLORSCHEME`.** kanagawa.nvim
reports `kanagawa` even when loaded as `kanagawa-wave`. The colors are correct;
only the reported name differs.

| Theme | `NVIM_COLORSCHEME` | reported `g:colors_name` |
|---|---|---|
| catppuccin-mocha | `catppuccin-mocha` | `catppuccin-mocha` |
| kanagawa-wave | `kanagawa-wave` | `kanagawa` |
| retro-82 | `retro82` | `retro82` |

**Neovim's server socket is not in `/tmp` on macOS.** It is under `$TMPDIR`
(`/var/folders/...`). And `/tmp` is itself a symlink, so `find /tmp` needs `-L`
to descend. `theme-set` searches `$TMPDIR`, `/tmp` and `/private/tmp`.

**The scripts must run on bash 3.2.** macOS ships bash 3.2.57 and
`#!/usr/bin/env bash` finds it before any Homebrew bash. No `mapfile`, no
associative arrays.

## chezmoi notes

Two things are deliberately not in the repo:

- **`current`** is runtime state — `theme-set` rewrites it constantly. It is in
  `.chezmoiignore`, and `run_onchange_after_setup-theme.sh.tmpl` seeds it to
  `retro-82` on a new machine if missing.
- **`wallpaper.jpg`** is generated. ~3 MB of deterministic binaries do not belong
  in git; the same script renders them on apply.

That setup script is a `run_onchange` keyed on a hash of every theme's
`colors.sh`, so editing a palette regenerates that theme's wallpaper on the next
`chezmoi apply`.

## Troubleshooting

```sh
readlink ~/.config/theme/current            # which theme is active
ghostty +show-config | grep -E 'foreground|background'
ghostty +show-config 2>&1 >/dev/null        # theme-name errors show here
nvim --headless -c 'lua print(vim.g.colors_name) vim.cmd("qa!")'
sketchybar --query bar | jq .color          # expect 0xcc<BG>
theme-list                                  # what is installed
```

If Ghostty shows a "Configuration Errors" dialog after a switch, the theme's
`ghostty` fragment names a theme Ghostty does not have. Compare against
`ghostty +list-themes`.
