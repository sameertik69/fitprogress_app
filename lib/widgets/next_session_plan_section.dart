import 'package:flutter/material.dart';

import '../models/muscle_metric.dart';
import '../models/progress_session.dart';

class NextSessionPlanSection extends StatelessWidget {
  const NextSessionPlanSection({required this.sessions, super.key});

  final List<ProgressSession> sessions;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return const SizedBox.shrink();
    }

    final plan = NextSessionPlan.fromSessions(sessions);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_turned_in_outlined,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'خطة الجلسة القادمة',
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
                child: PlanMetricCard(
                  label: 'هدف النتيجة',
                  value: '${plan.targetScore}%',
                  icon: Icons.track_changes,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: PlanMetricCard(
                  label: 'تركيز العضلة',
                  value: plan.focusMuscle,
                  icon: Icons.fitness_center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          PlanChecklistItem(
            icon: Icons.photo_camera_outlined,
            title: 'ثبّت التصوير',
            text: plan.photoGuidance,
          ),
          const SizedBox(height: 8),
          PlanChecklistItem(
            icon: Icons.monitor_weight_outlined,
            title: 'سجّل السياق',
            text: plan.contextGuidance,
          ),
          const SizedBox(height: 8),
          PlanChecklistItem(
            icon: Icons.timeline,
            title: 'اقرأ الاتجاه',
            text: plan.trendGuidance,
          ),
        ],
      ),
    );
  }
}

class NextSessionPlan {
  const NextSessionPlan({
    required this.targetScore,
    required this.focusMuscle,
    required this.photoGuidance,
    required this.contextGuidance,
    required this.trendGuidance,
  });

  final int targetScore;
  final String focusMuscle;
  final String photoGuidance;
  final String contextGuidance;
  final String trendGuidance;

  factory NextSessionPlan.fromSessions(List<ProgressSession> sessions) {
    final latestSession = sessions.first;
    final previousSession = sessions.length >= 2 ? sessions[1] : null;
    final focusMetric = _focusMetric(latestSession, previousSession);
    final visualDiff = previousSession == null
        ? 0
        : latestSession.visualScore - previousSession.visualScore;
    final targetStep = visualDiff >= 4 ? 1 : 2;

    return NextSessionPlan(
      targetScore: (latestSession.visualScore + targetStep).clamp(0, 100),
      focusMuscle: focusMetric.name,
      photoGuidance:
          'استخدم نفس المسافة والإضاءة والوقفة، وصوّر الأمام والجانب والخلف بنفس الترتيب.',
      contextGuidance:
          latestSession.weightKg == null && latestSession.phaseLabel.isEmpty
          ? 'أضف الوزن ومرحلة التمرين حتى تصبح المقارنة القادمة أوضح.'
          : 'حافظ على تسجيل الوزن والمرحلة والملاحظات بنفس الصيغة.',
      trendGuidance: previousSession == null
          ? 'بعد حفظ جلسة ثانية سيظهر اتجاه أوضح للمقارنة.'
          : visualDiff >= 0
          ? 'الاتجاه الحالي إيجابي، راقب استمرار التحسن بدون تغيير ظروف التصوير.'
          : 'الاتجاه أقل من السابق، ركّز على ثبات الصور قبل اعتبارها نتيجة فعلية.',
    );
  }

  static MuscleMetric _focusMetric(
    ProgressSession latestSession,
    ProgressSession? previousSession,
  ) {
    if (latestSession.muscleMetrics.isEmpty) {
      return defaultMuscleMetrics.first;
    }

    if (previousSession == null || previousSession.muscleMetrics.isEmpty) {
      final sortedMetrics = [...latestSession.muscleMetrics]
        ..sort((a, b) => a.score.compareTo(b.score));
      return sortedMetrics.first;
    }

    final previousByName = {
      for (final metric in previousSession.muscleMetrics) metric.name: metric,
    };
    final sortedMetrics = [...latestSession.muscleMetrics]
      ..sort((a, b) {
        final aPrevious = previousByName[a.name]?.score ?? a.score;
        final bPrevious = previousByName[b.name]?.score ?? b.score;
        final diffCompare = (a.score - aPrevious).compareTo(
          b.score - bPrevious,
        );
        if (diffCompare != 0) {
          return diffCompare;
        }

        return a.score.compareTo(b.score);
      });

    return sortedMetrics.first;
  }
}

class PlanMetricCard extends StatelessWidget {
  const PlanMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 94),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
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
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class PlanChecklistItem extends StatelessWidget {
  const PlanChecklistItem({
    required this.icon,
    required this.title,
    required this.text,
    super.key,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
