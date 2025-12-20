#!/bin/bash
VM_NAME="win10"
LIBVIRT_DEFAULT_URI=qemu:///system

# Check if it's already running
if virsh list --name | grep -q "^$VM_NAME$"; then
  notify-send "Windows 10" "Already running ✅"
  virt-manager --show-domain-console win10 -c qemu:///system
else
  notify-send "Windows 10" "Starting virtual machine..."
  virsh start "$VM_NAME"
  sleep 3
  virt-manager --show-domain-console win10 -c qemu:///system
fi
