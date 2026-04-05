#!/bin/bash
set -e

echo "========================================="
echo "ImmortalWrt Docker Bypass Router Setup"
echo "========================================="

# Check if running on Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
    echo "Warning: This script is designed for Raspberry Pi"
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Variables
BYPASS_IP="192.168.1.2"
GATEWAY_IP="192.168.1.1"
NETWORK_INTERFACE="eth0"

echo "Configuration:"
echo "  Bypass Router IP: $BYPASS_IP"
echo "  Main Router Gateway: $GATEWAY_IP"
echo "  Network Interface: $NETWORK_INTERFACE"
echo ""

# Confirm settings
read -p "Are these settings correct? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please edit this script to change settings"
    exit 1
fi

# Check Docker
echo "Step 1: Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    curl -fsSL https://get.docker.com | sh
    sudo usermod -aG docker $USER
    echo "Docker installed. Please logout and login again, then re-run this script."
    exit 0
fi

# Create macvlan network
echo ""
echo "Step 2: Creating macvlan network..."
docker network rm openwrt-net 2>/dev/null || true
docker network create -d macvlan \
  --subnet=192.168.1.0/24 \
  --gateway=$GATEWAY_IP \
  --ip-range=$BYPASS_IP/32 \
  -o parent=$NETWORK_INTERFACE \
  openwrt-net

# Pull or build image
echo ""
echo "Step 3: Pulling Docker image..."
if ! docker pull ghcr.io/panshuhan/immortalwrt-rpi4-bypass:latest; then
    echo "Failed to pull image. Will use local build."
    if [ ! -f "Dockerfile" ]; then
        echo "Error: Dockerfile not found and image not available"
        exit 1
    fi
    echo "Building locally..."
    docker build -t ghcr.io/panshuhan/immortalwrt-rpi4-bypass:latest .
fi

# Stop existing container
echo ""
echo "Step 4: Stopping existing container..."
docker stop immortalwrt-bypass 2>/dev/null || true
docker rm immortalwrt-bypass 2>/dev/null || true

# Run container
echo ""
echo "Step 5: Starting ImmortalWrt container..."
docker run -d \
  --name immortalwrt-bypass \
  --network openwrt-net \
  --ip $BYPASS_IP \
  --restart always \
  --privileged \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  -e TZ=Asia/Shanghai \
  ghcr.io/panshuhan/immortalwrt-rpi4-bypass:latest

# Wait for container to start
echo ""
echo "Step 6: Waiting for container to start..."
sleep 10

# Check container status
echo ""
echo "Step 7: Checking container status..."
docker ps | grep immortalwrt-bypass

echo ""
echo "========================================="
echo "Deployment Complete!"
echo "========================================="
echo ""
echo "ImmortalWrt is now running as a bypass router at: $BYPASS_IP"
echo ""
echo "Access the web interface:"
echo "  URL: http://$BYPASS_IP"
echo "  Default: No password (set one immediately!)"
echo ""
echo "To configure client devices:"
echo "  1. Set Gateway to: $BYPASS_IP"
echo "  2. Set DNS to: $BYPASS_IP"
echo ""
echo "Or configure on your main router:"
echo "  - DHCP Gateway: $BYPASS_IP"
echo "  - DHCP DNS: $BYPASS_IP"
echo ""
echo "Useful commands:"
echo "  View logs: docker logs -f immortalwrt-bypass"
echo "  Stop: docker stop immortalwrt-bypass"
echo "  Start: docker start immortalwrt-bypass"
echo "  Shell: docker exec -it immortalwrt-bypass /bin/sh"
echo ""
