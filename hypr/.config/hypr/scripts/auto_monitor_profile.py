#!/bin/python3
import socket
import os
import subprocess
import re
import time

HOME = os.path.expanduser("~")
CONF_PATH = os.path.join(HOME, ".config/hypr/hyprland.conf")

# Detect Hyprland IPC path
XDG_RUNTIME_DIR = os.environ.get("XDG_RUNTIME_DIR")
HYPRLAND_INSTANCE_SIGNATURE = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
if not XDG_RUNTIME_DIR:
    raise EnvironmentError("XDG_RUNTIME_DIR is not set.")
if not HYPRLAND_INSTANCE_SIGNATURE:
    raise EnvironmentError("HYPRLAND_INSTANCE_SIGNATURE is not set. Run inside Hyprland session.")

SOCKET_PATH = f"{XDG_RUNTIME_DIR}/hypr/{HYPRLAND_INSTANCE_SIGNATURE}/.socket2.sock"

# ---------------- Utility functions ----------------

def run(cmd):
    """Run a shell command and ignore errors."""
    try:
        subprocess.run(cmd, shell=True, check=True,
                       stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    except subprocess.CalledProcessError as e:
        print(f"[!] Command failed: {cmd}")
        print(e.stderr.decode())

def toggle_config_line(uncomment=True):
    """Comment/uncomment a specific line in hyprland.conf."""
    target_line = "source = ~/.config/hypr/plugin-split-monitor-workspace.conf"
    with open(CONF_PATH, "r") as f:
        lines = f.readlines()

    modified = False
    for i, line in enumerate(lines):
        if target_line in line:
            if uncomment and line.strip().startswith("#"):
                lines[i] = line.replace("#", "", 1)
                modified = True
            elif not uncomment and not line.strip().startswith("#"):
                lines[i] = "#" + line
                modified = True
            break

    if modified:
        with open(CONF_PATH, "w") as f:
            f.writelines(lines)
        print("[*] Updated hyprland.conf line.")
    else:
        print("[*] No matching line to modify or already correct.")

def is_vga_connected():
    """Check current connected monitors using hyprctl."""
    try:
        output = subprocess.check_output("hyprctl monitors -j", shell=True)
        return b"DP-1" in output
    except subprocess.CalledProcessError:
        return False

def apply_work_profile():
    print("[+] Applying 'work' profile for VGA-1 connection.")
    run("hyprmon --profile both_mons")
    # run("hyprpm enable split-monitor-workspaces")
    toggle_config_line(uncomment=True)

def revert_to_default():
    print("[-] Reverting to 'default' profile after VGA-1 disconnect.")
    # run("hyprmon profile load default")
    # run("hyprpm disable split-monitor-workspaces")
    toggle_config_line(uncomment=False)

# ---------------- Initial state check ----------------
print("[*] Checking current monitor setup...")

if is_vga_connected():
    apply_work_profile()
else:
    revert_to_default()

# ---------------- Listen for live events ----------------
print("[*] Listening for monitor connect/disconnect events...\n")

sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)

# Retry connection in case Hyprland is still starting
for _ in range(10):
    try:
        sock.connect(SOCKET_PATH)
        break
    except Exception:
        time.sleep(1)
else:
    raise ConnectionError(f"Cannot connect to Hyprland socket: {SOCKET_PATH}")

try:
    buffer = b""
    while True:
        data = sock.recv(4096)
        if not data:
            break

        buffer += data
        lines = buffer.split(b"\n")
        buffer = lines[-1]

        for line in lines[:-1]:
            msg = line.decode("utf-8", errors="ignore").strip()

            if msg.startswith("monitoradded>>"):
                monitor = msg.split(">>", 1)[1]
                if re.match(r"DP-1", monitor):
                    apply_work_profile()

            elif msg.startswith("monitorremoved>>"):
                monitor = msg.split(">>", 1)[1]
                if re.match(r"DP-1", monitor):
                    revert_to_default()

except KeyboardInterrupt:
    print("\n[*] Exiting...")
finally:
    sock.close()

