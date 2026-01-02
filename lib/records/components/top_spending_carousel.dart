import 'package:flutter/material.dart';
import 'package:pocket_guard/helpers/records-utility-functions.dart';
import 'package:pocket_guard/models/record.dart';

import '../../i18n.dart';

class TopSpendingCarousel extends StatelessWidget {
  final List<Record?> passedRecords;

  const TopSpendingCarousel({super.key, required this.passedRecords});

  final _subtitleFont = const TextStyle(fontSize: 13.0);

  @override
  Widget build(BuildContext context) {
    final topCategories = getTopCategories(passedRecords);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            "Top Spending".i18n,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 0.1,
            ),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: topCategories.length,
            itemBuilder: (context, index) {
              final category = topCategories.keys.elementAt(index);
              final totalSpent = topCategories.values.elementAt(index);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    // Placeholder for your Category Icon/Emoji logic
                    Icon(category.icon, size: 16, color: category.color),
                    const SizedBox(width: 8),
                    Text(
                      category.name ?? "",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      getCurrencyValueString(totalSpent),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
