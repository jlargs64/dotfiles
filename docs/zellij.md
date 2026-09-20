# Zellij

Zellij is the multiplexer. Ghostty launches one **per window**, so windows never
share panes.

```
command = zsh -lc "zellij -s ghostty-$(date +%H%M%S)-$$"
```

Previously every window ran `zellij attach -c main`, which attached them all to
one session — two windows showed the same panes and looked mirrored. The `$$`
(launching zsh's PID) keeps names unique when two windows open in the same
second.

```sh
zellij list-sessions        # what is alive
zellij attach <name>        # resume after closing a window
zellij delete-all-sessions  # clean up exited ones
```

Sessions accumulate by design. Clean up when it gets noisy.

## Two keybinding systems, both live

You can use either at any time; they do not conflict.

**zellij's own modes** — `Ctrl p` pane, `Ctrl t` tab, `Ctrl n` resize,
`Ctrl s` scroll, `Ctrl o` session, `Ctrl h` move, `Ctrl g` lock. Discoverable:
the status bar shows what each mode offers. This is the easy one.

**tmux mode** — `Ctrl b` prefix, following **real tmux defaults** so the muscle
memory transfers to an actual tmux session. This is the one to practise.

The status bar shows `TMUX` after you press `Ctrl b`.

## tmux mode reference

tmux calls them *windows*; zellij calls them *tabs*. Same thing.

### Panes

| Keys | Action |
|---|---|
| `C-b "` | split vertically (new pane below) |
| `C-b %` | split horizontally (new pane right) |
| `C-b ←↓↑→` | focus pane by direction |
| `C-b o` | next pane |
| `C-b ;` | last pane |
| `C-b x` | kill pane |
| `C-b z` | zoom pane (toggle fullscreen) |
| `C-b {` / `}` | swap pane back / forward |
| `C-b !` | break pane into its own window |
| `C-b space` | next layout |
| `C-b C-←↓↑→` | resize — **repeatable**, stays in tmux mode |

Note the arrow keys. `hjkl` are *not* tmux defaults and are deliberately not
bound here, because binding them would teach the wrong reflex. zellij's own
`Ctrl p` pane mode has hjkl if you want it.

### Windows (tabs)

| Keys | Action |
|---|---|
| `C-b c` | new window |
| `C-b n` / `p` | next / previous window |
| `C-b l` | **last** window (not "right" — this is the tmux meaning of `l`) |
| `C-b 0`–`9` | go to window N |
| `C-b ,` | rename window |
| `C-b &` | kill window |
| `C-b w` | choose window interactively |

### Sessions and copy mode

| Keys | Action |
|---|---|
| `C-b d` | detach |
| `C-b s` | choose session |
| `C-b f` | find window |
| `C-b [` | copy mode (zellij calls it scroll mode) |
| `C-b C-b` | send a literal `Ctrl-b` to the program inside |

`w`, `s` and `f` all open zellij's session-manager, which covers sessions, tabs
and panes in one picker. tmux has three separate choosers; zellij has one.

### Not bound

Zellij has no equivalent for these tmux keys, so they do nothing:

| Key | tmux action |
|---|---|
| `C-b ?` | list keys |
| `C-b :` | command prompt |
| `C-b $` | rename session |
| `C-b t` | clock |
| `C-b q` | display pane numbers |
| `C-b ]` | paste buffer (use `cmd+v`) |

## Theming

The theme is set to `current`, and `~/.config/zellij/themes/current.kdl` is a
symlink into the active theme. Zellij watches its config, so a running session
repaints in place on `theme-set` — no restart. See
[theme-system.md](theme-system.md).
