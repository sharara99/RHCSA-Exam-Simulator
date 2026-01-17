#!/bin/bash
# Validate container asciipdf exists and is running

# Check as alth user (rootless)
if sudo -u alth podman ps 2>/dev/null | grep -q "ascii2pdf\|asciipdf"; then
  echo "✅ Container 'asciipdf' exists and is running"
  exit 0
else
  # Also check as current user
  if podman ps 2>/dev/null | grep -q "ascii2pdf\|asciipdf"; then
    echo "✅ Container 'asciipdf' exists and is running"
    exit 0
  else
    echo "❌ Container 'asciipdf' does not exist or is not running"
    exit 1
  fi
fi
