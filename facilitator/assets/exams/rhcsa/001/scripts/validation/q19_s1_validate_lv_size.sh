#!/bin/bash
# Validate logical volume lv is resized to 300 MB

LV_SIZE=$(lvs --noheadings --units m -o lv_size /dev/vg/lv 2>/dev/null | awk '{print $1}' | sed 's/[^0-9.]//g')

if [ -z "$LV_SIZE" ]; then
  echo "❌ Logical volume 'lv' not found"
  exit 1
fi

# Check if size is approximately 300MB (allow some tolerance)
SIZE_INT=${LV_SIZE%.*}
if [ "$SIZE_INT" -ge "295" ] && [ "$SIZE_INT" -le "305" ]; then
  echo "✅ Logical volume 'lv' is resized to approximately 300 MB (actual: ${LV_SIZE}MB)"
  exit 0
else
  echo "❌ Logical volume 'lv' size is ${LV_SIZE}MB (expected: ~300MB)"
  exit 1
fi
