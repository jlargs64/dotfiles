#!/usr/bin/env bash
# Renders one native macOS Space indicator: its number, at one of three
# brightnesses.
#
#   focused    full foreground, bold
#   occupied   dim   (has at least one non-minimized window, per yabai)
#   empty      faint
#
# Focus detection order:
#   1. yabai's own view of which space has focus (authoritative when running)
#   2. $SELECTED, which SketchyBar sets on its native `space_change` event
# so the bar still highlights correctly if yabai is stopped or lacks
# Accessibility permission. Without yabai every unfocused Space renders as
# occupied, since there is no way to ask what is on it.

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh" 2>/dev/null

SID="$1"

# ----- which space has focus? ----------------------------------------------
FOCUSED=""
if command -v yabai >/dev/null 2>&1; then
  FOCUSED="$(yabai -m query --spaces 2>/dev/null \
    | jq -r 'map(select(."has-focus" == true)) | .[0].index // empty' 2>/dev/null)"
fi

if [ -n "$FOCUSED" ]; then
  [ "$SID" = "$FOCUSED" ] && IS_FOCUSED=1 || IS_FOCUSED=0
else
  # yabai unavailable: trust SketchyBar's own space component
  [ "${SELECTED:-false}" = "true" ] && IS_FOCUSED=1 || IS_FOCUSED=0
fi

# ----- does this space have windows? ---------------------------------------
WINDOWS=""
if command -v yabai >/dev/null 2>&1; then
  WINDOWS="$(yabai -m query --windows --space "$SID" 2>/dev/null \
    | jq -r 'map(select(."is-minimized" == false)) | length' 2>/dev/null)"
fi

# ----- render ---------------------------------------------------------------
if [ "$IS_FOCUSED" -eq 1 ]; then
  COLOR="$FG_FULL"
  FONT="Hack Nerd Font:Bold:13.0"
elif [ "${WINDOWS:-1}" -gt 0 ]; then
  COLOR="$FG_DIM"
  FONT="Hack Nerd Font:Regular:13.0"
else
  COLOR="$FG_FAINT"
  FONT="Hack Nerd Font:Regular:13.0"
fi

sketchybar --set "$NAME" \
  icon="$SID" \
  icon.color="$COLOR" \
  icon.font="$FONT"
