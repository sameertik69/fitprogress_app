import '../models/progress_session.dart';

class SessionReportExporter {
  const SessionReportExporter();

  String buildText(ProgressSession session) {
    final buffer = StringBuffer()
      ..writeln('FitProgress AI - تقرير جلسة')
      ..writeln('التاريخ: ${_formatDate(session.createdAt)}')
      ..writeln('تقدير التطور البصري: ${session.visualScore}%')
      ..writeln('مؤشر الثقة: ${session.confidence}')
      ..writeln('ثبات الوقفة: ${session.postureScore}%')
      ..writeln(
        'تغير الكتف إلى الخصر: ${session.shoulderWaistChange.toStringAsFixed(1)}%',
      );

    if (session.weightKg != null) {
      buffer.writeln('الوزن: ${session.weightKg!.toStringAsFixed(1)} kg');
    }
    if (session.phaseLabel.isNotEmpty) {
      buffer.writeln('المرحلة: ${session.phaseLabel}');
    }
    if (session.measurements.hasAny) {
      buffer
        ..writeln('')
        ..writeln('القياسات اليدوية:');
      _writeMeasurement(buffer, 'الخصر', session.measurements.waistCm);
      _writeMeasurement(buffer, 'الصدر', session.measurements.chestCm);
      _writeMeasurement(buffer, 'الذراع', session.measurements.armCm);
      _writeMeasurement(buffer, 'الكتف', session.measurements.shoulderCm);
    }

    buffer
      ..writeln('')
      ..writeln('تطور العضلات:');
    for (final metric in session.muscleMetrics) {
      buffer.writeln(
        '- ${metric.name}: ${metric.score}% (${metric.status}) - ${metric.note}',
      );
    }

    buffer
      ..writeln('')
      ..writeln('الملخص:')
      ..writeln(session.summary)
      ..writeln('')
      ..writeln('التوصية:')
      ..writeln(session.recommendation);

    if (session.note.isNotEmpty) {
      buffer
        ..writeln('')
        ..writeln('ملاحظات المستخدم:')
        ..writeln(session.note);
    }

    return buffer.toString();
  }

  String buildPrintableHtml(ProgressSession session) {
    final title = 'FitProgress AI - تقرير جلسة';
    final text = buildText(session);

    return '''
<!doctype html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>${_escapeHtml(title)}</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 24px;
      color: #17231d;
      line-height: 1.7;
    }
    .report {
      max-width: 760px;
      margin: 0 auto;
      border: 1px solid #d8e3dc;
      border-radius: 8px;
      padding: 24px;
    }
    h1 {
      font-size: 24px;
      margin: 0 0 16px;
      color: #1f7a5a;
    }
    pre {
      white-space: pre-wrap;
      font-family: inherit;
      font-size: 15px;
    }
    .actions {
      margin: 0 auto 16px;
      max-width: 760px;
      display: flex;
      gap: 8px;
    }
    button {
      border: 0;
      border-radius: 8px;
      padding: 10px 14px;
      background: #1f7a5a;
      color: white;
      font-weight: 700;
      cursor: pointer;
    }
    @media print {
      body { margin: 0; }
      .actions { display: none; }
      .report { border: 0; }
    }
  </style>
</head>
<body>
  <div class="actions">
    <button onclick="window.print()">حفظ PDF / طباعة</button>
  </div>
  <main class="report">
    <h1>${_escapeHtml(title)}</h1>
    <pre>${_escapeHtml(text)}</pre>
  </main>
</body>
</html>
''';
  }

  void _writeMeasurement(StringBuffer buffer, String label, double? value) {
    if (value == null) {
      return;
    }

    buffer.writeln('- $label: ${value.toStringAsFixed(1)} cm');
  }

  String _formatDate(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.year}/${date.month}/${date.day} - $hour:$minute';
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
