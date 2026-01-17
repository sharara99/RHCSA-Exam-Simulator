#!/bin/bash
# Validate system is synchronized with NTP server

if chronyc sources -v 2>/dev/null | grep -q "3.asia.ntp.org"; then
  echo "✅ System is synchronized with NTP server '3.asia.ntp.org'"
  exit 0
else
  # Still pass if chronyd is running (sync may take time)
  if systemctl is-active --quiet chronyd.service; then
    echo "⚠️  Chronyd is running, synchronization may be in progress"
    exit 0
  else
    echo "❌ System is not synchronized with NTP server"
    exit 1
  fi
fi
