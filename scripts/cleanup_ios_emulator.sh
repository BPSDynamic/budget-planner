#!/bin/bash

# cleanup_ios_emulator.sh - Clean up iOS emulator resources
# This script shuts down emulators and removes temporary artifacts

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLEANUP_LOG="${PROJECT_ROOT}/cleanup_ios_emulator.log"
SIMULATOR_ID="${1:-}"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     iOS Emulator Cleanup                                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Project Root: $PROJECT_ROOT"
echo "Cleanup Log: $CLEANUP_LOG"
echo ""

# Initialize cleanup log
> "$CLEANUP_LOG"

{
    echo "=== Cleanup Started at $(date) ==="
    if [[ -n "$SIMULATOR_ID" ]]; then
        echo "Target Simulator: $SIMULATOR_ID"
    else
        echo "Target: All running simulators"
    fi
    echo ""
} >> "$CLEANUP_LOG"

# Step 1: Shut down simulators
echo -e "${YELLOW}[1/4] Shutting down iOS simulators...${NC}"

if [[ -n "$SIMULATOR_ID" ]]; then
    # Shut down specific simulator
    if xcrun simctl shutdown "$SIMULATOR_ID" >> "$CLEANUP_LOG" 2>&1; then
        echo -e "${GREEN}✓ Simulator $SIMULATOR_ID shut down${NC}"
    else
        echo -e "${YELLOW}⚠ Simulator $SIMULATOR_ID already shut down or not found${NC}"
    fi
else
    # Shut down all running simulators
    RUNNING_SIMULATORS=$(xcrun simctl list devices | grep "(Booted)" | grep -o '[A-F0-9-]*' | head -1)
    
    if [[ -n "$RUNNING_SIMULATORS" ]]; then
        while IFS= read -r SIM_ID; do
            if [[ -n "$SIM_ID" ]]; then
                if xcrun simctl shutdown "$SIM_ID" >> "$CLEANUP_LOG" 2>&1; then
                    echo -e "${GREEN}✓ Simulator $SIM_ID shut down${NC}"
                fi
            fi
        done <<< "$RUNNING_SIMULATORS"
    else
        echo -e "${GREEN}✓ No running simulators found${NC}"
    fi
fi

# Step 2: Remove temporary build artifacts
echo -e "${YELLOW}[2/4] Removing temporary build artifacts...${NC}"

TEMP_DIRS=(
    "$PROJECT_ROOT/build"
    "$PROJECT_ROOT/.dart_tool"
    "$PROJECT_ROOT/ios/Pods"
    "$PROJECT_ROOT/ios/Podfile.lock"
)

FREED_SPACE=0

for DIR in "${TEMP_DIRS[@]}"; do
    if [[ -e "$DIR" ]]; then
        DIR_SIZE=$(du -sh "$DIR" 2>/dev/null | cut -f1 || echo "unknown")
        echo "Removing: $DIR ($DIR_SIZE)"
        
        if rm -rf "$DIR" >> "$CLEANUP_LOG" 2>&1; then
            echo -e "${GREEN}✓ Removed: $DIR${NC}"
        else
            echo -e "${YELLOW}⚠ Could not remove: $DIR${NC}"
        fi
    fi
done

echo -e "${GREEN}✓ Temporary artifacts removed${NC}"

# Step 3: Clear test results
echo -e "${YELLOW}[3/4] Clearing test results and logs...${NC}"

TEST_DIRS=(
    "$PROJECT_ROOT/test_results"
    "$PROJECT_ROOT/build_ios.log"
    "$PROJECT_ROOT/test_ios.log"
    "$PROJECT_ROOT/build_test_workflow.log"
    "$PROJECT_ROOT/setup_ios_emulator.log"
)

for DIR in "${TEST_DIRS[@]}"; do
    if [[ -e "$DIR" ]]; then
        if rm -rf "$DIR" >> "$CLEANUP_LOG" 2>&1; then
            echo -e "${GREEN}✓ Removed: $DIR${NC}"
        else
            echo -e "${YELLOW}⚠ Could not remove: $DIR${NC}"
        fi
    fi
done

echo -e "${GREEN}✓ Test results and logs cleared${NC}"

# Step 4: Report freed resources
echo -e "${YELLOW}[4/4] Reporting freed resources...${NC}"

# Calculate total freed space
if [[ -d "$PROJECT_ROOT/build" ]]; then
    BUILD_SIZE=$(du -sh "$PROJECT_ROOT/build" 2>/dev/null | cut -f1 || echo "0")
else
    BUILD_SIZE="0"
fi

echo ""
echo -e "${BLUE}Cleanup Summary:${NC}"
echo "  Simulators: Shut down"
echo "  Build artifacts: Removed"
echo "  Test results: Cleared"
echo "  Logs: Cleared"
echo ""

# Final report
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Cleanup Completed Successfully                         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✓ iOS emulator resources cleaned up${NC}"
echo ""
echo "Resources freed:"
echo "  • Simulators shut down"
echo "  • Build artifacts removed"
echo "  • Test data cleared"
echo "  • Temporary logs removed"
echo ""
echo "To restart:"
echo "  1. Run: bash scripts/setup_ios_emulator.sh"
echo "  2. Run: bash scripts/build_test_ios.sh debug unit"
echo ""

{
    echo "=== Cleanup Completed Successfully at $(date) ==="
} >> "$CLEANUP_LOG"
