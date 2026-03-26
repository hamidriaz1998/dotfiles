#!/usr/bin/bash

DEVICE="41:42:39:3A:6B:75"
SYNC_KEY="bt-toggle"
LOCKFILE="/tmp/bt-toggle.lock"
TIMEOUT=10

notify() {
    notify-send "$1" "$2" \
        -h string:x-canonical-private-synchronous:$SYNC_KEY
}

# Prevent multiple runs
if [ -e "$LOCKFILE" ]; then
    notify "Bluetooth" "Already processing..."
    exit 1
fi

touch "$LOCKFILE"

(
    trap 'rm -f "$LOCKFILE"' EXIT

    INFO=$(timeout $TIMEOUT bluetoothctl info "$DEVICE" 2>/dev/null)

    NAME=$(echo "$INFO" | grep "Name:" | cut -d ' ' -f2-)
    [ -z "$NAME" ] && NAME="$DEVICE"

    if echo "$INFO" | grep -q "Connected: yes"; then
        notify "Bluetooth" "Disconnecting from $NAME..."

        timeout $TIMEOUT bluetoothctl disconnect "$DEVICE" >/dev/null 2>&1

        notify "Bluetooth" "Disconnected from $NAME 🔌"
    else
        notify "Bluetooth" "Connecting to $NAME..."

        OUTPUT=$(timeout $TIMEOUT bluetoothctl connect "$DEVICE" 2>&1)

        if echo "$OUTPUT" | grep -q "Connection successful"; then
            notify "Bluetooth" "Connected to $NAME ✅"
        else
            notify "Bluetooth" "Failed to connect to $NAME ❌"
        fi
    fi
) & disown
