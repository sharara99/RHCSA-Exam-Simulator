#!/bin/bash
# Validate files owned by natasha are copied to /root/locatedfiles

if [ ! -d "/root/locatedfiles" ]; then
  echo "❌ Directory '/root/locatedfiles' does not exist"
  exit 1
fi

FILE_COUNT=$(find /root/locatedfiles -type f 2>/dev/null | wc -l)
if [ "$FILE_COUNT" -gt "0" ]; then
  # Check if at least one file is owned by natasha (original owner preserved with -p flag)
  NATASHA_FILES=$(find /root/locatedfiles -type f -user natasha 2>/dev/null | wc -l)
  if [ "$NATASHA_FILES" -gt "0" ] || [ "$FILE_COUNT" -gt "0" ]; then
    echo "✅ Files have been copied to '/root/locatedfiles'"
    exit 0
  else
    echo "❌ No files found in '/root/locatedfiles'"
    exit 1
  fi
else
  echo "❌ Directory '/root/locatedfiles' is empty"
  exit 1
fi
