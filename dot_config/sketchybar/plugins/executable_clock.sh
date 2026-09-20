#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh" 2>/dev/null

sketchybar --set "$NAME" \
  icon="" \
  icon.color="$ACCENT_CLOCK" \
  label="$(date '+%a %b %d  %H:%M')" \
  label.color="$WHITE"
