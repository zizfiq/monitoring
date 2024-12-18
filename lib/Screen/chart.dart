import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key, required this.title});
  final String title;

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage>
    with AutomaticKeepAliveClientMixin {
  final List<FlSpot> temperatureData = [];
  final List<FlSpot> pHData = [];
  final List<FlSpot> tdsData = [];
  final List<FlSpot> ecData = [];
  Timer? _timer;
  int dataPoints = 0;
  final int maxDataPoints = 86400; // 24 hours worth of seconds
  final String apiKey = 'AIzaSyC9kIkLAGkB0xIS31vXQ8mtqMXED9TnSQc';
  final String databaseUrl =
      'https://monitoring-2f6fc-default-rtdb.asia-southeast1.firebasedatabase.app';

  // ignore: unused_field
  late DateTime _startTime;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeChartData();
  }

  Future<void> _initializeChartData() async {
    final prefs = await SharedPreferences.getInstance();

    // Check if it's been more than 24 hours since last data collection
    final lastStartTimeMs = prefs.getInt('chart_start_time') ?? 0;
    final lastStartTime = DateTime.fromMillisecondsSinceEpoch(lastStartTimeMs);
    final currentTime = DateTime.now();

    // If more than 24 hours have passed, reset the data
    if (currentTime.difference(lastStartTime).inHours >= 24) {
      // Reset data points and clear existing data
      dataPoints = 0;
      temperatureData.clear();
      pHData.clear();
      tdsData.clear();
      ecData.clear();

      // Save new start time
      await prefs.setInt(
          'chart_start_time', currentTime.millisecondsSinceEpoch);
    } else {
      // Restore existing data points
      dataPoints = prefs.getInt('data_points') ?? 0;

      // Restore chart data from preferences
      _restoreChartData(prefs);
    }

    _startTime = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('chart_start_time') ?? currentTime.millisecondsSinceEpoch);

    // Start periodic data fetching
    _startTimer();
  }

  void _restoreChartData(SharedPreferences prefs) {
    // Restore temperature data
    final tempDataList = prefs.getStringList('temperature_data') ?? [];
    temperatureData.addAll(tempDataList.map((e) {
      final parts = e.split(',');
      return FlSpot(double.parse(parts[0]), double.parse(parts[1]));
    }));

    // Restore pH data
    final pHDataList = prefs.getStringList('ph_data') ?? [];
    pHData.addAll(pHDataList.map((e) {
      final parts = e.split(',');
      return FlSpot(double.parse(parts[0]), double.parse(parts[1]));
    }));

    // Restore TDS data
    final tdsDataList = prefs.getStringList('tds_data') ?? [];
    tdsData.addAll(tdsDataList.map((e) {
      final parts = e.split(',');
      return FlSpot(double.parse(parts[0]), double.parse(parts[1]));
    }));

    // Restore EC data
    final ecDataList = prefs.getStringList('ec_data') ?? [];
    ecData.addAll(ecDataList.map((e) {
      final parts = e.split(',');
      return FlSpot(double.parse(parts[0]), double.parse(parts[1]));
    }));
  }

  Future<void> _saveChartData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save data points
    await prefs.setInt('data_points', dataPoints);

    // Save chart data
    await prefs.setStringList('temperature_data',
        temperatureData.map((e) => '${e.x},${e.y}').toList());
    await prefs.setStringList(
        'ph_data', pHData.map((e) => '${e.x},${e.y}').toList());
    await prefs.setStringList(
        'tds_data', tdsData.map((e) => '${e.x},${e.y}').toList());
    await prefs.setStringList(
        'ec_data', ecData.map((e) => '${e.x},${e.y}').toList());
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchSensorData();
    });
  }

  Future<void> _fetchSensorData() async {
    final response =
        await http.get(Uri.parse('$databaseUrl/sensorData.json?auth=$apiKey'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        // Add new data points with incremental x values
        temperatureData.add(FlSpot(
            dataPoints.toDouble(), data['Temperature']?.toDouble() ?? 0));
        pHData.add(FlSpot(dataPoints.toDouble(), data['pH']?.toDouble() ?? 0));
        tdsData
            .add(FlSpot(dataPoints.toDouble(), data['TDS']?.toDouble() ?? 0));
        ecData.add(FlSpot(dataPoints.toDouble(), data['EC']?.toDouble() ?? 0));

        dataPoints++;

        // Save chart data periodically
        _saveChartData();

        // Reset after 24 hours
        if (dataPoints >= maxDataPoints) {
          _resetChartData();
        }
      });
    }
  }

  Future<void> _resetChartData() async {
    final prefs = await SharedPreferences.getInstance();

    dataPoints = 0;
    temperatureData.clear();
    pHData.clear();
    tdsData.clear();
    ecData.clear();

    // Update start time
    await prefs.setInt(
        'chart_start_time', DateTime.now().millisecondsSinceEpoch);
  }

  String formatTimeLabel(double value) {
    int seconds = value.round();
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}';
  }

  Widget _buildChart({
    required String title,
    required List<FlSpot> spots,
    required Color lineColor,
    required double minY,
    required double maxY,
  }) {
    if (spots.isEmpty) return Container(); // Don't show empty chart

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 3600, // Show hour markers
                      getTitlesWidget: (value, meta) {
                        return Text(
                          formatTimeLabel(value),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                    ),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black),
                ),
                minX: spots.first.x,
                maxX: spots.last.x,
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: lineColor,
                    barWidth: 2,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _saveChartData(); // Save data before disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return Scaffold(
      backgroundColor: const Color(0xFFF0F0F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildChart(
              title: 'Suhu (°C)',
              spots: temperatureData,
              lineColor: Colors.red,
              minY: 25,
              maxY: 35,
            ),
            _buildChart(
              title: 'pH Level',
              spots: pHData,
              lineColor: Colors.blue,
              minY: 0,
              maxY: 15,
            ),
            _buildChart(
              title: 'TDS (ppm)',
              spots: tdsData,
              lineColor: Colors.green,
              minY: 0,
              maxY: 1000,
            ),
            _buildChart(
              title: 'EC',
              spots: ecData,
              lineColor: Colors.orange,
              minY: 0,
              maxY: 5,
            ),
          ],
        ),
      ),
    );
  }
}
