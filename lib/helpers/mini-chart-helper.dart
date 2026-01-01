import 'package:fl_chart/fl_chart.dart';
import 'package:pocket_guard/models/record.dart';

List<FlSpot> calculateTrendSpots(List<Record?> records, double openingBalance) {
  // 1. Sort records by date to ensure the running total is accurate
  List<FlSpot> spots = [FlSpot(0, openingBalance)];
  records.sort((a, b) => a!.utcDateTime.compareTo(b!.utcDateTime));

  // 2. Map to store total for each day
  Map<int, double> dailyBalances = {};
  double runningTotal = openingBalance;

  // 3. Process records
  for (var record in records) {
    int day = record!.utcDateTime.day;

    // Check if category is income or expense based on your logic
    // Usually, expenses are stored as negative or have a category type
    // Assuming record.value is positive for income and negative for expense:
    runningTotal += record.value ?? 0.0;

    dailyBalances[day] = runningTotal;
  }

  // 4. Fill in the "gaps" (days without transactions)
  int maxDay = records
      .map((e) => e!.utcDateTime.day)
      .reduce((a, b) => a > b ? a : b);

  double lastKnownBalance = openingBalance;

  for (int i = 1; i <= maxDay; i++) {
    if (dailyBalances.containsKey(i)) {
      lastKnownBalance = dailyBalances[i]!;
    }

    // Only add spots up to 'today' if viewing current month
    // or up to end of month for past months
    spots.add(FlSpot(i.toDouble(), lastKnownBalance));
  }

  return spots;
}
