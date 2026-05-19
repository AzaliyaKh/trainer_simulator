import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:native_height/native_height.dart';

void main() => runApp(const WellMonitoringApp());

class AppColors {
  static const pageBackground = Color(0xFF202020);
  static const header = Color(0xFF111D2E);
  static const accentLine = Color(0xFFF2C94C);
  static const body = Color(0xFFF5F6F8);
  static const centerPanel = Color(0xFFE9ECEF);
  static const leftPanel = Color(0xFFF9FAFC);
  static const rightPanel = Color(0xFFF7F8FA);
  static const textDark = Color(0xFF111827);
  static const textMuted = Color(0xFF6B7280);
  static const darkCard = Color(0xFF111C2D);
  static const border = Color(0xFFE1E5EA);

  static const pressure = Color(0xFF2563EB);
  static const depth = Color(0xFF0B8F48);
  static const fluid = Color(0xFF7E22CE);
  static const flowRate = Color(0xFF0284A8);
  static const temperature = Color(0xFFEA580C);
  static const stepButton = Color(0xFFFFB300);
}

class AppSizes {
  static const double desktopBreakpoint = 900;
  static const double maxDashboardWidth = 1180;
  static const double headerHeight = 72;
  static const double leftPanelWidth = 292;
  static const double rightPanelWidth = 450;
  static const double chartCardHeight = 320;
  static const double metricCardHeight = 92;
  static const double stepButtonHeight = 58;
}

class ChartAssetPath {
  static const first = 'assets/data/first.csv';
  static const second = 'assets/data/second.csv';
  static const third = 'assets/data/third.csv';
}

class AppText {
  static const dashboardTitle = 'Мониторинг скважин';
  static const wellName = 'Скважина №1';
  static const metricsTitle = 'Основные показатели';
  static const stepButton = 'Сделать шаг';
  static const statusLabel = 'Статус скважины';
  static const statusValue = 'Работает';
  static const noData = 'Нет данных';
  static const defaultChartTitle = 'Динамика забойного давления в зависимости от времени';
  static const emptyChartTitle = 'какой-то график';
}

class ChartPoint {
  const ChartPoint(this.x, this.y);

  final double x;
  final double y;
}

class ChartDataSet {
  const ChartDataSet({
    this.first = const [],
    this.second = const [],
    this.third = const [],
  });

  final List<ChartPoint> first;
  final List<ChartPoint> second;
  final List<ChartPoint> third;

  bool get hasData => first.isNotEmpty || second.isNotEmpty || third.isNotEmpty;
}

class MetricInfo {
  const MetricInfo({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accent,
    required this.background,
    required this.border,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;
  final Color background;
  final Color border;
}

class MetricData {
  static const values = <MetricInfo>[
    MetricInfo(
      title: 'ДАВЛЕНИЕ',
      value: '22',
      unit: 'атм',
      icon: Icons.speed_rounded,
      accent: AppColors.pressure,
      background: Color(0xFFDCEBFF),
      border: Color(0xFFBBD4FF),
    ),
    MetricInfo(
      title: 'ГЛУБИНА',
      value: '600',
      unit: 'метров',
      icon: Icons.straighten_rounded,
      accent: AppColors.depth,
      background: Color(0xFFD9F8E1),
      border: Color(0xFFB8EFC9),
    ),
    MetricInfo(
      title: 'УРОВЕНЬ ФЛЮИДА',
      value: '390',
      unit: 'метров (65%)',
      icon: Icons.opacity_rounded,
      accent: AppColors.fluid,
      background: Color(0xFFF0E2FF),
      border: Color(0xFFE1C6FF),
    ),
    MetricInfo(
      title: 'ДЕБИТ',
      value: '112',
      unit: 'м³/сут',
      icon: Icons.show_chart_rounded,
      accent: AppColors.flowRate,
      background: Color(0xFFD4F7FC),
      border: Color(0xFFAEEBF4),
    ),
    MetricInfo(
      title: 'ТЕМПЕРАТУРА',
      value: '28',
      unit: '°C',
      icon: Icons.thermostat_rounded,
      accent: AppColors.temperature,
      background: Color(0xFFFFEBD3),
      border: Color(0xFFFFD9A8),
    ),
  ];
}

class ChartDataLoader {
  static Future<ChartDataSet> loadAll() async {
    final loaded = await Future.wait([
      _loadCsv(ChartAssetPath.first),
      _loadCsv(ChartAssetPath.second),
      _loadCsv(ChartAssetPath.third),
    ]);

    return ChartDataSet(
      first: loaded[0],
      second: loaded[1],
      third: loaded[2],
    );
  }

  static Future<List<ChartPoint>> _loadCsv(String path) async {
    final rawData = await rootBundle.loadString(path);
    final points = <ChartPoint>[];

    for (final line in rawData.split('\n')) {
      final point = _tryParsePoint(line);
      if (point != null) points.add(point);
    }

    return points;
  }

  static ChartPoint? _tryParsePoint(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty) return null;

    final parts = trimmed.split(',');
    if (parts.length < 2) return null;

    final x = double.tryParse(parts[0].trim());
    final y = double.tryParse(parts[1].trim());
    if (x == null || y == null) return null;

    return ChartPoint(x, y);
  }
}

class WellMonitoringApp extends StatelessWidget {
  const WellMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppText.dashboardTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: AppColors.pageBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.pressure,
          brightness: Brightness.light,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final math.Random _random = math.Random();

  ChartDataSet _chartData = const ChartDataSet();
  bool _isChartLoading = true;
  String? _chartErrorText;

  double _oilLevelRatio = 0.28;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    try {
      final loadedData = await ChartDataLoader.loadAll();
      if (!mounted) return;

      setState(() {
        _chartData = loadedData;
        _isChartLoading = false;
        _chartErrorText = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _chartErrorText = 'Ошибка загрузки данных: $error';
        _isChartLoading = false;
      });
    }
  }

  void _makeStep() {
    setState(() {
      _oilLevelRatio = NativeHeight.getHeight().clamp(0.1, 0.75).toDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= AppSizes.desktopBreakpoint;

          return Center(
            child: DashboardFrame(
              isDesktop: isDesktop,
              child: Column(
                children: [
                  const DashboardHeader(),
                  Expanded(
                    child: DashboardBody(
                      isDesktop: isDesktop,
                      metrics: MetricData.values,
                      oilLevelRatio: _oilLevelRatio,
                      chartData: _chartData,
                      isChartLoading: _isChartLoading,
                      chartErrorText: _chartErrorText,
                      onStepPressed: _makeStep,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class DashboardFrame extends StatelessWidget {
  const DashboardFrame({
    required this.isDesktop,
    required this.child,
    super.key,
  });

  final bool isDesktop;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: AppSizes.maxDashboardWidth),
      margin: EdgeInsets.all(isDesktop ? 12.0 : 0.0),
      decoration: const BoxDecoration(
        color: AppColors.body,
        boxShadow: [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class DashboardBody extends StatelessWidget {
  const DashboardBody({
    required this.isDesktop,
    required this.metrics,
    required this.oilLevelRatio,
    required this.chartData,
    required this.isChartLoading,
    required this.onStepPressed,
    this.chartErrorText,
    super.key,
  });

  final bool isDesktop;
  final List<MetricInfo> metrics;
  final double oilLevelRatio;
  final ChartDataSet chartData;
  final bool isChartLoading;
  final String? chartErrorText;
  final VoidCallback onStepPressed;

  @override
  Widget build(BuildContext context) {
    return isDesktop ? _DesktopDashboardBody(this) : _MobileDashboardBody(this);
  }
}

class _DesktopDashboardBody extends StatelessWidget {
  const _DesktopDashboardBody(this.data);

  final DashboardBody data;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: AppSizes.leftPanelWidth,
          child: MetricsPanel(
            metrics: data.metrics,
            onStepPressed: data.onStepPressed,
          ),
        ),
        Expanded(
          flex: 11,
          child: WellSchemePanel(oilLevelRatio: data.oilLevelRatio),
        ),
        SizedBox(
          width: AppSizes.rightPanelWidth,
          child: ChartsPanel(
            chartData: data.chartData,
            isLoading: data.isChartLoading,
            errorText: data.chartErrorText,
          ),
        ),
      ],
    );
  }
}

class _MobileDashboardBody extends StatelessWidget {
  const _MobileDashboardBody(this.data);

  final DashboardBody data;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          MetricsPanel(
            metrics: data.metrics,
            onStepPressed: data.onStepPressed,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 520,
            child: WellSchemePanel(oilLevelRatio: data.oilLevelRatio),
          ),
          ChartsPanel(
            chartData: data.chartData,
            isLoading: data.isChartLoading,
            errorText: data.chartErrorText,
          ),
        ],
      ),
    );
  }
}

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSizes.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: AppColors.header,
        border: Border(
          bottom: BorderSide(color: AppColors.accentLine, width: 2),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppText.dashboardTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),
          Text(
            AppText.wellName,
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class MetricsPanel extends StatelessWidget {
  const MetricsPanel({
    required this.metrics,
    required this.onStepPressed,
    super.key,
  });

  final List<MetricInfo> metrics;
  final VoidCallback onStepPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.leftPanel,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 14),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle(AppText.metricsTitle),
            const SizedBox(height: 14),
            StepButton(onPressed: onStepPressed),
            const SizedBox(height: 12),
            const StatusBanner(),
            const SizedBox(height: 12),
            MetricList(metrics: metrics),
          ],
        ),
      ),
    );
  }
}

class MetricList extends StatelessWidget {
  const MetricList({
    required this.metrics,
    super.key,
  });

  final List<MetricInfo> metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final metric in metrics) ...[
          MetricCard(metric: metric),
          if (metric != metrics.last) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textDark,
        fontSize: 14,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class StepButton extends StatelessWidget {
  const StepButton({
    required this.onPressed,
    super.key,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.stepButtonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.stepButton,
          foregroundColor: AppColors.textDark,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.25),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          AppText.stepButton,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class StatusBanner extends StatelessWidget {
  const StatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: const Row(
        children: [
          _StatusDot(),
          SizedBox(width: 10),
          _StatusText(),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF18E779),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF18E779).withOpacity(0.35),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppText.statusLabel,
          style: TextStyle(
            color: Color(0xFF8993A4),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          AppText.statusValue,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    required this.metric,
    super.key,
  });

  final MetricInfo metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: AppSizes.metricCardHeight,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 9),
      decoration: BoxDecoration(
        color: metric.background,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: metric.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MetricCardHeader(metric: metric),
          const SizedBox(height: 5),
          MetricValueText(metric: metric),
          const SizedBox(height: 3),
          MetricUnitText(metric: metric),
        ],
      ),
    );
  }
}

class MetricCardHeader extends StatelessWidget {
  const MetricCardHeader({
    required this.metric,
    super.key,
  });

  final MetricInfo metric;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(metric.icon, color: metric.accent, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            metric.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: metric.accent,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class MetricValueText extends StatelessWidget {
  const MetricValueText({
    required this.metric,
    super.key,
  });

  final MetricInfo metric;

  @override
  Widget build(BuildContext context) {
    return Text(
      metric.value,
      style: TextStyle(
        color: metric.accent.darken(0.2),
        fontSize: 27,
        height: 1,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class MetricUnitText extends StatelessWidget {
  const MetricUnitText({
    required this.metric,
    super.key,
  });

  final MetricInfo metric;

  @override
  Widget build(BuildContext context) {
    return Text(
      metric.unit,
      style: TextStyle(
        color: metric.accent,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class WellSchemePanel extends StatelessWidget {
  const WellSchemePanel({
    required this.oilLevelRatio,
    super.key,
  });

  final double oilLevelRatio;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.centerPanel,
        border: Border.symmetric(
          vertical: BorderSide(color: AppColors.border),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final diagramSize = WellDiagramSize.fromConstraints(constraints);

          return Center(
            child: SizedBox(
              width: diagramSize.width,
              height: diagramSize.height,
              child: WellDiagram(oilLevelRatio: oilLevelRatio),
            ),
          );
        },
      ),
    );
  }
}

class WellDiagramSize {
  const WellDiagramSize({
    required this.width,
    required this.height,
  });

  final double width;
  final double height;

  factory WellDiagramSize.fromConstraints(BoxConstraints constraints) {
    return WellDiagramSize(
      width: math.min(270.0, constraints.maxWidth * 0.62),
      height: math.min(620.0, constraints.maxHeight * 0.86),
    );
  }
}

class WellDiagram extends StatelessWidget {
  const WellDiagram({
    required this.oilLevelRatio,
    super.key,
  });

  final double oilLevelRatio;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WellDiagramPainter(oilLevelRatio: oilLevelRatio),
    );
  }
}

class WellDiagramPainter extends CustomPainter {
  WellDiagramPainter({
    required this.oilLevelRatio,
  });

  final double oilLevelRatio;

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = WellGeometry(size);

    _drawWellBody(canvas, geometry);
    _drawFluidLayers(canvas, geometry);
    _drawPipe(canvas, geometry);
    _drawLiquidMarker(canvas, geometry);
    _drawValves(canvas, geometry);
    _drawCap(canvas, geometry);
    _drawTopDivider(canvas, geometry);
  }

  void _drawWellBody(Canvas canvas, WellGeometry geometry) {
    final borderPaint = Paint()
      ..color = const Color(0xFFD1D5DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final topPaint = Paint()
      ..color = const Color(0xFFF4F7FB)
      ..style = PaintingStyle.fill;

    canvas.drawShadow(Path()..addRRect(geometry.wellRect), Colors.black, 10, true);
    canvas.drawRRect(geometry.wellRect, topPaint);
    canvas.drawRRect(geometry.wellRect, borderPaint);
  }

  void _drawFluidLayers(Canvas canvas, WellGeometry geometry) {
    final gasPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;

    final oilPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF8A3500),
          Color(0xFF1A0800),
        ],
      ).createShader(geometry.bounds);

    final gasHeight = geometry.innerHeight - geometry.oilHeight(oilLevelRatio);
    final oilTop = geometry.innerTop + gasHeight;

    final gasRect = Rect.fromLTWH(
      geometry.innerLeft,
      geometry.innerTop,
      geometry.innerWidth,
      gasHeight,
    );

    final oilRect = Rect.fromLTWH(
      geometry.innerLeft,
      oilTop,
      geometry.innerWidth,
      geometry.oilHeight(oilLevelRatio),
    );

    canvas.save();
    canvas.clipRRect(geometry.wellRect);
    canvas.drawRect(gasRect, gasPaint);
    canvas.drawRect(oilRect, oilPaint);
    canvas.restore();

    final separatorPaint = Paint()
      ..color = const Color(0xFF6B7280).withOpacity(0.4)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(geometry.innerLeft, oilTop),
      Offset(geometry.innerLeft + geometry.innerWidth, oilTop),
      separatorPaint,
    );
  }

  void _drawPipe(Canvas canvas, WellGeometry geometry) {
    final pipeOuterPaint = Paint()
      ..color = const Color(0xFFBFD7F5)
      ..style = PaintingStyle.fill;

    final pipeInnerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0xFF1D7CFF),
          Color(0xFF6FB6FF),
          Color(0xFF1D7CFF),
        ],
      ).createShader(geometry.pipeGradientBounds);

    canvas.drawRRect(geometry.pipeOuterRect, pipeOuterPaint);
    canvas.drawRRect(geometry.pipeInnerRect, pipeInnerPaint);
  }

  void _drawLiquidMarker(Canvas canvas, WellGeometry geometry) {
    final markerCenter = Offset(geometry.pipeCenterX, geometry.liquidLevelY(oilLevelRatio));

    final greenPaint = Paint()
      ..shader = const RadialGradient(
        colors: [
          Color(0xFF16E66D),
          Color(0xFF09C95B),
        ],
      ).createShader(Rect.fromCircle(center: markerCenter, radius: 42));

    final glowPaint = Paint()
      ..color = const Color(0xFF12E66D).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawCircle(markerCenter, 44, glowPaint);
    canvas.drawCircle(markerCenter, 34, greenPaint);
  }

  void _drawValves(Canvas canvas, WellGeometry geometry) {
    final valvePaint = Paint()
      ..color = const Color(0xFF18B960)
      ..style = PaintingStyle.fill;

    final darkValvePaint = Paint()
      ..color = const Color(0xFF0F8F49)
      ..style = PaintingStyle.fill;

    void drawValve(double x, double y) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x - 22, y - 6, 44, 12),
          const Radius.circular(3),
        ),
        valvePaint,
      );
      canvas.drawCircle(Offset(x, y), 10, darkValvePaint);
    }

    drawValve(geometry.width * 0.28, geometry.height * 0.11);
    drawValve(geometry.width * 0.72, geometry.height * 0.11);
  }

  void _drawCap(Canvas canvas, WellGeometry geometry) {
    final capPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.fill;

    final capDarkPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(geometry.capRect, capPaint);
    canvas.drawCircle(geometry.capCenter, 12, capDarkPaint);
  }

  void _drawTopDivider(Canvas canvas, WellGeometry geometry) {
    final linePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(geometry.width * 0.12, geometry.height * 0.18),
      Offset(geometry.width * 0.88, geometry.height * 0.18),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant WellDiagramPainter oldDelegate) {
    return oldDelegate.oilLevelRatio != oilLevelRatio;
  }
}

class WellGeometry {
  WellGeometry(Size size)
      : width = size.width,
        height = size.height,
        bounds = Offset.zero & size;

  final double width;
  final double height;
  final Rect bounds;

  RRect get wellRect => RRect.fromRectAndRadius(
        Rect.fromLTWH(width * 0.12, height * 0.03, width * 0.76, height * 0.94),
        const Radius.circular(10),
      );

  double get innerLeft => width * 0.13;
  double get innerTop => height * 0.18;
  double get innerWidth => width * 0.74;
  double get innerHeight => height * 0.78;

  double get pipeCenterX => width / 2;
  double get pipeTop => height * 0.08;
  double get pipeBottom => height * 0.97;

  Rect get pipeGradientBounds => Rect.fromLTWH(pipeCenterX - 14, pipeTop, 28, pipeBottom - pipeTop);

  RRect get pipeOuterRect => RRect.fromRectAndRadius(
        Rect.fromLTWH(pipeCenterX - 18, pipeTop, 36, pipeBottom - pipeTop),
        const Radius.circular(8),
      );

  RRect get pipeInnerRect => RRect.fromRectAndRadius(
        Rect.fromLTWH(pipeCenterX - 10, pipeTop, 20, pipeBottom - pipeTop),
        const Radius.circular(6),
      );

  RRect get capRect => RRect.fromRectAndRadius(
        Rect.fromLTWH(pipeCenterX - 18, height * 0.055, 36, 36),
        const Radius.circular(4),
      );

  Offset get capCenter => Offset(pipeCenterX, height * 0.075);

  double oilHeight(double oilLevelRatio) => innerHeight * oilLevelRatio.clamp(0.1, 0.75);

  double liquidLevelY(double oilLevelRatio) => innerTop + innerHeight - oilHeight(oilLevelRatio);
}

class ChartsPanel extends StatelessWidget {
  const ChartsPanel({
    required this.chartData,
    required this.isLoading,
    this.errorText,
    super.key,
  });

  final ChartDataSet chartData;
  final bool isLoading;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.rightPanel,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            PressureChartCard(
              chartData: chartData,
              isLoading: isLoading,
              errorText: errorText,
              title: AppText.defaultChartTitle,
            ),
            const SizedBox(height: 12),
            PressureChartCard(
              chartData: const ChartDataSet(),
              isLoading: false,
              title: AppText.emptyChartTitle,
            ),
          ],
        ),
      ),
    );
  }
}

class PressureChartCard extends StatelessWidget {
  const PressureChartCard({
    required this.chartData,
    required this.isLoading,
    this.title = AppText.defaultChartTitle,
    this.errorText,
    super.key,
  });

  final ChartDataSet chartData;
  final bool isLoading;
  final String title;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSizes.chartCardHeight,
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(child: ChartContent(chartData: chartData, isLoading: isLoading, errorText: errorText)),
        ],
      ),
    );
  }
}

class ChartContent extends StatelessWidget {
  const ChartContent({
    required this.chartData,
    required this.isLoading,
    this.errorText,
    super.key,
  });

  final ChartDataSet chartData;
  final bool isLoading;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (errorText != null) return ChartErrorText(errorText!);
    if (!chartData.hasData) return const EmptyChartMessage();

    return PressureChart(chartData: chartData);
  }
}

class ChartErrorText extends StatelessWidget {
  const ChartErrorText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.redAccent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class EmptyChartMessage extends StatelessWidget {
  const EmptyChartMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        AppText.noData,
        style: TextStyle(
          color: AppColors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class PressureChart extends StatelessWidget {
  const PressureChart({
    required this.chartData,
    super.key,
  });

  final ChartDataSet chartData;

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      margin: EdgeInsets.zero,
      plotAreaBorderWidth: 0.6,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.top,
        overflowMode: LegendItemOverflowMode.wrap,
        textStyle: const TextStyle(fontSize: 9),
        iconHeight: 7,
        iconWidth: 12,
      ),
      primaryXAxis: _ChartAxes.xAxis,
      primaryYAxis: _ChartAxes.yAxis,
      series: _buildSeries(),
    );
  }

  List<CartesianSeries<ChartPoint, double>> _buildSeries() {
    return [
      _buildStepLineSeries(
        data: chartData.first,
        name: 'Рбуф = 5 бар',
        color: const Color(0xFF00BFEF),
      ),
      _buildStepLineSeries(
        data: chartData.second,
        name: 'Рбуф = 10 бар',
        color: const Color(0xFF7C3AED),
      ),
      _buildStepLineSeries(
        data: chartData.third,
        name: 'Рбуф = 12 бар',
        color: Colors.black,
      ),
    ];
  }

  StepLineSeries<ChartPoint, double> _buildStepLineSeries({
    required List<ChartPoint> data,
    required String name,
    required Color color,
  }) {
    return StepLineSeries<ChartPoint, double>(
      dataSource: data,
      xValueMapper: (point, _) => point.x,
      yValueMapper: (point, _) => point.y,
      name: name,
      color: color,
      width: 1,
      markerSettings: const MarkerSettings(isVisible: true, width: 1.5, height: 1.5),
    );
  }
}

class _ChartAxes {
  static NumericAxis get xAxis => NumericAxis(
    minimum: 0,
    maximum: 13,
    interval: 1.1,
    title: AxisTitle(
      text: 'Время, ч',
      textStyle: TextStyle(fontSize: 10, color: AppColors.textMuted),
    ),
    labelStyle: const TextStyle(fontSize: 9, color: AppColors.textMuted),
    majorGridLines: const MajorGridLines(
      width: 0.6,
      dashArray: <double>[4, 4],
      color: Color(0xFFE5E7EB),
    ),
  );

  static NumericAxis get yAxis => NumericAxis(
    minimum: 45,
    maximum: 95,
    interval: 15,
    title: AxisTitle(
      text: 'Забойное давление, бар',
      textStyle: TextStyle(fontSize: 9, color: AppColors.textMuted),
    ),
    labelStyle: const TextStyle(fontSize: 9, color: AppColors.textMuted),
    majorGridLines: const MajorGridLines(
      width: 0.6,
      dashArray: <double>[4, 4],
      color: Color(0xFFE5E7EB),
    ),
  );
}

extension ColorDarken on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
