# Tech Stack & Build System

## Framework & Language

- **Framework**: Flutter (Dart SDK ^3.9.2)
- **Language**: Dart
- **UI Framework**: Material Design 3
- **State Management**: Provider (^6.1.5+1)

## Key Dependencies

- **UI & Fonts**: google_fonts (^6.3.2), cupertino_icons (^1.0.8)
- **Internationalization**: intl (^0.20.2)
- **Charts**: fl_chart (^1.1.1)
- **Storage**: shared_preferences (^2.5.3)
- **Utilities**: uuid (^4.5.2), image_picker (^1.1.2), args (^2.4.0)

## Development Dependencies

- **Testing**: flutter_test (SDK), test (^1.25.0)
- **Linting**: flutter_lints (^5.0.0)

## Build System

### Flutter Commands

```bash
# Get dependencies
flutter pub get

# Run app (default platform)
flutter run

# Build for specific platform
flutter build ios
flutter build android
flutter build web
flutter build macos
flutter build linux
flutter build windows

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib/ test/
```

### iOS-Specific Build System

The project includes a comprehensive iOS build and test infrastructure:

- **Build Scripts**: Located in `scripts/` directory
  - `build_ios.sh` - Build iOS app
  - `build_test_ios.sh` - Build and run tests
  - `test_ios.sh` - Run iOS tests
  - `setup_ios_emulator.sh` - Configure iOS emulator
  - `cleanup_ios_emulator.sh` - Clean up emulator resources

- **iOS Build Services**: Located in `lib/services/ios_build/`
  - Build management and orchestration
  - Emulator management
  - Test execution and reporting
  - Build caching and resource cleanup
  - Multi-version test coordination

- **Documentation**: See `docs/iOS_*.md` for detailed iOS build/test guides

## Code Quality

- **Linting**: Configured via `analysis_options.yaml` with flutter_lints
- **Code Style**: Follow Dart conventions and Flutter best practices
- **Formatting**: Use `dart format` for consistent code style

## Testing

- **Unit Tests**: Located in `test/` directory, mirror `lib/` structure
- **Integration Tests**: Feature-level integration tests in `test/features/`
- **Test Execution**: `flutter test` or platform-specific scripts

## Platforms & Emulators

- **iOS**: Xcode simulator (primary focus)
- **Android**: Android emulator
- **Web**: Chrome/Firefox
- **Desktop**: Native runners (macOS, Linux, Windows)
