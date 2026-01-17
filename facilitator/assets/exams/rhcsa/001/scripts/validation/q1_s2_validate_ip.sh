#!/bin/bash
# Validate IP address is configured correctly

EXPECTED_IP="192.168.71.240"
ACTUAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep "$EXPECTED_IP" || echo "")

if [ -n "$ACTUAL_IP" ]; then
  echo "✅ IP address '$EXPECTED_IP' is configured"
  exit 0
else
  echo "❌ IP address '$EXPECTED_IP' not found. Current IPs: $(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | tr '\n' ' ')"
  exit 1
fi
