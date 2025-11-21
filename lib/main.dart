import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/transactions/providers/budget_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/settings/providers/theme_provider.dart';
import 'features/settings/providers/language_provider.dart';
import 'features/home/screens/main_screen.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const BudgetPlannerApp());
}

class BudgetPlannerApp extends StatelessWidget {
  const BudgetPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        // BudgetProvider depends on SettingsProvider, so create it after
        ChangeNotifierProvider(
          create: (context) {
            final budgetProvider = BudgetProvider();
            final settingsProvider = context.read<SettingsProvider>();
            budgetProvider.initializeWithSettings(settingsProvider);
            return budgetProvider;
          },
        ),
      ],
      child: Consumer4<ThemeProvider, LanguageProvider, SettingsProvider, BudgetProvider>(
        builder: (context, themeProvider, languageProvider, settingsProvider, budgetProvider, _) {
          // Determine home screen based on user profile
          final isLoggedIn = settingsProvider.userProfile != null;
          
          return MaterialApp(
            title: 'Budget Planner',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: Locale(languageProvider.currentLanguage.toLowerCase()),
            home: isLoggedIn ? const MainScreen() : const LoginScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
