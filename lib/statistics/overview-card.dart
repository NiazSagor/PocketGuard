import 'package:flutter/material.dart';
import 'package:pocket_guard/models/record.dart';
import 'package:pocket_guard/statistics/statistics-models.dart';
import 'package:pocket_guard/statistics/statistics-utils.dart';

import '../helpers/records-utility-functions.dart';
import '../i18n.dart';

class OverviewCard extends StatefulWidget {
  final List<Record?> records;
  final AggregationMethod? aggregationMethod;
  final DateTime? from;
  final DateTime? to;

  const OverviewCard(
    this.from,
    this.to,
    this.records,
    this.aggregationMethod, {
    super.key,
  });

  @override
  State<OverviewCard> createState() => _OverviewCardState();
}

class _OverviewCardState extends State<OverviewCard> {
  final headerStyle = const TextStyle(fontSize: 13.0);

  final valueStyle = const TextStyle(fontSize: 18.0);

  final dateStyle = const TextStyle(fontSize: 24.0);

  late List<DateTimeSeriesRecord> aggregatedRecords;
  late double sumValues;
  late double averageValue;
  late double minAggregated;
  late double maxAggregated;

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  @override
  void didUpdateWidget(OverviewCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records ||
        oldWidget.aggregationMethod != widget.aggregationMethod) {
      _calculateStats();
    }
  }

  void _calculateStats() {
    final localRecords = List<Record?>.from(widget.records);

    aggregatedRecords = aggregateRecordsByDate(
      localRecords,
      widget.aggregationMethod,
    );

    sumValues = localRecords.fold(0.0, (acc, e) => acc + (e?.value ?? 0)).abs();

    if (aggregatedRecords.isNotEmpty) {
      final sortedAggregated = List<DateTimeSeriesRecord>.from(
        aggregatedRecords,
      )..sort((a, b) => a.value.abs().compareTo(b.value.abs()));

      minAggregated = sortedAggregated.first.value.abs();
      maxAggregated = sortedAggregated.last.value.abs();
      averageValue = sumValues / aggregatedRecords.length;
    } else {
      minAggregated = 0;
      maxAggregated = 0;
      averageValue = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.all(8.0), child: _buildCard());
  }

  Widget _buildCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildStatPair(
            labelLeft: "Sum".i18n,
            valueLeft: getCurrencyValueString(sumValues!.abs()),
            labelRight: "Average".i18n,
            valueRight: getCurrencyValueString(averageValue.abs()),
          ),
          const Divider(height: 24, thickness: 1, indent: 20, endIndent: 20),
          _buildStatPair(
            labelLeft:
                "${"Max".i18n} (${widget.aggregationMethod == AggregationMethod.MONTH ? "Month".i18n : "Day".i18n})",
            valueLeft: getCurrencyValueString(maxAggregated.abs()),
            labelRight:
                "${"Min".i18n} (${widget.aggregationMethod == AggregationMethod.MONTH ? "Month".i18n : "Day".i18n})",
            valueRight: getCurrencyValueString(minAggregated.abs()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPair({
    required String labelLeft,
    required String valueLeft,
    required String labelRight,
    required String valueRight,
  }) {
    return Row(
      children: [
        Expanded(child: _buildSingleStat(labelLeft, valueLeft)),
        Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
        Expanded(child: _buildSingleStat(labelRight, valueRight)),
      ],
    );
  }

  Widget _buildSingleStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: headerStyle, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(value, style: valueStyle, textAlign: TextAlign.center),
      ],
    );
  }
}
