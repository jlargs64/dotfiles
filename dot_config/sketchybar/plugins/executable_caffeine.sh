#!/usr/bin/env bash
# Toggle `caffeinate -dims` from the bar. While on, the display, system and
# disks are kept awake and idle sleep is blocked; click again to let the Mac
# sleep normally.
#
# The icon reports the toggle THIS BAR owns, tracked by PID in a file so it
# survives `sketchybar --reload`. It deliberately does not light up for every
# `caffeinate` process on the machine: tools spawn short, narrow ones (Claude
# Code uses `caffeinate -i -t 300`, which blocks idle system sleep for five
# minutes and never touches display sleep), so matching on the process name
# alone reported "Awake" while the Mac went to sleep anyway.
#
# A caffeinate started elsewhere that really does hold the display awake gets
# its own dimmer state, so the bar stays honest without pretending the toggle
# is on.

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh" 2>/dev/null
source "$CONFIG_DIR/plugins/hover.sh"

PIDFILE="${XDG_CACHE_HOME:-$HOME/.cache}/sketchybar/caffeinate.pid"
mkdir -p "$(dirname "$PIDFILE")"

# The PID of our own caffeinate, printed only if it is still alive and still
# caffeinate. A PID recorded before a reboot can be reused by an unrelated
# process, so the name is checked too, and a stale file is cleared.
own_pid() {
  local pid
  pid="$(cat "$PIDFILE" 2>/dev/null)"
  case "$pid" in
    "" | *[!0-9]*) return 1 ;;
  esac
  if [ "$(ps -p "$pid" -o comm= 2>/dev/null | xargs -r basename 2>/dev/null)" = "caffeinate" ]; then
    printf '%s\n' "$pid"
    return 0
  fi
  rm -f "$PIDFILE"
  return 1
}

# True when anything at all is holding display sleep off. This is the
# assertion that decides whether the screen -- and a minute later, on these
# settings, the machine -- stays awake.
display_held() {
  pmset -g assertions 2>/dev/null \
    | grep -qE '^[[:space:]]*PreventUserIdleDisplaySleep[[:space:]]+1$'
}

if [ "$SENDER" = "mouse.clicked" ]; then
  if PID="$(own_pid)"; then
    # Only ever kill the process we started. The old fallback was a bare
    # `pkill -x caffeinate`, which took out other tools' assertions too.
    kill "$PID" 2>/dev/null
    rm -f "$PIDFILE"
  else
    nohup caffeinate -dims >/dev/null 2>&1 &
    echo $! > "$PIDFILE"
  fi
fi

if own_pid >/dev/null; then
  ICON="󰅶"
  COLOR="$WHITE"
  LABEL="Awake"
elif display_held; then
  ICON="󰅶"
  COLOR="$FG_DIM"
  LABEL="Awake (elsewhere)"
else
  ICON="󰾪"
  COLOR="$FG_DIM"
  LABEL="Sleep allowed"
fi

sketchybar --set "$NAME" \
  icon="$ICON" \
  icon.color="$COLOR" \
  label="$LABEL" \
  label.color="$WHITE"
