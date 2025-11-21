import 'package:flutter/material.dart';

class MultiYearDashboardScreen extends StatefulWidget {
  const MultiYearDashboardScreen({super.key});

  @override
  State<MultiYearDashboardScreen> createState() =>
      _MultiYearDashboardScreenState();
}

class _MultiYearDashboardScreenState extends State<MultiYearDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multi-Year Dashboard'),
      ),
      body: const Center(
        child: Text('Multi-Year Dashboard'),
      ),
    );
  }
}
