#!/bin/bash
# Validate user alex exists with UID 3456

if ! getent passwd alex &>/dev/null; then
  echo "❌ User 'alex' does not exist"
  exit 1
fi

ACTUAL_UID=$(getent passwd alex | cut -d: -f3)
if [ "$ACTUAL_UID" == "3456" ]; then
  echo "✅ User 'alex' exists with UID 3456"
  exit 0
else
  echo "❌ User 'alex' has incorrect UID: '$ACTUAL_UID' (expected: 3456)"
  exit 1
fi
