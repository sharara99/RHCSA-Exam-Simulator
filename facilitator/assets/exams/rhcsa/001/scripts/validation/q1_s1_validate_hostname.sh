#!/bin/bash
# Validate hostname is configured correctly

EXPECTED_HOSTNAME="node1.domain.example.com"
ACTUAL_HOSTNAME=$(hostname)

if [ "$ACTUAL_HOSTNAME" == "$EXPECTED_HOSTNAME" ]; then
  echo "✅ Hostname is correctly set to '$EXPECTED_HOSTNAME'"
  exit 0
else
  echo "❌ Hostname mismatch. Expected: '$EXPECTED_HOSTNAME', Actual: '$ACTUAL_HOSTNAME'"
  exit 1
fi
