import 'dart:math' as math;
import 'package:flutter/material.dart';

class DbReference {
  final int db;
  final String description;
  final Color color;

  const DbReference(this.db, this.description, this.color);
}

const List<DbReference> dbReferences = [
  DbReference(10, 'Breathing', Color(0xFF1E88E5)),
  DbReference(20, 'Clock Ticking', Color(0xFF039BE5)),
  DbReference(30, 'Whisper', Color(0xFF00ACC1)),
  DbReference(40, 'Quiet Library', Color(0xFF00897B)),
  DbReference(50, 'Quiet Office', Color(0xFF43A047)),
  DbReference(60, 'Conversation', Color(0xFFFDD835)),
  DbReference(70, 'Restaurant', Color(0xFFFB8C00)),
  DbReference(80, 'Busy Traffic', Color(0xFF6D4C41)),
  DbReference(90, 'Motorcycle', Color(0xFF5D4037)),
  DbReference(100, 'Subway Train', Color(0xFF4E342E)),
  DbReference(110, 'Concerts', Color(0xFF3E2723)),
  DbReference(120, 'Thunder', Color(0xFFE53935)),
  DbReference(130, 'Ambulance', Color(0xFFD32F2F)),
  DbReference(140, 'Gun Shots', Color(0xFFB71C1C)),
];

enum FrequencyWeighting {
  a('dBA', 'A-Weighting', 'Mimics human hearing. Best for environmental and office noise.'),
  c('dBC', 'C-Weighting', 'Flatter filter. Best for loud machinery and concerts.'),
  z('dBZ', 'Z-Weighting', 'Zero weighting. Raw, unfiltered sound data.');

  final String unit;
  final String label;
  final String description;
  const FrequencyWeighting(this.unit, this.label, this.description);
}

enum TimeWeighting {
  fast('Fast', '125ms averaging. Standard for general noise.', Duration(milliseconds: 125)),
  slow('Slow', '1s averaging. Best for fluctuating noise.', Duration(seconds: 1)),
  impulse('Impulse', '35ms rise time. For sharp sounds like gunshots.', Duration(milliseconds: 35));

  final String label;
  final String description;
  final Duration tau;
  const TimeWeighting(this.label, this.description, this.tau);
}

class SoundUtils {
  /// Applies frequency weighting to a dB value based on the frequency.
  /// Formulae based on IEC 61672-1:2003
  static double getFrequencyWeightingOffset(double frequency, FrequencyWeighting type) {
    if (type == FrequencyWeighting.z || frequency <= 0) return 0.0;

    final f2 = frequency * frequency;
    const double f1v = 20.6;
    const double f4v = 12194.0;

    if (type == FrequencyWeighting.a) {
      const double f2v = 107.7;
      const double f3v = 737.9;
      
      final num = math.pow(f4v, 2) * math.pow(frequency, 4);
      final den = (f2 + math.pow(f1v, 2)) * 
                  math.sqrt((f2 + math.pow(f2v, 2)) * (f2 + math.pow(f3v, 2))) * 
                  (f2 + math.pow(f4v, 2));
      
      final ra = num / den;
      return 2.00 + 20 * math.log(ra) / math.ln10;
    } else if (type == FrequencyWeighting.c) {
      final num = math.pow(f4v, 2) * f2;
      final den = (f2 + math.pow(f1v, 2)) * (f2 + math.pow(f4v, 2));
      
      final rc = num / den;
      return 0.06 + 20 * math.log(rc) / math.ln10;
    }
    
    return 0.0;
  }

  /// Calculates the smoothing factor alpha for a given time constant.
  /// alpha = 1 - e^(-T/tau) where T is sampling period.
  static double calculateAlpha(Duration interval, Duration tau) {
    return 1.0 - math.exp(-interval.inMilliseconds / tau.inMilliseconds);
  }
}

String getEnvironmentDescription(double db) {
  if (db < 10) return '0dB : Silence';
  for (var i = dbReferences.length - 1; i >= 0; i--) {
    if (db >= dbReferences[i].db) {
      return '${dbReferences[i].db}dB : ${dbReferences[i].description}';
    }
  }
  return '0dB : Silence';
}
