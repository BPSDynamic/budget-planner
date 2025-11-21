# iOS Emulator Build & Test - Troubleshooting Guide

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Environment Setup Issues](#environment-setup-issues)
3. [Build Issues](#build-issues)
4. [Test Execution Issues](#test-execution-issues)
5. [Simulator Issues](#simulator-issues)
6. [Performance Issues](#performance-issues)
7. [Resource Issues](#resource-issues)
8. [Advanced Debugging](#advanced-debugging)

---

## Installation Issues

### Issue: Xcode Command Line Tools Not Found

**Symptoms:**
```
xcode-select: error: unable to get active developer directory
```

**Root Cause:**
Xcode command-line tools are not installed or not properly configured.

**Solutions:**

1. **Install Xcode from App Store:**
   ```bash
   # Open App Store and search for "Xcode"
   # Or use direct link
   open "macappstore://apps.apple.com/app/xcode/id497799835"
   ```

2. **Accept Xcode License:**
   ```bash
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcode-select --reset
   ```

3. **Verify Installation:**
   ```bash
   xcode-select -p
   # Should output: /Applications/Xcode.app/Contents/Developer
   ```

4. **Install Command Line Tools Only:**
   ```bash
   xcode-select --install
   ```

### Issue: Xcode License Not Accepted

**Symptoms:**
```
Xcode license agreement has not been accepted
```

**Solutions:**

1. **Accept License:**
   ```bash
   sudo xcodebuild -license accept
   ```

2. **Or Open Xcode and Accept:**
   ```bash
   open /Applications/Xcode.app
   # Follow prompts to accept license
   ```

3. **Verify:**
   ```bash
   xcodebuild -license
   ```

### Issue: Flutter Not Found

**Symptoms:**
```
command not found: flutter
```

**Solutions:**

1. **Install Flutter:**
   ```bash
   # Download from flutter.dev
   cd ~/development
   git clone https://github.com/flutter/flutter.git -b stable
   ```

2. **Add to PATH:**
   ```bash
   # Add to ~/.zshrc or ~/.bash_profile
   export PATH="$PATH:$HOME/development/flutter/bin"
   
   # Reload shell
   source ~/.zshrc
   ```

3. **Verify Installation:**
   ```bash
   flutter --version
   flutter doctor
   ```

### Issue: CocoaPods Not Found

**Symptoms:**
```
command not found: pod
```

**Solutions:**

1. **Install CocoaPods:**
   ```bash
   sudo gem install cocoapods
   ```

2. **Update Repository:**
   ```bash
   pod repo update
   ```

3. **Verify Installation:**
   ```bash
   pod --version
   ```

---

## Environment Setup Issues

### Issue: iOS SDK Not Found

**Symptoms:**
```
✗ iOS SDK not found
Please install iOS SDK via Xcode
```

**Root Cause:**
iOS SDK is not installed or not properly configured.

**Solutions:**

1. **Check Available SDKs:**
   ```bash
   xcrun simctl list runtimes
   ```

2. **Open Xcode Preferences:**
   ```bash
   open /Applications/Xcode.app/Contents/Developer/Applications/Simulator.app
   ```

3. **Install Additional Components:**
   - Open Xcode
   - Go to Preferences → Locations
   - Select Command Line Tools
   - Download additional components if needed

4. **Verify Installation:**
   ```bash
   xcrun simctl list runtimes | grep iOS
   ```

### Issue: No iOS Simulators Available

**Symptoms:**
```
✗ No iOS simulators available
```

**Root Cause:**
No simulators are created or all are deleted.

**Solutions:**

1. **List Existing Simulators:**
   ```bash
   xcrun simctl list devices
   ```

2. **Create New Simulator:**
   ```bash
   # Get available device types
   xcrun simctl list devicetypes
   
   # Get available runtimes
   xcrun simctl list runtimes
   
   # Create simulator
   xcrun simctl create "iPhone 14 (iOS 17.0)" \
     com.apple.CoreSimulator.SimDeviceType.iPhone-14 \
     com.apple.CoreSimulator.SimRuntime.iOS-17-0
   ```

3. **Or Use Setup Script:**
   ```bash
   bash scripts/setup_ios_emulator.sh "iPhone 14" "17.0"
   ```

### Issue: Simulator Device Type Not Found

**Symptoms:**
```
Device type 'iPhone 14' not found
```

**Root Cause:**
Device type name is incorrect or not available.

**Solutions:**

1. **List Available Device Types:**
   ```bash
   xcrun simctl list devicetypes
   ```

2. **Use Correct Device Name:**
   ```bash
   # Correct format includes full name
   xcrun simctl list devicetypes | grep iPhone
   
   # Example output:
   # iPhone 15 (com.apple.CoreSimulator.SimDeviceType.iPhone-15)
   # iPhone 14 (com.apple.CoreSimulator.SimDeviceType.iPhone-14)
   ```

3. **Create with Correct Name:**
   ```bash
   bash scripts/setup_ios_emulator.sh "iPhone 14" "17.0"
   ```

---

## Build Issues

### Issue: Pod Install Fails

**Symptoms:**
```
✗ Failed to install CocoaPods
Error: Unable to find a specification for dependency
```

**Root Cause:**
CocoaPods repository is outdated or corrupted.

**Solutions:**

1. **Update CocoaPods Repository:**
   ```bash
   pod repo update
   ```

2. **Clean CocoaPods Cache:**
   ```bash
   rm -rf ios/Pods
   rm -rf ios/Podfile.lock
   pod install
   ```

3. **Update CocoaPods:**
   ```bash
   sudo gem install cocoapods
   pod repo update
   ```

4. **Retry Build:**
   ```bash
   bash scripts/build_ios.sh debug
   ```

### Issue: Flutter Pub Get Fails

**Symptoms:**
```
✗ Failed to resolve Flutter dependencies
Error: pub get failed
```

**Root Cause:**
Dart dependencies are corrupted or network issue.

**Solutions:**

1. **Clean Pub Cache:**
   ```bash
   flutter clean
   rm -rf pubspec.lock
   ```

2. **Get Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Upgrade Dependencies:**
   ```bash
   flutter pub upgrade
   ```

4. **Check Network:**
   ```bash
   ping pub.dev
   ```

### Issue: Build Compilation Error

**Symptoms:**
```
✗ Failed to build Flutter app
Error: Compilation failed
```

**Root Cause:**
Dart code has syntax errors or incompatibilities.

**Solutions:**

1. **Check Build Log:**
   ```bash
   tail -100 build_ios.log
   ```

2. **Analyze Code:**
   ```bash
   flutter analyze
   ```

3. **Fix Issues:**
   - Review error messages in log
   - Fix syntax errors
   - Update incompatible dependencies

4. **Retry Build:**
   ```bash
   flutter clean
   bash scripts/build_ios.sh debug
   ```

### Issue: Build Artifact Not Found

**Symptoms:**
```
✗ Build artifact not found at build/ios/iphoneos/Runner.app
```

**Root Cause:**
Build completed but artifact was not generated.

**Solutions:**

1. **Check Build Output:**
   ```bash
   ls -la build/ios/iphoneos/
   ```

2. **Verify Build Mode:**
   ```bash
   # Debug build
   flutter build ios --debug
   
   # Release build
   flutter build ios --release
   ```

3. **Clean and Rebuild:**
   ```bash
   flutter clean
   bash scripts/build_ios.sh debug
   ```

### Issue: Insufficient Disk Space

**Symptoms:**
```
✗ Build failed: No space left on device
```

**Root Cause:**
Disk is full or nearly full.

**Solutions:**

1. **Check Disk Space:**
   ```bash
   df -h
   ```

2. **Clean Up:**
   ```bash
   # Clean Flutter
   flutter clean
   
   # Clean build artifacts
   bash scripts/cleanup_ios_emulator.sh
   
   # Clean Xcode cache
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   
   # Clean CocoaPods
   rm -rf ~/.cocoapods/repos
   ```

3. **Free Up Space:**
   ```bash
   # Remove old Xcode versions
   rm -rf /Library/Developer/Xcode/DerivedData/*
   
   # Remove old simulators
   xcrun simctl delete unavailable
   ```

---

## Test Execution Issues

### Issue: Tests Fail to Run

**Symptoms:**
```
✗ Tests failed
Error: Unable to run tests
```

**Root Cause:**
Simulator not running or test framework issue.

**Solutions:**

1. **Check Simulator Status:**
   ```bash
   xcrun simctl list devices
   ```

2. **Boot Simulator:**
   ```bash
   xcrun simctl boot <simulator-id>
   sleep 10
   ```

3. **Retry Tests:**
   ```bash
   bash scripts/test_ios.sh unit
   ```

### Issue: Unit Tests Timeout

**Symptoms:**
```
⚠ Test timeout
Tests did not complete within timeout period
```

**Root Cause:**
Tests are taking too long or simulator is slow.

**Solutions:**

1. **Increase Timeout:**
   ```bash
   flutter test --timeout=60s
   ```

2. **Check System Resources:**
   ```bash
   # Check CPU usage
   top -l 1 | head -20
   
   # Check memory
   vm_stat
   ```

3. **Close Other Applications:**
   - Close unnecessary apps
   - Free up system resources
   - Retry tests

4. **Simplify Tests:**
   - Run specific test file
   - Run specific test case
   - Reduce test complexity

### Issue: Widget Tests Fail

**Symptoms:**
```
✗ Widget tests failed
Error: Widget rendering failed
```

**Root Cause:**
Widget rendering issue or test setup problem.

**Solutions:**

1. **Check Test Code:**
   ```bash
   # Review test file
   cat test/features/budget/screens/budget_category_screen_test.dart
   ```

2. **Run with Verbose Output:**
   ```bash
   flutter test -v test/features/budget/screens/budget_category_screen_test.dart
   ```

3. **Check Dependencies:**
   ```bash
   flutter pub get
   flutter pub upgrade
   ```

4. **Rebuild and Retry:**
   ```bash
   flutter clean
   flutter pub get
   flutter test
   ```

### Issue: Integration Tests Fail

**Symptoms:**
```
✗ Integration tests failed
Error: Driver connection failed
```

**Root Cause:**
App not running or driver connection issue.

**Solutions:**

1. **Check App Installation:**
   ```bash
   xcrun simctl list apps <simulator-id>
   ```

2. **Reinstall App:**
   ```bash
   flutter drive --target=test_driver/app.dart --driver=test_driver/integration_test.dart
   ```

3. **Check Test Driver:**
   ```bash
   # Verify test_driver/app.dart exists
   ls -la test_driver/
   ```

4. **Retry Tests:**
   ```bash
   bash scripts/test_ios.sh integration
   ```

---

## Simulator Issues

### Issue: Simulator Won't Boot

**Symptoms:**
```
⚠ Simulator boot timeout
Simulator did not boot within timeout period
```

**Root Cause:**
Simulator is stuck or system resources exhausted.

**Solutions:**

1. **Force Shutdown:**
   ```bash
   xcrun simctl shutdown <simulator-id>
   sleep 5
   ```

2. **Erase Simulator:**
   ```bash
   xcrun simctl erase <simulator-id>
   ```

3. **Restart Simulator Service:**
   ```bash
   killall "Simulator"
   sleep 5
   xcrun simctl boot <simulator-id>
   ```

4. **Check System Resources:**
   ```bash
   # Check available memory
   vm_stat
   
   # Check CPU usage
   top -l 1 | head -20
   ```

### Issue: Simulator Crashes

**Symptoms:**
```
Simulator crashed unexpectedly
```

**Root Cause:**
Simulator process crashed or system issue.

**Solutions:**

1. **Kill Simulator Process:**
   ```bash
   killall "Simulator"
   killall "simctl"
   ```

2. **Restart Simulator:**
   ```bash
   xcrun simctl shutdown <simulator-id>
   sleep 5
   xcrun simctl boot <simulator-id>
   ```

3. **Erase and Recreate:**
   ```bash
   xcrun simctl erase <simulator-id>
   xcrun simctl boot <simulator-id>
   ```

4. **Restart Mac:**
   - Last resort if simulator keeps crashing
   - Restart macOS
   - Retry simulator

### Issue: App Won't Install on Simulator

**Symptoms:**
```
✗ Failed to install app on simulator
Error: Installation failed
```

**Root Cause:**
App binary issue or simulator state problem.

**Solutions:**

1. **Check App Binary:**
   ```bash
   ls -la build/ios/iphoneos/Runner.app
   ```

2. **Uninstall Previous App:**
   ```bash
   xcrun simctl uninstall <simulator-id> com.example.budgetPlanner
   ```

3. **Erase Simulator:**
   ```bash
   xcrun simctl erase <simulator-id>
   ```

4. **Rebuild and Reinstall:**
   ```bash
   flutter clean
   bash scripts/build_ios.sh debug
   bash scripts/test_ios.sh unit
   ```

### Issue: Simulator Slow or Unresponsive

**Symptoms:**
```
Simulator is very slow
Tests timing out
```

**Root Cause:**
System resources exhausted or simulator overloaded.

**Solutions:**

1. **Check System Resources:**
   ```bash
   # Memory usage
   vm_stat
   
   # CPU usage
   top -l 1 | head -20
   
   # Disk usage
   df -h
   ```

2. **Close Other Applications:**
   - Close unnecessary apps
   - Free up RAM
   - Reduce CPU load

3. **Reduce Simulator Load:**
   ```bash
   # Shutdown other simulators
   xcrun simctl shutdown all
   
   # Boot only needed simulator
   xcrun simctl boot <simulator-id>
   ```

4. **Increase System Resources:**
   - Close background processes
   - Restart Mac
   - Upgrade RAM if possible

---

## Performance Issues

### Issue: Build Takes Too Long

**Symptoms:**
```
Build is very slow (> 5 minutes)
```

**Root Cause:**
First build, no cache, or system resources limited.

**Solutions:**

1. **Use Debug Mode:**
   ```bash
   # Debug is faster than release
   bash scripts/build_ios.sh debug
   ```

2. **Check System Resources:**
   ```bash
   # Ensure sufficient RAM and CPU
   vm_stat
   top -l 1 | head -20
   ```

3. **Use Build Cache:**
   ```bash
   # Subsequent builds should be faster
   bash scripts/build_ios.sh debug
   ```

4. **Parallel Build:**
   ```bash
   # Use multiple cores
   flutter build ios --debug -j 4
   ```

### Issue: Tests Run Slowly

**Symptoms:**
```
Tests take > 10 minutes
```

**Root Cause:**
Simulator slow, tests complex, or system resources limited.

**Solutions:**

1. **Run Specific Tests:**
   ```bash
   # Run single test file
   flutter test test/features/budget/models/budget_category_test.dart
   ```

2. **Use Unit Tests First:**
   ```bash
   # Unit tests are fastest
   bash scripts/test_ios.sh unit
   ```

3. **Check System Resources:**
   ```bash
   # Free up resources
   killall -9 Simulator
   sleep 5
   ```

4. **Optimize Tests:**
   - Reduce test complexity
   - Remove unnecessary assertions
   - Use mocks for external dependencies

---

## Resource Issues

### Issue: Memory Exhaustion

**Symptoms:**
```
Out of memory error
Simulator crashes
```

**Root Cause:**
Too many simulators running or memory leak.

**Solutions:**

1. **Check Memory Usage:**
   ```bash
   vm_stat
   ```

2. **Shutdown Simulators:**
   ```bash
   xcrun simctl shutdown all
   ```

3. **Kill Simulator Process:**
   ```bash
   killall "Simulator"
   ```

4. **Restart Mac:**
   - Last resort
   - Clears all memory

### Issue: CPU Overload

**Symptoms:**
```
System very slow
Simulator unresponsive
```

**Root Cause:**
Too many processes or simulator consuming CPU.

**Solutions:**

1. **Check CPU Usage:**
   ```bash
   top -l 1 | head -20
   ```

2. **Kill Unnecessary Processes:**
   ```bash
   killall Simulator
   killall Xcode
   ```

3. **Reduce Load:**
   - Close other applications
   - Shutdown extra simulators
   - Reduce build parallelism

---

## Advanced Debugging

### Enable Verbose Logging

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

### Check System Logs

```bash
# System logs
log stream --predicate 'process == "Simulator"'

# Xcode build logs
cat ~/Library/Logs/com.apple.dt.Xcode/IDEBuildOperationActivityLogs/

# Flutter logs
flutter logs
```

### Debug Simulator

```bash
# Get simulator info
xcrun simctl list devices <simulator-id>

# Get simulator environment
xcrun simctl getenv <simulator-id> PATH

# Run command in simulator
xcrun simctl spawn <simulator-id> launchctl list
```

### Debug Build

```bash
# Check build settings
flutter build ios --debug -v 2>&1 | grep -i "setting"

# Check build phases
xcodebuild -showBuildSettings -project ios/Runner.xcodeproj

# Check CocoaPods
pod install --verbose
```

### Collect Diagnostics

```bash
# Flutter doctor
flutter doctor -v

# System info
system_profiler SPSoftwareDataType SPHardwareDataType

# Xcode info
xcode-select -p
xcodebuild -version

# iOS SDK info
xcrun simctl list runtimes
xcrun simctl list devicetypes
```

---

## Getting Help

If you're still stuck:

1. **Collect Diagnostics:**
   ```bash
   flutter doctor -v > diagnostics.txt
   ```

2. **Check Logs:**
   ```bash
   tail -100 build_ios.log > error_log.txt
   ```

3. **Search Issues:**
   - GitHub: flutter/flutter issues
   - Stack Overflow: [flutter] tag
   - Flutter Discord: #ios channel

4. **Report Issue:**
   - Include diagnostics output
   - Include error logs
   - Include reproduction steps
   - Include system info

---

## Quick Fixes Checklist

- [ ] Run `flutter doctor` to check environment
- [ ] Run `bash scripts/setup_ios_emulator.sh` to validate setup
- [ ] Check disk space: `df -h`
- [ ] Check system resources: `vm_stat`
- [ ] Clean Flutter: `flutter clean`
- [ ] Update dependencies: `flutter pub get`
- [ ] Shutdown simulators: `xcrun simctl shutdown all`
- [ ] Restart Mac (if all else fails)

---

## Summary

Most issues can be resolved by:

1. **Validating Environment**: Run setup script
2. **Checking Resources**: Ensure sufficient disk/memory/CPU
3. **Cleaning Up**: Remove old artifacts and caches
4. **Restarting**: Shutdown and restart simulators
5. **Rebuilding**: Clean build from scratch

For persistent issues, collect diagnostics and seek help from the Flutter community.
