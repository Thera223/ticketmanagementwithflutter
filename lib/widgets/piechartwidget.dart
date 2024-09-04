import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: Legend(isVisible: true),
      series: <CircularSeries>[
        PieSeries<ChartData, String>(
          dataSource: _createSampleData(),
          xValueMapper: (ChartData data, _) => data.label,
          yValueMapper: (ChartData data, _) => data.value,
          dataLabelSettings: DataLabelSettings(isVisible: true),
        )
      ],
    );
  }

  List<ChartData> _createSampleData() {
    return [
      ChartData('Résolu', 40),
      ChartData('En cours', 30),
      ChartData('En attente', 30),
    ];
  }
}

class ChartData {
  final String label;
  final int value;

  ChartData(this.label, this.value);
}
