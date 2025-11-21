# iOS Emulator Build & Test Setup Guide

## Table of Contents

1. [Overview](#overview)
2. [Quick Start](#quick-start)
3. [Prerequisites](#prerequisites)
4. [Environment Setup](#environment-setup)
5. [Building the iOS App](#building-the-ios-app)
6. [Running Tests](#running-tests)
7. [CLI Commands](#cli-commands)
8. [Shell Scripts](#shell-scripts)
9. [Supported iOS Versions and Devices](#supported-ios-versions-and-devices)
10. [Troubleshooting](#troubleshooting)
11. [Advanced Usage](#advanced-usage)

---

## Overview

The iOS Emulator Build & Test Setup feature provides a comprehensive infrastructure for building, testing, and validating the Budget Planner application on iOS emulators. This guide covers:

- **Environment Setup**: Configuring iOS emulators with specific iOS versions and device types
- **Build Process**: Automated dependency resolution, CocoaPods installation, and app compilation
- **Test Execution**: Running unit, widget, and integration tests on emulators
- **Automation**: Scripts and CLI commands for orchestrating the complete workflow
- **Resource Management**: Cleanup and optimization of emulator resources

---

## Quick Start

### For Impatient Developers

```bash
# 1. Set up the iOS emulator environment
bash scripts/setup_ios_emulator.sh

# 2. Build and test the app (full workflow)
bash scripts/build_test_ios.sh debug unit

# 3. Clean up resources when done
bash scripts/cleanup_ios_emulator.sh
```

That's it! The complete build and test workflow will execute automatically.

---

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

- **Xcode 14.0+**: Apple's integrated development environment
  - Install from the App Store or download from [developer.apple.com](https://developer.apple.com)
  - Verify: `xcode-select -p` should return a path

- **iOS SDK 16.0+**: Included with Xcode
  - Verify: `xcrun simctl list runtimes` should show available iOS versions

- **Flutter 3.0+**: Cross-platform development framework
  - Install from [flutter.dev](https://flutter.dev)
  - Verify: `flutter --version`

- **CocoaPods 1.11+**: iOS dependency manager
  - Install: `sudo gem install cocoapods`
  - Verify: `pod --version`

- **macOS 12.0+**: Operating system
  - Verify: `sw_vers`

### System Requirements

- **Disk Space**: At least 20 GB free (for Xcode, iOS SDKs, and build artifacts)
- **RAM**: At least 8 GB (16 GB recommended for smooth emulator performance)
- **CPU**: Intel or Apple Silicon processor

### Verify Installation

Run the setup script to validate all prerequisites:

```bash
bash scripts/setup_ios_emulator.sh
```

This will check for:
- ✓ Xcode installation
- ✓ iOS SDK availability
- ✓ Flutter installation
- ✓ CocoaPods installation
- ✓ Available iOS simulators

---

## Environment Setup

### Initial Setup

The setup script configures your iOS emulator environment:

```bash
bash scripts/setup_ios_emulator.sh [device_type] [ios_version]
```

**Parameters:**
- `device_type` (optional): Device type (default: "iPhone 14")
  - Examples: "iPhone 14", "iPhone 15", "iPhone 15 Pro", "iPad Pro"
- `ios_version` (optional): iOS version (default: "17.0")
  - Examples: "16.0", "16.4", "17.0", "17.1"

**Examples:**

```bash
# Set up with default device (iPhone 14, iOS 17.0)
bash scripts/setup_ios_emulator.sh

# Set up with iPhone 15 and iOS 17.0
bash scripts/setup_ios_emulator.sh "iPhone 15" "17.0"

# Set up with iPad Pro and iOS 16.4
bash scripts/setup_ios_emulator.sh "iPad Pro" "16.4"
```

### What the Setup Script Does

1. **Validates Xcode Installation**: Checks for Xcode and its command-line tools
2. **Validates iOS SDK**: Verifies the requested iOS version is installed
3. **Checks Existing Simulators**: Lists available simulators for the iOS version
4. **Creates New Simulator** (if needed): Creates a simulator if none exists for the version
5. **Validates Flutter**: Checks Flutter installation and version
6. **Validates CocoaPods**: Installs CocoaPods if not present

### Manual Simulator Creation

If you prefer to create simulators manually:

```bash
# List available device types
xcrun simctl list devicetypes

# List available iOS runtimes
xcrun simctl list runtimes

# Create a simulator
xcrun simctl create "iPhone 14 (iOS 17.0)" com.apple.CoreSimulator.SimDeviceType.iPhone-14 com.apple.CoreSimulator.SimRuntime.iOS-17-0

# List all simulators
xcrun simctl list devices
```

---

## Building the iOS App

### Build Script

The build script handles dependency resolution, CocoaPods installation, and app compilation:

```bash
bash scripts/build_ios.sh [build_mode]
```

**Parameters:**
- `build_mode` (optional): Build mode (default: "debug")
  - `debug`: Development build with debugging symbols
  - `release`: Optimized production build
  - `profile`: Profiling build for performance analysis

**Examples:**

```bash
# Build in debug mode (default)
bash scripts/build_ios.sh

# Build in release mode
bash scripts/build_ios.sh release

# Build in profile mode
bash scripts/build_ios.sh profile
```

### Build Process Steps

1. **Resolve Flutter Dependencies** (flutter pub get)
   - Downloads and resolves all Dart dependencies
   - Updates pubspec.lock

2. **Install CocoaPods** (pod install)
   - Installs iOS-specific packages
   - Generates Xcode workspace

3. **Compile Flutter App** (flutter build ios)
   - Compiles Dart code to native iOS code
   - Generates iOS app binary (.app file)

4. **Verify Build Artifact**
   - Confirms the .app file was created
   - Reports artifact location and size

### Build Output

The build script generates:
- **Build Artifact**: `build/ios/iphoneos/Runner.app`
- **Build Log**: `build_ios.log`
- **Console Output**: Real-time progress with color-coded status

### Build Modes Explained

| Mode | Use Case | Performance | Debug Info |
|------|----------|-------------|-----------|
| **debug** | Development, testing | Slower | Full symbols |
| **release** | Production, performance testing | Fastest | Minimal symbols |
| **profile** | Performance profiling | Medium | Profiling data |

---

## Running Tests

### Test Script

The test script executes tests on iOS emulators:

```bash
bash scripts/test_ios.sh [test_type] [simulator_id]
```

**Parameters:**
- `test_type` (optional): Type of tests to run (default: "unit")
  - `unit`: Unit tests (fast, isolated)
  - `widget`: Widget tests (UI component tests)
  - `integration`: Integration tests (end-to-end workflows)
- `simulator_id` (optional): Specific simulator to use
  - If not specified, uses the first available simulator

**Examples:**

```bash
# Run unit tests on default simulator
bash scripts/test_ios.sh unit

# Run widget tests on default simulator
bash scripts/test_ios.sh widget

# Run integration tests on default simulator
bash scripts/test_ios.sh integration

# Run unit tests on specific simulator
bash scripts/test_ios.sh unit "SIMULATOR-ID-HERE"
```

### Test Execution Process

1. **Detect/Validate Simulator**
   - Finds available simulator or uses specified one
   - Displays simulator name and iOS version

2. **Boot Simulator** (if needed)
   - Starts the simulator if not already running
   - Waits for full boot completion

3. **Run Tests**
   - Executes tests using Flutter test framework
   - Captures test output in JSON format

4. **Parse Results**
   - Extracts test statistics (total, passed, failed)
   - Displays summary in console

### Test Results

Test results are saved to:
- **Results Directory**: `test_results/`
- **Result Files**: `{test_type}_results.json`
- **Test Log**: `test_ios.log`

### Test Types Explained

| Type | Purpose | Speed | Coverage |
|------|---------|-------|----------|
| **unit** | Test individual functions/classes | Fast | High |
| **widget** | Test UI components | Medium | Medium |
| **integration** | Test complete workflows | Slow | Low (but realistic) |

---

## CLI Commands

The iOS Build & Test CLI provides programmatic access to build and test operations:

### Available Commands

#### 1. flutter_build_ios

Build the iOS app with specified options.

```bash
flutter_build_ios [options]
```

**Options:**
- `--mode <mode>`: Build mode (debug, release, profile) [default: debug]
- `--help`: Show help message

**Examples:**

```bash
# Build in debug mode
flutter_build_ios --mode debug

# Build in release mode
flutter_build_ios --mode release

# Show help
flutter_build_ios --help
```

#### 2. flutter_test_ios

Run tests on iOS emulator.

```bash
flutter_test_ios [options]
```

**Options:**
- `--type <type>`: Test type (unit, widget, integration) [default: unit]
- `--simulator <id>`: Simulator ID (optional, uses first available if not specified)
- `--help`: Show help message

**Examples:**

```bash
# Run unit tests
flutter_test_ios --type unit

# Run widget tests
flutter_test_ios --type widget

# Run integration tests on specific simulator
flutter_test_ios --type integration --simulator "SIMULATOR-ID"

# Show help
flutter_test_ios --help
```

#### 3. flutter_build_test_ios

Execute complete build and test workflow.

```bash
flutter_build_test_ios [options]
```

**Options:**
- `--mode <mode>`: Build mode (debug, release, profile) [default: debug]
- `--help`: Show help message

**Examples:**

```bash
# Run full workflow with debug build
flutter_build_test_ios --mode debug

# Run full workflow with release build
flutter_build_test_ios --mode release

# Show help
flutter_build_test_ios --help
```

**Output:**
- Build report with status and duration
- Test report with pass/fail statistics
- Recommendations for next steps
- Overall workflow status

#### 4. flutter_list_simulators

List available iOS simulators.

```bash
flutter_list_simulators [options]
```

**Options:**
- `--json`: Output as JSON (useful for scripting)
- `--help`: Show help message

**Examples:**

```bash
# List simulators in human-readable format
flutter_list_simulators

# List simulators as JSON
flutter_list_simulators --json

# Show help
flutter_list_simulators --help
```

**Output:**
```
Available iOS Simulators:

  iPhone 14
    ID: 12345678-1234-1234-1234-123456789012
    iOS: 17.0
    Status: (stopped)

  iPhone 15
    ID: 87654321-4321-4321-4321-210987654321
    iOS: 17.0
    Status: (running)
```

#### 5. flutter_create_simulator

Create a new iOS simulator.

```bash
flutter_create_simulator [options]
```

**Options:**
- `--device <type>`: Device type (required)
  - Examples: "iPhone 14", "iPhone 15", "iPad Pro"
- `--ios <version>`: iOS version (required)
  - Examples: "16.0", "17.0"
- `--help`: Show help message

**Examples:**

```bash
# Create iPhone 14 with iOS 17.0
flutter_create_simulator --device "iPhone 14" --ios 17.0

# Create iPhone 15 Pro with iOS 17.0
flutter_create_simulator --device "iPhone 15 Pro" --ios 17.0

# Create iPad Pro with iOS 16.4
flutter_create_simulator --device "iPad Pro" --ios 16.4

# Show help
flutter_create_simulator --help
```

---

## Shell Scripts

### Script Overview

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup_ios_emulator.sh` | Configure iOS emulator environment | `bash scripts/setup_ios_emulator.sh [device] [ios]` |
| `build_ios.sh` | Build iOS app | `bash scripts/build_ios.sh [mode]` |
| `test_ios.sh` | Run tests on emulator | `bash scripts/test_ios.sh [type] [simulator]` |
| `build_test_ios.sh` | Full build and test workflow | `bash scripts/build_test_ios.sh [mode] [type]` |
| `cleanup_ios_emulator.sh` | Clean up resources | `bash scripts/cleanup_ios_emulator.sh [simulator]` |

### setup_ios_emulator.sh

**Purpose**: Validate and configure iOS emulator environment

**Usage**:
```bash
bash scripts/setup_ios_emulator.sh [device_type] [ios_version]
```

**Parameters**:
- `device_type`: Device type (default: "iPhone 14")
- `ios_version`: iOS version (default: "17.0")

**Output**:
- Validates Xcode, iOS SDK, Flutter, CocoaPods
- Creates simulator if needed
- Displays setup summary

**Example**:
```bash
bash scripts/setup_ios_emulator.sh "iPhone 15" "17.0"
```

### build_ios.sh

**Purpose**: Build iOS app with dependency resolution

**Usage**:
```bash
bash scripts/build_ios.sh [build_mode]
```

**Parameters**:
- `build_mode`: Build mode (default: "debug")
  - Options: debug, release, profile

**Output**:
- Build log: `build_ios.log`
- Build artifact: `build/ios/iphoneos/Runner.app`
- Console output with progress

**Example**:
```bash
bash scripts/build_ios.sh debug
```

### test_ios.sh

**Purpose**: Run tests on iOS emulator

**Usage**:
```bash
bash scripts/test_ios.sh [test_type] [simulator_id]
```

**Parameters**:
- `test_type`: Test type (default: "unit")
  - Options: unit, widget, integration
- `simulator_id`: Simulator ID (optional)

**Output**:
- Test log: `test_ios.log`
- Test results: `test_results/{type}_results.json`
- Console output with summary

**Example**:
```bash
bash scripts/test_ios.sh unit
```

### build_test_ios.sh

**Purpose**: Execute complete build and test workflow

**Usage**:
```bash
bash scripts/build_test_ios.sh [build_mode] [test_type]
```

**Parameters**:
- `build_mode`: Build mode (default: "debug")
- `test_type`: Test type (default: "unit")

**Output**:
- Workflow log: `build_test_workflow.log`
- Build and test results
- Final status report with recommendations

**Example**:
```bash
bash scripts/build_test_ios.sh debug unit
```

### cleanup_ios_emulator.sh

**Purpose**: Clean up emulator resources and temporary artifacts

**Usage**:
```bash
bash scripts/cleanup_ios_emulator.sh [simulator_id]
```

**Parameters**:
- `simulator_id`: Specific simulator to shut down (optional)
  - If not specified, shuts down all running simulators

**Cleanup Actions**:
- Shuts down simulators
- Removes build artifacts (`build/`, `.dart_tool/`)
- Removes CocoaPods files (`ios/Pods/`, `ios/Podfile.lock`)
- Clears test results and logs

**Output**:
- Cleanup log: `cleanup_ios_emulator.log`
- Summary of freed resources

**Example**:
```bash
# Clean up all simulators
bash scripts/cleanup_ios_emulator.sh

# Clean up specific simulator
bash scripts/cleanup_ios_emulator.sh "SIMULATOR-ID"
```

---

## Supported iOS Versions and Devices

### Supported iOS Versions

The iOS Emulator Build & Test Setup supports the following iOS versions:

| iOS Version | Status | Notes |
|-------------|--------|-------|
| **17.0+** | ✓ Recommended | Latest iOS version, full feature support |
| **16.0 - 16.7** | ✓ Supported | Stable, widely used |
| **15.0 - 15.8** | ✓ Supported | Older but still supported |
| **14.0 - 14.8** | ⚠ Limited | May have compatibility issues |
| **< 14.0** | ✗ Not Supported | Too old, not recommended |

### Supported Device Types

The following device types are available for emulation:

#### iPhones

| Device | iOS 17.0 | iOS 16.x | iOS 15.x | Notes |
|--------|----------|----------|----------|-------|
| iPhone 15 | ✓ | ✗ | ✗ | Latest model |
| iPhone 15 Plus | ✓ | ✗ | ✗ | Latest model |
| iPhone 15 Pro | ✓ | ✗ | ✗ | Latest model |
| iPhone 15 Pro Max | ✓ | ✗ | ✗ | Latest model |
| iPhone 14 | ✓ | ✓ | ✗ | Recommended |
| iPhone 14 Plus | ✓ | ✓ | ✗ | Recommended |
| iPhone 14 Pro | ✓ | ✓ | ✗ | Recommended |
| iPhone 14 Pro Max | ✓ | ✓ | ✗ | Recommended |
| iPhone 13 | ✓ | ✓ | ✓ | Older model |
| iPhone 13 mini | ✓ | ✓ | ✓ | Older model |
| iPhone 13 Pro | ✓ | ✓ | ✓ | Older model |
| iPhone 13 Pro Max | ✓ | ✓ | ✓ | Older model |
| iPhone SE (3rd generation) | ✓ | ✓ | ✓ | Compact device |

#### iPads

| Device | iOS 17.0 | iOS 16.x | iOS 15.x | Notes |
|--------|----------|----------|----------|-------|
| iPad Pro (12.9-inch) | ✓ | ✓ | ✓ | Large screen |
| iPad Pro (11-inch) | ✓ | ✓ | ✓ | Medium screen |
| iPad Air (5th generation) | ✓ | ✓ | ✗ | Mid-range |
| iPad (10th generation) | ✓ | ✓ | ✗ | Entry-level |
| iPad mini (6th generation) | ✓ | ✓ | ✗ | Compact |

### Checking Available Devices and Versions

To see what's available on your system:

```bash
# List available device types
xcrun simctl list devicetypes

# List available iOS runtimes
xcrun simctl list runtimes

# List all simulators
xcrun simctl list devices
```

### Recommended Configuration

For optimal development experience:

- **Primary Device**: iPhone 14 or iPhone 15
- **Primary iOS Version**: 17.0 (latest)
- **Secondary Device**: iPhone SE (for compact screen testing)
- **Secondary iOS Version**: 16.x (for compatibility testing)

---

## Troubleshooting

### Common Issues and Solutions

#### Issue: "Xcode not found"

**Error Message**:
```
✗ Xcode not found
Please install Xcode from the App Store
```

**Solution**:
1. Install Xcode from the App Store
2. Accept Xcode license: `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
3. Verify: `xcode-select -p`

#### Issue: "iOS SDK not found"

**Error Message**:
```
✗ iOS SDK not found
Please install iOS SDK via Xcode
```

**Solution**:
1. Open Xcode: `open /Applications/Xcode.app`
2. Go to Preferences → Locations
3. Select Command Line Tools version
4. Download additional components if needed
5. Verify: `xcrun simctl list runtimes`

#### Issue: "Flutter not found"

**Error Message**:
```
✗ Flutter not found
Please install Flutter from https://flutter.dev
```

**Solution**:
1. Install Flutter from [flutter.dev](https://flutter.dev)
2. Add Flutter to PATH: `export PATH="$PATH:~/flutter/bin"`
3. Verify: `flutter --version`

#### Issue: "CocoaPods not found"

**Error Message**:
```
⚠ CocoaPods not found
Installing CocoaPods...
```

**Solution**:
1. Install CocoaPods: `sudo gem install cocoapods`
2. Verify: `pod --version`
3. Update repo: `pod repo update`

#### Issue: "No iOS simulators available"

**Error Message**:
```
✗ No iOS simulators available
```

**Solution**:
1. Run setup script: `bash scripts/setup_ios_emulator.sh`
2. Or manually create simulator:
   ```bash
   xcrun simctl create "iPhone 14 (iOS 17.0)" \
     com.apple.CoreSimulator.SimDeviceType.iPhone-14 \
     com.apple.CoreSimulator.SimRuntime.iOS-17-0
   ```

#### Issue: "Simulator boot timeout"

**Error Message**:
```
⚠ Simulator boot timeout
```

**Solution**:
1. Check system resources (RAM, CPU)
2. Close other applications
3. Manually boot simulator: `xcrun simctl boot <simulator-id>`
4. Wait 30-60 seconds for full boot
5. Retry test execution

#### Issue: "Build failed: Pod install error"

**Error Message**:
```
✗ Failed to install CocoaPods
```

**Solution**:
1. Clean CocoaPods cache: `rm -rf ios/Pods ios/Podfile.lock`
2. Update CocoaPods: `sudo gem install cocoapods`
3. Update repo: `pod repo update`
4. Retry build: `bash scripts/build_ios.sh`

#### Issue: "Build failed: Compilation error"

**Error Message**:
```
✗ Failed to build Flutter app
```

**Solution**:
1. Check build log: `tail -50 build_ios.log`
2. Clean build: `flutter clean`
3. Resolve dependencies: `flutter pub get`
4. Retry build: `bash scripts/build_ios.sh`

#### Issue: "Tests failed: Simulator not responding"

**Error Message**:
```
✗ Tests failed
Simulator not responding
```

**Solution**:
1. Shut down simulator: `xcrun simctl shutdown <simulator-id>`
2. Wait 5 seconds
3. Retry test: `bash scripts/test_ios.sh unit`

#### Issue: "Insufficient disk space"

**Error Message**:
```
✗ Build failed: No space left on device
```

**Solution**:
1. Check disk space: `df -h`
2. Clean up: `bash scripts/cleanup_ios_emulator.sh`
3. Remove old Xcode caches: `rm -rf ~/Library/Developer/Xcode/DerivedData/*`
4. Retry build

#### Issue: "Permission denied" errors

**Error Message**:
```
✗ Permission denied: /path/to/file
```

**Solution**:
1. Check file permissions: `ls -la scripts/`
2. Make scripts executable: `chmod +x scripts/*.sh`
3. Retry operation

### Debug Mode

Enable verbose output for troubleshooting:

```bash
# Verbose Flutter build
flutter build ios -v

# Verbose Flutter test
flutter test -v

# Verbose CocoaPods
pod install --verbose

# Verbose simulator commands
xcrun simctl -v list devices
```

### Checking Logs

Important log files:

- **Build Log**: `build_ios.log`
- **Test Log**: `test_ios.log`
- **Workflow Log**: `build_test_workflow.log`
- **Setup Log**: `setup_ios_emulator.log`
- **Cleanup Log**: `cleanup_ios_emulator.log`

View logs:
```bash
# View last 50 lines
tail -50 build_ios.log

# View entire log
cat build_ios.log

# Search for errors
grep -i error build_ios.log
```

### Getting Help

If you encounter issues not covered here:

1. Check the log files for detailed error messages
2. Run setup script to validate environment: `bash scripts/setup_ios_emulator.sh`
3. Check Flutter documentation: [flutter.dev/docs](https://flutter.dev/docs)
4. Check Xcode documentation: [developer.apple.com](https://developer.apple.com)
5. Search GitHub issues for similar problems

---

## Advanced Usage

### Multi-Version Testing

Test the app on multiple iOS versions:

```bash
# Test on iOS 17.0
bash scripts/setup_ios_emulator.sh "iPhone 14" "17.0"
bash scripts/build_test_ios.sh debug unit

# Test on iOS 16.4
bash scripts/setup_ios_emulator.sh "iPhone 14" "16.4"
bash scripts/build_test_ios.sh debug unit

# Compare results
diff test_results/unit_results.json test_results/unit_results_16.4.json
```

### Multi-Device Testing

Test on different device types:

```bash
# Test on iPhone 14
bash scripts/setup_ios_emulator.sh "iPhone 14" "17.0"
bash scripts/build_test_ios.sh debug unit

# Test on iPhone SE
bash scripts/setup_ios_emulator.sh "iPhone SE" "17.0"
bash scripts/build_test_ios.sh debug unit

# Test on iPad Pro
bash scripts/setup_ios_emulator.sh "iPad Pro" "17.0"
bash scripts/build_test_ios.sh debug unit
```

### Parallel Testing

Run tests on multiple simulators in parallel:

```bash
# Terminal 1: Test on iPhone 14
bash scripts/test_ios.sh unit "simulator-id-1" &

# Terminal 2: Test on iPhone 15
bash scripts/test_ios.sh unit "simulator-id-2" &

# Wait for both to complete
wait
```

### Custom Build Configurations

Build with different modes:

```bash
# Debug build (fastest, full symbols)
bash scripts/build_ios.sh debug

# Profile build (medium speed, profiling data)
bash scripts/build_ios.sh profile

# Release build (slowest to build, fastest to run)
bash scripts/build_ios.sh release
```

### Continuous Integration

Integrate with CI/CD pipelines:

```bash
#!/bin/bash
set -e

# Setup
bash scripts/setup_ios_emulator.sh "iPhone 14" "17.0"

# Build
bash scripts/build_ios.sh debug

# Test
bash scripts/test_ios.sh unit
bash scripts/test_ios.sh widget
bash scripts/test_ios.sh integration

# Cleanup
bash scripts/cleanup_ios_emulator.sh

echo "CI/CD pipeline completed successfully"
```

### Performance Profiling

Profile app performance:

```bash
# Build in profile mode
bash scripts/build_ios.sh profile

# Run tests with profiling
bash scripts/test_ios.sh unit

# Analyze results
cat test_results/unit_results.json | jq '.[] | {name, duration}'
```

### Caching and Optimization

Optimize build times:

```bash
# First build (full)
time bash scripts/build_ios.sh debug

# Subsequent builds (cached)
time bash scripts/build_ios.sh debug

# Clean build (no cache)
flutter clean
time bash scripts/build_ios.sh debug
```

---

## Summary

This guide covers everything you need to build and test the Budget Planner app on iOS emulators:

- ✓ Prerequisites and system requirements
- ✓ Environment setup and configuration
- ✓ Building the iOS app
- ✓ Running tests (unit, widget, integration)
- ✓ CLI commands for programmatic access
- ✓ Shell scripts for automation
- ✓ Supported iOS versions and devices
- ✓ Troubleshooting common issues
- ✓ Advanced usage patterns

For more information, see the [Requirements Document](.kiro/specs/ios-emulator-build-test/requirements.md) and [Design Document](.kiro/specs/ios-emulator-build-test/design.md).
