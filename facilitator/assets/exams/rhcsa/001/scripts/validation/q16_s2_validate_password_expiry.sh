#!/bin/bash
# Validate password expiration is set to 20 days

if grep -q "^PASS_MAX_DAYS.*20" /etc/login.defs 2>/dev/null; then
  echo "✅ Password expiration is set to 20 days in /etc/login.defs"
  exit 0
else
  echo "❌ Password expiration is not set to 20 days in /etc/login.defs"
  exit 1
fi
