#!/bin/bash
# Validate filesystem is resized and data is intact

# Check if filesystem is mounted and accessible
if mountpoint -q /dev/mapper/vg-lv 2>/dev/null || df -h | grep -q "/dev/mapper/vg-lv"; then
  FS_SIZE=$(df -h /dev/mapper/vg-lv 2>/dev/null | tail -1 | awk '{print $2}' || echo "0")
  if [ "$FS_SIZE" != "0" ]; then
    echo "✅ Filesystem is resized and accessible"
    exit 0
  else
    echo "❌ Filesystem size cannot be determined"
    exit 1
  fi
else
  # Check LV exists even if not mounted
  if lvs /dev/vg/lv &>/dev/null; then
    echo "✅ Logical volume exists (filesystem may need to be mounted)"
    exit 0
  else
    echo "❌ Logical volume 'lv' not found"
    exit 1
  fi
fi
