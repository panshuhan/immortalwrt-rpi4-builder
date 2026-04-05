#!/bin/bash
set -e

# customize-firmware.sh
# Customize firmware settings before building
# This script modifies files in config/custom-files/ directory

echo "========================================="
echo "Customizing Firmware Settings"
echo "========================================="
echo ""

CUSTOM_FILES_DIR="config/custom-files"

if [ ! -d "$CUSTOM_FILES_DIR" ]; then
    echo "ERROR: $CUSTOM_FILES_DIR directory not found"
    exit 1
fi

echo "Step 1: Verifying custom files structure..."
if [ -d "$CUSTOM_FILES_DIR/etc/config" ]; then
    echo "✓ Found: $CUSTOM_FILES_DIR/etc/config"
else
    echo "⚠ Warning: $CUSTOM_FILES_DIR/etc/config not found"
fi

echo ""
echo "Step 2: Checking configuration files..."

# List all custom configuration files
echo "Configuration files that will be copied to firmware:"
find "$CUSTOM_FILES_DIR" -type f | sort

echo ""
echo "Step 3: Validating network configuration..."
if [ -f "$CUSTOM_FILES_DIR/etc/config/network" ]; then
    LAN_IP=$(grep -A5 "interface 'lan'" "$CUSTOM_FILES_DIR/etc/config/network" | grep "option ipaddr" | awk '{print $3}' | tr -d "'")
    if [ -n "$LAN_IP" ]; then
        echo "✓ LAN IP address: $LAN_IP"
    else
        echo "⚠ Warning: LAN IP not found in network config"
    fi
fi

echo ""
echo "Step 4: Validating system configuration..."
if [ -f "$CUSTOM_FILES_DIR/etc/config/system" ]; then
    HOSTNAME=$(grep "option hostname" "$CUSTOM_FILES_DIR/etc/config/system" | awk '{print $3}' | tr -d "'")
    TIMEZONE=$(grep "option zonename" "$CUSTOM_FILES_DIR/etc/config/system" | awk '{print $3}' | tr -d "'")
    echo "✓ Hostname: $HOSTNAME"
    echo "✓ Timezone: $TIMEZONE"
fi

echo ""
echo "Step 5: Ensuring proper permissions..."
# Make sure rc.local is executable
if [ -f "$CUSTOM_FILES_DIR/etc/rc.local" ]; then
    chmod +x "$CUSTOM_FILES_DIR/etc/rc.local"
    echo "✓ Made rc.local executable"
fi

echo ""
echo "========================================="
echo "Firmware customization completed!"
echo "========================================="
echo ""
echo "Summary:"
echo "- Custom files location: $CUSTOM_FILES_DIR"
echo "- These files will be copied into the firmware during build"
echo "- LAN IP will be: ${LAN_IP:-192.168.1.1}"
echo "- Hostname will be: ${HOSTNAME:-ImmortalWrt}"
echo ""
