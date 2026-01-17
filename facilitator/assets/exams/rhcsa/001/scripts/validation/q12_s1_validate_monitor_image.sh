#!/bin/bash
# Validate container image 'monitor' exists

# Check as alth user (rootless)
if sudo -u alth podman images 2>/dev/null | grep -q "monitor"; then
  echo "✅ Container image 'monitor' exists"
  exit 0
else
  # Also check as current user
  if podman images 2>/dev/null | grep -q "monitor"; then
    echo "✅ Container image 'monitor' exists"
    exit 0
  else
    echo "❌ Container image 'monitor' does not exist"
    exit 1
  fi
fi
