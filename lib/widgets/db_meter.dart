import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DbMeter extends StatelessWidget {
  final double currentDb;
  final double minDb;
  final double maxDb;
  final double avgDb;
  final Duration duration;
  final bool hasReading;
  final String description;

  const DbMeter({
    super.key,
    required this.currentDb,
    required this.minDb,
    required this.maxDb,
    required this.avgDb,
    required this.duration,
    required this.hasReading,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildGauge(context),
        _buildDigitalDisplay(context),
        const SizedBox(height: 30),
        Text(
          description,
          style: const TextStyle(color: Colors.grey, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildGauge(BuildContext context) {
    return SizedBox(
      height: 250,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 20,
            maximum: 120,
            startAngle: 200,
            endAngle: -20,
            interval: 10,
            radiusFactor: 1.05,
            canScaleToFit: true,
            showAxisLine: false,
            showLastLabel: true,
            useRangeColorForAxis: true,
            labelsPosition: ElementsPosition.outside,
            ticksPosition: ElementsPosition.outside,
            minorTicksPerInterval: 1,
            majorTickStyle: const MajorTickStyle(length: 25, thickness: 3),
            minorTickStyle: const MinorTickStyle(length: 10, thickness: 2),
            axisLabelStyle: const GaugeTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            ranges: <GaugeRange>[
              GaugeRange(
                startValue: 0,
                endValue: 90,
                color: const Color(0xFF6A6A6A),
                startWidth: 8,
                endWidth: 8,
              ),
              GaugeRange(
                startValue: 90,
                endValue: 120,
                color: const Color(0xFFE85A3F),
                startWidth: 8,
                endWidth: 8,
              ),
            ],
            pointers: <GaugePointer>[
              // Needle pointing to current DB
              NeedlePointer(
                value: hasReading ? currentDb : 0,
                needleLength: 0.75,
                lengthUnit: GaugeSizeUnit.factor,
                needleColor: const Color(0xFFE85A3F),
                needleStartWidth: 2,
                needleEndWidth: 4,
                knobStyle: const KnobStyle(
                  knobRadius: 0.05,
                  color: Color(0xFFE85A3F),
                ),
              ),
            ],
            annotations: <GaugeAnnotation>[
              // Min Label
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Min',
                      style: TextStyle(color: Color(0xFF6A6A6A), fontSize: 13),
                    ),
                    Text(
                      hasReading ? minDb.toStringAsFixed(0) : '-',
                      style: const TextStyle(
                        color: Color(0xFF6A6A6A),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                angle: 180,
                positionFactor: 0.6,
              ),
              // Peak Label
              GaugeAnnotation(
                widget: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Peak',
                      style: TextStyle(color: Color(0xFFE85A3F), fontSize: 13),
                    ),
                    Text(
                      hasReading ? maxDb.toStringAsFixed(0) : '-',
                      style: const TextStyle(
                        color: Color(0xFFE85A3F),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                angle: 0,
                positionFactor: 0.6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalDisplay(BuildContext context) {
    String minutes = duration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    String seconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // AVG Block
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'AVG',
              style: TextStyle(color: Color(0xFF999999), fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              hasReading ? avgDb.toStringAsFixed(1) : '--',
              style: const TextStyle(color: Color(0xFF999999), fontSize: 20),
            ),
          ],
        ),

        // Current Main Value Block
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              hasReading ? currentDb.toStringAsFixed(1) : '-.-',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 50,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                ),
                const Text(
                  'dB',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        // MAX Block
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'MAX',
              style: TextStyle(color: Color(0xFF999999), fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              hasReading ? maxDb.toStringAsFixed(1) : '--',
              style: const TextStyle(color: Color(0xFF999999), fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }
}
