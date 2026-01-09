import 'package:pocket_guard/models/record.dart';
import 'package:pocket_guard/statistics/statistics-models.dart';
import 'package:pocket_guard/statistics/statistics-utils.dart';

class StatSummary {
  final double sum;
  final double average;
  final double minAggregated;
  final double maxAggregated;
  final List<DateTimeSeriesRecord> aggregated;

  StatSummary({
    required this.sum,
    required this.average,
    required this.minAggregated,
    required this.maxAggregated,
    required this.aggregated,
  });

  static StatSummary calculate(
    List<Record?> records,
    AggregationMethod method,
  ) {
    if (records.isEmpty) {
      return StatSummary(
        sum: 0,
        average: 0,
        minAggregated: 0,
        maxAggregated: 0,
        aggregated: [],
      );
    }

    // Work on a copy to avoid side-effects
    final sortedByAbs = List<Record?>.from(records)
      ..sort((a, b) => a!.value!.abs().compareTo(b!.value!.abs()));

    final aggregated = aggregateRecordsByDate(records, method);
    final sum = records.fold(0.0, (acc, e) => acc + (e?.value ?? 0)).abs();

    // Sort aggregated to find min/max
    final sortedAggregated = List<DateTimeSeriesRecord>.from(aggregated)
      ..sort((a, b) => a.value.abs().compareTo(b.value.abs()));

    return StatSummary(
      sum: sum,
      aggregated: aggregated,
      minAggregated: sortedAggregated.first.value.abs(),
      maxAggregated: sortedAggregated.last.value.abs(),
      average: sum / (aggregated.isEmpty ? 1 : aggregated.length),
    );
  }
}
