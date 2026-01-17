#!/bin/bash
# Validate archive myetcbackup.tgz exists and contains /etc

if [ ! -f "/root/myetcbackup.tgz" ]; then
  echo "❌ Archive '/root/myetcbackup.tgz' does not exist"
  exit 1
fi

# Try to list contents (gzip compressed tar)
if tar -tzf /root/myetcbackup.tgz 2>/dev/null | grep -q "^etc/"; then
  echo "✅ Archive '/root/myetcbackup.tgz' exists and contains /etc"
  exit 0
else
  echo "❌ Archive '/root/myetcbackup.tgz' does not contain /etc or is corrupted"
  exit 1
fi
