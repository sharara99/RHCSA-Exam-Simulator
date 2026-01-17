#!/bin/bash
# Validate BaseOS repository is configured

REPO_FILE="/etc/yum.repos.d/yum.repo"
EXPECTED_URL="http://content.example.com/rhel9/x86_64/dvd/BaseOS"

if [ ! -f "$REPO_FILE" ]; then
  echo "❌ Repository file '$REPO_FILE' not found"
  exit 1
fi

if grep -q "$EXPECTED_URL" "$REPO_FILE"; then
  echo "✅ BaseOS repository is configured with URL '$EXPECTED_URL'"
  exit 0
else
  echo "❌ BaseOS repository URL not found in '$REPO_FILE'"
  exit 1
fi
