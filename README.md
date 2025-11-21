# Budget Planner

A comprehensive personal finance management application built with Flutter, designed to help users track expenses, manage budgets, and analyze spending patterns across multiple platforms.

## Overview

Budget Planner is a feature-rich mobile and web application that enables users to:
- Track income and expenses with detailed categorization
- Create and manage budget categories with monthly limits
- Capture and process receipts via OCR technology
- Analyze spending trends with interactive charts and reports
- View multi-year budget performance and forecasts
- Customize settings including currency, language, and theme preferences

## Supported Platforms

- **iOS** (primary focus with dedicated build infrastructure)
- **Android**
- **Web**
- **macOS**
- **Linux**
- **Windows**

## Tech Stack

### Framework & Language
- **Framework**: Flutter (Dart SDK ^3.9.2)
- **Language**: Dart
- **UI Framework**: Material Design 3
- **State Management**: Provider (^6.1.5+1)

### Key Dependencies
- **UI & Fonts**: google_fonts (^6.3.2), cupertino_icons (^1.0.8)
- **Internationalization**: intl (^0.20.2)
- **Charts**: fl_chart (^1.1.1)
- **Storage**: shared_preferences (^2.5.3)
- **Utilities**: uuid (^4.5.2), image_picker (^1.1.2)

### Development Dependencies
- **Testing**: flutter_test (SDK), test (^1.25.0)
- **Linting**: flutter_lints (^5.0.0)

## Project Structure

```
budget_planner/
├── lib/                          # Main application code
│   ├── main.dart                 # App entry point with MultiProvider setup
│   ├── core/                     # Core utilities and theme
│   │   ├── constants/            # App-wide constants
│   │   ├── theme/               # Theme configuration
│   │   └── utils/               # Utility functions
│   ├── features/                # Feature modules (clean architecture)
│   │   ├── auth/                # Authentication
│   │   ├── home/                # Main navigation
│   │   ├── dashboard/           # Dashboard overview
│   │   ├── transactions/        # Transaction management
│   │   ├── budget/              # Budget management & analytics
│   │   ├── receipt/             # Receipt scanning & OCR
│   │   ├── analytics/           # Analytics & reporting
│   │   └── settings/            # User settings & preferences
│   ├── services/                # Platform-specific services
│   │   └── ios_build/           # iOS build/test orchestration
│   └── ui/                      # Shared UI components
├── test/                        # Test files
├── scripts/                     # Build and utility scripts
├── docs/                        # Documentation
└── pubspec.yaml                 # Flutter dependencies
```

## Getting Started

### Prerequisites
- Flutter SDK ^3.9.2
- Dart SDK ^3.9.2
- Xcode (for iOS development)
- Android Studio (for Android development)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd budget_planner
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Running on Specific Platforms

**iOS:**
```bash
flutter run -d "iPhone Simulator"
```

**Android:**
```bash
flutter run -d emulator-5554
```

**Web:**
```bash
flutter run -d chrome
```

## Features

### 1. Transaction Management
- Record income and expenses
- Categorize transactions
- View transaction history
- Edit and delete transactions

### 2. Budget Management
- Create budget categories
- Set monthly limits
- Track spending against budgets
- View budget performance

### 3. Receipt Scanning
- Capture receipts via camera
- OCR processing for automatic data extraction
- Manual entry option
- Receipt storage and retrieval

### 4. Analytics & Reporting
- Interactive spending charts
- Monthly and yearly comparisons
- Spending trends analysis
- Budget forecasting

### 5. Multi-Year Dashboard
- Year-over-year budget comparison
- Historical spending analysis
- Performance metrics

### 6. Settings & Personalization
- Currency selection (USD, EUR, GBP, etc.)
- Language preferences (English, Spanish, French, etc.)
- Dark/Light theme support
- Notification preferences

## Architecture

The app follows clean architecture principles with feature-based organization:

### Feature Structure
Each feature module contains:
- **models/**: Data models with serialization
- **providers/**: State management using Provider pattern
- **screens/**: UI screens and pages
- **services/**: Business logic and data operations
- **widgets/**: Feature-specific reusable components

### State Management
- Uses Provider pattern with ChangeNotifier
- Centralized state in SettingsProvider
- Reactive updates across the app
- Local persistence via SharedPreferences

### Data Persistence
- SharedPreferences for local storage
- JSON serialization/deserialization
- Automatic persistence on state changes

## Testing

### Unit Tests
Located in `test/` directory, mirroring `lib/` structure:
```bash
flutter test
```

### Widget Tests
Test UI components and interactions:
```bash
flutter test test/features/auth/screens/login_screen_test.dart
```

### Integration Tests
Feature-level integration tests:
```bash
flutter test test/features/settings/integration_test.dart
```

## Build & Deployment

### iOS Build
```bash
flutter build ios --release
```

### Android Build
```bash
flutter build appbundle --release
```

### Web Build
```bash
flutter build web --release
```

### iOS-Specific Build Infrastructure
The project includes comprehensive iOS build services in `lib/services/ios_build/`:
- Build management and orchestration
- Emulator management
- Test execution and reporting
- Build caching and resource cleanup

See `docs/iOS_BUILD_SYSTEM_README.md` for detailed iOS build documentation.

## Code Quality

### Linting
```bash
flutter analyze
```

### Code Formatting
```bash
dart format lib/ test/
```

### Linting Configuration
Configured via `analysis_options.yaml` with flutter_lints

## Documentation

- [iOS Build System](docs/iOS_BUILD_SYSTEM_README.md) - Comprehensive iOS build infrastructure
- [iOS Emulator Guide](docs/iOS_EMULATOR_BUILD_TEST_GUIDE.md) - iOS emulator setup and testing
- [iOS Troubleshooting](docs/iOS_EMULATOR_TROUBLESHOOTING.md) - Common iOS issues and solutions
- [iOS Quick Reference](docs/iOS_EMULATOR_QUICK_REFERENCE.md) - Quick reference for iOS commands

## Contributing

1. Follow the project structure and naming conventions
2. Ensure all code passes linting and formatting checks
3. Write tests for new features
4. Update documentation as needed
5. Follow Material Design 3 guidelines for UI

## License

[Add your license information here]

## Support

For issues, questions, or suggestions, please open an issue in the repository.
