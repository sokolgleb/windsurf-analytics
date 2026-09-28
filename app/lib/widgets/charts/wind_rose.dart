import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:windsurf_analytics/l10n/app_localizations.dart';

import '../../core/constants.dart';
import '../../models/analysis_result.dart';

class WindRoseChart extends StatelessWidget {
  final List<WindRoseEntry> data;
  final String spotName;
  final int startHour;
  final int endHour;

  const WindRoseChart({
    super.key,
    required this.data,
    required this.spotName,
    required this.startHour,
    required this.endHour,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            l10n.chartWindRoseTitle(spotName, '$startHour', '$endHour'),
            style: theme.textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: _WindRosePainter(data, theme),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              for (int i = 0; i < windSpeedBinLabels.length; i++)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: _binColors[i],
                    ),
                    const SizedBox(width: 4),
                    Text('${windSpeedBinLabels[i]} kn',
                        style: theme.textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(l10n.chartWindRoseHint,
              style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }
}

const _binColors = [
  Color(0xFFB2DFDB), // 0-10
  Color(0xFF80CBC4), // 10-14
  Color(0xFF4DB6AC), // 14-18
  Color(0xFF26A69A), // 18-22
  Color(0xFF00897B), // 22-28
  Color(0xFF00695C), // 28+
];

class _WindRosePainter extends CustomPainter {
  final List<WindRoseEntry> data;
  final ThemeData theme;

  _WindRosePainter(this.data, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 * 0.85;

    // Draw concentric circles
    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = theme.colorScheme.outline.withValues(alpha: 0.2)
      ..strokeWidth = 0.5;
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, circlePaint);
    }

    // Find max count per direction (stacked)
    final dirTotals = <String, int>{};
    for (final e in data) {
      dirTotals[e.direction] =
          (dirTotals[e.direction] ?? 0) + e.count;
    }
    final maxTotal =
        dirTotals.values.fold<int>(0, (a, b) => a > b ? a : b);
    if (maxTotal == 0) return;

    // Draw stacked bars for each direction
    const sectorAngle = 2 * math.pi / 8;
    const barAngle = sectorAngle * 0.7;

    for (int dirIdx = 0; dirIdx < compassPoints.length; dirIdx++) {
      final dir = compassPoints[dirIdx];
      // Angle: N=top (−π/2), clockwise
      final baseAngle = dirIdx * sectorAngle - math.pi / 2;

      // Collect bins for this direction (in order)
      final bins = <WindRoseEntry>[];
      for (final e in data) {
        if (e.direction == dir) bins.add(e);
      }

      double innerR = 0;
      for (int binIdx = 0; binIdx < bins.length; binIdx++) {
        final entry = bins[binIdx];
        if (entry.count == 0) continue;

        final outerR = innerR + (entry.count / maxTotal) * radius;
        final paint = Paint()
          ..style = PaintingStyle.fill
          ..color = _binColors[binIdx % _binColors.length];

        final path = _arcPath(
          center,
          innerR,
          outerR,
          baseAngle - barAngle / 2,
          baseAngle + barAngle / 2,
        );
        canvas.drawPath(path, paint);
        innerR = outerR;
      }
    }

    // Draw direction labels
    final textStyle = TextStyle(
      color: theme.colorScheme.onSurface,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    for (int i = 0; i < compassPoints.length; i++) {
      final angle = i * sectorAngle - math.pi / 2;
      final labelR = radius + 14;
      final offset = Offset(
        center.dx + labelR * math.cos(angle),
        center.dy + labelR * math.sin(angle),
      );
      final tp = TextPainter(
        text: TextSpan(text: compassPoints[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(offset.dx - tp.width / 2, offset.dy - tp.height / 2));
    }
  }

  Path _arcPath(
      Offset center, double innerR, double outerR, double startA, double endA) {
    final path = Path();
    if (innerR == 0) {
      path.moveTo(center.dx, center.dy);
    } else {
      path.moveTo(
        center.dx + innerR * math.cos(startA),
        center.dy + innerR * math.sin(startA),
      );
    }
    path.arcTo(
      Rect.fromCircle(center: center, radius: outerR),
      startA,
      endA - startA,
      false,
    );
    if (innerR == 0) {
      path.lineTo(center.dx, center.dy);
    } else {
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerR),
        endA,
        startA - endA,
        false,
      );
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _WindRosePainter old) => old.data != data;
}
