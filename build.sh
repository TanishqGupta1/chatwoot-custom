#!/bin/bash

# Build script for Chatwoot with configurable ElevenLabs agent ID
# Usage: ./build.sh [agent_id] [voice_id] [agent_name] [image_tag]

set -e

# Default values
AGENT_ID="${1:-agent_6601kc1fqeecfc88s7d52jde0syq}"
VOICE_ID="${2:-}"
AGENT_NAME="${3:-AI Assistant}"
IMAGE_TAG="${4:-v1.0.1}"
REGISTRY="690816807846.dkr.ecr.us-west-2.amazonaws.com"
IMAGE_NAME="prod-chatwoot"

echo "🔨 Building Chatwoot with ElevenLabs Voice Integration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Agent ID:     $AGENT_ID"
echo "Voice ID:     ${VOICE_ID:-(default)}"
echo "Agent Name:   $AGENT_NAME"
echo "Image Tag:    $IMAGE_TAG"
echo "Registry:     $REGISTRY"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Build Docker image
docker build \
  --platform linux/amd64 \
  --build-arg VITE_ELEVENLABS_AGENT_ID="$AGENT_ID" \
  --build-arg VITE_ELEVENLABS_VOICE_ID="$VOICE_ID" \
  --build-arg VITE_ELEVENLABS_AGENT_NAME="$AGENT_NAME" \
  -t $IMAGE_NAME:$IMAGE_TAG \
  -f Dockerfile \
  .

echo "✅ Build complete!"
echo ""
echo "Tagging for ECR..."
docker tag $IMAGE_NAME:$IMAGE_TAG $REGISTRY/$IMAGE_NAME:$IMAGE_TAG

echo "Run container with:"
echo "  docker compose up -d"
echo ""
echo "Or push to registry:"
echo "  docker push $REGISTRY/$IMAGE_NAME:$IMAGE_TAG"
