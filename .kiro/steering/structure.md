# Project Structure & Architecture

## Directory Organization

```
budget_planner/
├── lib/                          # Main application code
│   ├── main.dart                 # App entry point with MultiProvider setup
│   ├── core/                     # Core utilities and theme
│   │   ├── constants/            # App-wide constants
│   │   ├── theme/               # Theme configuration (colors, styles)
│   │   └── utils/               # Utility functions
│   ├── features/                # Feature modules (clean architecture)
│   │   ├── auth/                # Authentication feature
│   │   ├── home/                # Home/main navigation
│   │   ├── dashboard/           # Dashboard overview
│   │   ├── transactions/        # Transaction management
│   │   ├── budget/              # Budget management & analytics
│   │   ├── receipt/             # Receipt scanning & OCR
│   │   ├── analytics/           # Analytics & reporting
│   │   └── settings/            # User settings & preferences
│   ├── services/                # Platform-specific services
│   │   └── ios_build/           # iOS build/test orchestration
│   └── ui/                      # Shared UI components
├── test/                        # Test files (mirror lib/ structure)
│   ├── features/                # Feature integration tests
│   ├── services/                # Service tests
│   └── widget_test.dart         # Basic widget tests
├── scripts/                     # Build and utility scripts
│   ├── build_ios.sh
│   ├── build_test_ios.sh
│   ├── test_ios.sh
│   ├── setup_ios_emulator.sh
│   └── cleanup_ios_emulator.sh
├── docs/                        # Documentation
│   ├── iOS_BUILD_SYSTEM_README.md
│   ├── iOS_EMULATOR_BUILD_TEST_GUIDE.md
│   ├── iOS_EMULATOR_QUICK_REFERENCE.md
│   └── iOS_EMULATOR_TROUBLESHOOTING.md
├── design-reference/            # Design system reference (React/TypeScript)
├── android/                     # Android native code
├── ios/                         # iOS native code
├── macos/                       # macOS native code
├── linux/                       # Linux native code
├── windows/                     # Windows native code
├── web/                         # Web platform code
├── pubspec.yaml                 # Flutter dependencies
├── analysis_options.yaml        # Dart linting rules
└── .kiro/                       # Kiro configuration
    ├── specs/                   # Feature specifications
    └── steering/                # Steering rules (this directory)
```

## Feature Architecture Pattern

Each feature follows a consistent structure:

```
features/[feature_name]/
├── models/              # Data models (with toMap/fromMap for serialization)
├── providers/           # State management (ChangeNotifier providers)
├── screens/             # UI screens/pages
├── services/            # Business logic and data operations
└── widgets/             # Feature-specific reusable widgets
```

### Example: Budget Feature

```
features/budget/
├── models/
│   ├── budget_category.dart
│   ├── forecast.dart
│   ├── historical_summary.dart
│   ├── aggregated_data.dart
│   └── index.dart
├── providers/           # (empty - uses services)
├── screens/
│   ├── budget_category_screen.dart
│   ├── forecast_management_screen.dart
│   ├── historical_view_screen.dart
│   └── multi_year_dashboard_screen.dart
├── services/
│   ├── budget_category_manager.dart
│   ├── forecast_manager.dart
│   ├── historical_data_manager.dart
│   ├── data_aggregator.dart
│   └── serialization_service.dart
└── widgets/             # (if needed)
```

## State Management Pattern

- **Provider Pattern**: Use `ChangeNotifier` with `Provider` for state management
- **Location**: Providers in `features/[feature]/providers/`
- **Initialization**: Set up in `main.dart` with `MultiProvider`
- **Dependencies**: Use `ProxyProvider` for provider dependencies

## Data Persistence

- **Storage**: SharedPreferences for local data
- **Serialization**: Models implement `toMap()` and `fromMap()` methods
- **Services**: Dedicated serialization services handle JSON encoding/decoding

## Code Conventions

### Naming
- **Classes**: PascalCase (e.g., `BudgetCategory`, `SettingsProvider`)
- **Files**: snake_case (e.g., `budget_category.dart`, `settings_provider.dart`)
- **Variables/Methods**: camelCase (e.g., `monthlyLimit`, `getUserProfile()`)
- **Constants**: camelCase (e.g., `defaultCurrency`)

### Model Structure
- Include `id` field (UUID generated if not provided)
- Include `createdDate` timestamp
- Implement `toMap()` and `fromMap()` for serialization
- Implement `==` operator and `hashCode` for equality
- Use `copyWith()` for immutable updates

### Provider Structure
- Extend `ChangeNotifier`
- Use private fields with public getters
- Call `notifyListeners()` after state changes
- Implement async methods for persistence operations

### Testing
- Unit tests mirror source structure: `test/features/[feature]/`
- Integration tests in `test/features/[feature]/integration_test.dart`
- Test files follow naming: `[source_file]_test.dart`

## iOS Build Infrastructure

The project includes specialized iOS build services in `lib/services/ios_build/`:

- **Models**: Build/test configurations and results
- **Managers**: Emulator, build, test, and resource management
- **Orchestrators**: Coordinate multi-step build/test workflows
- **Utilities**: Caching, reporting, CLI command execution

See `docs/iOS_*.md` for detailed iOS-specific documentation.
