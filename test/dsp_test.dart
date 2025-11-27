import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:equalizer_app/services/dsp.dart';

double computeRms(List<double> buffer, int channels) {
  final frames = (buffer.length / channels).floor();
  double sum = 0.0;
  for (var i = 0; i < frames; i++) {
    final s = buffer[i * channels];
    sum += s * s;
  }
  return frames > 0 ? sqrt(sum / frames) : 0.0;
}

List<double> generateSine(int sampleRate, double freq, double durationSeconds, double amplitude) {
  final frames = (sampleRate * durationSeconds).floor();
  final buf = List<double>.filled(frames, 0.0);
  for (var i = 0; i < frames; i++) {
    buf[i] = amplitude * sin(2 * pi * freq * i / sampleRate);
  }
  return buf;
}

void main() {
  test('Biquad peaking increases RMS near center frequency', () {
    const sampleRate = 44100;
    const freq = 440.0;
    const duration = 0.5;
    final input = generateSine(sampleRate, freq, duration, 0.3);

    final rmsBefore = computeRms(input, 1);

    final bq = Biquad();
    // apply +8 dB peaking at the sine frequency
    bq.setPeaking(freq, 1.0, 8.0, sampleRate.toDouble());

    final processed = List<double>.from(input);
    processInterleavedBuffer(processed, 1, [bq], sampleRate.toDouble());

    final rmsAfter = computeRms(processed, 1);

    // Expect that RMS after is noticeably larger than before
    expect(rmsAfter, greaterThan(rmsBefore));
  });
}
