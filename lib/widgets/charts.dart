import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  final double x;
  final double y;
  ChartData(this.x, this.y);
}

// Timeline Chart
class TimelineChartWidget extends StatelessWidget {
  final List<double> history;

  const TimelineChartWidget({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    List<ChartData> data = [];
    double totalTimeSec = history.length * 0.033;
    for (int i = 0; i < history.length; i++) {
      double x = (i * 0.033) - totalTimeSec;
      data.add(ChartData(x, history[i]));
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: SfCartesianChart(
        margin: const EdgeInsets.all(0),
        plotAreaBorderWidth: 0,
        primaryXAxis: const NumericAxis(
          minimum: -24,
          maximum: 0,
          interval: 4,
          labelFormat: '{value}s',
          majorGridLines: MajorGridLines(
            width: 1,
            dashArray: [5, 5],
            color: Colors.white24,
          ),
          axisLine: AxisLine(width: 0),
          labelStyle: TextStyle(color: Colors.white54, fontSize: 10),
        ),
        primaryYAxis: const NumericAxis(
          minimum: 0,
          maximum: 120,
          interval: 20,
          labelFormat: '{value}',
          majorGridLines: MajorGridLines(
            width: 1,
            dashArray: [5, 5],
            color: Colors.white24,
          ),
          axisLine: AxisLine(width: 0),
          labelStyle: TextStyle(color: Colors.white54, fontSize: 10),
        ),
        series: <CartesianSeries>[
          LineSeries<ChartData, double>(
            dataSource: data,
            xValueMapper: (ChartData d, _) => d.x,
            yValueMapper: (ChartData d, _) => d.y,
            color: const Color(0xFFE85A3F),
            width: 1.5,
            animationDuration: 0,
          ),
        ],
      ),
    );
  }
}

// Waveform Chart
class WaveChartWidget extends StatelessWidget {
  final List<double> waveData;

  const WaveChartWidget({super.key, required this.waveData});

  @override
  Widget build(BuildContext context) {
    List<ChartData> data = [];
    for (int i = 0; i < waveData.length; i++) {
      data.add(ChartData(i.toDouble(), waveData[i]));
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: SfCartesianChart(
        margin: const EdgeInsets.all(0),
        plotAreaBorderWidth: 0,
        primaryXAxis: const NumericAxis(
          minimum: 0,
          maximum: 256,
          interval: 32,
          isVisible: true,
          majorGridLines: MajorGridLines(
            width: 1,
            dashArray: [5, 5],
            color: Colors.white24,
          ),
          axisLine: AxisLine(width: 0),
          labelStyle: TextStyle(fontSize: 0),
          minorGridLines: MinorGridLines(width: 0),
          majorTickLines: MajorTickLines(size: 0),
        ),
        primaryYAxis: const NumericAxis(
          minimum: -1,
          maximum: 1,
          interval: 0.5,
          isVisible: true,
          labelFormat: '{value}',
          majorGridLines: MajorGridLines(
            width: 1,
            dashArray: [5, 5],
            color: Colors.white24,
          ),
          axisLine: AxisLine(width: 0),
          labelStyle: TextStyle(color: Colors.white54, fontSize: 10),
          minorGridLines: MinorGridLines(width: 0),
          majorTickLines: MajorTickLines(size: 0),
        ),
        series: <CartesianSeries>[
          LineSeries<ChartData, double>(
            dataSource: data,
            xValueMapper: (ChartData d, _) => d.x,
            yValueMapper: (ChartData d, _) => d.y,
            color: const Color(0xFFE85A3F),
            width: 1.5,
            animationDuration: 0,
          ),
        ],
      ),
    );
  }
}

// FFT Chart
class FftChartWidget extends StatelessWidget {
  final List<double> fftData;
  final double peakFrequency;

  const FftChartWidget({
    super.key,
    required this.fftData,
    required this.peakFrequency,
  });

  @override
  Widget build(BuildContext context) {
    List<ChartData> data = [];
    for (int i = 0; i < fftData.length; i++) {
      double freq = (i * 86.13);
      if (freq < 20) freq = 20;

      // flutter_recorder returns raw linear frequency bins
      // simple scalar curve to approximate dB
      double val = (fftData[i] * 500) - 20;
      val = val.clamp(-20.0, 100.0);
      data.add(ChartData(freq, val));
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: SfCartesianChart(
        margin: const EdgeInsets.all(0),
        plotAreaBorderWidth: 0,
        primaryXAxis: const LogarithmicAxis(
          minimum: 20,
          maximum: 20000,
          labelFormat: '{value}',
          majorGridLines: MajorGridLines(
            width: 1,
            dashArray: [5, 5],
            color: Colors.white24,
          ),
          axisLine: AxisLine(width: 0),
          labelStyle: TextStyle(color: Colors.white54, fontSize: 10),
        ),
        primaryYAxis: const NumericAxis(
          minimum: -20,
          maximum: 100,
          interval: 20,
          labelFormat: '{value}',
          majorGridLines: MajorGridLines(
            width: 1,
            dashArray: [5, 5],
            color: Colors.white24,
          ),
          axisLine: AxisLine(width: 0),
          labelStyle: TextStyle(color: Colors.white54, fontSize: 10),
        ),
        annotations: <CartesianChartAnnotation>[
          CartesianChartAnnotation(
            widget: Text(
              '${peakFrequency.toStringAsFixed(1)} Hz',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            coordinateUnit: CoordinateUnit.percentage,
            x: '50%',
            y: '10%',
          ),
        ],
        series: <CartesianSeries>[
          LineSeries<ChartData, double>(
            dataSource: data,
            xValueMapper: (ChartData d, _) => d.x,
            yValueMapper: (ChartData d, _) => d.y,
            color: const Color(0xFFE85A3F),
            width: 1.5,
            animationDuration: 0,
          ),
        ],
      ),
    );
  }
}
