import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:pocket_guard/helpers/mini-chart-helper.dart';
import 'package:pocket_guard/models/category-type.dart';
import 'package:pocket_guard/models/record.dart';
import 'package:pocket_guard/services/database/database-interface.dart';

class ChartProvider extends ChangeNotifier {
  final DatabaseInterface database;

  ChartProvider({required this.database});

  bool _isLoading = false;
  List<FlSpot> _spots = [];
  bool _isProfitable = true;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;

  bool get isLoading => _isLoading;

  List<FlSpot> get spots => _spots;

  bool get isProfitable => _isProfitable;

  double get totalIncome => _totalIncome;

  double get totalExpense => _totalExpense;

  Future<void> prepareChart(List<Record?> records) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (records.isEmpty) {
        _spots = [];
        _totalIncome = 0;
        _totalExpense = 0;
        _isProfitable = true;
        return;
      }

      _totalIncome = records
          .where(
            (record) => record!.category!.categoryType == CategoryType.income,
          )
          .fold(0.0, (previousValue, record) => previousValue + record!.value!);

      _totalExpense = records
          .where(
            (record) => record!.category!.categoryType == CategoryType.expense,
          )
          .fold(0.0, (previousValue, record) => previousValue + record!.value!);

      final openingBalance = await _calculateOpeningBalance(DateTime.now());

      _spots = calculateTrendSpots(records, openingBalance);
      if (_spots.isNotEmpty) {
        _isProfitable = _spots.last.y >= openingBalance;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<double> _calculateOpeningBalance(DateTime currentMonth) async {
    final DateTime startOfTime = DateTime(1900);
    DateTime startOfThisMonth = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );

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
}
