#!/bin/bash
# Validate script creates /root/script with correct content

if [ ! -f "/root/script" ]; then
  echo "❌ Output file '/root/script' does not exist"
  exit 1
fi

# Check if file has content (files with SGID bit under /usr)
FILE_SIZE=$(stat -c '%s' /root/script 2>/dev/null || stat -f '%z' /root/script 2>/dev/null)
if [ "$FILE_SIZE" -gt "0" ]; then
  echo "✅ Script output file '/root/script' exists and has content"
  exit 0
else
  echo "❌ Script output file '/root/script' is empty"
  exit 1
fi
