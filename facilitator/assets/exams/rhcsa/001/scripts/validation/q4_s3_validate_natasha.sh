#!/bin/bash
# Validate user natasha exists and belongs to adminuser

if ! getent passwd natasha &>/dev/null; then
  echo "❌ User 'natasha' does not exist"
  exit 1
fi

if groups natasha 2>/dev/null | grep -q "adminuser"; then
  echo "✅ User 'natasha' exists and belongs to 'adminuser' group"
  exit 0
else
  echo "❌ User 'natasha' does not belong to 'adminuser' group"
  exit 1
fi
