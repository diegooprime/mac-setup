#!/usr/bin/env bash
source "$HOME/.config/palette/colors.sh"

SID=$(echo "$NAME" | cut -d. -f2)
FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
APP=$(aerospace list-windows --workspace "$SID" --format '%{app-name}' 2>/dev/null | head -1)

# Map app to bundle ID
BID=""
if [ -n "$APP" ]; then
  case "$APP" in
    Ghostty)           BID="com.mitchellh.ghostty" ;;
    Alacritty)         BID="org.alacritty" ;;
    Arc)               BID="company.thebrowser.Browser" ;;
    Obsidian)          BID="md.obsidian" ;;
    Slack)             BID="com.tinyspeck.slackmacgap" ;;
    Spotify)           BID="com.spotify.client" ;;
    WhatsApp)          BID="net.whatsapp.WhatsApp" ;;
    Finder)            BID="com.apple.finder" ;;
    Safari)            BID="com.apple.Safari" ;;
    "System Settings") BID="com.apple.systempreferences" ;;
    Messages)          BID="com.apple.MobileSMS" ;;
    Mail)              BID="com.apple.mail" ;;
    Preview)           BID="com.apple.Preview" ;;
    Discord)           BID="com.hnc.Discord" ;;
    Figma)             BID="com.figma.Desktop" ;;
    Code)              BID="com.microsoft.VSCode" ;;
    Notion)            BID="notion.id" ;;
    Music)             BID="com.apple.Music" ;;
    Claude)            BID="com.anthropic.claudefordesktop" ;;
    *)                 BID=$(osascript -e "id of app \"$APP\"" 2>/dev/null) ;;
  esac
fi

ACTIVE=$( [ "$SID" = "$FOCUSED" ] && echo 1 || echo 0 )

# App icon
if [ -n "$BID" ]; then
  sketchybar --set "$NAME" \
    icon.background.image="app.$BID" \
    icon.background.image.scale=$([ "$ACTIVE" = 1 ] && echo 0.6 || echo 0.45) \
    icon.background.drawing=on \
    icon=" " \
    icon.font="JetBrainsMono Nerd Font:Bold:4.0" \
    icon.color=0x00000000 \
    icon.padding_left=10 \
    icon.padding_right=10
else
  sketchybar --set "$NAME" \
    icon.background.drawing=off \
    icon="$SID" \
    icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
    icon.padding_left=10 \
    icon.padding_right=10
fi

# Active = bigger brighter icon, inactive = smaller dimmer. No backgrounds.
if [ "$ACTIVE" = 1 ]; then
  sketchybar --set "$NAME" \
    icon.color=$([ -n "$BID" ] && echo 0x00000000 || echo "$CF_SKB_WHITE") \
    icon.background.image.scale=$([ -n "$BID" ] && echo 0.7 || echo 1.0) \
    background.drawing=off
else
  sketchybar --set "$NAME" \
    icon.color=$([ -n "$BID" ] && echo 0x00000000 || echo "$CF_SKB_DIM") \
    icon.background.image.scale=$([ -n "$BID" ] && echo 0.45 || echo 1.0) \
    background.drawing=off
fi
