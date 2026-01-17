#!/bin/bash
# Validate recommended tuned profile is active

ACTIVE_PROFILE=$(tuned-adm active 2>/dev/null | awk '{print $4}')

if [ -n "$ACTIVE_PROFILE" ] && [ "$ACTIVE_PROFILE" != "none" ]; then
  echo "✅ Tuned profile is active: '$ACTIVE_PROFILE'"
  exit 0
else
  echo "❌ No tuned profile is active"
  exit 1
fi
