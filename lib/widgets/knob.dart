import 'dart:math';

import 'package:flutter/material.dart';

/// A simple rotary knob widget.
///
/// - value is in the range [min, max]
/// - onChanged is called with the updated value
class Knob extends StatefulWidget {
  final double size;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final bool glow;
  final Color color;

  const Knob({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 80,
    this.min = 0,
    this.max = 1,
  this.glow = false,
  this.color = Colors.blue,
  });

  @override
  State<Knob> createState() => _KnobState();
}

class _KnobState extends State<Knob> with SingleTickerProviderStateMixin {
  // knob sweep in radians: from -150deg to +150deg (300deg total)
  static const double startAngle = -5 * pi / 6;
  static const double sweepAngle = 10 * pi / 6;

  double get normalizedValue => ((widget.value - widget.min) /
      (widget.max - widget.min)).clamp(0.0, 1.0);

  late final AnimationController _pulseController;
  // drag state is represented by _pulseController value

  double valueFromAngle(double angle) {
    // normalize angle to [-pi, pi]
    while (angle < -pi) {
      angle += 2 * pi;
    }
    while (angle > pi) {
      angle -= 2 * pi;
    }

    // Clamp angle into the sweep
    double relative = (angle - startAngle);
    // adjust wrapping
    while (relative < 0) {
      relative += 2 * pi;
    }
    if (relative > sweepAngle) relative = sweepAngle;
  return (relative / sweepAngle) * (widget.max - widget.min) + widget.min;
  }

  void _onPanUpdate(DragUpdateDetails details, Offset center) {
    final localPos = details.localPosition;
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;
    final angle = atan2(dy, dx);
    final newValue = valueFromAngle(angle);
    widget.onChanged(newValue.clamp(widget.min, widget.max));
  }

  void _onPanStart() {
    _pulseController.repeat(reverse: true);
    setState(() {});
  }

  void _onPanEnd() {
    _pulseController.animateTo(0.0, duration: const Duration(milliseconds: 300));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final angle = startAngle + normalizedValue * sweepAngle;
    return GestureDetector(
      onPanStart: (d) => _onPanStart(),
      onPanUpdate: (d) {
        // We need the center to convert local coords. Use RenderBox in post-frame.
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final center = box.size.center(Offset.zero);
        _onPanUpdate(d, center);
      },
      onPanEnd: (d) => _onPanEnd(),
      onTapDown: (td) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final center = box.size.center(Offset.zero);
        final dx = td.localPosition.dx - center.dx;
        final dy = td.localPosition.dy - center.dy;
        final angle = atan2(dy, dx);
        final newValue = valueFromAngle(angle);
        widget.onChanged(newValue.clamp(widget.min, widget.max));
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _KnobPainter(angle: angle, color: widget.color, glow: widget.glow, glowLevel: _pulseController.value),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..value = 0.0;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}

class _KnobPainter extends CustomPainter {
  final double angle;
  final Color color;
  final bool glow;
  final double glowLevel;

  _KnobPainter({required this.angle, required this.color, this.glow = false, this.glowLevel = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
  final radius = min(size.width, size.height) / 2 * 0.88;

    final basePaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    if (glow) {
      // stronger neon outer glow
      final alpha = (0.18 + 0.4 * glowLevel).clamp(0.0, 1.0);
      final blur = radius * (1.2 + 1.2 * glowLevel);
      final glowPaint = Paint()
        ..color = color.withAlpha((alpha * 255).round())
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
      canvas.drawCircle(center, radius * (1.08 + 0.12 * glowLevel), glowPaint);

      final innerGlow = Paint()
        ..shader = RadialGradient(
          colors: [color.withAlpha((120 * (0.8 + glowLevel)).round()), Colors.transparent],
        ).createShader(Rect.fromCircle(center: center, radius: radius * (0.9 + 0.06 * glowLevel)));
      canvas.drawCircle(center, radius * (0.9 + 0.06 * glowLevel), innerGlow);
    }

    final ringPaint = Paint()
      ..color = color.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.14
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.3);

    canvas.drawCircle(center, radius, basePaint);
    canvas.drawCircle(center, radius, ringPaint);

    // indicator
    final indicatorLength = radius * 0.72;
    final indicatorPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withAlpha(220), Colors.transparent],
        startAngle: angle - 0.06,
        endAngle: angle + 0.06,
      ).createShader(Rect.fromCircle(center: center, radius: indicatorLength))
      ..strokeWidth = max(3, radius * 0.09)
      ..strokeCap = StrokeCap.round;

    final indicator = Offset(
      center.dx + cos(angle) * indicatorLength,
      center.dy + sin(angle) * indicatorLength,
    );

    canvas.drawLine(center, indicator, indicatorPaint);

  // small center dot
  canvas.drawCircle(center, radius * 0.12, Paint()..color = Colors.black.withAlpha((0.18 * 255).round()));
  }

  @override
  bool shouldRepaint(covariant _KnobPainter old) => old.angle != angle || old.color != color || old.glow != glow;
}
