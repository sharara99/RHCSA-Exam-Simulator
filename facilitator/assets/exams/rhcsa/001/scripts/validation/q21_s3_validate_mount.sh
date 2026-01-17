#!/bin/bash
# Validate logical volume is mounted at /mnt/database

if mountpoint -q /mnt/database 2>/dev/null || df -h | grep -q "/mnt/database"; then
  MOUNTED_DEV=$(df -h /mnt/database 2>/dev/null | tail -1 | awk '{print $1}')
  if echo "$MOUNTED_DEV" | grep -q "datastore.*database"; then
    echo "✅ Logical volume is mounted at /mnt/database"
    exit 0
  else
    echo "❌ /mnt/database is mounted but not to the correct device"
    exit 1
  fi
else
  # Check if it's in fstab even if not currently mounted
  if grep -q "/mnt/database" /etc/fstab 2>/dev/null; then
    echo "✅ Logical volume is configured in /etc/fstab for /mnt/database"
    exit 0
  else
    echo "❌ Logical volume is not mounted at /mnt/database"
    exit 1
  fi
fi
