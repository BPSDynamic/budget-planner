# iOS Build System - README

## Overview

The iOS Build System provides a comprehensive infrastructure for building, testing, and managing iOS app builds for the Budget Planner application. This system is designed to streamline the development workflow and ensure consistent, reliable builds across different environments.

## Quick Start

### 1. Initial Setup

```bash
# Set up iOS emulator environment
bash scripts/setup_ios_emulator.sh

# This will:
# - Validate Xcode installation
# - Check iOS SDK availability
# - Verify Flutter installation
# - Ensure CocoaPods is installed
# - Create iOS simulator if needed
```

### 2. Build the App

```bash
# Build in debug mode (fastest)
bash scripts/build_ios.sh debug

# Or use CLI
flutter_build_ios --mode debug
```

### 3. Run Tests

```bash
# Run unit tests
bash scripts/test_ios.sh unit

# Or use CLI
flutter_test_ios --type unit
```

### 4. Full Workflow

```bash
# Build and test in one command
bash scripts/build_test_ios.sh debug unit

# Or use CLI
flutter_build_test_ios --mode debug
```

### 5. Cleanup

```bash
# Clean up resources when done
bash scripts/cleanup_ios_emulator.sh
```

## System Architecture

### Components

The iOS Build System consists of several key components:

#### 1. **Emulator Manager** (`lib/services/ios_build/emulator_manager.dart`)
- Detects available iOS simulators
- Creates new simulators
- Manages simulator lifecycle (boot, shutdown)
- Verifies simulator readiness

#### 2. **Build Manager** (`lib/services/ios_build/build_manager.dart`)
- Resolves Flutter dependencies
- Installs CocoaPods
- Compiles Flutter app to iOS binary
- Manages build artifacts
- Reports build status

#### 3. **App Installer** (`lib/services/ios_build/app_installer.dart`)
- Installs built app on simulator
- Verifies installation
- Launches app
- Uninstalls app

#### 4. **Test Executor** (`lib/services/ios_build/test_executor.dart`)
- Runs unit tests
- Runs widget tests
- Runs integration tests
- Captures test results
- Captures screenshots and logs

#### 5. **Report Generator** (`lib/services/ios_build/report_generator.dart`)
- Generates test reports
- Generates build reports
- Generates compatibility reports
- Exports reports (JSON, HTML)

#### 6. **Build Cache Manager** (`lib/services/ios_build/build_cache_manager.dart`)
- Caches build artifacts
- Manages cache invalidation
- Reports cache statistics

#### 7. **Multi-Version Test Coordinator** (`lib/services/ios_build/multi_version_test_coordinator.dart`)
- Configures multiple simulators
- Runs tests on multiple iOS versions
- Aggregates results

#### 8. **Build Test Orchestrator** (`lib/services/ios_build/build_test_orchestrator.dart`)
- Coordinates entire workflow
- Validates prerequisites
- Handles error recovery
- Generates final reports

### Data Models

#### SimulatorConfig
```dart
{
  simulatorId: String,        // UUID
  deviceType: String,         // iPhone 14, iPad Pro, etc.
  iOSVersion: String,         // 16.0, 17.0, etc.
  isRunning: bool,
  bootTime: DateTime,
  memoryUsage: int            // MB
}
```

#### BuildConfig
```dart
{
  buildMode: String,          // debug, release, profile
  targetPlatform: String,     // ios
  buildNumber: int,
  buildTimestamp: DateTime,
  sourceHash: String,         // for cache validation
  artifactPath: String
}
```

#### TestResult
```dart
{
  testName: String,
  testType: String,           // unit, widget, integration
  status: String,             // passed, failed, skipped
  duration: int,              // milliseconds
  errorMessage: String,
  stackTrace: String,
  timestamp: DateTime
}
```

## Scripts

### setup_ios_emulator.sh

**Purpose**: Configure iOS emulator environment

**Usage**:
```bash
bash scripts/setup_ios_emulator.sh [device_type] [ios_version]
```

**Parameters**:
- `device_type`: Device type (default: "iPhone 14")
- `ios_version`: iOS version (default: "17.0")

**What it does**:
1. Validates Xcode installation
2. Checks iOS SDK availability
3. Lists existing simulators
4. Creates new simulator if needed
5. Validates Flutter installation
6. Validates CocoaPods installation

**Example**:
```bash
bash scripts/setup_ios_emulator.sh "iPhone 15" "17.0"
```

### build_ios.sh

**Purpose**: Build iOS app

**Usage**:
```bash
bash scripts/build_ios.sh [build_mode]
```

**Parameters**:
- `build_mode`: Build mode (default: "debug")
  - `debug`: Development build
  - `release`: Production build
  - `profile`: Profiling build

**What it does**:
1. Resolves Flutter dependencies
2. Installs CocoaPods
3. Compiles Flutter app
4. Verifies build artifact

**Output**:
- Build artifact: `build/ios/iphoneos/Runner.app`
- Build log: `build_ios.log`

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
  - `unit`: Unit tests
  - `widget`: Widget tests
  - `integration`: Integration tests
- `simulator_id`: Simulator ID (optional)

**What it does**:
1. Detects/validates simulator
2. Boots simulator if needed
3. Runs tests
4. Parses results
5. Reports summary

**Output**:
- Test results: `test_results/{type}_results.json`
- Test log: `test_ios.log`

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

**What it does**:
1. Validates prerequisites
2. Builds iOS app
3. Runs tests
4. Generates final report

**Output**:
- Workflow log: `build_test_workflow.log`
- Build and test results
- Final status report

**Example**:
```bash
bash scripts/build_test_ios.sh debug unit
```

### cleanup_ios_emulator.sh

**Purpose**: Clean up resources

**Usage**:
```bash
bash scripts/cleanup_ios_emulator.sh [simulator_id]
```

**Parameters**:
- `simulator_id`: Specific simulator (optional)

**What it does**:
1. Shuts down simulators
2. Removes build artifacts
3. Clears test results
4. Removes temporary logs

**Example**:
```bash
bash scripts/cleanup_ios_emulator.sh
```

## CLI Commands

### flutter_build_ios

Build iOS app programmatically.

```bash
flutter_build_ios --mode debug
```

### flutter_test_ios

Run tests programmatically.

```bash
flutter_test_ios --type unit
```

### flutter_build_test_ios

Execute full workflow programmatically.

```bash
flutter_build_test_ios --mode debug
```

### flutter_list_simulators

List available simulators.

```bash
flutter_list_simulators --json
```

### flutter_create_simulator

Create new simulator.

```bash
flutter_create_simulator --device "iPhone 14" --ios 17.0
```

## Build Modes

| Mode | Speed | Debug Info | Use Case |
|------|-------|-----------|----------|
| **debug** | Slow | Full | Development |
| **release** | Fast | Minimal | Production |
| **profile** | Medium | Profiling | Performance |

## Test Types

| Type | Speed | Coverage | Use Case |
|------|-------|----------|----------|
| **unit** | Fast | High | Function testing |
| **widget** | Medium | Medium | UI component testing |
| **integration** | Slow | Low | End-to-end workflows |

## Supported Devices

### iPhones
- iPhone 15, 15 Plus, 15 Pro, 15 Pro Max
- iPhone 14, 14 Plus, 14 Pro, 14 Pro Max
- iPhone 13, 13 mini, 13 Pro, 13 Pro Max
- iPhone SE (3rd generation)

### iPads
- iPad Pro (12.9-inch, 11-inch)
- iPad Air (5th generation)
- iPad (10th generation)
- iPad mini (6th generation)

## Supported iOS Versions

- iOS 17.0+ (Recommended)
- iOS 16.0 - 16.7 (Supported)
- iOS 15.0 - 15.8 (Supported)
- iOS 14.0 - 14.8 (Limited)

## Workflow Examples

### Basic Development Workflow

```bash
#!/bin/bash
set -e

# Setup
bash scripts/setup_ios_emulator.sh

# Build
bash scripts/build_ios.sh debug

# Test
bash scripts/test_ios.sh unit

# Cleanup
bash scripts/cleanup_ios_emulator.sh
```

### Multi-Version Testing

```bash
#!/bin/bash
set -e

# Test on iOS 17.0
bash scripts/setup_ios_emulator.sh "iPhone 14" "17.0"
bash scripts/build_test_ios.sh debug unit

# Test on iOS 16.4
bash scripts/setup_ios_emulator.sh "iPhone 14" "16.4"
bash scripts/build_test_ios.sh debug unit

# Cleanup
bash scripts/cleanup_ios_emulator.sh
```

### CI/CD Pipeline

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

## Troubleshooting

### Common Issues

**Xcode not found**
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

**iOS SDK not found**
```bash
# Open Xcode and install additional components
open /Applications/Xcode.app
```

**CocoaPods not found**
```bash
sudo gem install cocoapods
pod repo update
```

**No simulators available**
```bash
bash scripts/setup_ios_emulator.sh
```

**Build failed**
```bash
flutter clean
flutter pub get
bash scripts/build_ios.sh debug
```

For more troubleshooting, see [iOS_EMULATOR_TROUBLESHOOTING.md](iOS_EMULATOR_TROUBLESHOOTING.md).

## Performance Tips

1. **Use debug mode for development** - Faster builds
2. **Use release mode for performance testing** - Accurate results
3. **Run unit tests first** - Fastest feedback
4. **Use specific simulator** - Avoid detection overhead
5. **Clean build occasionally** - Prevents stale artifacts

## Log Files

- `build_ios.log` - Build output
- `test_ios.log` - Test output
- `build_test_workflow.log` - Full workflow output
- `setup_ios_emulator.log` - Setup output
- `cleanup_ios_emulator.log` - Cleanup output

View logs:
```bash
tail -50 build_ios.log
```

## Documentation

- **Full Guide**: [iOS_EMULATOR_BUILD_TEST_GUIDE.md](iOS_EMULATOR_BUILD_TEST_GUIDE.md)
- **Quick Reference**: [iOS_EMULATOR_QUICK_REFERENCE.md](iOS_EMULATOR_QUICK_REFERENCE.md)
- **Troubleshooting**: [iOS_EMULATOR_TROUBLESHOOTING.md](iOS_EMULATOR_TROUBLESHOOTING.md)
- **Requirements**: [.kiro/specs/ios-emulator-build-test/requirements.md](.kiro/specs/ios-emulator-build-test/requirements.md)
- **Design**: [.kiro/specs/ios-emulator-build-test/design.md](.kiro/specs/ios-emulator-build-test/design.md)
- **Tasks**: [.kiro/specs/ios-emulator-build-test/tasks.md](.kiro/specs/ios-emulator-build-test/tasks.md)

## Next Steps

1. **Setup Environment**: `bash scripts/setup_ios_emulator.sh`
2. **Build App**: `bash scripts/build_ios.sh debug`
3. **Run Tests**: `bash scripts/test_ios.sh unit`
4. **Review Results**: Check `test_results/` directory
5. **Cleanup**: `bash scripts/cleanup_ios_emulator.sh`

## Support

For issues or questions:

1. Check [iOS_EMULATOR_TROUBLESHOOTING.md](iOS_EMULATOR_TROUBLESHOOTING.md)
2. Review log files for error details
3. Run `flutter doctor -v` to check environment
4. Search Flutter documentation
5. Ask in Flutter community channels

---

**Last Updated**: November 2025
**Version**: 1.0
**Status**: Production Ready
