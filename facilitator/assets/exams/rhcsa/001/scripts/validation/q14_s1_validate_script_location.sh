#!/bin/bash
# Validate script exists in /usr/local/bin/myscript.sh

if [ -f "/usr/local/bin/myscript.sh" ]; then
  echo "✅ Script '/usr/local/bin/myscript.sh' exists"
  exit 0
else
  echo "❌ Script '/usr/local/bin/myscript.sh' does not exist"
  exit 1
fi
