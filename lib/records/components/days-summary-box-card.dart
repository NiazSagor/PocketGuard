import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pocket_guard/helpers/mini-chart-helper.dart';
import 'package:pocket_guard/helpers/records-utility-functions.dart';
import 'package:pocket_guard/models/category-type.dart';
import 'package:pocket_guard/models/record.dart';
import 'package:pocket_guard/records/components/mini_balance_chart.dart';
import 'package:pocket_guard/services/database/database-interface.dart';
import 'package:pocket_guard/services/service-config.dart';

import '../../i18n.dart';

class DaysSummaryBox extends StatefulWidget {
  /// DaysSummaryBox is a card that, given a list of records,
  /// shows the total income, total expenses, total balance resulting from
  /// all the movements in input days.

  final List<Record?> records;

  DaysSummaryBox(this.records);

  @override
  DaysSummaryBoxState createState() => DaysSummaryBoxState();
}

class DaysSummaryBoxState extends State<DaysSummaryBox> {
  DatabaseInterface database = ServiceConfig.database;
  List<FlSpot> _cachedSpots = [];
  bool _isLoadingChart = false;
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _subtitleFont = const TextStyle(fontSize: 13.0);

  late bool _isProfitable = true;

  double totalIncome() {
    return widget.records
        .where(
          (record) => record!.category!.categoryType == CategoryType.income,
        )
        .fold(0.0, (previousValue, record) => previousValue + record!.value!);
  }

  double totalExpenses() {
    return widget.records
        .where(
          (record) => record!.category!.categoryType == CategoryType.expense,
        )
        .fold(0.0, (previousValue, record) => previousValue + record!.value!);
  }

  double totalBalance() {
    return totalIncome() + totalExpenses();
  }

  Future<double> calculateOpeningBalance(DateTime currentMonth) async {
    final DateTime startOfTime = DateTime(1900);
    DateTime startOfThisMonth = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );

    // Fetch all records before this month
    List<Record?> previousRecords = await database.getAllRecordsInInterval(
      startOfTime,
      startOfThisMonth,
    );

    double balance = 0.0;

    for (var record in previousRecords) {
      if (record != null) {
        balance += record.value ?? 0.0;
      }
    }

    return balance;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      //color: Colors.white,
      //surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow(),

            if (widget.records.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildMiniChart(),
            ],

            const SizedBox(height: 16),
            _buildIncomeExpenseProgressBar(totalIncome(), totalExpenses()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Income".i18n,
                style: _subtitleFont,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5), // spacing
              Text(
                getCurrencyValueString(totalIncome()),
                style: _biggerFont,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _verticalDivider(),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Expenses".i18n,
                style: _subtitleFont,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5), // spacing
              Text(
                getCurrencyValueString(totalExpenses()),
                style: _biggerFont,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _verticalDivider(),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Balance".i18n,
                style: _subtitleFont,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 5), // spacing
              Text(
                getCurrencyValueString(totalBalance()),
                style: _biggerFont,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 30, // Manually set how tall you want the divider to be
      width: 1,
      color: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  @override
  void initState() {
    super.initState();
    _prepareChart();
  }

  @override
  void didUpdateWidget(DaysSummaryBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records) {
      _prepareChart();
    }
  }

  Future<void> _prepareChart() async {
    setState(() => _isLoadingChart = true);

    final openingBalance = await calculateOpeningBalance(DateTime.now());
    final spots = calculateTrendSpots(widget.records, openingBalance);

    bool isProfitable = true;
    if (spots.isNotEmpty) {
      isProfitable = spots.last.y >= openingBalance;
    }

    setState(() {
      _cachedSpots = spots;
      _isLoadingChart = false;
      _isProfitable = isProfitable;
    });
  }

  Widget _buildMiniChart() {
    if (_isLoadingChart) return const SizedBox(height: 60);
    if (_cachedSpots.isEmpty) return const SizedBox.shrink();

    return MiniBalanceChart(
      spots: _cachedSpots,
      isPositiveColor: _isProfitable ? Colors.green : Colors.red,
    );
  }

  Widget _buildIncomeExpenseProgressBar(double income, double expenses) {
    // 1. Calculate the ratio (0.0 to 1.0)
    // We use .abs() because expenses might be stored as negative numbers
    double expenseRatio = (income > 0) ? (expenses.abs() / income) : 0.0;

    // 2. Ensure it doesn't break the UI if expenses > income
    double displayWidth = expenseRatio.clamp(0.0, 1.0);

    // 3. Pick a color based on "danger" levels
    Color progressColor = Colors.green;
    if (expenseRatio > 0.7) progressColor = Colors.orange;
    if (expenseRatio > 0.9) progressColor = Colors.redAccent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${(expenseRatio * 100).toStringAsFixed(1)}% of income spent",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            Text(
              "Remaining: ${getCurrencyValueString(income - expenses.abs())}",
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1), // The "Income" Background
            borderRadius: BorderRadius.circular(10),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: displayWidth, // This controls the "fill"
            child: Container(
              decoration: BoxDecoration(
                color: progressColor, // The "Expense" Fill
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: progressColor.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
