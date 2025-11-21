import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../../budget/models/budget_category.dart';
import '../../budget/models/forecast.dart';
import '../../budget/models/aggregated_data.dart';
import '../../budget/services/serialization_service.dart';
import '../../budget/services/data_aggregator.dart';
import '../../settings/providers/settings_provider.dart';

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory DateRange.fromMap(Map<String, dynamic> map) {
    return DateRange(
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}

class BudgetProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  List<BudgetCategory> _categories = [];
  List<Forecast> _forecasts = [];
  DateRange? _dateRangePreference;
  AggregatedData? _aggregatedData;
  SettingsProvider? _settingsProvider;
  String _currency = 'USD'; // Default currency

  final SerializationService _serializationService = SerializationService();
  final DataAggregator _dataAggregator = DataAggregator();

  List<Transaction> get transactions => _transactions;
  List<BudgetCategory> get categories => _categories;
  List<Forecast> get forecasts => _forecasts;
  DateRange? get dateRangePreference => _dateRangePreference;
  AggregatedData? get aggregatedData => _aggregatedData;
  
  /// Get currency from SettingsProvider if available, otherwise use local currency
  String get currency {
    if (_settingsProvider != null) {
      return _settingsProvider!.currency;
    }
    return _currency;
  }

  /// Get currency symbol for display
  String getCurrencySymbol() {
    return currency;
  }

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  BudgetProvider() {
    _initializeData();
  }

  /// Initialize BudgetProvider with SettingsProvider reference
  /// Call this from a context where SettingsProvider is available
  void initializeWithSettings(SettingsProvider settingsProvider) {
    _settingsProvider = settingsProvider;
    // Listen to settings changes
    _settingsProvider!.addListener(_onSettingsChanged);
    notifyListeners();
  }

  void _onSettingsChanged() {
    // Notify listeners when settings (including currency) change
    notifyListeners();
  }

  void _initializeData() {
    try {
      _loadData();
    } catch (e) {
      // Silently handle initialization errors
    }
  }

  // Transaction methods
  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    _saveData();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  // Category methods
  void addCategory(BudgetCategory category) {
    _categories.add(category);
    _saveData();
    notifyListeners();
  }

  void deleteCategory(String categoryId) {
    _categories.removeWhere((cat) => cat.id == categoryId);
    _saveData();
    notifyListeners();
  }

  // Forecast methods
  void addForecast(Forecast forecast) {
    _forecasts.add(forecast);
    _saveData();
    notifyListeners();
  }

  void deleteForecast(String forecastId) {
    _forecasts.removeWhere((f) => f.id == forecastId);
    _saveData();
    notifyListeners();
  }

  // Date range preference methods
  void setDateRangePreference(DateTime startDate, DateTime endDate) {
    _dateRangePreference = DateRange(
      startDate: startDate,
      endDate: endDate,
    );
    _saveData();
    notifyListeners();
  }

  DateRange? getDateRangePreference() {
    return _dateRangePreference;
  }

  /// Set currency locally (for backward compatibility)
  /// Prefer using SettingsProvider.setCurrency() instead
  void setCurrency(String newCurrency) {
    _currency = newCurrency;
    _saveData();
    notifyListeners();
  }

  // Aggregation methods
  AggregatedData? getAggregatedDataForPeriod(DateTime startDate, DateTime endDate) {
    final monthlyData = _dataAggregator.aggregateByMonth(_transactions);

    double totalIncome = 0;
    double totalExpense = 0;
    final Map<String, double> categoryTotals = {};

    for (final transaction in _transactions) {
      if (transaction.date.isAfter(startDate) &&
          transaction.date.isBefore(endDate.add(Duration(days: 1)))) {
        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }

        categoryTotals[transaction.category] =
            (categoryTotals[transaction.category] ?? 0) + transaction.amount;
      }
    }

    _aggregatedData = AggregatedData(
      period: '${startDate.year}-${startDate.month.toString().padLeft(2, '0')} to ${endDate.year}-${endDate.month.toString().padLeft(2, '0')}',
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      byCategory: categoryTotals,
      byMonth: monthlyData,
    );

    return _aggregatedData;
  }

  Map<String, AggregatedData> getMonthlyBreakdown(int year) {
    final monthlyData = _dataAggregator.aggregateByMonth(_transactions);

    final result = <String, AggregatedData>{};
    monthlyData.forEach((monthKey, data) {
      final parts = monthKey.split('-');
      if (int.parse(parts[0]) == year) {
        result[monthKey] = data;
      }
    });

    return result;
  }

  Map<String, double> getCategoryTotals(String period) {
    return _dataAggregator.aggregateByCategory(_transactions, period);
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save transactions
    final String encodedTransactions = jsonEncode(
      _transactions.map((t) => t.toMap()).toList(),
    );
    await prefs.setString('transactions', encodedTransactions);

    // Save categories
    final String encodedCategories =
        _serializationService.serializeBudgetData(_categories);
    await prefs.setString('categories', encodedCategories);

    // Save forecasts
    final String encodedForecasts =
        _serializationService.serializeForecasts(_forecasts);
    await prefs.setString('forecasts', encodedForecasts);

    // Save date range preference
    if (_dateRangePreference != null) {
      final String encodedDateRange =
          jsonEncode(_dateRangePreference!.toMap());
      await prefs.setString('dateRangePreference', encodedDateRange);
    }

    // Save currency locally for backward compatibility
    await prefs.setString('currency', _currency);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load transactions
    final String? transactionsString = prefs.getString('transactions');
    if (transactionsString != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(transactionsString);
        _transactions = decodedList
            .map((item) => Transaction.fromMap(item))
            .toList();
      } catch (e) {
        // Handle error silently
        _transactions = [];
      }
    }

    // Load categories
    final String? categoriesString = prefs.getString('categories');
    if (categoriesString != null) {
      try {
        _categories = _serializationService.deserializeBudgetData(categoriesString);
      } catch (e) {
        // Handle error silently
        _categories = [];
      }
    }

    // Load forecasts
    final String? forecastsString = prefs.getString('forecasts');
    if (forecastsString != null) {
      try {
        _forecasts = _serializationService.deserializeForecasts(forecastsString);
      } catch (e) {
        // Handle error silently
        _forecasts = [];
      }
    }

    // Load date range preference
    final String? dateRangeString = prefs.getString('dateRangePreference');
    if (dateRangeString != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(dateRangeString);
        _dateRangePreference = DateRange.fromMap(decoded);
      } catch (e) {
        // Handle error silently
        _dateRangePreference = null;
      }
    }

    // Load currency
    final String? savedCurrency = prefs.getString('currency');
    if (savedCurrency != null) {
      _currency = savedCurrency;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up listener when provider is disposed
    if (_settingsProvider != null) {
      _settingsProvider!.removeListener(_onSettingsChanged);
    }
    super.dispose();
  }
}
