#!/bin/bash
# Validate string 'strato' is found and saved to /root/lines

if [ ! -f "/root/lines" ]; then
  echo "❌ File '/root/lines' does not exist"
  exit 1
fi

if grep -q "strato" /root/lines 2>/dev/null; then
  echo "✅ String 'strato' is found in '/root/lines'"
  exit 0
else
  echo "❌ String 'strato' is not found in '/root/lines'"
  exit 1
fi
