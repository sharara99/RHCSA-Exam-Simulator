#!/bin/bash
# Validate SELinux allows port 82 for HTTP

if semanage port -l 2>/dev/null | grep http_port_t | grep -q "82"; then
  echo "✅ Port 82 is allowed by SELinux for HTTP"
  exit 0
else
  echo "❌ Port 82 is not allowed by SELinux for HTTP"
  exit 1
fi
