#!/bin/bash
# Validate logical volume database exists with 50 PEs

if ! lvs /dev/datastore/database &>/dev/null; then
  echo "❌ Logical volume 'database' does not exist"
  exit 1
fi

# Check PE count (50 PEs * 16MB = 800MB)
LV_SIZE=$(lvs --noheadings --units m -o lv_size /dev/datastore/database 2>/dev/null | awk '{print $1}' | sed 's/[^0-9.]//g')
SIZE_INT=${LV_SIZE%.*}

# 50 PEs * 16MB = 800MB (allow tolerance)
if [ "$SIZE_INT" -ge "795" ] && [ "$SIZE_INT" -le "805" ]; then
  echo "✅ Logical volume 'database' exists with approximately 50 PEs (${LV_SIZE}MB)"
  exit 0
else
  echo "❌ Logical volume 'database' size is ${LV_SIZE}MB (expected: ~800MB for 50 PEs)"
  exit 1
fi
