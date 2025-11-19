import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../transactions/providers/budget_provider.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  final List<String> currencies = const ['\$', '€', '£', '¥', 'R', '₹'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, 'General'),
          _buildCurrencyTile(context),
          const Divider(),
          _buildSectionHeader(context, 'Appearance'),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.dark_mode_outlined, color: Colors.orange),
            ),
            title: const Text('Theme'),
            subtitle: const Text('Light Mode (Forced)'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dark mode is currently disabled for better visibility.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildCurrencyTile(BuildContext context) {
    return Consumer<BudgetProvider>(
      builder: (context, provider, child) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.attach_money, color: AppColors.primary),
          ),
          title: const Text('Currency'),
          subtitle: Text('Current: ${provider.currency}'),
          trailing: DropdownButton<String>(
            value: currencies.contains(provider.currency) ? provider.currency : currencies.first,
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                provider.setCurrency(newValue);
              }
            },
            items: currencies.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
