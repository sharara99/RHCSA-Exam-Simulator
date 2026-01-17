#!/bin/bash
# Validate repositories are accessible (Node2)

if yum repolist &>/dev/null; then
  REPO_COUNT=$(yum repolist enabled 2>/dev/null | grep -c "repo id" || echo "0")
  if [ "$REPO_COUNT" -gt "0" ]; then
    echo "✅ Repositories are accessible and enabled"
    exit 0
  else
    echo "❌ No enabled repositories found"
    exit 1
  fi
else
  echo "❌ Cannot access repositories"
  exit 1
fi
