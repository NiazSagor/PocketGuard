import 'package:flutter/material.dart';
import 'package:pocket_guard/models/category-type.dart';
import 'package:pocket_guard/models/record.dart';
import 'package:pocket_guard/statistics/statistics-tab-page.dart';

import '../helpers/datetime-utility-functions.dart';
import '../i18n.dart';

class StatisticsPage extends StatelessWidget {
  /// Statistics Page
  /// It has takes the initial date, ending date and a list of records
  /// and shows widgets representing statistics of the given records

  List<Record?> records;
  DateTime? from;
  DateTime? to;

  StatisticsPage(this.from, this.to, this.records);

  @override
  Widget build(BuildContext context) {
    String title = getDateRangeStr(from!, to!);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: "Expenses".i18n.toUpperCase()),
              Tab(text: "Income".i18n.toUpperCase()),
            ],
          ),
          title: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[Text(title)],
          ),
        ),
        body: TabBarView(
          children: [
            StatisticsTabPage(
              from,
              to,
              records
                  .where(
                    (element) =>
                        element!.category!.categoryType == CategoryType.expense,
                  )
                  .toList(),
            ),
            StatisticsTabPage(
              from,
              to,
              records
                  .where(
                    (element) =>
                        element!.category!.categoryType == CategoryType.income,
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
