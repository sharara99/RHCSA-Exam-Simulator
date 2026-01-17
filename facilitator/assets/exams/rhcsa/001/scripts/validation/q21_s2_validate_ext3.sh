#!/bin/bash
# Validate logical volume is formatted with ext3

FS_TYPE=$(blkid -s TYPE -o value /dev/datastore/database 2>/dev/null || file -s /dev/datastore/database 2>/dev/null | grep -o "ext3")

if [ "$FS_TYPE" == "ext3" ]; then
  echo "✅ Logical volume is formatted with ext3 filesystem"
  exit 0
else
  echo "❌ Logical volume is not formatted with ext3 (type: '$FS_TYPE')"
  exit 1
fi
