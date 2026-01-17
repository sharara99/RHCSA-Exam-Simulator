#!/bin/bash
# Validate umask is set for natasha user

if grep -q "umask 277" /home/natasha/.bashrc 2>/dev/null; then
  echo "✅ Umask 277 is configured in /home/natasha/.bashrc"
  exit 0
else
  echo "❌ Umask 277 is not configured in /home/natasha/.bashrc"
  exit 1
fi
