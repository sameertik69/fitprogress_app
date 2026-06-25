import 'package:flutter/material.dart';

import '../models/progress_session.dart';

class DataQualityDashboard extends StatelessWidget {
  const DataQualityDashboard({required this.sessions, super.key});

  final List<ProgressSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    final snapshot = DataQualitySnapshot.fromSessions(sessions);
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
              Icon(
                Icons.dashboard_customize_outlined,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'جاهزية البيانات',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: DashboardMetricCard(
                  label: 'الجلسات',
                  value: '${snapshot.sessionCount}',
                  icon: Icons.history,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DashboardMetricCard(
                  label: 'ثبات الوقفة',
                  value: '${snapshot.averagePostureScore}%',
                  icon: Icons.accessibility_new,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DashboardMetricCard(
                  label: 'آخر فحص',
                  value: snapshot.latestDateLabel,
                  icon: Icons.event_available_outlined,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DashboardMetricCard(
                  label: 'جاهزية AI',
                  value: snapshot.aiReadinessLabel,
                  icon: Icons.psychology_alt_outlined,
                  isWarning: !snapshot.isAiReady,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DataQualityNotice(snapshot: snapshot),
        ],
      ),
    );
  }
}

class DataQualitySnapshot {
  const DataQualitySnapshot({
    required this.sessionCount,
    required this.averagePostureScore,
    required this.latestDateLabel,
    required this.hasEnoughSessions,
    required this.hasMeasurements,
    required this.hasPhotos,
    required this.hasWeakComparison,
  });

  final int sessionCount;
  final int averagePostureScore;
  final String latestDateLabel;
  final bool hasEnoughSessions;
  final bool hasMeasurements;
  final bool hasPhotos;
  final bool hasWeakComparison;

  bool get isAiReady => hasEnoughSessions && hasMeasurements && hasPhotos;

  String get aiReadinessLabel => isAiReady ? 'جاهزة' : 'ناقصة';

  String get notice {
    if (hasWeakComparison) {
      return 'آخر المقارنات تحتاج تثبيتًا أفضل للصور قبل الاعتماد على الاتجاه.';
    }
    if (!hasEnoughSessions) {
      return 'احفظ جلستين على الأقل حتى تصبح قراءة الاتجاهات أوضح.';
    }
    if (!hasMeasurements) {
      return 'أضف قياسات يدوية في جلسة واحدة على الأقل لتحسين جودة التحليل لاحقًا.';
    }
    if (!hasPhotos) {
      return 'الجلسات محفوظة، لكن الصور غير مرتبطة بكل السجل الحالي.';
    }

    return 'السجل الحالي مناسب كبداية قوية قبل مرحلة AI.';
  }

  factory DataQualitySnapshot.fromSessions(List<ProgressSession> sessions) {
    final postureAverage =
        sessions
            .map((session) => session.postureScore)
            .reduce((value, element) => value + element) /
        sessions.length;
    final hasWeakComparison =
        sessions.length >= 2 &&
        (sessions.first.comparabilityLabel == 'ضعيفة' ||
            sessions[1].comparabilityLabel == 'ضعيفة' ||
            (sessions.first.postureScore - sessions[1].postureScore).abs() >
                12);

    return DataQualitySnapshot(
      sessionCount: sessions.length,
      averagePostureScore: postureAverage.round(),
      latestDateLabel: _formatShortDate(sessions.first.createdAt),
      hasEnoughSessions: sessions.length >= 2,
      hasMeasurements: sessions.any((session) => session.measurements.hasAny),
      hasPhotos: sessions.any((session) => session.hasPhotoPaths),
      hasWeakComparison: hasWeakComparison,
    );
  }

  static String _formatShortDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final valueColor = isWarning ? colorScheme.error : colorScheme.primary;

    return Container(
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
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

class DataQualityNotice extends StatelessWidget {
  const DataQualityNotice({required this.snapshot, super.key});

  final DataQualitySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWarning = !snapshot.isAiReady || snapshot.hasWeakComparison;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWarning
            ? colorScheme.errorContainer.withValues(alpha: 0.45)
            : colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isWarning ? Icons.info_outline : Icons.check_circle_outline,
            color: isWarning ? colorScheme.error : colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              snapshot.notice,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
