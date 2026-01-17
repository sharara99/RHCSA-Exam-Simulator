#!/bin/bash
# Validate cron job at 14:23 is configured for natasha

if crontab -u natasha -l 2>/dev/null | grep -q "23 14.*Ex200 is processing"; then
  echo "✅ Cron job at 14:23 is configured for user 'natasha'"
  exit 0
else
  echo "❌ Cron job at 14:23 is not configured for user 'natasha'"
  exit 1
fi
