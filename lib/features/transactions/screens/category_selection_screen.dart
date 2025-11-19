import 'package:flutter/material.dart';

class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  final List<Map<String, dynamic>> categories = const [
    {'icon': Icons.add, 'label': 'Add', 'color': Colors.purple},
    {'icon': Icons.shopping_bag, 'label': 'Groceries', 'color': Colors.green},
    {'icon': Icons.flight, 'label': 'Travel', 'color': Colors.blue},
    {'icon': Icons.directions_car, 'label': 'Car', 'color': Colors.orange},
    {'icon': Icons.home, 'label': 'Home', 'color': Colors.pink},
    {'icon': Icons.security, 'label': 'Insurances', 'color': Colors.teal},
    {'icon': Icons.school, 'label': 'Education', 'color': Colors.indigo},
    {'icon': Icons.campaign, 'label': 'Marketing', 'color': Colors.amber},
    {'icon': Icons.shopping_cart, 'label': 'Shopping', 'color': Colors.green},
    {'icon': Icons.wifi, 'label': 'Internet', 'color': Colors.blue},
    {'icon': Icons.water_drop, 'label': 'Water', 'color': Colors.cyan},
    {'icon': Icons.key, 'label': 'Rent', 'color': Colors.brown},
    {'icon': Icons.fitness_center, 'label': 'Gym', 'color': Colors.orange},
    {'icon': Icons.subscriptions, 'label': 'Subscription', 'color': Colors.purple},
    {'icon': Icons.beach_access, 'label': 'Vacation', 'color': Colors.green},
    {'icon': Icons.more_horiz, 'label': 'Other', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Select Category'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search for Categories',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return InkWell(
                  onTap: () {
                    Navigator.pop(context, category['label']);
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: category['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category['label'] as String,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
