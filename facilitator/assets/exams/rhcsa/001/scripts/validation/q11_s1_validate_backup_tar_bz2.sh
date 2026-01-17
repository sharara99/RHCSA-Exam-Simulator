#!/bin/bash
# Validate archive backup.tar.bz2 exists and contains /usr/local

if [ ! -f "/root/backup.tar.bz2" ]; then
  echo "❌ Archive '/root/backup.tar.bz2' does not exist"
  exit 1
fi

# Try to list contents (bzip2 compressed tar)
if tar -tjf /root/backup.tar.bz2 2>/dev/null | grep -q "usr/local"; then
  echo "✅ Archive '/root/backup.tar.bz2' exists and contains /usr/local"
  exit 0
else
  echo "❌ Archive '/root/backup.tar.bz2' does not contain /usr/local or is corrupted"
  exit 1
fi
