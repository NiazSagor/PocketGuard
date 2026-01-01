import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MiniBalanceChart extends StatelessWidget {
  final List<FlSpot> spots; // The data points (day, balance)
  final Color isPositiveColor;

  const MiniBalanceChart({
    super.key,
    required this.spots,
    this.isPositiveColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    double padding = (maxY - minY).abs() * 0.1;
    if (padding == 0) padding = 10;
    return SizedBox(
      height: 60, // Keep it small so it fits inside the card
      child: LineChart(
        LineChartData(
          minY: minY - padding,
          maxY: maxY + padding,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5000,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          // Hide background grid
          titlesData: const FlTitlesData(show: false),
          // Hide axes numbers
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              // Smooth "wave" look
              color: isPositiveColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              // Hide circles on points
              belowBarData: BarAreaData(
                show: true,
                // Soft gradient under the line
                color: isPositiveColor.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: LineTouchData(enabled: true),
        ),
      ),
    );
  }
}
