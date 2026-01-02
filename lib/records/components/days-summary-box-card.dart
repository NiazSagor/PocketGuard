import 'package:flutter/material.dart';
import 'package:pocket_guard/helpers/records-utility-functions.dart';
import 'package:pocket_guard/models/record.dart';
import 'package:pocket_guard/records/components/mini_balance_chart.dart';
import 'package:pocket_guard/records/notifiers/chart_provider.dart';
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
  final _biggerFont = const TextStyle(fontSize: 18.0);
  final _subtitleFont = const TextStyle(fontSize: 13.0);
  late ChartProvider _chartProvider;

  @override
  void initState() {
    super.initState();
    _chartProvider = ChartProvider(database: database);
    _chartProvider.prepareChart(widget.records);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: ListenableBuilder(
          listenable: _chartProvider,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSummaryRow(
                  _chartProvider.totalIncome,
                  _chartProvider.totalExpense,
                ),

                if (_chartProvider.isLoading)
                  const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_chartProvider.spots.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  MiniBalanceChart(
                    spots: _chartProvider.spots,
                    isPositiveColor: _chartProvider.isProfitable
                        ? Colors.green
                        : Colors.red,
                  ),
                ],

                const SizedBox(height: 16),
                _buildIncomeExpenseProgressBar(
                  _chartProvider.totalIncome,
                  _chartProvider.totalExpense,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryRow(double totalIncome, double totalExpenses) {
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
                getCurrencyValueString(totalIncome),
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
                getCurrencyValueString(totalExpenses),
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
                getCurrencyValueString(totalExpenses + totalIncome),
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
  void didUpdateWidget(DaysSummaryBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records) {
      _chartProvider.prepareChart(widget.records);
    }
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
