#!/bin/bash
# Script to rebuild all Docker images from scratch without using cache

set -e

echo "=========================================="
echo "Rebuilding Red Hat Exam Simulator from scratch"
echo "=========================================="
echo ""

# Stop and remove all containers
echo "Step 1: Stopping and removing all containers..."
docker compose down --volumes --remove-orphans
echo "✓ Containers stopped and removed"
echo ""

# Remove all related images
echo "Step 2: Removing old images..."
docker images | grep -E "ck-x-enviroment" | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || echo "No images to remove"
echo "✓ Old images removed"
echo ""

# Rebuild all images from scratch
echo "Step 3: Rebuilding all images from scratch (this may take 10-20 minutes)..."
echo "This will rebuild all images without using any cache."
echo ""
docker compose build --no-cache --parallel
echo "✓ All images rebuilt"
echo ""

# Start services
echo "Step 4: Starting services..."
docker compose up -d
echo "✓ Services started"
echo ""

echo "=========================================="
echo "Rebuild complete!"
echo "=========================================="
echo ""
echo "Services are starting. Check status with:"
echo "  docker compose ps"
echo ""
echo "View logs with:"
echo "  docker compose logs -f"
echo ""
echo "Access the application at:"
echo "  http://localhost:30080"
echo ""
