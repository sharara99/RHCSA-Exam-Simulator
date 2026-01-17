#!/bin/bash
# Validate HTTPD service is running

if systemctl is-active --quiet httpd.service; then
  echo "✅ HTTPD service is running"
  exit 0
else
  echo "❌ HTTPD service is not running"
  exit 1
fi
