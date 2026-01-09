import 'package:flutter/material.dart';
import 'package:pocket_guard/helpers/records-utility-functions.dart';
import 'package:pocket_guard/statistics/aggregated-list-view.dart';
import 'package:pocket_guard/statistics/categories-piechart.dart';
import 'package:pocket_guard/statistics/category-summary-card.dart';
import 'package:pocket_guard/statistics/detailed-statistics-page.dart';
import 'package:pocket_guard/statistics/statistics-models.dart';
import 'package:pocket_guard/statistics/summary-models.dart';

import '../components/category_icon_circle.dart';
import '../i18n.dart';
import '../models/category.dart';
import '../models/record.dart';

class CategoriesSummaryCard extends StatefulWidget {
  final List<Record?> records;
  final AggregationMethod? aggregationMethod;
  final DateTime? from;
  final DateTime? to;

  const CategoriesSummaryCard(
    this.from,
    this.to,
    this.records,
    this.aggregationMethod, {
    super.key,
  });

  @override
  State<CategoriesSummaryCard> createState() => _CategoriesSummaryCardState();
}

class _CategoriesSummaryCardState extends State<CategoriesSummaryCard> {
  late List<CategorySumTuple> categoriesAndSums;
  double totalExpensesSum = 0;
  double maxExpensesSum = 0;
  final _biggerFont = const TextStyle(fontSize: 16.0);

  @override
  void initState() {
    super.initState();
    _calculateData();
  }

  @override
  void didUpdateWidget(CategoriesSummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records) {
      _calculateData();
    }
  }

  void _calculateData() {
    if (widget.records.isEmpty) {
      categoriesAndSums = [];
      totalExpensesSum = 0;
      maxExpensesSum = 0;
      return;
    }

    // Map to hold our accumulated totals
    final Map<Category, double> accumulationMap = {};
    double runningTotal = 0;

    for (var record in widget.records) {
      if (record == null || record.category == null) continue;

      final category = record.category!;
      final val = record.value ?? 0;

      runningTotal += val;

      // Update the double value in the map
      accumulationMap.update(
        category,
        (currentSum) => currentSum + val,
        ifAbsent: () => val,
      );
    }

    // Convert the map into your list of CategorySumTuple objects
    categoriesAndSums = accumulationMap.entries.map((entry) {
      return CategorySumTuple(entry.key, entry.value);
    }).toList();

    // Sort by absolute value descending
    categoriesAndSums.sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    totalExpensesSum = runningTotal;

    // Now that it's sorted, the first one is the max
    maxExpensesSum = categoriesAndSums.isNotEmpty
        ? categoriesAndSums[0].value.abs()
        : 0;
  }

  @override
  Widget build(BuildContext context) {
    return _buildCategoryStatsCard();
  }

  Widget _buildCategoryStatsCard() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Entries grouped by category".i18n,
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  getCurrencyValueString(totalExpensesSum),
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          new Divider(),
          CategoriesPieChart(widget.records),
          _buildCategoriesList(),
        ],
      ),
    );
  }

  Widget _buildCategoriesList() {
    return AggregatedListView<CategorySumTuple>(
      items: categoriesAndSums,
      itemBuilder: (context, categoryAndSum, i) {
        return _buildCategoryStatsRow(context, categoryAndSum);
      },
    );
  }

  Widget _buildCategoryStatsRow(
    BuildContext context,
    CategorySumTuple categoryAndSum,
  ) {
    // Memoize these calculations
    final double val = categoryAndSum.value ?? 0;
    final double percentage = totalExpensesSum == 0
        ? 0
        : (100 * val) / totalExpensesSum;
    final Category category = categoryAndSum.key!;
    double currentVal = categoryAndSum.value.abs();
    double maxVal = maxExpensesSum.abs();
    double percentageBar = maxVal > 0
        ? (currentVal / maxVal).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        ListTile(
          leading: CategoryIconCircle(
            iconEmoji: category.iconEmoji,
            iconDataFromDefaultIconSet: category.icon,
            backgroundColor: category.color,
            overlayIcon: category.isArchived ? Icons.archive : null,
          ),
          title: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      category.name!,
                      style: _biggerFont,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "${getCurrencyValueString(val.abs())} (${percentage.toStringAsFixed(1)}%)",
                    style: _biggerFont,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percentageBar,
                backgroundColor: Colors.grey.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  category.color ?? Colors.blue,
                ),
              ),
            ],
          ),
          onTap: () {
            final categoryRecords = widget.records
                .where((r) => r?.category?.name == category.name)
                .toList();

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailedStatisticPage(
                  widget.from,
                  widget.to,
                  categoryRecords,
                  widget.aggregationMethod,
                  detailedKey: category.name!,
                  // Ensure this card also uses our new optimized structure
                  summaryCard: CategorySummaryCard(
                    categoryRecords,
                    widget.aggregationMethod,
                  ),
                ),
              ),
            );
          },
        ),
        const Divider(),
      ],
    );
  }
}
