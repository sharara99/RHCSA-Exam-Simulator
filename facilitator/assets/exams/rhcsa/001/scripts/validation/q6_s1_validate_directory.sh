#!/bin/bash
# Validate directory /home/admin exists with correct group ownership

if [ ! -d "/home/admin" ]; then
  echo "❌ Directory '/home/admin' does not exist"
  exit 1
fi

GROUP=$(stat -c '%G' /home/admin 2>/dev/null || stat -f '%Sg' /home/admin 2>/dev/null)
if [ "$GROUP" == "adminuser" ]; then
  echo "✅ Directory '/home/admin' exists with group ownership 'adminuser'"
  exit 0
else
  echo "❌ Directory '/home/admin' has incorrect group ownership: '$GROUP' (expected: 'adminuser')"
  exit 1
fi
