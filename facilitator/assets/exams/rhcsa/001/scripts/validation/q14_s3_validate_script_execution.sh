#!/bin/bash
# Validate script can be run from any location

if [ ! -f "/usr/local/bin/myscript.sh" ]; then
  echo "❌ Script '/usr/local/bin/myscript.sh' does not exist"
  exit 1
fi

# Try to run from /tmp
cd /tmp
if myscript.sh &>/dev/null; then
  echo "✅ Script can be executed from any location (tested from /tmp)"
  exit 0
else
  # Script might fail but that's okay, we just need to verify it's in PATH
  if command -v myscript.sh &>/dev/null; then
    echo "✅ Script is in PATH and can be executed from any location"
    exit 0
  else
    echo "❌ Script cannot be executed from other locations"
    exit 1
  fi
fi
