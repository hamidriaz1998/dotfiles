#!/bin/bash

# Show available WiFi networks in wofi, connect on selection

CURRENT_CONNECTED=$(nmcli -t -f NAME,DEVICE con show --active 2>/dev/null | grep -v ':lo$' | grep ':wl' | head -1 | cut -d: -f1)

WIFI_LIST=$(nmcli -t -f SSID,SECURITY,SIGNAL,BARS device wifi list --rescan yes 2>/dev/null | sort -t: -k3 -rn | uniq)

if [[ -z "$WIFI_LIST" ]]; then
  notify-send "WiFi" "No networks found"
  exit 1
fi

MENU_ITEMS=""
while IFS=: read -r ssid security signal bars; do
  [[ -z "$ssid" ]] && continue
  if [[ "$ssid" == "$CURRENT_CONNECTED" ]]; then
    MENU_ITEMS+=" $ssid  ($bars)\n"
  else
    MENU_ITEMS+="  $ssid  ($bars)\n"
  fi
done <<< "$WIFI_LIST"

MENU_ITEMS="${MENU_ITEMS%\\n}"
MENU_ITEMS+="\n---\n Disconnect current"

SELECTED=$(printf "%b" "$MENU_ITEMS" | wofi \
  --dmenu \
  --prompt "WiFi Networks" \
  --width 400 \
  --height 400 \
  --location center \
  --hide-scroll \
  --cache-file /dev/null \
  2>/dev/null)

[[ -z "$SELECTED" ]] && exit 0

SELECTED_SSID=$(echo "$SELECTED" | sed 's/^.\{3\}//' | sed 's/  (.*)//' | xargs)

if echo "$SELECTED" | grep -q "Disconnect current"; then
  nmcli connection down "$CURRENT_CONNECTED" 2>/dev/null
  notify-send "WiFi" "Disconnected from $CURRENT_CONNECTED"
  exit 0
fi

SEC=$(echo "$WIFI_LIST" | grep -F "${SELECTED_SSID}:" | head -1 | cut -d: -f2)

if [[ "$SEC" == "" ]]; then
  nmcli device wifi connect "$SELECTED_SSID" 2>/dev/null
  notify-send "WiFi" "Connected to $SELECTED_SSID"
elif [[ "$SEC" != "" && "$SEC" != "--" ]]; then
  PASSWORD=$(printf "" | wofi --dmenu --prompt "Password for $SELECTED_SSID" --password --width 400 2>/dev/null)
  if [[ -n "$PASSWORD" ]]; then
    nmcli device wifi connect "$SELECTED_SSID" password "$PASSWORD" 2>/dev/null
    if [[ $? -eq 0 ]]; then
      notify-send "WiFi" "Connected to $SELECTED_SSID"
    else
      notify-send -u critical "WiFi" "Failed to connect. Check password."
    fi
  fi
else
  nmcli device wifi connect "$SELECTED_SSID" 2>/dev/null
  notify-send "WiFi" "Connected to $SELECTED_SSID"
fi
