#!/usr/bin/env bash
# Derived from the active theme: ~/.config/theme/current/colors.sh
# Edit the theme, not this file.

# shellcheck disable=SC1091
source "$HOME/.config/theme/current/colors.sh"

# Snapshot the raw palette first, so deriving never reads an already-prefixed value.
_bg=$BG; _fg=$FG; _accent=$ACCENT; _accent2=$ACCENT2; _muted=$MUTED
_red=$RED; _green=$GREEN; _yellow=$YELLOW; _blue=$BLUE; _magenta=$MAGENTA; _cyan=$CYAN

# Base palette
export BLACK=0xff${_bg}
export WHITE=0xff${_fg}
export RED=0xff${_red}
export GREEN=0xff${_green}
export BLUE=0xff${_blue}
export YELLOW=0xff${_yellow}
export ORANGE=0xff${_yellow}
export MAGENTA=0xff${_magenta}
export GREY=0xff${_muted}
export TRANSPARENT=0x00000000

# Bar & pill backgrounds
export BAR_BG=0xcc${_bg}
export PILL_BG=0xcc${_bg}
export PILL_BORDER=0x66${_muted}
export PILL_ACTIVE_BG=0x44${_accent}
export PILL_ACTIVE_BORDER=0xff${_accent}

# Accents
export ACCENT_WORKSPACE=0xff${_accent}
export ACCENT_APP=0xff${_accent2}
export ACCENT_MEDIA=0xff${_magenta}
export ACCENT_STATS=0xff${_yellow}
export ACCENT_WIFI=0xff${_cyan}
export ACCENT_VOLUME=0xff${_cyan}
export ACCENT_BATTERY=0xff${_green}
export ACCENT_CLOCK=0xff${_accent2}
