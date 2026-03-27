import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/recording_model.dart';
import '../utils/sound_utils.dart';

class DetailScreen extends StatefulWidget {
  final SoundRecording recording;

  const DetailScreen({super.key, required this.recording});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  AudioSource? _audioSource;
  SoundHandle? _soundHandle;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  double _volume = 4.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    try {
      if (!SoLoud.instance.isInitialized) {
        await SoLoud.instance.init();
      }
      _audioSource = await SoLoud.instance.loadFile(widget.recording.filePath);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading audio: $e');
    }
  }

  @override
  void dispose() {
    _stopPlayback(silent: true);
    if (_audioSource != null) {
      SoLoud.instance.disposeSource(_audioSource!);
    }
    super.dispose();
  }

  Future<void> _togglePlayback() async {
    if (_audioSource == null) return;

    if (_isPlaying) {
      await _pausePlayback();
    } else {
      await _startPlayback();
    }
  }

  Future<void> _startPlayback() async {
    if (_audioSource == null) return;
    if (_soundHandle != null && SoLoud.instance.getPause(_soundHandle!)) {
      SoLoud.instance.setPause(_soundHandle!, false);
    } else {
      _soundHandle = await SoLoud.instance.play(_audioSource!, volume: _volume);
      // If we previously seeked while stopped/paused, apply it now.
      if (_currentPosition > Duration.zero) {
        SoLoud.instance.seek(_soundHandle!, _currentPosition);
      }
    }
    if (mounted) {
      setState(() {
        _isPlaying = true;
      });
    }

    _pollPosition();
  }

  Future<void> _pausePlayback() async {
    if (_soundHandle == null) return;
    SoLoud.instance.setPause(_soundHandle!, true);
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _stopPlayback({bool silent = false}) {
    if (_soundHandle != null) {
      SoLoud.instance.stop(_soundHandle!);
      _soundHandle = null;
    }
    _isPlaying = false;
    _currentPosition = Duration.zero;
    if (!silent && mounted) {
      setState(() {});
    }
  }

  void _pollPosition() async {
    while (_isPlaying && _soundHandle != null && mounted) {
      if (!_isDragging) {
        final pos = SoLoud.instance.getPosition(_soundHandle!);
        if (pos >= widget.recording.duration) {
          _stopPlayback();
          break;
        }
        if (mounted) {
          setState(() {
            _currentPosition = pos;
          });
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy • HH:mm');
    final classification = getEnvironmentDescription(widget.recording.avgDb);

    return Scaffold(
      appBar: AppBar(title: const Text('Recording Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recording.name,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateFormat.format(widget.recording.timestamp),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    classification,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildStatsCard(context),
            const SizedBox(height: 32),
            const Text(
              'Noise Level History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 200, child: _buildHistoryChart(context)),
            const SizedBox(height: 40),
            _buildPlayerControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            'Min',
            '${widget.recording.minDb.toStringAsFixed(1)} ${widget.recording.unit}',
          ),
          _buildStatItem(
            context,
            'Avg',
            '${widget.recording.avgDb.toStringAsFixed(1)} ${widget.recording.unit}',
            isPrimary: true,
          ),
          _buildStatItem(
            context,
            'Max',
            '${widget.recording.maxDb.toStringAsFixed(1)} ${widget.recording.unit}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value, {
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrimary ? 20 : 18,
            fontWeight: FontWeight.bold,
            color: isPrimary
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryChart(BuildContext context) {
    return SfCartesianChart(
      margin: EdgeInsets.zero,
      primaryXAxis: const NumericAxis(isVisible: false),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 120,
        interval: 20,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
      series: <CartesianSeries<double, int>>[
        AreaSeries<double, int>(
          dataSource: widget.recording.dbHistory,
          xValueMapper: (double val, int index) => index,
          yValueMapper: (double val, _) => val,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          borderColor: Theme.of(context).colorScheme.primary,
          borderWidth: 2,
        ),
      ],
      plotAreaBorderWidth: 0,
    );
  }

  Widget _buildPlayerControls(BuildContext context) {
    final progress = widget.recording.duration.inMilliseconds > 0
        ? _currentPosition.inMilliseconds /
              widget.recording.duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChangeStart: (_) {
              setState(() {
                _isDragging = true;
              });
            },
            onChangeEnd: (value) {
              final target = Duration(
                milliseconds: (value * widget.recording.duration.inMilliseconds)
                    .toInt(),
              );
              if (_soundHandle != null) {
                SoLoud.instance.seek(_soundHandle!, target);
              }
              setState(() {
                _currentPosition = target;
                _isDragging = false;
              });
            },
            onChanged: (value) {
              setState(() {
                _currentPosition = Duration(
                  milliseconds:
                      (value * widget.recording.duration.inMilliseconds)
                          .toInt(),
                );
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_currentPosition)),
              Text(_formatDuration(widget.recording.duration)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.stop_rounded),
              iconSize: 32,
              onPressed: _stopPlayback,
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: _togglePlayback,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(width: 72), // Maintain spacing balance if needed or just remove it.
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
