import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RatingBarChart extends StatelessWidget {
  final String title;
  final double angle;
  final double spacing;
  final double reservedSpace;
  final List<dynamic> xAxisList;
  final List<double> yAxisList;
  final double interval;

  const RatingBarChart({
    super.key,
    required this.title,
    required this.angle,
    required this.spacing,
    required this.reservedSpace,
    required this.xAxisList,
    required this.yAxisList,
    required this.interval
  });

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            axisNameSize: 30,
            axisNameWidget: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            sideTitles: const SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) =>
                  bottomTitles(value, angle, spacing, meta, xAxisList.map((e) => e.name as String).toList()),
              reservedSize: reservedSpace,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              interval: interval,
              getTitlesWidget: leftTitles,
            ),
          ),
        ),
        borderData: FlBorderData(
          border: const Border(
            top: BorderSide.none,
            right: BorderSide.none,
            left: BorderSide(width: 1),
            bottom: BorderSide(width: 1),
          ),
        ),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(
          xAxisList.length,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                  toY: double.parse(yAxisList[index].toStringAsFixed(2)),
                  width: 15,
                  color: Color(xAxisList.map((e) => e.color).toList()[index]),
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      topLeft: Radius.circular(10))),
            ],
          ),
        ).toList(),
      ),
    );
  }

  Widget bottomTitles(double value, double angle, double spacing, TitleMeta meta, List<String> bottomTilesData) {
    String str = bottomTilesData[value.toInt()];
    if (str.length > 10){
      str = "${str.substring(0, 10)}...";
    }

    final Widget text = Text(
      str,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );

    return SideTitleWidget(
      meta: meta,
      angle: angle,
      space: spacing, 
      child: text,
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    final formattedValue = (value).toStringAsFixed(0);
    final Widget text = Text(
      formattedValue,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );

    return SideTitleWidget(
      meta: meta,
      space: 16, 
      child: text,
    );
  }
}