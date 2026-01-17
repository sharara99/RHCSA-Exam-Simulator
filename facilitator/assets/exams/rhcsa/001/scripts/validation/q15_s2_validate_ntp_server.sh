#!/bin/bash
# Validate NTP server 3.asia.ntp.org is configured

if grep -q "3.asia.ntp.org" /etc/chrony.conf 2>/dev/null; then
  echo "✅ NTP server '3.asia.ntp.org' is configured in /etc/chrony.conf"
  exit 0
else
  echo "❌ NTP server '3.asia.ntp.org' is not configured in /etc/chrony.conf"
  exit 1
fi
