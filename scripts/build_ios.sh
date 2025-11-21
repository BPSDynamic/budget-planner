#!/bin/bash

# build_ios.sh - Build iOS app for emulator testing
# This script handles dependency resolution, CocoaPods installation, and app compilation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BUILD_MODE="${1:-debug}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_LOG="${PROJECT_ROOT}/build_ios.log"

# Validate build mode
if [[ ! "$BUILD_MODE" =~ ^(debug|release|profile)$ ]]; then
    echo -e "${RED}Error: Invalid build mode '$BUILD_MODE'. Must be debug, release, or profile.${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting iOS build in $BUILD_MODE mode...${NC}"
echo "Build log: $BUILD_LOG"

# Step 1: Resolve Flutter dependencies
echo -e "${YELLOW}[1/4] Resolving Flutter dependencies...${NC}"
if cd "$PROJECT_ROOT" && flutter pub get >> "$BUILD_LOG" 2>&1; then
    echo -e "${GREEN}✓ Flutter dependencies resolved${NC}"
else
    echo -e "${RED}✗ Failed to resolve Flutter dependencies${NC}"
    tail -20 "$BUILD_LOG"
    exit 1
fi

# Step 2: Install CocoaPods
echo -e "${YELLOW}[2/4] Installing CocoaPods dependencies...${NC}"
if cd "$PROJECT_ROOT/ios" && pod install >> "$BUILD_LOG" 2>&1; then
    echo -e "${GREEN}✓ CocoaPods installed${NC}"
else
    echo -e "${RED}✗ Failed to install CocoaPods${NC}"
    tail -20 "$BUILD_LOG"
    exit 1
fi

# Step 3: Build Flutter app for iOS
echo -e "${YELLOW}[3/4] Building Flutter app for iOS...${NC}"
if cd "$PROJECT_ROOT" && flutter build ios --$BUILD_MODE >> "$BUILD_LOG" 2>&1; then
    echo -e "${GREEN}✓ Flutter app built successfully${NC}"
else
    echo -e "${RED}✗ Failed to build Flutter app${NC}"
    tail -20 "$BUILD_LOG"
    exit 1
fi

# Step 4: Verify build artifact
echo -e "${YELLOW}[4/4] Verifying build artifact...${NC}"
APP_PATH="$PROJECT_ROOT/build/ios/iphoneos/Runner.app"
if [[ -d "$APP_PATH" ]]; then
    APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
    echo -e "${GREEN}✓ Build artifact verified${NC}"
    echo -e "${GREEN}  Location: $APP_PATH${NC}"
    echo -e "${GREEN}  Size: $APP_SIZE${NC}"
else
    echo -e "${RED}✗ Build artifact not found at $APP_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}Build completed successfully!${NC}"
echo "Build mode: $BUILD_MODE"
echo "Artifact: $APP_PATH"
