#!/bin/bash
# Validate AutoFS service is running and enabled

if systemctl is-active --quiet autofs && systemctl is-enabled --quiet autofs; then
  echo "✅ AutoFS service is running and enabled"
  exit 0
else
  echo "❌ AutoFS service is not running or not enabled"
  exit 1
fi
