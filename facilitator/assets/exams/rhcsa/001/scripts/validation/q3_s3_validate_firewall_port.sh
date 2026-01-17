#!/bin/bash
# Validate port 82 is accessible via firewall

if firewall-cmd --list-ports 2>/dev/null | grep -q "82/tcp"; then
  echo "✅ Port 82/tcp is configured in firewall"
  exit 0
else
  echo "❌ Port 82/tcp is not configured in firewall"
  exit 1
fi
