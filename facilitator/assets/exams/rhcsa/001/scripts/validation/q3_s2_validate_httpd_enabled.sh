#!/bin/bash
# Validate HTTPD service is enabled at boot

if systemctl is-enabled --quiet httpd.service; then
  echo "✅ HTTPD service is enabled at boot"
  exit 0
else
  echo "❌ HTTPD service is not enabled at boot"
  exit 1
fi
