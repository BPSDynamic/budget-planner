import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class BudgetProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  String _currency = '\$'; // Default currency
  
  List<Transaction> get transactions => _transactions;
  String get currency => _currency;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  BudgetProvider() {
    _loadData();
  }

  void addTransaction(Transaction transaction) {
    _transactions.insert(0, transaction);
    _saveTransactions();
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveTransactions();
    notifyListeners();
  }

  void setCurrency(String newCurrency) {
    _currency = newCurrency;
    _saveCurrency();
    notifyListeners();
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      _transactions.map((t) => t.toMap()).toList(),
    );
    await prefs.setString('transactions', encodedList);
  }

  Future<void> _saveCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', _currency);
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsString = prefs.getString('transactions');
    final String? savedCurrency = prefs.getString('currency');
    
    if (savedCurrency != null) {
      _currency = savedCurrency;
    }

    if (transactionsString != null) {
      final List<dynamic> decodedList = jsonDecode(transactionsString);
      _transactions = decodedList
          .map((item) => Transaction.fromMap(item))
          .toList();
    }
    notifyListeners();
  }
}
