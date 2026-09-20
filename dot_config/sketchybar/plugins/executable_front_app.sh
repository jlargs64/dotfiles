#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh" 2>/dev/null
source "$CONFIG_DIR/icon_map.sh"

APP_NAME="${INFO:-$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)}"

if [ -z "$APP_NAME" ]; then
  APP_NAME="Finder"
fi

__icon_map "$APP_NAME"

sketchybar --set "$NAME" \
  icon.font="sketchybar-app-font:Regular:16.0" \
  icon="$icon_result" \
  icon.color="$ACCENT_APP" \
  label="$APP_NAME" \
  label.color="$WHITE"
