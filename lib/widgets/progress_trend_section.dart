import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/progress_session.dart';

class ProgressTrendSection extends StatelessWidget {
  const ProgressTrendSection({required this.sessions, super.key});

  final List<ProgressSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    final trend = ProgressTrendSnapshot.fromSessions(sessions);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.insights_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'اتجاه التطور',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 132,
            child: CustomPaint(
              painter: ProgressTrendChartPainter(
                scores: trend.chartScores,
                colorScheme: colorScheme,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TrendMetricCard(
                  label: 'آخر نتيجة',
                  value: '${trend.latestScore}%',
                  icon: Icons.flag_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TrendMetricCard(
                  label: 'التغير',
                  value: trend.changeLabel,
                  icon: trend.change >= 0
                      ? Icons.trending_up
                      : Icons.trending_down,
                  isNegative: trend.change < 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TrendMetricCard(
                  label: 'أفضل نتيجة',
                  value: '${trend.bestScore}%',
                  icon: Icons.emoji_events_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TrendMetricCard(
                  label: 'متوسط آخر 3',
                  value: '${trend.recentAverageScore}%',
                  icon: Icons.timeline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            trend.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressTrendSnapshot {
  const ProgressTrendSnapshot({
    required this.latestScore,
    required this.change,
    required this.bestScore,
    required this.recentAverageScore,
    required this.chartScores,
  });

  final int latestScore;
  final int change;
  final int bestScore;
  final int recentAverageScore;
  final List<int> chartScores;

  String get changeLabel {
    if (change == 0) {
      return '0%';
    }

    return change > 0 ? '+$change%' : '$change%';
  }

  String get summary {
    if (chartScores.length == 1) {
      return 'هذه أول نقطة في السجل. بعد جلستين أو أكثر سيظهر اتجاه أوضح للتطور.';
    }

    if (change > 0) {
      return 'الاتجاه العام إيجابي مقارنة بأول جلسة محفوظة.';
    }

    if (change < 0) {
      return 'الاتجاه الحالي أقل من البداية. راجع ثبات الإضاءة والوقفة قبل الحكم على النتيجة.';
    }

    return 'الاتجاه مستقر تقريبًا بين أول وآخر جلسة محفوظة.';
  }

  factory ProgressTrendSnapshot.fromSessions(List<ProgressSession> sessions) {
    final chronologicalSessions = sessions.reversed.toList(growable: false);
    final scores = chronologicalSessions
        .map((session) => session.visualScore)
        .toList(growable: false);
    final recentSessions = sessions.take(3).toList(growable: false);
    final recentAverage =
        recentSessions
            .map((session) => session.visualScore)
            .reduce((value, element) => value + element) /
        recentSessions.length;

    return ProgressTrendSnapshot(
      latestScore: sessions.first.visualScore,
      change:
          sessions.first.visualScore - chronologicalSessions.first.visualScore,
      bestScore: scores.reduce(math.max),
      recentAverageScore: recentAverage.round(),
      chartScores: scores,
    );
  }
}

class TrendMetricCard extends StatelessWidget {
  const TrendMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isNegative = false,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final valueColor = isNegative ? colorScheme.error : colorScheme.primary;

    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: valueColor, size: 22),
          const SizedBox(height: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressTrendChartPainter extends CustomPainter {
  const ProgressTrendChartPainter({
    required this.scores,
    required this.colorScheme,
  });

  final List<int> scores;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty || size.isEmpty) {
      return;
    }

    final gridPaint = Paint()
      ..color = colorScheme.outlineVariant
      ..strokeWidth = 1;
    final linePaint = Paint()
      ..color = colorScheme.primary
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final fillPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    final pointPaint = Paint()
      ..color = colorScheme.primary
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 4; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < scores.length; i++) {
      final x = scores.length == 1
          ? size.width / 2
          : size.width * i / (scores.length - 1);
      final normalizedScore = scores[i].clamp(0, 100) / 100;
      final y = size.height - (normalizedScore * size.height);
      points.add(Offset(x, y));
    }

    if (points.length == 1) {
      canvas.drawCircle(points.first, 6, pointPaint);
      return;
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, size.height)
      ..lineTo(points.first.dx, points.first.dy);
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);

    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
      fillPath.lineTo(point.dx, point.dy);
    }

    fillPath
      ..lineTo(points.last.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    for (final point in points) {
      canvas.drawCircle(point, 4.5, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ProgressTrendChartPainter oldDelegate) {
    return oldDelegate.scores != scores ||
        oldDelegate.colorScheme != colorScheme;
  }
}
