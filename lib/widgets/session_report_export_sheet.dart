import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/progress_session.dart';
import '../services/report_print_launcher.dart';
import '../services/session_report_exporter.dart';

Future<void> showSessionReportExportSheet(
  BuildContext context,
  ProgressSession session,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) {
      return SessionReportExportSheet(session: session);
    },
  );
}

class SessionReportExportSheet extends StatelessWidget {
  const SessionReportExportSheet({required this.session, super.key});

  final ProgressSession session;

  @override
  Widget build(BuildContext context) {
    const exporter = SessionReportExporter();
    final reportText = exporter.buildText(session);
    final colorScheme = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.82,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'تصدير التقرير',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Text(
                  'إذا لم يعمل النسخ التلقائي على الموبايل، حدد النص من المربع وانسخه يدويًا.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        reportText,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(height: 1.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _copyReport(context, reportText),
                  icon: const Icon(Icons.content_copy),
                  label: const Text('نسخ التقرير'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => _openPdf(context, exporter),
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  label: const Text('فتح PDF / طباعة'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _copyReport(BuildContext context, String reportText) async {
    try {
      await Clipboard.setData(ClipboardData(text: reportText));
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم نسخ التقرير')));
    } on Object {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر النسخ التلقائي، حدد النص يدويًا')),
      );
    }
  }

  void _openPdf(BuildContext context, SessionReportExporter exporter) {
    final didOpen = openPrintableReport(exporter.buildPrintableHtml(session));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          didOpen
              ? 'اختر حفظ PDF من نافذة الطباعة'
              : 'فتح PDF متاح حاليًا على نسخة الويب',
        ),
      ),
    );
  }
}
