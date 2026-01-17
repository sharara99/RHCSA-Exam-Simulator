#!/bin/bash
# Validate new files get adminuser group ownership (setgid bit)

if [ ! -d "/home/admin" ]; then
  echo "❌ Directory '/home/admin' does not exist"
  exit 1
fi

# Check if setgid bit is set
PERMS=$(stat -c '%a' /home/admin 2>/dev/null || stat -f '%OLp' /home/admin 2>/dev/null | sed 's/^0//')
if echo "$PERMS" | grep -q "^2"; then
  echo "✅ Setgid bit is set on '/home/admin' directory"
  exit 0
else
  echo "❌ Setgid bit is not set on '/home/admin' directory"
  exit 1
fi
