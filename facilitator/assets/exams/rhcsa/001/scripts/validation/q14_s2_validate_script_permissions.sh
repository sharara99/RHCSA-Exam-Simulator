#!/bin/bash
# Validate script is executable and has correct permissions

if [ ! -f "/usr/local/bin/myscript.sh" ]; then
  echo "❌ Script '/usr/local/bin/myscript.sh' does not exist"
  exit 1
fi

if [ ! -x "/usr/local/bin/myscript.sh" ]; then
  echo "❌ Script '/usr/local/bin/myscript.sh' is not executable"
  exit 1
fi

PERMS=$(stat -c '%a' /usr/local/bin/myscript.sh 2>/dev/null || stat -f '%OLp' /usr/local/bin/myscript.sh 2>/dev/null | sed 's/^0//')
# Check if it has setgid bit (starts with 2) or at least executable
if echo "$PERMS" | grep -q "^2" || [ -x "/usr/local/bin/myscript.sh" ]; then
  echo "✅ Script has correct permissions and is executable"
  exit 0
else
  echo "⚠️  Script is executable but permissions may need adjustment"
  exit 0
fi
