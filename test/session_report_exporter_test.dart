import 'package:flutter_test/flutter_test.dart';

import 'package:fitprogress_app/models/body_measurements.dart';
import 'package:fitprogress_app/models/muscle_metric.dart';
import 'package:fitprogress_app/models/progress_session.dart';
import 'package:fitprogress_app/services/session_report_exporter.dart';

void main() {
  test('exports session report as readable text', () {
    const exporter = SessionReportExporter();
    final text = exporter.buildText(
      ProgressSession(
        createdAt: DateTime(2026, 6, 21, 12),
        visualScore: 81,
        confidence: 'مرتفع',
        postureScore: 88,
        summary: 'ملخص الجلسة',
        symmetryLabel: 'جيد',
        comparabilityLabel: 'قوية',
        shoulderWaistChange: 6.1,
        recommendation: 'استمر',
        weightKg: 82.5,
        phaseLabel: 'تنشيف',
        note: 'أسبوع جيد',
        measurements: BodyMeasurements(waistCm: 82, chestCm: 104),
        muscleMetrics: [
          MuscleMetric(
            name: 'الأكتاف',
            score: 82,
            status: 'جيد',
            note: 'تحسن واضح',
          ),
        ],
      ),
    );

    expect(text, contains('FitProgress AI - تقرير جلسة'));
    expect(text, contains('تقدير التطور البصري: 81%'));
    expect(text, contains('- الخصر: 82.0 cm'));
    expect(text, contains('- الأكتاف: 82% (جيد)'));
    expect(text, contains('أسبوع جيد'));
  });

  test('exports printable html for PDF flow', () {
    const exporter = SessionReportExporter();
    final html = exporter.buildPrintableHtml(
      ProgressSession(
        createdAt: DateTime(2026, 6, 21, 12),
        visualScore: 81,
        confidence: 'مرتفع',
        postureScore: 88,
        summary: 'ملخص <الجلسة>',
        symmetryLabel: 'جيد',
        comparabilityLabel: 'قوية',
        shoulderWaistChange: 6.1,
        recommendation: 'استمر',
      ),
    );

    expect(html, contains('<!doctype html>'));
    expect(html, contains('حفظ PDF / طباعة'));
    expect(html, contains('ملخص &lt;الجلسة&gt;'));
  });
}
