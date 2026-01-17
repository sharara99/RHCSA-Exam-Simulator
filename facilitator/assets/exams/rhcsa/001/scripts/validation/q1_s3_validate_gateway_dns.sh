#!/bin/bash
# Validate gateway and DNS are configured correctly

EXPECTED_GATEWAY="192.168.71.2"
EXPECTED_DNS="192.168.71.2"

# Check gateway
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -1)
DNS=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | head -1)

GATEWAY_OK=false
DNS_OK=false

if [ "$GATEWAY" == "$EXPECTED_GATEWAY" ]; then
  GATEWAY_OK=true
fi

if [ "$DNS" == "$EXPECTED_DNS" ]; then
  DNS_OK=true
fi

if [ "$GATEWAY_OK" == "true" ] && [ "$DNS_OK" == "true" ]; then
  echo "✅ Gateway '$EXPECTED_GATEWAY' and DNS '$EXPECTED_DNS' are configured correctly"
  exit 0
else
  echo "❌ Configuration mismatch. Gateway: '$GATEWAY' (expected: '$EXPECTED_GATEWAY'), DNS: '$DNS' (expected: '$EXPECTED_DNS')"
  exit 1
fi
