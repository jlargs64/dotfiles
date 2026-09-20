#!/usr/bin/env bash

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh" 2>/dev/null

IP="$(ipconfig getifaddr en0 2>/dev/null)"
SSID="$(ipconfig getsummary en0 2>/dev/null | awk -F': ' '/  SSID : / {print $2}')"

if [ "$SSID" = "<redacted>" ] || [ -z "$SSID" ]; then
  SSID="$(networksetup -getairportnetwork en0 2>/dev/null | awk -F': ' '{print $2}')"
fi

if [ -n "$IP" ]; then
  if [ -n "$SSID" ] && [ "$SSID" != "You are not associated with an AirPort network." ] && [ "$SSID" != "<redacted>" ]; then
    LABEL="$SSID"
  else
    LABEL="Wi-Fi"
  fi
  if [ ${#LABEL} -gt 12 ]; then
    LABEL="${LABEL:0:10}…"
  fi
  ICON=""
  sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$ACCENT_WIFI" \
    label="$LABEL" \
    label.color="$WHITE"
else
  ICON=""
  sketchybar --set "$NAME" \
    icon="$ICON" \
    icon.color="$RED" \
    label="Offline" \
    label.color="$GREY"
fi
