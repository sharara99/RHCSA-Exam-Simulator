#!/bin/bash
# Validate volume mounts are configured correctly

# Check if directories exist
if [ ! -d "/opt/files" ] || [ ! -d "/opt/processed" ]; then
  echo "❌ Required directories /opt/files or /opt/processed do not exist"
  exit 1
fi

# Check ownership
FILES_OWNER=$(stat -c '%U' /opt/files 2>/dev/null || stat -f '%Su' /opt/files 2>/dev/null)
PROCESSED_OWNER=$(stat -c '%U' /opt/processed 2>/dev/null || stat -f '%Su' /opt/processed 2>/dev/null)

if [ "$FILES_OWNER" == "alth" ] && [ "$PROCESSED_OWNER" == "alth" ]; then
  echo "✅ Volume directories have correct ownership (alth:alth)"
  exit 0
else
  echo "❌ Volume directories have incorrect ownership. Files: '$FILES_OWNER', Processed: '$PROCESSED_OWNER'"
  exit 1
fi
