#!/bin/bash
# Validate Tuned service is running and enabled

if systemctl is-active --quiet tuned.service && systemctl is-enabled --quiet tuned.service; then
  echo "✅ Tuned service is running and enabled"
  exit 0
else
  echo "❌ Tuned service is not running or not enabled"
  exit 1
fi
