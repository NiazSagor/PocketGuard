import 'dart:math';

import 'package:community_charts_flutter/community_charts_flutter.dart'
    as charts;
import 'package:community_charts_flutter/community_charts_flutter.dart';
import 'package:community_charts_flutter/src/text_element.dart' as ChartText;
import 'package:community_charts_flutter/src/text_style.dart' as style;
import 'package:flutter/material.dart' as fmaterial;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocket_guard/models/record.dart';
import 'package:pocket_guard/statistics/statistics-models.dart';
import 'package:pocket_guard/statistics/statistics-utils.dart';

import '../i18n.dart';

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  Color textColor = Color.black;
  Color backgroundColor = Color.white;
  String? text;

  CustomCircleSymbolRenderer(bool isDarkMode, String text) {
    textColor = isDarkMode ? Color.white : Color.black;
    backgroundColor = isDarkMode ? Color.black : Color.white;
    text = text;
  }

  @override
  void paint(
    ChartCanvas canvas,
    Rectangle<num> bounds, {
    List<int>? dashPattern,
    Color? fillColor,
    FillPatternType? fillPattern,
    Color? strokeColor,
    double? strokeWidthPx,
  }) {
    super.paint(
      canvas,
      bounds,
      dashPattern: dashPattern,
      fillColor: fillColor,
      strokeColor: strokeColor,
      strokeWidthPx: strokeWidthPx,
    );

    var textStyle = style.TextStyle();
    textStyle.color = this.textColor;
    textStyle.fontSize = 15;
    canvas.drawText(
      ChartText.TextElement(text!, style: textStyle),
      (bounds.left - 40).round(),
      (bounds.top - 30).round(),
    );
  }
}

class BarChartCard extends StatefulWidget {
  final List<Record?> records;
  final AggregationMethod? aggregationMethod;
  final DateTime? from, to;

  const BarChartCard(
    this.from,
    this.to,
    this.records,
    this.aggregationMethod, {
    super.key,
  });

  @override
  State<BarChartCard> createState() => _BarChartCardState();
}

class _BarChartCardState extends State<BarChartCard> {
  // All chart-ready data is cached here
  String _currentPointerValue = ""; // Local state
  late CustomCircleSymbolRenderer _renderer;
  late List<charts.Series<StringSeriesRecord, String>> seriesList;
  late List<TickSpec<num>> ticksListY;
  late List<TickSpec<String>> ticksListX;
  late String chartScope;
  double average = 0;
  bool animate = true;
  static final categoryCount = 5;

  @override
  void initState() {
    super.initState();
    _renderer = CustomCircleSymbolRenderer(false, _currentPointerValue);
    _prepareChartData();
  }

  @override
  void didUpdateWidget(BarChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.records != widget.records ||
        oldWidget.aggregationMethod != widget.aggregationMethod) {
      _prepareChartData();
    }
  }

  void _prepareChartData() {
    final aggregatedRecords = aggregateRecordsByDate(
      widget.records,
      widget.aggregationMethod,
    );

    DateTime start, end;
    DateFormat dateFormat;
    if (widget.aggregationMethod == AggregationMethod.MONTH) {
      dateFormat = DateFormat("MM");
      start = DateTime(widget.from!.year);
      end = DateTime(widget.to!.year + 1);
      chartScope = DateFormat("yyyy").format(start);
    } else {
      dateFormat = DateFormat("dd"); // placeholder
      start = DateTime.now(); // placeholder
      end = DateTime.now(); // placeholder
      chartScope = ""; // placeholder
    }

    ticksListY = _createYTicks(aggregatedRecords);
    ticksListX = _createXTicks(start, end, dateFormat);
    seriesList = _createStringSeriesFromAggregated(
      aggregatedRecords,
      start,
      end,
      dateFormat,
    );

    double sumValues = aggregatedRecords
        .fold(0.0, (acc, e) => acc + e.value)
        .abs();
    average = aggregatedRecords.isEmpty
        ? 0
        : sumValues / aggregatedRecords.length;
  }

  List<charts.Series<StringSeriesRecord, String>>
  _createStringSeriesFromAggregated(
    List<DateTimeSeriesRecord> records,
    DateTime start,
    DateTime end,
    DateFormat formatter,
  ) {
    final Map<DateTime, StringSeriesRecord> aggregatedByDay = {};

    for (var d in records) {
      final truncated = truncateDateTime(d.time!, widget.aggregationMethod);
      aggregatedByDay[truncated] = StringSeriesRecord(
        truncated,
        d.value,
        formatter,
      );
    }

    DateTime current = start;
    while (current.isBefore(end)) {
      final truncated = truncateDateTime(current, widget.aggregationMethod);
      aggregatedByDay.putIfAbsent(
        truncated,
        () => StringSeriesRecord(truncated, 0, formatter),
      );

      if (widget.aggregationMethod == AggregationMethod.DAY) {
        current = current.add(const Duration(days: 1));
      } else {
        current = DateTime(current.year, current.month + 1);
      }
    }

    final data = aggregatedByDay.values.toList()
      ..sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

    return [
      charts.Series<StringSeriesRecord, String>(
        id: 'DailyRecords',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (rec, _) => rec.key!,
        measureFn: (rec, _) => rec.value,
        data: data,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return _buildCard(context);
  }

  Widget _buildLineChart(BuildContext context) {
    var isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _renderer.text = _currentPointerValue;
    charts.Color labelAxesColor = isDarkMode ? Color.white : Color.black;
    return new Container(
      padding: EdgeInsets.fromLTRB(5, 0, 5, 5),
      child: new charts.BarChart(
        seriesList,
        animate: animate,
        behaviors: [
          charts.LinePointHighlighter(symbolRenderer: _renderer),
          charts.RangeAnnotation([
            new charts.LineAnnotationSegment(
              average!,
              charts.RangeAnnotationAxisType.measure,
              color: labelAxesColor,
              endLabel: 'Average'.i18n,
              labelStyleSpec: new charts.TextStyleSpec(
                fontSize: 12, // size in Pts.
                color: labelAxesColor,
              ),
            ),
          ], layoutPaintOrder: 100),
        ],
        selectionModels: [
          SelectionModelConfig(
            changedListener: (SelectionModel model) {
              if (model.hasDatumSelection) {
                final value = model.selectedSeries[0]
                    .measureFn(model.selectedDatum[0].index)
                    ?.toStringAsFixed(2);

                final label = model.selectedSeries[0].domainFn(
                  model.selectedDatum[0].index,
                );

                setState(() {
                  _currentPointerValue = "$label: $value";
                });
              }
            },
          ),
        ],
        domainAxis: charts.OrdinalAxisSpec(
          tickProviderSpec: charts.StaticOrdinalTickProviderSpec(ticksListX),
          renderSpec: charts.SmallTickRendererSpec(
            // Tick and Label styling here.
            labelStyle: charts.TextStyleSpec(
              fontSize: 14, // size in Pts.
              color: labelAxesColor,
            ),

            // Change the line colors to match text color.
            lineStyle: charts.LineStyleSpec(color: labelAxesColor),
          ),
        ),
        primaryMeasureAxis: charts.NumericAxisSpec(
          renderSpec: charts.SmallTickRendererSpec(
            // Tick and Label styling here.
            labelStyle: charts.TextStyleSpec(
              fontSize: 14, // size in Pts.
              color: labelAxesColor,
            ),

            // Change the line colors to match text color.
            lineStyle: charts.LineStyleSpec(color: labelAxesColor),
          ),
          tickProviderSpec: charts.StaticNumericTickProviderSpec(ticksListY),
        ),
      ),
    );
  }

  // Ticks creation utils
  List<TickSpec<num>> _createYTicks(List<DateTimeSeriesRecord> records) {
    double maxRecord = records.map((e) => e.value.abs()).reduce(max);
    int maxNumberOfTicks = 4;
    var interval = max(10, (maxRecord / (maxNumberOfTicks * 10)).round() * 10);
    List<TickSpec<num>> ticksNumber = [];
    for (double i = 0; i <= maxRecord + interval; i = i + interval) {
      ticksNumber.add(charts.TickSpec<num>(i.toInt()));
    }
    return ticksNumber;
  }

  List<charts.TickSpec<String>> _createXTicks(
    DateTime start,
    DateTime end,
    DateFormat formatter,
  ) {
    List<charts.TickSpec<String>> ticks = [];
    while (start.isBefore(end)) {
      ticks.add(charts.TickSpec<String>(formatter.format(start)));
      // advance start
      if (widget.aggregationMethod == AggregationMethod.DAY) {
        start = start.add(Duration(days: 3));
      } else if (widget.aggregationMethod == AggregationMethod.MONTH) {
        start = DateTime(start.year, start.month + 1);
      } else if (widget.aggregationMethod == AggregationMethod.YEAR) {
        start = DateTime(start.year + 1, end.month);
      }
    }
    return ticks;
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      height: 250,
      margin: EdgeInsets.only(top: 10, bottom: 10),
      child: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(10, 8, 8, 0),
            child: Align(
              alignment: fmaterial.Alignment.centerLeft,
              child: Text(
                "Trend in".i18n + " " + chartScope,
                style: fmaterial.TextStyle(fontSize: 14),
              ),
            ),
          ),
          new Divider(),
          fmaterial.Expanded(child: _buildLineChart(context)),
        ],
      ),
    );
  }
}
