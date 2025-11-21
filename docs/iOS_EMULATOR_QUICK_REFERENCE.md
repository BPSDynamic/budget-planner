# iOS Emulator Build & Test - Quick Reference

## One-Minute Setup

```bash
# 1. Setup environment
bash scripts/setup_ios_emulator.sh

# 2. Build and test
bash scripts/build_test_ios.sh debug unit

# 3. Cleanup
bash scripts/cleanup_ios_emulator.sh
```

---

## Common Commands

### Setup & Configuration

```bash
# Setup with defaults (iPhone 14, iOS 17.0)
bash scripts/setup_ios_emulator.sh

# Setup with specific device and iOS version
bash scripts/setup_ios_emulator.sh "iPhone 15" "17.0"

# List available simulators
flutter_list_simulators

# Create new simulator
flutter_create_simulator --device "iPhone 14" --ios 17.0
```

### Building

```bash
# Build in debug mode (default)
bash scripts/build_ios.sh

# Build in release mode
bash scripts/build_ios.sh release

# Build in profile mode
bash scripts/build_ios.sh profile

# CLI: Build iOS app
flutter_build_ios --mode debug
```

### Testing

```bash
# Run unit tests
bash scripts/test_ios.sh unit

# Run widget tests
bash scripts/test_ios.sh widget

# Run integration tests
bash scripts/test_ios.sh integration

# CLI: Run tests
flutter_test_ios --type unit

# Full workflow (build + test)
bash scripts/build_test_ios.sh debug unit
```

### Cleanup

```bash
# Cleanup all simulators
bash scripts/cleanup_ios_emulator.sh

# Cleanup specific simulator
bash scripts/cleanup_ios_emulator.sh "SIMULATOR-ID"
```

---

## Build Modes

| Mode | Speed | Debug Info | Use Case |
|------|-------|-----------|----------|
| **debug** | Slow | Full | Development |
| **release** | Fast | Minimal | Production |
| **profile** | Medium | Profiling | Performance |

---

## Test Types

| Type | Speed | Coverage | Use Case |
|------|-------|----------|----------|
| **unit** | Fast | High | Function testing |
| **widget** | Medium | Medium | UI component testing |
| **integration** | Slow | Low | End-to-end workflows |

---

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

---

## Supported iOS Versions

- iOS 17.0+ (Recommended)
- iOS 16.0 - 16.7 (Supported)
- iOS 15.0 - 15.8 (Supported)
- iOS 14.0 - 14.8 (Limited)

---

## Troubleshooting

### Xcode not found
```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

### iOS SDK not found
```bash
# Open Xcode and install additional components
open /Applications/Xcode.app
```

### CocoaPods not found
```bash
sudo gem install cocoapods
pod repo update
```

### No simulators available
```bash
bash scripts/setup_ios_emulator.sh
```

### Build failed
```bash
flutter clean
flutter pub get
bash scripts/build_ios.sh
```

### Simulator not responding
```bash
xcrun simctl shutdown <simulator-id>
sleep 5
bash scripts/test_ios.sh unit
```

### Insufficient disk space
```bash
bash scripts/cleanup_ios_emulator.sh
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```

---

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

---

## CLI Commands

```bash
# Build
flutter_build_ios --mode debug

# Test
flutter_test_ios --type unit

# Full workflow
flutter_build_test_ios --mode debug

# List simulators
flutter_list_simulators --json

# Create simulator
flutter_create_simulator --device "iPhone 14" --ios 17.0
```

---

## Performance Tips

1. **Use debug mode for development** - Faster builds
2. **Use release mode for performance testing** - Accurate results
3. **Run unit tests first** - Fastest feedback
4. **Use specific simulator** - Avoid detection overhead
5. **Clean build occasionally** - Prevents stale artifacts

---

## Useful Commands

```bash
# List all simulators
xcrun simctl list devices

# Boot simulator
xcrun simctl boot <simulator-id>

# Shutdown simulator
xcrun simctl shutdown <simulator-id>

# Erase simulator
xcrun simctl erase <simulator-id>

# Get simulator info
xcrun simctl list devices | grep <simulator-id>
```

---

## Full Workflow Example

```bash
#!/bin/bash
set -e

echo "Setting up iOS emulator..."
bash scripts/setup_ios_emulator.sh "iPhone 14" "17.0"

echo "Building iOS app..."
bash scripts/build_ios.sh debug

echo "Running unit tests..."
bash scripts/test_ios.sh unit

echo "Running widget tests..."
bash scripts/test_ios.sh widget

echo "Running integration tests..."
bash scripts/test_ios.sh integration

echo "Cleaning up..."
bash scripts/cleanup_ios_emulator.sh

echo "Done!"
```

---

## Documentation

- **Full Guide**: `docs/iOS_EMULATOR_BUILD_TEST_GUIDE.md`
- **Requirements**: `.kiro/specs/ios-emulator-build-test/requirements.md`
- **Design**: `.kiro/specs/ios-emulator-build-test/design.md`
- **Tasks**: `.kiro/specs/ios-emulator-build-test/tasks.md`
