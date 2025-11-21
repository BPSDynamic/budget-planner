#!/bin/bash

# test_ios.sh - Run tests on iOS emulator
# This script handles test execution, result capture, and reporting

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
TEST_TYPE="${1:-unit}"
SIMULATOR_ID="${2:-}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_LOG="${PROJECT_ROOT}/test_ios.log"
TEST_RESULTS_DIR="${PROJECT_ROOT}/test_results"

# Validate test type
if [[ ! "$TEST_TYPE" =~ ^(unit|widget|integration)$ ]]; then
    echo -e "${RED}Error: Invalid test type '$TEST_TYPE'. Must be unit, widget, or integration.${NC}"
    exit 1
fi

echo -e "${YELLOW}Starting iOS $TEST_TYPE tests...${NC}"
echo "Test log: $TEST_LOG"

# Create results directory
mkdir -p "$TEST_RESULTS_DIR"

# Step 1: Detect or validate simulator
echo -e "${YELLOW}[1/4] Checking iOS simulator...${NC}"
if [[ -z "$SIMULATOR_ID" ]]; then
    # Detect first available simulator
    SIMULATOR_ID=$(xcrun simctl list devices available | grep -E "^\s+[A-F0-9-]+ \(" | head -1 | sed 's/.*(\([A-F0-9-]*\)).*/\1/')
    
    if [[ -z "$SIMULATOR_ID" ]]; then
        echo -e "${RED}✗ No iOS simulators available${NC}"
        exit 1
    fi
    
    SIMULATOR_NAME=$(xcrun simctl list devices | grep "$SIMULATOR_ID" | sed 's/.*(\([^)]*\)).*/\1/')
    echo -e "${GREEN}✓ Using simulator: $SIMULATOR_NAME${NC}"
else
    echo -e "${GREEN}✓ Using specified simulator: $SIMULATOR_ID${NC}"
fi

# Step 2: Boot simulator if needed
echo -e "${YELLOW}[2/4] Ensuring simulator is booted...${NC}"
SIMULATOR_STATE=$(xcrun simctl list devices | grep "$SIMULATOR_ID" | grep -o "(Booted)\|(Shutdown)")

if [[ "$SIMULATOR_STATE" == "(Shutdown)" ]]; then
    echo "Booting simulator..."
    xcrun simctl boot "$SIMULATOR_ID" >> "$TEST_LOG" 2>&1 || true
    sleep 5
    echo -e "${GREEN}✓ Simulator booted${NC}"
else
    echo -e "${GREEN}✓ Simulator already running${NC}"
fi

# Step 3: Run tests
echo -e "${YELLOW}[3/4] Running $TEST_TYPE tests...${NC}"
TEST_RESULT_FILE="$TEST_RESULTS_DIR/${TEST_TYPE}_results.json"

case "$TEST_TYPE" in
    unit)
        if cd "$PROJECT_ROOT" && flutter test --reporter=json > "$TEST_RESULT_FILE" 2>> "$TEST_LOG"; then
            echo -e "${GREEN}✓ Unit tests completed${NC}"
        else
            echo -e "${RED}✗ Unit tests failed${NC}"
            tail -20 "$TEST_LOG"
            exit 1
        fi
        ;;
    widget)
        if cd "$PROJECT_ROOT" && flutter test --reporter=json > "$TEST_RESULT_FILE" 2>> "$TEST_LOG"; then
            echo -e "${GREEN}✓ Widget tests completed${NC}"
        else
            echo -e "${RED}✗ Widget tests failed${NC}"
            tail -20 "$TEST_LOG"
            exit 1
        fi
        ;;
    integration)
        if cd "$PROJECT_ROOT" && flutter drive --target=test_driver/app.dart > "$TEST_RESULT_FILE" 2>> "$TEST_LOG"; then
            echo -e "${GREEN}✓ Integration tests completed${NC}"
        else
            echo -e "${RED}✗ Integration tests failed${NC}"
            tail -20 "$TEST_LOG"
            exit 1
        fi
        ;;
esac

# Step 4: Parse and report results
echo -e "${YELLOW}[4/4] Parsing test results...${NC}"
if [[ -f "$TEST_RESULT_FILE" ]]; then
    # Extract test statistics from JSON
    TOTAL_TESTS=$(grep -o '"testCount":[0-9]*' "$TEST_RESULT_FILE" | head -1 | cut -d: -f2)
    PASSED_TESTS=$(grep -o '"success":true' "$TEST_RESULT_FILE" | wc -l)
    FAILED_TESTS=$((TOTAL_TESTS - PASSED_TESTS))
    
    echo -e "${GREEN}✓ Test results parsed${NC}"
    echo -e "${BLUE}Test Summary:${NC}"
    echo "  Total: $TOTAL_TESTS"
    echo "  Passed: $PASSED_TESTS"
    echo "  Failed: $FAILED_TESTS"
    
    if [[ $FAILED_TESTS -gt 0 ]]; then
        echo -e "${RED}Some tests failed!${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ Test result file not found${NC}"
fi

echo -e "${GREEN}Tests completed successfully!${NC}"
echo "Results saved to: $TEST_RESULTS_DIR"
