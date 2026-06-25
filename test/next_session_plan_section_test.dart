import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitprogress_app/models/muscle_metric.dart';
import 'package:fitprogress_app/models/progress_session.dart';
import 'package:fitprogress_app/widgets/next_session_plan_section.dart';

void main() {
  test('builds next session plan from latest sessions', () {
    final plan = NextSessionPlan.fromSessions([
      _session(
        score: 81,
        weightKg: 82.5,
        phaseLabel: 'تنشيف',
        muscles: const [
          MuscleMetric(name: 'الأكتاف', score: 82, status: 'جيد', note: 'تحسن'),
          MuscleMetric(name: 'الصدر', score: 70, status: 'مقبول', note: 'أبطأ'),
        ],
      ),
      _session(
        score: 78,
        muscles: const [
          MuscleMetric(name: 'الأكتاف', score: 76, status: 'جيد', note: 'سابق'),
          MuscleMetric(name: 'الصدر', score: 72, status: 'مقبول', note: 'سابق'),
        ],
      ),
    ]);

    expect(plan.targetScore, 83);
    expect(plan.focusMuscle, 'الصدر');
    expect(plan.contextGuidance, contains('حافظ على تسجيل الوزن'));
  });

  testWidgets('shows next session plan section', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: NextSessionPlanSection(
              sessions: [_session(score: 81), _session(score: 78)],
            ),
          ),
        ),
      ),
    );

    expect(find.text('خطة الجلسة القادمة'), findsOneWidget);
    expect(find.text('هدف النتيجة'), findsOneWidget);
    expect(find.text('83%'), findsOneWidget);
    expect(find.text('تركيز العضلة'), findsOneWidget);
  });
}

ProgressSession _session({
  required int score,
  double? weightKg,
  String phaseLabel = '',
  List<MuscleMetric> muscles = defaultMuscleMetrics,
}) {
  return ProgressSession(
    createdAt: DateTime(2026, 6, 21),
    visualScore: score,
    confidence: 'متوسط',
    postureScore: 84,
    summary: 'جلسة اختبار',
    symmetryLabel: 'جيد',
    comparabilityLabel: 'مقبولة',
    shoulderWaistChange: 5.2,
    recommendation: 'حافظ على نفس ظروف التصوير',
    weightKg: weightKg,
    phaseLabel: phaseLabel,
    muscleMetrics: muscles,
  );
}
