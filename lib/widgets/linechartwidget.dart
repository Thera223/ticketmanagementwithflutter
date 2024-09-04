import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(), // Définit l'axe X comme une catégorie
      series: <CartesianSeries>[
        LineSeries<ChartData, String>(
          dataSource: _createSampleData(),
          xValueMapper: (ChartData data, _) =>
              data.year, // Axe X de type String
          yValueMapper: (ChartData data, _) =>
              data.value, // Axe Y de type num (int ou double)
          color: Colors.blue,
          dataLabelSettings: DataLabelSettings(
              isVisible: true), // Affiche les étiquettes de données
        ),
      ],
    );
  }

  List<ChartData> _createSampleData() {
    return [
      ChartData('2022', 5),
      ChartData('2023', 25),
      ChartData('2024', 100),
      ChartData('2025', 75),
    ];
  }
}

class ChartData {
  final String year; // Utilise String pour l'axe X
  final int value; // Utilise int pour l'axe Y

  ChartData(this.year, this.value);
}
