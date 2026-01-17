#!/bin/bash
# Validate swap partition of 715MB exists

SWAP_SIZE=$(free -m | grep Swap | awk '{print $2}')

if [ -z "$SWAP_SIZE" ] || [ "$SWAP_SIZE" == "0" ]; then
  echo "❌ No swap partition found or swap is not active"
  exit 1
fi

# Check if swap is approximately 715MB (allow some tolerance)
if [ "$SWAP_SIZE" -ge "710" ] && [ "$SWAP_SIZE" -le "720" ]; then
  echo "✅ Swap partition of approximately 715MB is configured (actual: ${SWAP_SIZE}MB)"
  exit 0
else
  echo "❌ Swap size is ${SWAP_SIZE}MB (expected: ~715MB)"
  exit 1
fi
