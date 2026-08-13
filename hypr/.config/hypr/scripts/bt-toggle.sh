#!/usr/bin/bash

DEVICE="41:42:39:3A:6B:75"
LOCKFILE="/tmp/bt-toggle.lock"
NOTIFICATION_ID_FILE="/tmp/bt-toggle.notification-id"
TIMEOUT=10
# Pick up the ID of a still-visible toast from a previous run so a fresh
# invocation (e.g. pressing the keybind again before it's dismissed) replaces
# it instead of stacking a new one. A stale/dismissed ID is harmless: the
# notification server falls back to creating a new toast.
NOTIFICATION_ID=$(cat "$NOTIFICATION_ID_FILE" 2>/dev/null || true)

notify() {
    local id

    if [ -n "$NOTIFICATION_ID" ]; then
        id=$(omarchy-notification-send --app-name "bt-toggle" "$1" "$2" \
            --replace-id "$NOTIFICATION_ID" -p)
    else
        # Keep the processing toast alive for the Bluetooth timeout window so
        # the final status can replace it instead of creating a new toast.
        id=$(omarchy-notification-send --app-name "bt-toggle" "$1" "$2" \
            -t 30000 -p)
    fi

    if [ -n "$id" ]; then
        NOTIFICATION_ID="$id"
        printf '%s' "$id" > "$NOTIFICATION_ID_FILE"
    fi
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
