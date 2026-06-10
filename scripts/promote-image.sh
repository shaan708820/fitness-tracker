#!/bin/bash

# ==============================================================================
# Docker Image Promotion Script
# Purpose: Promotes a Docker image from a source tag to a target tag without rebuilding.
# Handles pulling, tagging, pushing, validation, and execution logging.
# ==============================================================================

# Require arguments
SOURCE_IMAGE=$1
TARGET_IMAGE=$2
LOG_FILE="image_promotion.log"

# Setup logging function
log() {
    local MESSAGE=$1
    local TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    echo "[$TIMESTAMP] $MESSAGE" | tee -a "$LOG_FILE"
}

# Validate inputs
if [ -z "$SOURCE_IMAGE" ] || [ -z "$TARGET_IMAGE" ]; then
    log "ERROR: Missing arguments."
    log "USAGE: ./promote-image.sh <source_image:tag> <target_image:tag>"
    exit 1
fi

log "========================================"
log "Starting Image Promotion Process"
log "Source: $SOURCE_IMAGE"
log "Target: $TARGET_IMAGE"
log "========================================"

# Step 1: Pull the source image
log "Step 1: Pulling source image..."
if docker pull "$SOURCE_IMAGE" >> "$LOG_FILE" 2>&1; then
    log "SUCCESS: Pulled $SOURCE_IMAGE"
else
    log "CRITICAL ERROR: Failed to pull source image. Check credentials and image name."
    exit 1
fi

# Step 2: Tag the image
log "Step 2: Tagging image..."
if docker tag "$SOURCE_IMAGE" "$TARGET_IMAGE" >> "$LOG_FILE" 2>&1; then
    log "SUCCESS: Tagged image as $TARGET_IMAGE"
else
    log "CRITICAL ERROR: Failed to tag image."
    exit 1
fi

# Step 3: Push the target image
log "Step 3: Pushing target image to registry..."
if docker push "$TARGET_IMAGE" >> "$LOG_FILE" 2>&1; then
    log "SUCCESS: Pushed $TARGET_IMAGE to registry"
else
    log "CRITICAL ERROR: Failed to push target image. Check registry permissions."
    exit 1
fi

# Step 4: Validation
log "Step 4: Validating promotion..."
# Check if the target image exists in the local Docker daemon after tagging
if docker inspect "$TARGET_IMAGE" > /dev/null 2>&1; then
    log "VALIDATION PASSED: Image $TARGET_IMAGE is verified and ready for deployment."
else
    log "VALIDATION FAILED: Could not inspect $TARGET_IMAGE."
    exit 1
fi

log "========================================"
log "PROMOTION COMPLETED SUCCESSFULLY"
log "========================================"