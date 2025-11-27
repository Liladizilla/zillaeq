import 'dart:async';
import 'dart:math';
import 'package:just_audio/just_audio.dart';
import 'dsp.dart';

/// Simple equalizer engine that maintains one peaking filter per band.
/// It exposes an [rmsStream] which emits estimated RMS values (0..1)
/// and a [processBuffer] method that can process Float PCM buffers.
class EqualizerEngine {
  final AudioPlayer _player;
  final List<Biquad> _filters = [];
  final _rmsController = StreamController<double>.broadcast();
  double _sampleRate = 44100.0;

  EqualizerEngine(this._player);

  Stream<double> get rmsStream => _rmsController.stream;

  void setSampleRate(double sr) {
    _sampleRate = sr;
  }

  /// Configure filters using center frequencies and dB gains.
  void applyBands(List<double> bandsDb, {List<double>? freqs}) {
    final f = freqs ?? [60, 230, 910, 3600, 14000];
    _filters.clear();
    for (var i = 0; i < bandsDb.length; i++) {
      final bq = Biquad();
      final freq = (i < f.length) ? f[i] : f.last;
      // Q and sample rate are heuristic values; Q=1.0 is reasonable for peaking
      bq.setPeaking(freq.toDouble(), 1.0, bandsDb[i].toDouble(), _sampleRate);
      _filters.add(bq);
    }
    // also apply an overall volume multiplier (backwards compatibility)
    if (bandsDb.isNotEmpty) {
      final avgDb = bandsDb.reduce((a, b) => a + b) / bandsDb.length;
      final linear = pow(10, avgDb / 20).toDouble();
      _player.setVolume(linear.clamp(0.0, 2.0));
    }
  }

  /// Process an interleaved PCM buffer (double list) and emit RMS.
  /// `channels` is number of interleaved channels (1 = mono, 2 = stereo).
  void processBuffer(List<double> buffer, int channels) {
    if (_filters.isEmpty) return;
    processInterleavedBuffer(buffer, channels, _filters, _sampleRate);

    // compute RMS on first channel (approx)
    double sumSquares = 0.0;
    var frames = (buffer.length / channels).floor();
    for (var i = 0; i < frames; i++) {
      final sample = buffer[i * channels];
      sumSquares += sample * sample;
    }
  final rms = frames > 0 ? sqrt(sumSquares / frames) : 0.0;
    final clamped = rms.isFinite ? rms.clamp(0.0, 1.0) : 0.0;
    _rmsController.add(clamped);
  }

  void dispose() {
    _rmsController.close();
  }
}
