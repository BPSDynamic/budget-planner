# Getting Started with Budget Planner

This guide will help you set up and run the Budget Planner application on your development machine.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version ^3.9.2
- **Dart SDK**: Version ^3.9.2 (included with Flutter)
- **Git**: For version control
- **Xcode**: For iOS development (macOS only)
- **Android Studio**: For Android development
- **VS Code or Android Studio**: As your IDE

### System Requirements

- **macOS**: 10.15 or later
- **iOS**: 11.0 or later
- **Android**: API level 21 or later
- **Web**: Modern browser (Chrome, Firefox, Safari, Edge)

## Installation Steps

### 1. Install Flutter

Follow the official Flutter installation guide for your operating system:
- [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

Verify installation:
```bash
flutter --version
dart --version
```

### 2. Clone the Repository

```bash
git clone <repository-url>
cd budget_planner
```

### 3. Get Dependencies

```bash
flutter pub get
```

This will download all required packages listed in `pubspec.yaml`.

### 4. Verify Setup

Run the analyzer to check for any issues:
```bash
flutter analyze
```

## Running the App

### Run on Default Device

```bash
flutter run
```

Flutter will automatically detect and run on the connected device or emulator.

### Run on Specific Platform

**iOS Simulator:**
```bash
flutter run -d "iPhone 15"
```

**Android Emulator:**
```bash
flutter run -d emulator-5554
```

**Web (Chrome):**
```bash
flutter run -d chrome
```

**macOS:**
```bash
flutter run -d macos
```

### Run in Release Mode

For better performance:
```bash
flutter run --release
```

## Development Workflow

### Code Formatting

Keep code consistent with the project style:
```bash
dart format lib/ test/
```

### Running Tests

Execute all tests:
```bash
flutter test
```

Run specific test file:
```bash
flutter test test/features/auth/screens/login_screen_test.dart
```

Run tests with coverage:
```bash
flutter test --coverage
```

### Code Analysis

Check for linting issues:
```bash
flutter analyze
```

Fix common issues automatically:
```bash
dart fix --apply
```

## Project Structure Overview

```
lib/
├── main.dart                 # App entry point
├── core/
│   ├── constants/           # App constants
│   ├── theme/              # Theme configuration
│   └── utils/              # Utility functions
├── features/               # Feature modules
│   ├── auth/              # Authentication
│   ├── home/              # Home screen
│   ├── dashboard/         # Dashboard
│   ├── transactions/      # Transactions
│   ├── budget/            # Budget management
│   ├── receipt/           # Receipt scanning
│   ├── analytics/         # Analytics
│   └── settings/          # Settings
├── services/              # Services
│   └── ios_build/        # iOS build services
└── ui/                    # Shared UI components
```

## Feature Overview

### Authentication
- Login with email/password
- Social login (Google, Facebook)
- User profile management

### Dashboard
- Monthly spending overview
- Budget status
- Recent transactions
- Income summary

### Transactions
- Add/edit/delete transactions
- Categorize expenses
- View transaction history
- Filter by category and date

### Budget Management
- Create budget categories
- Set monthly limits
- Track spending
- View budget performance

### Receipt Scanning
- Capture receipts via camera
- OCR processing
- Manual entry
- Receipt storage

### Analytics
- Spending charts
- Trend analysis
- Monthly comparisons
- Forecasting

### Settings
- Currency selection
- Language preferences
- Theme (dark/light)
- Notification settings

## Troubleshooting

### Common Issues

**Issue: "Flutter command not found"**
- Solution: Add Flutter to your PATH. See [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

**Issue: "No devices found"**
- Solution: Start an emulator or connect a physical device
- iOS: `open -a Simulator`
- Android: Open Android Studio and start an emulator

**Issue: "Gradle build failed"**
- Solution: Run `flutter clean` then `flutter pub get`

**Issue: "Pod install failed" (iOS)**
- Solution: Run `cd ios && pod repo update && pod install && cd ..`

### Getting Help

- Check the [Flutter Documentation](https://flutter.dev/docs)
- Review [iOS Build System Documentation](iOS_BUILD_SYSTEM_README.md)
- Check [iOS Troubleshooting Guide](iOS_EMULATOR_TROUBLESHOOTING.md)

## Next Steps

1. Explore the codebase structure
2. Read the [Architecture Guide](ARCHITECTURE.md)
3. Review the [Feature Documentation](FEATURES.md)
4. Check out the [Testing Guide](TESTING.md)
5. Start developing features

## Development Tips

- Use `flutter run -v` for verbose output when debugging
- Use `flutter devices` to list available devices
- Use `flutter logs` to view app logs
- Use `flutter attach` to attach to a running app
- Use `flutter pub upgrade` to update dependencies

## Building for Production

See the [Build Guide](BUILD.md) for detailed instructions on building for production deployment.
