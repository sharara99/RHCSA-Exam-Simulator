#!/bin/bash
# Validate user sarah exists with no interactive shell and not in adminuser

if ! getent passwd sarah &>/dev/null; then
  echo "❌ User 'sarah' does not exist"
  exit 1
fi

SHELL=$(getent passwd sarah | cut -d: -f7)
if [ "$SHELL" != "/sbin/nologin" ] && [ "$SHELL" != "/usr/sbin/nologin" ]; then
  echo "❌ User 'sarah' has interactive shell: '$SHELL'"
  exit 1
fi

if groups sarah 2>/dev/null | grep -q "adminuser"; then
  echo "❌ User 'sarah' is a member of 'adminuser' group (should not be)"
  exit 1
fi

echo "✅ User 'sarah' exists with no interactive shell and is not in 'adminuser' group"
exit 0
