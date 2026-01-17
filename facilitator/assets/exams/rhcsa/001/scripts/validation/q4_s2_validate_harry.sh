#!/bin/bash
# Validate user harry exists and belongs to adminuser

if ! getent passwd harry &>/dev/null; then
  echo "❌ User 'harry' does not exist"
  exit 1
fi

if groups harry 2>/dev/null | grep -q "adminuser"; then
  echo "✅ User 'harry' exists and belongs to 'adminuser' group"
  exit 0
else
  echo "❌ User 'harry' does not belong to 'adminuser' group"
  exit 1
fi
