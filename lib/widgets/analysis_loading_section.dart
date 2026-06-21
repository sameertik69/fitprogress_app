import 'package:flutter/material.dart';

class AnalysisLoadingSection extends StatelessWidget {
  const AnalysisLoadingSection({super.key});

  @override
  Widget build(BuildContext context) {
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
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'جاري تحليل الصور...',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const AnalysisStep(text: 'التحقق من وضوح الصور'),
          const SizedBox(height: 8),
          const AnalysisStep(text: 'مراجعة ثبات الزوايا والوقفة'),
          const SizedBox(height: 8),
          const AnalysisStep(text: 'حساب تقدير بصري أولي'),
          const SizedBox(height: 8),
          const AnalysisStep(text: 'تجهيز تقرير التقدم'),
        ],
      ),
    );
  }
}

class AnalysisStep extends StatelessWidget {
  const AnalysisStep({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(Icons.check_circle_outline, size: 18, color: colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
