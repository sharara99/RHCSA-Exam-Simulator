#!/bin/bash
# Validate sudo privileges are configured for adminuser group

if grep -q "^%adminuser.*NOPASSWD" /etc/sudoers 2>/dev/null || grep -q "^%adminuser.*NOPASSWD" /etc/sudoers.d/* 2>/dev/null; then
  echo "✅ Sudo privileges are configured for 'adminuser' group with NOPASSWD"
  exit 0
else
  echo "❌ Sudo privileges are not configured for 'adminuser' group"
  exit 1
fi
