import 'package:flutter/material.dart';

import '../models/muscle_metric.dart';
import '../models/photo_angle.dart';
import '../models/progress_session.dart';
import '../services/supabase_session_service.dart';
import 'muscle_breakdown_section.dart';
import 'session_report_export_sheet.dart';

enum SessionHistoryFilter { all, withMeasurements, withPhotos }

class SessionHistorySection extends StatefulWidget {
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
  State<SessionHistorySection> createState() => _SessionHistorySectionState();
}

class _SessionHistorySectionState extends State<SessionHistorySection> {
  SessionHistoryFilter _filter = SessionHistoryFilter.all;

  List<ProgressSession> get _filteredSessions {
    return switch (_filter) {
      SessionHistoryFilter.all => widget.sessions,
      SessionHistoryFilter.withMeasurements =>
        widget.sessions
            .where((session) => session.measurements.hasAny)
            .toList(growable: false),
      SessionHistoryFilter.withPhotos =>
        widget.sessions
            .where((session) => session.hasPhotoPaths)
            .toList(growable: false),
    };
  }

  @override
  Widget build(BuildContext context) {
    final filteredSessions = _filteredSessions;

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
          onPressed: widget.onClearSessions,
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
        SessionHistoryFilterBar(
          selectedFilter: _filter,
          onChanged: (filter) {
            setState(() {
              _filter = filter;
            });
          },
        ),
        const SizedBox(height: 12),
        if (widget.sessions.length >= 2) ...[
          OutlinedButton.icon(
            onPressed: widget.onToggleComparison,
            icon: const Icon(Icons.compare_arrows),
            label: Text(
              widget.showComparison ? 'إخفاء المقارنة' : 'مقارنة آخر جلستين',
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (widget.showComparison) ...[
            SessionComparisonCard(
              current: widget.sessions[0],
              previous: widget.sessions[1],
            ),
            const SizedBox(height: 12),
          ],
        ],
        if (filteredSessions.isEmpty) ...[
          const EmptyFilteredHistoryMessage(),
          const SizedBox(height: 10),
        ],
        for (final session in filteredSessions) ...[
          SessionHistoryTile(
            session: session,
            onDelete: () => widget.onDeleteSession(session),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class SessionHistoryFilterBar extends StatelessWidget {
  const SessionHistoryFilterBar({
    required this.selectedFilter,
    required this.onChanged,
    super.key,
  });

  final SessionHistoryFilter selectedFilter;
  final ValueChanged<SessionHistoryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SessionHistoryFilter>(
      segments: const [
        ButtonSegment(
          value: SessionHistoryFilter.all,
          label: Text('الكل'),
          icon: Icon(Icons.list),
        ),
        ButtonSegment(
          value: SessionHistoryFilter.withMeasurements,
          label: Text('قياسات'),
          icon: Icon(Icons.straighten),
        ),
        ButtonSegment(
          value: SessionHistoryFilter.withPhotos,
          label: Text('صور'),
          icon: Icon(Icons.photo_library_outlined),
        ),
      ],
      selected: {selectedFilter},
      onSelectionChanged: (selection) => onChanged(selection.first),
      showSelectedIcon: false,
    );
  }
}

class EmptyFilteredHistoryMessage extends StatelessWidget {
  const EmptyFilteredHistoryMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'لا توجد جلسات تطابق هذا الفلتر.',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
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
  static const _supabaseSessionService = SupabaseSessionService();

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
          if (current.hasPhotoPaths && previous.hasPhotoPaths) ...[
            const SizedBox(height: 14),
            SessionPhotoComparison(
              current: current,
              previous: previous,
              service: _supabaseSessionService,
            ),
          ],
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
          const SizedBox(height: 16),
          MuscleComparisonSection(
            currentMetrics: current.muscleMetrics,
            previousMetrics: previous.muscleMetrics,
          ),
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

class MuscleComparisonSection extends StatelessWidget {
  const MuscleComparisonSection({
    required this.currentMetrics,
    required this.previousMetrics,
    super.key,
  });

  final List<MuscleMetric> currentMetrics;
  final List<MuscleMetric> previousMetrics;

  @override
  Widget build(BuildContext context) {
    final rows = _comparisonRows();
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    final summary = MuscleComparisonSummary.fromRows(rows);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'فرق العضلات',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        for (final row in rows) ...[
          MuscleComparisonRow(row: row),
          if (row != rows.last) const SizedBox(height: 8),
        ],
        const SizedBox(height: 10),
        MuscleComparisonSummaryCard(summary: summary),
      ],
    );
  }

  List<MuscleComparisonData> _comparisonRows() {
    final previousByName = {
      for (final metric in previousMetrics) metric.name: metric,
    };

    final rows = <MuscleComparisonData>[];
    for (final currentMetric in currentMetrics) {
      final previousMetric = previousByName[currentMetric.name];
      if (previousMetric == null) {
        continue;
      }

      rows.add(
        MuscleComparisonData(
          name: currentMetric.name,
          currentScore: currentMetric.score,
          previousScore: previousMetric.score,
        ),
      );
    }

    return rows;
  }
}

class MuscleComparisonSummary {
  const MuscleComparisonSummary({
    required this.best,
    required this.needsAttention,
  });

  final MuscleComparisonData best;
  final MuscleComparisonData needsAttention;

  factory MuscleComparisonSummary.fromRows(List<MuscleComparisonData> rows) {
    final sortedRows = [...rows]..sort((a, b) => b.diff.compareTo(a.diff));
    final attentionRows = [...rows]..sort((a, b) => a.diff.compareTo(b.diff));

    return MuscleComparisonSummary(
      best: sortedRows.first,
      needsAttention: attentionRows.first,
    );
  }
}

class MuscleComparisonSummaryCard extends StatelessWidget {
  const MuscleComparisonSummaryCard({required this.summary, super.key});

  final MuscleComparisonSummary summary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.auto_graph, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'ملخص العضلات',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'أفضل تحسن: ${summary.best.name} (${summary.best.diffLabel}).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary.needsAttention.diff < 0
                ? 'تحتاج متابعة: ${summary.needsAttention.name} (${summary.needsAttention.diffLabel}).'
                : 'أقل تحسن: ${summary.needsAttention.name} (${summary.needsAttention.diffLabel}).',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: summary.needsAttention.diff < 0
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class MuscleComparisonData {
  const MuscleComparisonData({
    required this.name,
    required this.currentScore,
    required this.previousScore,
  });

  final String name;
  final int currentScore;
  final int previousScore;

  int get diff => currentScore - previousScore;

  String get diffLabel {
    if (diff == 0) {
      return '0%';
    }

    return diff > 0 ? '+$diff%' : '$diff%';
  }
}

class MuscleComparisonRow extends StatelessWidget {
  const MuscleComparisonRow({required this.row, super.key});

  final MuscleComparisonData row;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isPositive = row.diff >= 0;
    final diffColor = isPositive ? colorScheme.primary : colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  'من ${row.previousScore}% إلى ${row.currentScore}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            row.diffLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: diffColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class SessionPhotoComparison extends StatelessWidget {
  const SessionPhotoComparison({
    required this.current,
    required this.previous,
    required this.service,
    super.key,
  });

  final ProgressSession current;
  final ProgressSession previous;
  final SupabaseSessionService service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<
      ({Map<String, String> current, Map<String, String> previous})
    >(
      future: _loadPhotoUrls(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 140,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data;
        if (data == null || data.current.isEmpty || data.previous.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              'المقارنة المصورة غير متاحة لهذه الجلسات.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'مقارنة الصور',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            for (final angle in PhotoAngle.values) ...[
              if (data.current[angle.storageName] != null &&
                  data.previous[angle.storageName] != null) ...[
                PhotoAngleComparisonRow(
                  label: angle.arabicLabel,
                  currentUrl: data.current[angle.storageName]!,
                  previousUrl: data.previous[angle.storageName]!,
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        );
      },
    );
  }

  Future<({Map<String, String> current, Map<String, String> previous})>
  _loadPhotoUrls() async {
    final currentUrls = await service.createSignedPhotoUrlsByAngle(current);
    final previousUrls = await service.createSignedPhotoUrlsByAngle(previous);
    return (current: currentUrls, previous: previousUrls);
  }
}

class PhotoAngleComparisonRow extends StatelessWidget {
  const PhotoAngleComparisonRow({
    required this.label,
    required this.currentUrl,
    required this.previousUrl,
    super.key,
  });

  final String label;
  final String currentUrl;
  final String previousUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LabeledComparisonPhoto(
                  label: 'السابقة',
                  url: previousUrl,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LabeledComparisonPhoto(
                  label: 'الحالية',
                  url: currentUrl,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LabeledComparisonPhoto extends StatelessWidget {
  const LabeledComparisonPhoto({
    required this.label,
    required this.url,
    super.key,
  });

  final String label;
  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        StoredPhotoPreview(url: url),
      ],
    );
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
  static const _supabaseSessionService = SupabaseSessionService();

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
                    if (session.measurements.hasAny) ...[
                      const SizedBox(height: 16),
                      SessionMeasurementsSection(session: session),
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
                    MuscleBreakdownSection(metrics: session.muscleMetrics),
                    if (session.hasPhotoPaths) ...[
                      const SizedBox(height: 16),
                      SessionStoredPhotos(
                        session: session,
                        service: _supabaseSessionService,
                      ),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () =>
                          showSessionReportExportSheet(context, session),
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

class SessionMeasurementsSection extends StatelessWidget {
  const SessionMeasurementsSection({required this.session, super.key});

  final ProgressSession session;

  @override
  Widget build(BuildContext context) {
    final measurements = session.measurements;
    final rows = <({String label, double? value})>[
      (label: 'الخصر', value: measurements.waistCm),
      (label: 'الصدر', value: measurements.chestCm),
      (label: 'الذراع', value: measurements.armCm),
      (label: 'الكتف', value: measurements.shoulderCm),
    ].where((row) => row.value != null).toList(growable: false);

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'القياسات اليدوية',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final row in rows)
              MeasurementChip(label: row.label, value: row.value!),
          ],
        ),
      ],
    );
  }
}

class MeasurementChip extends StatelessWidget {
  const MeasurementChip({required this.label, required this.value, super.key});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label ${value.toStringAsFixed(1)} cm',
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class SessionStoredPhotos extends StatelessWidget {
  const SessionStoredPhotos({
    required this.session,
    required this.service,
    super.key,
  });

  final ProgressSession session;
  final SupabaseSessionService service;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<List<String>>(
      future: service.createSignedPhotoUrls(session),
      builder: (context, snapshot) {
        final urls = snapshot.data ?? const [];
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 96,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (urls.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'تعذر تحميل صور الجلسة الآن.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'صور الجلسة',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final url in urls) ...[
                  Expanded(child: StoredPhotoPreview(url: url)),
                  if (url != urls.last) const SizedBox(width: 8),
                ],
              ],
            ),
          ],
        );
      },
    );
  }
}

class StoredPhotoPreview extends StatelessWidget {
  const StoredPhotoPreview({required this.url, super.key});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return ColoredBox(
              color: colorScheme.errorContainer,
              child: Icon(
                Icons.broken_image_outlined,
                color: colorScheme.onErrorContainer,
              ),
            );
          },
        ),
      ),
    );
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
