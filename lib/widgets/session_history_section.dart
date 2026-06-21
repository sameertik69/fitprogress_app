import 'package:flutter/material.dart';

import '../models/progress_session.dart';

class SessionHistorySection extends StatelessWidget {
  const SessionHistorySection({
    required this.sessions,
    required this.showComparison,
    required this.onToggleComparison,
    required this.onDeleteSession,
    required this.onClearSessions,
    super.key,
  });

  final List<ProgressSession> sessions;
  final bool showComparison;
  final VoidCallback onToggleComparison;
  final ValueChanged<ProgressSession> onDeleteSession;
  final VoidCallback onClearSessions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'سجل الجلسات',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Text(
          'هذا سجل محلي مؤقت للتجربة. لاحقًا سيتم حفظه في قاعدة بيانات.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onClearSessions,
          icon: const Icon(Icons.delete_sweep_outlined),
          label: const Text('مسح السجل'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (sessions.length >= 2) ...[
          OutlinedButton.icon(
            onPressed: onToggleComparison,
            icon: const Icon(Icons.compare_arrows),
            label: Text(
              showComparison ? 'إخفاء المقارنة' : 'مقارنة آخر جلستين',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (showComparison) ...[
            SessionComparisonCard(current: sessions[0], previous: sessions[1]),
            const SizedBox(height: 12),
          ],
        ],
        for (final session in sessions) ...[
          SessionHistoryTile(
            session: session,
            onDelete: () => onDeleteSession(session),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class SessionComparisonCard extends StatelessWidget {
  const SessionComparisonCard({
    required this.current,
    required this.previous,
    super.key,
  });

  final ProgressSession current;
  final ProgressSession previous;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scoreDiff = current.visualScore - previous.visualScore;
    final postureDiff = current.postureScore - previous.postureScore;
    final shoulderDiff =
        current.shoulderWaistChange - previous.shoulderWaistChange;
    final scoreLabel = scoreDiff >= 0 ? '+$scoreDiff%' : '$scoreDiff%';
    final postureLabel = postureDiff >= 0 ? '+$postureDiff%' : '$postureDiff%';
    final shoulderLabel = shoulderDiff >= 0
        ? '+${shoulderDiff.toStringAsFixed(1)}%'
        : '${shoulderDiff.toStringAsFixed(1)}%';
    final weightLabel = _formatWeightDiff(current.weightKg, previous.weightKg);
    final summary = scoreDiff >= 0
        ? 'آخر جلسة تظهر تحسنًا بصريًا مقارنة بالجلسة السابقة.'
        : 'آخر جلسة أقل من السابقة. قد يكون السبب اختلاف الإضاءة أو الزاوية.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.compare_arrows, color: colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                'مقارنة آخر جلستين',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ComparisonRow(label: 'فرق تقدير التطور البصري', value: scoreLabel),
          const Divider(height: 22),
          ComparisonRow(label: 'فرق ثبات الوقفة', value: postureLabel),
          const Divider(height: 22),
          ComparisonRow(label: 'فرق الكتف إلى الخصر', value: shoulderLabel),
          if (weightLabel != null) ...[
            const Divider(height: 22),
            ComparisonRow(label: 'فرق الوزن المسجل', value: weightLabel),
          ],
          const SizedBox(height: 12),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  String? _formatWeightDiff(double? currentWeight, double? previousWeight) {
    if (currentWeight == null || previousWeight == null) {
      return null;
    }

    final diff = currentWeight - previousWeight;
    final value = diff.toStringAsFixed(1);
    return diff >= 0 ? '+$value kg' : '$value kg';
  }
}

class ComparisonRow extends StatelessWidget {
  const ComparisonRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = !value.startsWith('-');

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: isPositive ? colorScheme.primary : colorScheme.error,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class SessionHistoryTile extends StatelessWidget {
  const SessionHistoryTile({
    required this.session,
    required this.onDelete,
    super.key,
  });

  final ProgressSession session;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () => _showSessionDetails(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.history,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جلسة ${_formatSessionDate(session.createdAt)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'مؤشر الثقة: ${session.confidence}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (session.phaseLabel.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        session.phaseLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${session.visualScore}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.keyboard_arrow_left,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 2),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
                color: colorScheme.error,
                tooltip: 'حذف الجلسة',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'تفاصيل الجلسة',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatSessionDate(session.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SessionDetailRow(
                      label: 'تقدير التطور البصري',
                      value: '${session.visualScore}%',
                    ),
                    const Divider(height: 22),
                    SessionDetailRow(
                      label: 'مؤشر الثقة',
                      value: session.confidence,
                    ),
                    const Divider(height: 22),
                    SessionDetailRow(
                      label: 'ثبات الوقفة',
                      value: '${session.postureScore}%',
                    ),
                    const Divider(height: 22),
                    SessionDetailRow(
                      label: 'تغير الكتف إلى الخصر',
                      value:
                          '+${session.shoulderWaistChange.toStringAsFixed(1)}%',
                    ),
                    if (session.weightKg != null) ...[
                      const Divider(height: 22),
                      SessionDetailRow(
                        label: 'الوزن المسجل',
                        value: '${session.weightKg!.toStringAsFixed(1)} kg',
                      ),
                    ],
                    if (session.phaseLabel.isNotEmpty) ...[
                      const Divider(height: 22),
                      SessionDetailRow(
                        label: 'مرحلة التمرين',
                        value: session.phaseLabel,
                      ),
                    ],
                    const SizedBox(height: 14),
                    Text(
                      session.summary,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(height: 1.45),
                    ),
                    if (session.note.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        session.note,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatSessionDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}/${date.month}/${date.day} - $hour:$minute';
  }
}

class SessionDetailRow extends StatelessWidget {
  const SessionDetailRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
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
