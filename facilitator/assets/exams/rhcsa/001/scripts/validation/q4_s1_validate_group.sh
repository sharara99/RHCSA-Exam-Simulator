#!/bin/bash
# Validate group adminuser exists

if getent group adminuser &>/dev/null; then
  echo "✅ Group 'adminuser' exists"
  exit 0
else
  echo "❌ Group 'adminuser' does not exist"
  exit 1
fi
