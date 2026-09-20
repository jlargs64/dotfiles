#!/usr/bin/env bash
# Renders one native macOS Space indicator, with the app icons of the windows
# yabai reports on that space.
#
# Focus detection order:
#   1. yabai's own view of which space has focus (authoritative when running)
#   2. $SELECTED, which SketchyBar sets on its native `space_change` event
# so the bar still highlights correctly if yabai is stopped or lacks
# Accessibility permission.

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh" 2>/dev/null
source "$CONFIG_DIR/icon_map.sh"

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

# ----- app icons on this space ---------------------------------------------
APPS=()
if command -v yabai >/dev/null 2>&1; then
  while IFS= read -r app; do
    [ -n "$app" ] && APPS+=("$app")
  done < <(yabai -m query --windows --space "$SID" 2>/dev/null \
    | jq -r '.[] | select(."is-minimized" == false) | .app' 2>/dev/null | sort -u)
fi

ICONS=""
for app in "${APPS[@]:-}"; do
  [ -z "$app" ] && continue
  __icon_map "$app"
  ICONS="$ICONS $icon_result"
done
ICONS="$(echo "$ICONS" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

# ----- render ---------------------------------------------------------------
if [ "$IS_FOCUSED" -eq 1 ]; then
  args=(
    background.drawing=on
    background.color="$PILL_ACTIVE_BG"
    background.border_color="$PILL_ACTIVE_BORDER"
    background.border_width=1
    icon="$SID"
    icon.color="$ACCENT_WORKSPACE"
  )
  LABEL_COLOR="$ACCENT_WORKSPACE"
else
  args=(
    background.drawing=off
    background.border_width=0
    icon="$SID"
    icon.color="$GREY"
  )
  LABEL_COLOR="$GREY"
fi

if [ -n "$ICONS" ]; then
  sketchybar --set "$NAME" "${args[@]}" \
    icon.padding_right=2 \
    label="$ICONS" \
    label.drawing=on \
    label.font="sketchybar-app-font:Regular:14.0" \
    label.color="$LABEL_COLOR"
else
  sketchybar --set "$NAME" "${args[@]}" \
    icon.padding_right=6 \
    label="" \
    label.drawing=off
fi
