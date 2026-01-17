#!/bin/bash
# Validate systemd user service is configured and enabled

# Check as alth user
if sudo -u alth systemctl --user is-enabled container-ascii2pdf.service 2>/dev/null | grep -q "enabled"; then
  if sudo -u alth systemctl --user is-active --quiet container-ascii2pdf.service 2>/dev/null; then
    echo "✅ Systemd user service 'container-ascii2pdf.service' is configured and enabled"
    exit 0
  else
    echo "⚠️  Service is enabled but not active"
    exit 0
  fi
else
  echo "❌ Systemd user service 'container-ascii2pdf.service' is not enabled"
  exit 1
fi
