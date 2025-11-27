import 'dart:math' as math;

class Biquad {
  // Direct Form 1
  double a0 = 1, a1 = 0, a2 = 0, b0 = 1, b1 = 0, b2 = 0;
  double x1 = 0, x2 = 0, y1 = 0, y2 = 0;

  double processSample(double x0) {
    final y0 = (b0 / a0) * x0 + (b1 / a0) * x1 + (b2 / a0) * x2 - (a1 / a0) * y1 - (a2 / a0) * y2;
    x2 = x1;
    x1 = x0;
    y2 = y1;
    y1 = y0;
    return y0;
  }

  // peaking EQ design
  void setPeaking(double freq, double q, double dbGain, double sampleRate) {
    final A = math.pow(10.0, dbGain / 40.0);
    final omega = 2.0 * math.pi * freq / sampleRate;
    final alpha = math.sin(omega) / (2.0 * q);
    final cosw = math.cos(omega);

    b0 = 1 + alpha * A;
    b1 = -2 * cosw;
    b2 = 1 - alpha * A;
    a0 = 1 + alpha / A;
    a1 = -2 * cosw;
    a2 = 1 - alpha / A;
  }

  void reset() {
    x1 = x2 = y1 = y2 = 0.0;
  }
}

// Process an interleaved Float32List PCM buffer in-place per channel
void processInterleavedBuffer(List<double> buffer, int channels, List<Biquad> filters, double sampleRate) {
  if (channels <= 0) return;
  final frameCount = (buffer.length / channels).floor();
  for (var f = 0; f < frameCount; f++) {
    for (var ch = 0; ch < channels; ch++) {
      final idx = f * channels + ch;
      var sample = buffer[idx];
      for (final filter in filters) {
        sample = filter.processSample(sample);
      }
      buffer[idx] = sample;
    }
  }
}
