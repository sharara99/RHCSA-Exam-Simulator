#!/bin/bash
# Validate swap is configured in /etc/fstab

if grep -q "swap.*swap" /etc/fstab 2>/dev/null; then
  echo "✅ Swap is configured in /etc/fstab"
  exit 0
else
  echo "❌ Swap is not configured in /etc/fstab"
  exit 1
fi
