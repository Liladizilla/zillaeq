import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class Waveform extends StatefulWidget {
  final double amplitude; // 0..1
  final int bars;
  final Color color;
  final Stream<double>? rmsStream;
  final Duration updateInterval;

  const Waveform({super.key, this.amplitude = 0.0, this.bars = 20, this.color = Colors.cyanAccent, this.rmsStream, this.updateInterval = const Duration(milliseconds: 120)});

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Timer _timer;
  List<double> _levels = [];
  StreamSubscription<double>? _rmsSub;
  double _rms = 0.0;

  @override
  void initState() {
    super.initState();
    _levels = List<double>.filled(widget.bars, 0.05);
  _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))..repeat();
  _timer = Timer.periodic(widget.updateInterval, (_) => _tick());
    if (widget.rmsStream != null) {
      _rmsSub = widget.rmsStream!.listen((v) {
        setState(() {
          _rms = v.clamp(0.0, 1.0);
        });
      });
    }
  }

  void _tick() {
    final rnd = Random();
  final a = (widget.rmsStream != null ? _rms : widget.amplitude).clamp(0.0, 1.0);
    setState(() {
      for (var i = 0; i < _levels.length; i++) {
        final target = a * (0.2 + rnd.nextDouble() * 0.8) * (1 - (i / _levels.length));
        _levels[i] = (_levels[i] * 0.7) + (target * 0.3);
      }
    });
  }

  @override
  void didUpdateWidget(covariant Waveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bars != widget.bars) {
      _levels = List<double>.filled(widget.bars, 0.05);
    }
  }

  @override
  void dispose() {
  _rmsSub?.cancel();
    _timer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_levels.length, (i) {
          final h = (_levels[i].clamp(0.02, 1.0));
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: h * 48,
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
