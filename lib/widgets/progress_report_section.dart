import 'package:flutter/material.dart';

class ProgressReportSection extends StatelessWidget {
  const ProgressReportSection({
    required this.isSaved,
    required this.onSaveReport,
    required this.onEditPhotos,
    required this.onResetScan,
    super.key,
  });

  final bool isSaved;
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
              Text(
                'تقرير التقدم التجريبي',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ReportSummaryCard(),
          const SizedBox(height: 12),
          const ScoreCard(),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: MiniMetricCard(
                  icon: Icons.balance_outlined,
                  title: 'التناسق العام',
                  value: 'جيد',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: MiniMetricCard(
                  icon: Icons.accessibility_new,
                  title: 'ثبات الوقفة',
                  value: '81%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: MiniMetricCard(
                  icon: Icons.image_search_outlined,
                  title: 'وضوح الصور',
                  value: 'متوسط',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: MiniMetricCard(
                  icon: Icons.compare_arrows,
                  title: 'قابلية المقارنة',
                  value: 'مقبولة',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ReportMetric(
            title: 'تقدير التطور البصري',
            value: '72%',
            description:
                'تحسن ظاهر في تناسق الجزء العلوي مقارنة بالجلسة السابقة.',
          ),
          const Divider(height: 24),
          const ReportMetric(
            title: 'مؤشر الثقة',
            value: 'متوسط',
            description:
                'يعتمد على ثبات الإضاءة والمسافة ووضوح الصور المختارة.',
          ),
          const Divider(height: 24),
          const ReportMetric(
            title: 'تغير نسبة الكتف إلى الخصر',
            value: '+4.8%',
            description:
                'تغير تقديري مبني على مقارنة بصرية وليس قياسًا تشريحيًا دقيقًا.',
          ),
          const Divider(height: 24),
          const ReportMetric(
            title: 'ثبات الوقفة',
            value: '81%',
            description:
                'كلما كانت الوقفة أقرب بين الجلسات كانت المقارنة أفضل.',
          ),
          const SizedBox(height: 16),
          const RecommendationBox(),
          const SizedBox(height: 12),
          const WarningBox(),
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
  const ReportSummaryCard({super.key});

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
                  'تحسن بصري جيد',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'المقارنة التجريبية تشير إلى تقدم جيد في شكل الجزء العلوي، مع حاجة بسيطة لتحسين ثبات ظروف التصوير في الجلسات القادمة.',
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
  const ScoreCard({super.key});

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
              value: 0.72,
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
                  '72%',
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

class RecommendationBox extends StatelessWidget {
  const RecommendationBox({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MessageBox(
      icon: Icons.lightbulb_outline,
      iconColor: colorScheme.primary,
      title: 'توصية الجلسة القادمة',
      text:
          'استمر بنفس طريقة التصوير: نفس المسافة، نفس الإضاءة، ونفس الوقفة. هذا يجعل مقارنة تطور الجسم والعضلات أكثر اتساقًا.',
    );
  }
}

class WarningBox extends StatelessWidget {
  const WarningBox({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MessageBox(
      icon: Icons.info_outline,
      iconColor: colorScheme.tertiary,
      title: 'تنبيه مهم',
      text:
          'هذه النتائج تقديرية وتجريبية، ولا تمثل قياسًا طبيًا أو قياسًا دقيقًا للكتلة العضلية. التحليل الحقيقي سيُضاف لاحقًا.',
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
