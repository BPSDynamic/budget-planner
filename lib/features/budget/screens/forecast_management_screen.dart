import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/forecast.dart';
import '../../transactions/providers/budget_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/theme/app_colors.dart';

class ForecastManagementScreen extends StatefulWidget {
  const ForecastManagementScreen({super.key});

  @override
  State<ForecastManagementScreen> createState() =>
      _ForecastManagementScreenState();
}

class _ForecastManagementScreenState extends State<ForecastManagementScreen> {
  late BudgetProvider _budgetProvider;

  @override
  void initState() {
    super.initState();
    _budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
  }

  void _showAddForecastDialog() {
    final periodController = TextEditingController();
    final categoryController = TextEditingController();
    final amountController = TextEditingController();
    final assumptionsController = TextEditingController();
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Forecast'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: periodController,
                decoration: const InputDecoration(
                  labelText: 'Period (YYYY-MM)',
                  hintText: 'e.g., 2025-01',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g., Groceries',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Projected Amount',
                  hintText: 'e.g., 500',
                  prefixText: '${settingsProvider.currency} ',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: assumptionsController,
                decoration: const InputDecoration(
                  labelText: 'Assumptions',
                  hintText: 'e.g., Based on last 3 months average',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (periodController.text.isEmpty ||
                  categoryController.text.isEmpty ||
                  amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                  ),
                );
                return;
              }

              try {
                final amount = double.parse(amountController.text);
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Projected amount must be positive'),
                    ),
                  );
                  return;
                }

                // Validate period format
                if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(periodController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Period must be in YYYY-MM format'),
                    ),
                  );
                  return;
                }

                // Validate period is in future or current month
                final parts = periodController.text.split('-');
                final year = int.parse(parts[0]);
                final month = int.parse(parts[1]);
                final forecastDate = DateTime(year, month, 1);
                final now = DateTime.now();
                final currentMonth = DateTime(now.year, now.month, 1);

                if (forecastDate.isBefore(currentMonth)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forecast period must be in the future'),
                    ),
                  );
                  return;
                }

                final forecast = Forecast(
                  period: periodController.text,
                  category: categoryController.text,
                  projectedAmount: amount,
                  assumptions: assumptionsController.text,
                );

                _budgetProvider.addForecast(forecast);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Forecast added successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditForecastDialog(Forecast forecast) {
    final periodController = TextEditingController(text: forecast.period);
    final categoryController = TextEditingController(text: forecast.category);
    final amountController =
        TextEditingController(text: forecast.projectedAmount.toString());
    final assumptionsController =
        TextEditingController(text: forecast.assumptions);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Forecast'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: periodController,
                decoration: const InputDecoration(
                  labelText: 'Period (YYYY-MM)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Projected Amount',
                  prefixText: '${settingsProvider.currency} ',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: assumptionsController,
                decoration: const InputDecoration(
                  labelText: 'Assumptions',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (periodController.text.isEmpty ||
                  categoryController.text.isEmpty ||
                  amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                  ),
                );
                return;
              }

              try {
                final amount = double.parse(amountController.text);
                if (amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Projected amount must be positive'),
                    ),
                  );
                  return;
                }

                // Validate period format
                if (!RegExp(r'^\d{4}-\d{2}$').hasMatch(periodController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Period must be in YYYY-MM format'),
                    ),
                  );
                  return;
                }

                // Validate period is in future or current month
                final parts = periodController.text.split('-');
                final year = int.parse(parts[0]);
                final month = int.parse(parts[1]);
                final forecastDate = DateTime(year, month, 1);
                final now = DateTime.now();
                final currentMonth = DateTime(now.year, now.month, 1);

                if (forecastDate.isBefore(currentMonth)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Forecast period must be in the future'),
                    ),
                  );
                  return;
                }

                final updatedForecast = Forecast(
                  id: forecast.id,
                  period: periodController.text,
                  category: categoryController.text,
                  projectedAmount: amount,
                  assumptions: assumptionsController.text,
                  createdDate: forecast.createdDate,
                );

                // Update in provider
                _budgetProvider.deleteForecast(forecast.id);
                _budgetProvider.addForecast(updatedForecast);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Forecast updated successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Forecast forecast) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Forecast'),
        content: Text(
          'Are you sure you want to delete the forecast for ${forecast.category} in ${forecast.period}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _budgetProvider.deleteForecast(forecast.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Forecast deleted successfully')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Map<String, List<Forecast>> _groupForecastsByPeriod(
      List<Forecast> forecasts) {
    final grouped = <String, List<Forecast>>{};
    for (final forecast in forecasts) {
      if (!grouped.containsKey(forecast.period)) {
        grouped[forecast.period] = [];
      }
      grouped[forecast.period]!.add(forecast);
    }
    // Sort by period in descending order
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final sortedMap = <String, List<Forecast>>{};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }
    return sortedMap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forecast Management'),
        elevation: 0,
      ),
      body: Consumer<BudgetProvider>(
        builder: (context, budgetProvider, _) {
          if (budgetProvider.forecasts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No forecasts yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a forecast to get started',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            );
          }

          final groupedForecasts =
              _groupForecastsByPeriod(budgetProvider.forecasts);

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedForecasts.length,
            itemBuilder: (context, periodIndex) {
              final period = groupedForecasts.keys.elementAt(periodIndex);
              final forecastsForPeriod = groupedForecasts[period]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      period,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                  ...forecastsForPeriod.map((forecast) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        forecast.category,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Consumer<SettingsProvider>(
                                          builder: (context, settingsProvider, _) => Text(
                                            '${settingsProvider.currency} ${forecast.projectedAmount.toStringAsFixed(2)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Edit'),
                                      onTap: () =>
                                          _showEditForecastDialog(forecast),
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Delete'),
                                      onTap: () =>
                                          _showDeleteConfirmation(forecast),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (forecast.assumptions.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Assumptions',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      forecast.assumptions,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddForecastDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
