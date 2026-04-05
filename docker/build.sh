#!/bin/bash
set -e

echo "========================================="
echo "Building ImmortalWrt Docker Image"
echo "========================================="

# Variables
IMAGE_NAME="immortalwrt-rpi4-bypass"
VERSION="24.10.5"
PLATFORM="linux/arm64"

echo "Image: $IMAGE_NAME:$VERSION"
echo "Platform: $PLATFORM"
echo ""

# Build for ARM64 (Raspberry Pi 4)
echo "Step 1: Building Docker image..."
docker buildx build \
  --platform $PLATFORM \
  --tag $IMAGE_NAME:$VERSION \
  --tag $IMAGE_NAME:latest \
  --load \
  .

echo ""
echo "Step 2: Verifying image..."
docker images | grep $IMAGE_NAME

echo ""
echo "========================================="
echo "Build Complete!"
echo "========================================="
echo "Image: $IMAGE_NAME:latest"
echo ""
echo "To run the container:"
echo "  docker-compose up -d"
echo ""
echo "To push to registry:"
echo "  docker tag $IMAGE_NAME:latest ghcr.io/panshuhan/$IMAGE_NAME:latest"
echo "  docker push ghcr.io/panshuhan/$IMAGE_NAME:latest"
echo ""
