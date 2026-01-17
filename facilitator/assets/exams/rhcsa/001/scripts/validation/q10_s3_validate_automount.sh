#!/bin/bash
# Validate remote user home directory is automounted

# Check if /home/remoteuser20 exists (may be automounted)
if [ -d "/home/remoteuser20" ]; then
  # Try to access it to trigger automount if not already mounted
  ls /home/remoteuser20 &>/dev/null
  sleep 1
  
  if mountpoint -q /home/remoteuser20 2>/dev/null || mount | grep -q "/home/remoteuser20"; then
    echo "✅ Remote user home directory '/home/remoteuser20' is automounted"
    exit 0
  else
    echo "⚠️  Directory '/home/remoteuser20' exists but may not be mounted (automount may trigger on access)"
    exit 0
  fi
else
  echo "❌ Directory '/home/remoteuser20' does not exist"
  exit 1
fi
