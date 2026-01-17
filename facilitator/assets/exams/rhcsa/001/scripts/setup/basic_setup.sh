#!/bin/bash
# Basic setup for RHCSA exam environment

echo "Setting up RHCSA exam environment..."

# Ensure /tmp/exam directory exists
mkdir -p /tmp/exam

# Ensure basic directories exist
mkdir -p /root/locatedfiles
mkdir -p /opt/files /opt/processed

echo "RHCSA exam environment setup complete"
exit 0
