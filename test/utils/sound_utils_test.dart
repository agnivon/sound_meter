import 'package:flutter_test/flutter_test.dart';
import 'package:sound_meter/utils/sound_utils.dart';

void main() {
  group('SoundUtils', () {
    group('getFrequencyWeightingOffset', () {
      test('Z-weighting should always return 0.0', () {
        expect(
          SoundUtils.getFrequencyWeightingOffset(1000, FrequencyWeighting.z),
          0.0,
        );
        expect(
          SoundUtils.getFrequencyWeightingOffset(20, FrequencyWeighting.z),
          0.0,
        );
        expect(
          SoundUtils.getFrequencyWeightingOffset(20000, FrequencyWeighting.z),
          0.0,
        );
      });

      test('negative or zero frequency should return 0', () {
        expect(
          SoundUtils.getFrequencyWeightingOffset(0, FrequencyWeighting.a),
          0.0,
        );
        expect(
          SoundUtils.getFrequencyWeightingOffset(-100, FrequencyWeighting.c),
          0.0,
        );
      });

      test('A-weighting calculates correctly', () {
        final offset1000 = SoundUtils.getFrequencyWeightingOffset(
          1000,
          FrequencyWeighting.a,
        );
        // At 1000Hz, A-weighting is approximately 0
        expect(offset1000, closeTo(0.0, 1.0));

        final offset20 = SoundUtils.getFrequencyWeightingOffset(
          20,
          FrequencyWeighting.a,
        );
        // At 20Hz, A-weighting is highly negative (-50.4 dB theoretically)
        expect(offset20, lessThan(-40.0));
      });

      test('C-weighting calculates correctly', () {
        final offset1000 = SoundUtils.getFrequencyWeightingOffset(
          1000,
          FrequencyWeighting.c,
        );
        // At 1000Hz, C-weighting is approximately 0
        expect(offset1000, closeTo(0.0, 1.0));

        final offset20 = SoundUtils.getFrequencyWeightingOffset(
          20,
          FrequencyWeighting.c,
        );
        // At 20Hz, C-weighting drops by around -6.2 dB
        expect(offset20, closeTo(-6.2, 2.0));
      });
    });

    group('calculateAlpha', () {
      test('calculates correct alpha for fast weighting', () {
        final alpha = SoundUtils.calculateAlpha(
          const Duration(milliseconds: 100),
          TimeWeighting.fast.tau, // 125ms
        );
        expect(alpha, closeTo(0.550, 0.01));
      });

      test('calculates correct alpha for slow weighting', () {
        final alpha = SoundUtils.calculateAlpha(
          const Duration(milliseconds: 100),
          TimeWeighting.slow.tau, // 1000ms
        );
        expect(alpha, closeTo(0.095, 0.01));
      });

      test('calculates correct alpha for impulse weighting', () {
        final alpha = SoundUtils.calculateAlpha(
          const Duration(milliseconds: 10),
          TimeWeighting.impulse.tau, // 35ms
        );
        expect(alpha, closeTo(0.248, 0.01));
      });
    });
  });

  group('getEnvironmentDescription', () {
    test('returns correct descriptions based on DB levels', () {
      expect(getEnvironmentDescription(5), '0dB : Silence');
      expect(getEnvironmentDescription(10), '10dB : Breathing');
      expect(getEnvironmentDescription(55), '50dB : Quiet Office');
      expect(getEnvironmentDescription(60), '60dB : Conversation');
      expect(getEnvironmentDescription(150), '140dB : Gun Shots');
    });
  });
}
