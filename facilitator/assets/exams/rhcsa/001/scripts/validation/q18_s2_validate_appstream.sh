#!/bin/bash
# Validate AppStream repository is configured (Node2)

REPO_FILE="/etc/yum.repos.d/yum.repo"
EXPECTED_URL="http://domain10.example.com/rhel9/x86_64/dvd/AppStream"

if [ ! -f "$REPO_FILE" ]; then
  echo "❌ Repository file '$REPO_FILE' not found"
  exit 1
fi

if grep -q "$EXPECTED_URL" "$REPO_FILE"; then
  echo "✅ AppStream repository is configured with URL '$EXPECTED_URL'"
  exit 0
else
  echo "❌ AppStream repository URL not found in '$REPO_FILE'"
  exit 1
fi
