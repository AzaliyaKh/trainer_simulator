import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  runApp(const MyApp());
}

class ChartPoint {
  final double x;
  final double y;

  ChartPoint(this.x, this.y);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const ChartPage(),
    );
  }
}

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  List<ChartPoint> firstData = [];
  List<ChartPoint> secondData = [];
  List<ChartPoint> thirdData = [];

  bool isLoading = true;
  String? errorText;

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  Future<List<ChartPoint>> loadSingleCsv(String path) async {
    final rawData = await rootBundle.loadString(path);
    final lines = rawData.split('\n');

    final List<ChartPoint> loadedData = [];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split(',');
      if (parts.length < 2) continue;

      final double x = double.parse(parts[0].trim());
      final double y = double.parse(parts[1].trim());

      loadedData.add(ChartPoint(x, y));
    }

    return loadedData;
  }

  Future<void> loadCsvData() async {
    try {
      final loadedFirst = await loadSingleCsv('assets/data/first.csv');
      final loadedSecond = await loadSingleCsv('assets/data/second.csv');
      final loadedThird = await loadSingleCsv('assets/data/third.csv');

      setState(() {
        firstData = loadedFirst;
        secondData = loadedSecond;
        thirdData = loadedThird;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorText = 'Ошибка загрузки данных: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Динамика забойного давления (бар) в зависимости от времени (часы)'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : errorText != null
                ? Text(errorText!)
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: SfCartesianChart(
                      legend: Legend(isVisible: true),
                      primaryXAxis: NumericAxis(
                        minimum: 0,
                        maximum: 13,
                        title: AxisTitle(text: 'X'),
                      ),
                      primaryYAxis: NumericAxis(
                        minimum: 45,
                        maximum: 95,
                        title: AxisTitle(text: 'Y'),
                      ),
                      series: <CartesianSeries>[
                        StepLineSeries<ChartPoint, double>(
                          dataSource: firstData,
                          xValueMapper: (ChartPoint point, _) => point.x,
                          yValueMapper: (ChartPoint point, _) => point.y,
                          name: 'Рбуф = 5 бар',
                        ),
                        StepLineSeries<ChartPoint, double>(
                          dataSource: secondData,
                          xValueMapper: (ChartPoint point, _) => point.x,
                          yValueMapper: (ChartPoint point, _) => point.y,
                          name: 'Рбуф = 10 бар',
                        ),
                        StepLineSeries<ChartPoint, double>(
                          dataSource: thirdData,
                          xValueMapper: (ChartPoint point, _) => point.x,
                          yValueMapper: (ChartPoint point, _) => point.y,
                          name: 'Рбуф = 12 бар',
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}