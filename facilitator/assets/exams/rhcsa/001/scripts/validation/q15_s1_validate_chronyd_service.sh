#!/bin/bash
# Validate Chronyd service is running and enabled

if systemctl is-active --quiet chronyd.service && systemctl is-enabled --quiet chronyd.service; then
  echo "✅ Chronyd service is running and enabled"
  exit 0
else
  echo "❌ Chronyd service is not running or not enabled"
  exit 1
fi
