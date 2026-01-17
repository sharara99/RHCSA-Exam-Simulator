#!/bin/bash
# Validate cron job every minute is configured for natasha

if crontab -u natasha -l 2>/dev/null | grep -q "\*/1.*\*.*\*.*\*.*Ex200 is processing"; then
  echo "✅ Cron job every minute is configured for user 'natasha'"
  exit 0
else
  echo "❌ Cron job every minute is not configured for user 'natasha'"
  exit 1
fi
