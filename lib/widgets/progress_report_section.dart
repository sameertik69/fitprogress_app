import 'package:flutter/material.dart';

import '../models/progress_session.dart';
import 'muscle_breakdown_section.dart';
import 'session_report_export_sheet.dart';

class ProgressReportSection extends StatelessWidget {
  const ProgressReportSection({
    required this.session,
    required this.isSaved,
    required this.weightController,
    required this.waistController,
    required this.chestController,
    required this.armController,
    required this.shoulderController,
    required this.phaseController,
    required this.noteController,
    required this.onSaveReport,
    required this.onEditPhotos,
    required this.onResetScan,
    super.key,
  });

  final ProgressSession session;
  final bool isSaved;
  final TextEditingController weightController;
  final TextEditingController waistController;
  final TextEditingController chestController;
  final TextEditingController armController;
  final TextEditingController shoulderController;
  final TextEditingController phaseController;
  final TextEditingController noteController;
  final VoidCallback onSaveReport;
  final VoidCallback onEditPhotos;
  final VoidCallback onResetScan;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_outlined, color: colorScheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'تقرير التقدم التجريبي',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ReportSummaryCard(session: session),
          const SizedBox(height: 12),
          ScoreCard(score: session.visualScore),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MiniMetricCard(
                  icon: Icons.balance_outlined,
                  title: 'التناسق العام',
                  value: session.symmetryLabel,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiniMetricCard(
                  icon: Icons.accessibility_new,
                  title: 'ثبات الوقفة',
                  value: '${session.postureScore}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MiniMetricCard(
                  icon: Icons.image_search_outlined,
                  title: 'وضوح الصور',
                  value: session.confidence,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MiniMetricCard(
                  icon: Icons.compare_arrows,
                  title: 'قابلية المقارنة',
                  value: session.comparabilityLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ReportMetric(
            title: 'تقدير التطور البصري',
            value: '${session.visualScore}%',
            description: session.summary,
          ),
          const Divider(height: 24),
          ReportMetric(
            title: 'مؤشر الثقة',
            value: session.confidence,
            description:
                'يعتمد على ثبات الإضاءة والمسافة ووضوح الصور المختارة.',
          ),
          const Divider(height: 24),
          ReportMetric(
            title: 'تغير نسبة الكتف إلى الخصر',
            value: '+${session.shoulderWaistChange.toStringAsFixed(1)}%',
            description:
                'تغير تقديري مبني على مقارنة بصرية وليس قياسًا تشريحيًا دقيقًا.',
          ),
          const Divider(height: 24),
          ReportMetric(
            title: 'ثبات الوقفة',
            value: '${session.postureScore}%',
            description:
                'كلما كانت الوقفة أقرب بين الجلسات كانت المقارنة أفضل.',
          ),
          const SizedBox(height: 16),
          MuscleBreakdownSection(metrics: session.muscleMetrics),
          const SizedBox(height: 16),
          SessionInputs(
            weightController: weightController,
            waistController: waistController,
            chestController: chestController,
            armController: armController,
            shoulderController: shoulderController,
            phaseController: phaseController,
            noteController: noteController,
            enabled: !isSaved,
          ),
          const SizedBox(height: 16),
          MessageBox(
            icon: Icons.lightbulb_outline,
            iconColor: colorScheme.primary,
            title: 'توصية الجلسة القادمة',
            text: session.recommendation,
          ),
          const SizedBox(height: 12),
          MessageBox(
            icon: Icons.info_outline,
            iconColor: colorScheme.tertiary,
            title: 'تنبيه مهم',
            text:
                'هذه النتائج تقديرية وتجريبية، ولا تمثل قياسًا طبيًا أو قياسًا دقيقًا للكتلة العضلية. التحليل الحقيقي سيُضاف لاحقًا.',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: isSaved ? null : onSaveReport,
            icon: Icon(isSaved ? Icons.check_circle : Icons.save_outlined),
            label: Text(isSaved ? 'تم حفظ التقرير' : 'حفظ التقرير'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => showSessionReportExportSheet(context, session),
            icon: const Icon(Icons.ios_share),
            label: const Text('تصدير التقرير'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEditPhotos,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('تعديل الصور'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onResetScan,
                  icon: const Icon(Icons.refresh),
                  label: const Text('فحص جديد'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReportSummaryCard extends StatelessWidget {
  const ReportSummaryCard({required this.session, super.key});

  final ProgressSession session;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.trending_up, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.visualScore >= 84 ? 'تحسن بصري قوي' : 'تحسن بصري جيد',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.summary,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ScoreCard extends StatelessWidget {
  const ScoreCard({required this.score, super.key});

  final int score;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              backgroundColor: colorScheme.surface,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visual progress estimate',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$score%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SessionInputs extends StatelessWidget {
  const SessionInputs({
    required this.weightController,
    required this.waistController,
    required this.chestController,
    required this.armController,
    required this.shoulderController,
    required this.phaseController,
    required this.noteController,
    required this.enabled,
    super.key,
  });

  final TextEditingController weightController;
  final TextEditingController waistController;
  final TextEditingController chestController;
  final TextEditingController armController;
  final TextEditingController shoulderController;
  final TextEditingController phaseController;
  final TextEditingController noteController;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'معلومات الجلسة',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: weightController,
                enabled: enabled,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'الوزن',
                  suffixText: 'kg',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: phaseController,
                enabled: enabled,
                decoration: const InputDecoration(
                  labelText: 'المرحلة',
                  hintText: 'تنشيف / تضخيم',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'قياسات اختيارية',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MeasurementField(
                controller: waistController,
                enabled: enabled,
                label: 'الخصر',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MeasurementField(
                controller: chestController,
                enabled: enabled,
                label: 'الصدر',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MeasurementField(
                controller: armController,
                enabled: enabled,
                label: 'الذراع',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MeasurementField(
                controller: shoulderController,
                enabled: enabled,
                label: 'الكتف',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: noteController,
          enabled: enabled,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'ملاحظات',
            hintText: 'مثال: بعد أسبوعين من الالتزام أو تغيير البرنامج',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}

class MeasurementField extends StatelessWidget {
  const MeasurementField({
    required this.controller,
    required this.enabled,
    required this.label,
    super.key,
  });

  final TextEditingController controller;
  final bool enabled;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'cm',
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class MiniMetricCard extends StatelessWidget {
  const MiniMetricCard({
    required this.icon,
    required this.title,
    required this.value,
    super.key,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class ReportMetric extends StatelessWidget {
  const ReportMetric({
    required this.title,
    required this.value,
    required this.description,
    super.key,
  });

  final String title;
  final String value;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class MessageBox extends StatelessWidget {
  const MessageBox({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.text,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
