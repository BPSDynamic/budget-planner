#!/bin/bash

# build_test_ios.sh - Full workflow: build and test iOS app
# This script orchestrates the complete build and test process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUILD_MODE="${1:-debug}"
TEST_TYPE="${2:-unit}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_LOG="${PROJECT_ROOT}/build_test_workflow.log"
START_TIME=$(date +%s)

# Validate inputs
if [[ ! "$BUILD_MODE" =~ ^(debug|release|profile)$ ]]; then
    echo -e "${RED}Error: Invalid build mode '$BUILD_MODE'. Must be debug, release, or profile.${NC}"
    exit 1
fi

if [[ ! "$TEST_TYPE" =~ ^(unit|widget|integration)$ ]]; then
    echo -e "${RED}Error: Invalid test type '$TEST_TYPE'. Must be unit, widget, or integration.${NC}"
    exit 1
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     iOS Build & Test Workflow                             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Build Mode: $BUILD_MODE"
echo "Test Type: $TEST_TYPE"
echo "Project Root: $PROJECT_ROOT"
echo "Workflow Log: $WORKFLOW_LOG"
echo ""

# Initialize workflow log
> "$WORKFLOW_LOG"

# Step 1: Validate prerequisites
echo -e "${YELLOW}[1/3] Validating prerequisites...${NC}"
{
    echo "=== Workflow Started at $(date) ==="
    echo "Build Mode: $BUILD_MODE"
    echo "Test Type: $TEST_TYPE"
    echo ""
} >> "$WORKFLOW_LOG"

# Check Xcode
if ! command -v xcode-select &> /dev/null; then
    echo -e "${RED}✗ Xcode not found${NC}"
    echo "Please install Xcode from the App Store"
    exit 1
fi
echo -e "${GREEN}✓ Xcode found${NC}"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}✗ Flutter not found${NC}"
    echo "Please install Flutter from https://flutter.dev"
    exit 1
fi
echo -e "${GREEN}✓ Flutter found${NC}"

# Check iOS SDK
if ! xcrun simctl list devices &> /dev/null; then
    echo -e "${RED}✗ iOS SDK not found${NC}"
    echo "Please install iOS SDK via Xcode"
    exit 1
fi
echo -e "${GREEN}✓ iOS SDK found${NC}"

echo -e "${GREEN}✓ All prerequisites validated${NC}"
echo ""

# Step 2: Build iOS app
echo -e "${YELLOW}[2/3] Building iOS app...${NC}"
{
    echo "=== Build Phase Started at $(date) ==="
} >> "$WORKFLOW_LOG"

if bash "$SCRIPTS_DIR/build_ios.sh" "$BUILD_MODE" >> "$WORKFLOW_LOG" 2>&1; then
    echo -e "${GREEN}✓ Build completed successfully${NC}"
    {
        echo "=== Build Phase Completed Successfully ==="
    } >> "$WORKFLOW_LOG"
else
    echo -e "${RED}✗ Build failed${NC}"
    {
        echo "=== Build Phase Failed ==="
    } >> "$WORKFLOW_LOG"
    tail -30 "$WORKFLOW_LOG"
    exit 1
fi
echo ""

# Step 3: Run tests
echo -e "${YELLOW}[3/3] Running tests...${NC}"
{
    echo "=== Test Phase Started at $(date) ==="
} >> "$WORKFLOW_LOG"

if bash "$SCRIPTS_DIR/test_ios.sh" "$TEST_TYPE" >> "$WORKFLOW_LOG" 2>&1; then
    echo -e "${GREEN}✓ Tests completed successfully${NC}"
    {
        echo "=== Test Phase Completed Successfully ==="
    } >> "$WORKFLOW_LOG"
else
    echo -e "${RED}✗ Tests failed${NC}"
    {
        echo "=== Test Phase Failed ==="
    } >> "$WORKFLOW_LOG"
    tail -30 "$WORKFLOW_LOG"
    exit 1
fi
echo ""

# Calculate workflow duration
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

# Final report
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Workflow Completed Successfully                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ Build and test workflow completed${NC}"
echo "  Build Mode: $BUILD_MODE"
echo "  Test Type: $TEST_TYPE"
echo "  Duration: ${MINUTES}m ${SECONDS}s"
echo ""
echo "Recommendations:"
echo "  • Review test results in test_results/ directory"
echo "  • Check build artifacts in build/ios/ directory"
echo "  • For detailed logs, see: $WORKFLOW_LOG"
echo ""

{
    echo "=== Workflow Completed Successfully at $(date) ==="
    echo "Total Duration: ${MINUTES}m ${SECONDS}s"
} >> "$WORKFLOW_LOG"
