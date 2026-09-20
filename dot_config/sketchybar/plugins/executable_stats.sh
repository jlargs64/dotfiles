#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh" 2>/dev/null

STATS=$(top -l 1 -n 0 -s 0 2>/dev/null | awk '/CPU usage/ {cpu=$3} /PhysMem/ {mem=$2} END {print cpu " " mem}')
CPU=$(echo "$STATS" | awk '{print int($1)}')
MEM=$(echo "$STATS" | awk '{print $2}')

CPU_ICON=""
MEM_ICON=""

sketchybar --set "$NAME" \
  icon="$CPU_ICON" \
  icon.color="$ACCENT_STATS" \
  label="${CPU}% $MEM_ICON ${MEM}" \
  label.color="$WHITE"
