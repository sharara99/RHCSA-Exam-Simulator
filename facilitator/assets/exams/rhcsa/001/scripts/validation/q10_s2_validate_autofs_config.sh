#!/bin/bash
# Validate AutoFS configuration files are correct

MASTER_FILE="/etc/auto.master.d/remoteuser.autofs"
MAP_FILE="/etc/auto.remoteuser"

if [ ! -f "$MASTER_FILE" ]; then
  echo "❌ AutoFS master file '$MASTER_FILE' does not exist"
  exit 1
fi

if [ ! -f "$MAP_FILE" ]; then
  echo "❌ AutoFS map file '$MAP_FILE' does not exist"
  exit 1
fi

if grep -q "/home/remoteuser20" "$MASTER_FILE" && grep -q "auto.remoteuser" "$MASTER_FILE"; then
  if grep -q "192.168.71.254" "$MAP_FILE"; then
    echo "✅ AutoFS configuration files are correct"
    exit 0
  else
    echo "❌ AutoFS map file does not contain correct NFS server"
    exit 1
  fi
else
  echo "❌ AutoFS master file configuration is incorrect"
  exit 1
fi
