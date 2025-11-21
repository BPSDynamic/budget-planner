#!/bin/bash

# setup_ios_emulator.sh - Set up iOS emulator environment
# This script validates and configures the iOS emulator environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEVICE_TYPE="${1:-iPhone 14}"
IOS_VERSION="${2:-17.0}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETUP_LOG="${PROJECT_ROOT}/setup_ios_emulator.log"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     iOS Emulator Environment Setup                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Device Type: $DEVICE_TYPE"
echo "iOS Version: $IOS_VERSION"
echo "Setup Log: $SETUP_LOG"
echo ""

# Initialize setup log
> "$SETUP_LOG"

# Step 1: Validate Xcode installation
echo -e "${YELLOW}[1/5] Validating Xcode installation...${NC}"
{
    echo "=== Setup Started at $(date) ==="
    echo "Device Type: $DEVICE_TYPE"
    echo "iOS Version: $IOS_VERSION"
    echo ""
} >> "$SETUP_LOG"

if ! command -v xcode-select &> /dev/null; then
    echo -e "${RED}✗ Xcode not found${NC}"
    echo "Please install Xcode from the App Store"
    exit 1
fi

XCODE_PATH=$(xcode-select -p)
echo -e "${GREEN}✓ Xcode found at: $XCODE_PATH${NC}"

# Step 2: Validate iOS SDK
echo -e "${YELLOW}[2/5] Validating iOS SDK...${NC}"
if ! xcrun simctl list runtimes | grep -q "iOS $IOS_VERSION"; then
    echo -e "${YELLOW}⚠ iOS $IOS_VERSION SDK not found${NC}"
    echo "Available iOS versions:"
    xcrun simctl list runtimes | grep "iOS" | sed 's/^/  /'
    echo ""
    echo -e "${YELLOW}Installing iOS $IOS_VERSION SDK...${NC}"
    # Note: Actual SDK installation would require Xcode command line tools
    echo -e "${YELLOW}Please install iOS $IOS_VERSION SDK via Xcode preferences${NC}"
else
    echo -e "${GREEN}✓ iOS $IOS_VERSION SDK found${NC}"
fi

# Step 3: Check for existing simulators
echo -e "${YELLOW}[3/5] Checking for existing simulators...${NC}"
EXISTING_SIMULATORS=$(xcrun simctl list devices | grep -c "($IOS_VERSION)" || true)
echo "Found $EXISTING_SIMULATORS simulator(s) with iOS $IOS_VERSION"

if [[ $EXISTING_SIMULATORS -gt 0 ]]; then
    echo -e "${GREEN}✓ Simulators available${NC}"
    echo ""
    echo "Available simulators:"
    xcrun simctl list devices | grep "($IOS_VERSION)" | sed 's/^/  /'
else
    echo -e "${YELLOW}⚠ No simulators found for iOS $IOS_VERSION${NC}"
    echo ""
    echo -e "${YELLOW}[4/5] Creating new simulator...${NC}"
    
    # Get device type identifier
    DEVICE_TYPE_ID=$(xcrun simctl list devicetypes | grep "$DEVICE_TYPE" | awk '{print $NF}' | tr -d '()' | head -1)
    
    if [[ -z "$DEVICE_TYPE_ID" ]]; then
        echo -e "${RED}✗ Device type '$DEVICE_TYPE' not found${NC}"
        echo "Available device types:"
        xcrun simctl list devicetypes | sed 's/^/  /'
        exit 1
    fi
    
    # Get runtime identifier
    RUNTIME_ID=$(xcrun simctl list runtimes | grep "iOS $IOS_VERSION" | awk '{print $NF}' | tr -d '()' | head -1)
    
    if [[ -z "$RUNTIME_ID" ]]; then
        echo -e "${RED}✗ iOS $IOS_VERSION runtime not found${NC}"
        exit 1
    fi
    
    # Create simulator
    SIMULATOR_NAME="${DEVICE_TYPE} (iOS $IOS_VERSION)"
    echo "Creating simulator: $SIMULATOR_NAME"
    
    if xcrun simctl create "$SIMULATOR_NAME" "$DEVICE_TYPE_ID" "$RUNTIME_ID" >> "$SETUP_LOG" 2>&1; then
        SIMULATOR_ID=$(xcrun simctl list devices | grep "$SIMULATOR_NAME" | grep -o '[A-F0-9-]*' | head -1)
        echo -e "${GREEN}✓ Simulator created successfully${NC}"
        echo "  ID: $SIMULATOR_ID"
        echo "  Name: $SIMULATOR_NAME"
    else
        echo -e "${RED}✗ Failed to create simulator${NC}"
        tail -20 "$SETUP_LOG"
        exit 1
    fi
fi

# Step 4: Validate Flutter installation
echo -e "${YELLOW}[4/5] Validating Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found${NC}"
    echo "Please install Flutter from https://flutter.dev"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version | head -1)
echo -e "${GREEN}✓ Flutter found: $FLUTTER_VERSION${NC}"

# Step 5: Validate CocoaPods
echo -e "${YELLOW}[5/5] Validating CocoaPods installation...${NC}"
if ! command -v pod &> /dev/null; then
    echo -e "${YELLOW}⚠ CocoaPods not found${NC}"
    echo "Installing CocoaPods..."
    if sudo gem install cocoapods >> "$SETUP_LOG" 2>&1; then
        echo -e "${GREEN}✓ CocoaPods installed${NC}"
    else
        echo -e "${RED}✗ Failed to install CocoaPods${NC}"
        echo "Please install manually: sudo gem install cocoapods"
        exit 1
    fi
else
    POD_VERSION=$(pod --version)
    echo -e "${GREEN}✓ CocoaPods found: $POD_VERSION${NC}"
fi

# Final report
echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Environment Setup Completed Successfully               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ iOS emulator environment is ready${NC}"
echo ""
echo "Next steps:"
echo "  1. Run: bash scripts/build_ios.sh debug"
echo "  2. Run: bash scripts/test_ios.sh unit"
echo "  3. Or run full workflow: bash scripts/build_test_ios.sh debug unit"
echo ""

{
    echo "=== Setup Completed Successfully at $(date) ==="
} >> "$SETUP_LOG"
