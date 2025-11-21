import 'package:budget_planner/features/budget/models/forecast.dart';

class ForecastManager {
  final List<Forecast> _forecasts = [];

  /// Creates a new forecast entry
  /// Validates that amount is positive and period is in the future
  /// Returns the created forecast
  Forecast createForecast({
    required String period,
    required String category,
    required double amount,
    required String assumptions,
  }) {
    validateForecast(
      period: period,
      amount: amount,
    );

    final forecast = Forecast(
      period: period,
      category: category,
      projectedAmount: amount,
      assumptions: assumptions,
    );

    _forecasts.add(forecast);
    return forecast;
  }

  /// Validates forecast data
  /// Throws ArgumentError if validation fails
  void validateForecast({
    required String period,
    required double amount,
  }) {
    // Validate amount is positive
    if (amount <= 0) {
      throw ArgumentError('Projected amount must be positive');
    }

    // Validate period format (YYYY-MM)
    if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(period)) {
      throw ArgumentError('Period must be in YYYY-MM format');
    }

    // Parse period and validate it's in the future or current month
    try {
      final parts = period.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);

      final forecastDate = DateTime(year, month, 1);
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month, 1);

      if (forecastDate.isBefore(currentMonth)) {
        throw ArgumentError('Forecast period must be in the future');
      }
    } catch (e) {
      if (e is ArgumentError) {
        rethrow;
      }
      throw ArgumentError('Invalid period format');
    }
  }

  /// Deletes a forecast by ID
  /// Returns true if deleted, false if not found
  bool deleteForecast(String forecastId) {
    final index = _forecasts.indexWhere((f) => f.id == forecastId);
    if (index == -1) {
      return false;
    }

    _forecasts.removeAt(index);
    return true;
  }

  /// Gets all forecasts for a specific period
  /// Period format: YYYY-MM
  List<Forecast> getForecastsByPeriod(String period) {
    return _forecasts
        .where((forecast) => forecast.period == period)
        .toList();
  }

  /// Gets all forecasts for a specific category
  List<Forecast> getForecastsByCategory(String category) {
    return _forecasts
        .where((forecast) => forecast.category == category)
        .toList();
  }

  /// Gets all forecasts
  List<Forecast> getAllForecasts() {
    return List.unmodifiable(_forecasts);
  }

  /// Gets a specific forecast by ID
  Forecast? getForecastById(String forecastId) {
    try {
      return _forecasts.firstWhere((f) => f.id == forecastId);
    } catch (e) {
      return null;
    }
  }

  /// Clears all forecasts
  void clear() {
    _forecasts.clear();
  }

  /// Gets the count of forecasts
  int get forecastCount => _forecasts.length;
}
