#!/bin/bash
# Validate swap is active

if swapon --show 2>/dev/null | grep -q "/dev/"; then
  echo "✅ Swap is active"
  exit 0
else
  echo "❌ Swap is not active"
  exit 1
fi
