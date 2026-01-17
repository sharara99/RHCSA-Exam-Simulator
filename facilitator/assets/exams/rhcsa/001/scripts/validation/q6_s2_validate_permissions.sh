#!/bin/bash
# Validate directory has correct permissions (2770)

PERMS=$(stat -c '%a' /home/admin 2>/dev/null || stat -f '%OLp' /home/admin 2>/dev/null | sed 's/^0//')

if [ "$PERMS" == "2770" ]; then
  echo "✅ Directory '/home/admin' has correct permissions (2770)"
  exit 0
else
  echo "❌ Directory '/home/admin' has incorrect permissions: '$PERMS' (expected: 2770)"
  exit 1
fi
