import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitprogress_app/models/progress_session.dart';
import 'package:fitprogress_app/widgets/progress_trend_section.dart';

void main() {
  test('builds a trend snapshot from newest-first sessions', () {
    final sessions = [
      _session(score: 84, createdAt: DateTime(2026, 6, 22)),
      _session(score: 81, createdAt: DateTime(2026, 6, 21)),
      _session(score: 76, createdAt: DateTime(2026, 6, 20)),
    ];

    final trend = ProgressTrendSnapshot.fromSessions(sessions);

    expect(trend.latestScore, 84);
    expect(trend.change, 8);
    expect(trend.changeLabel, '+8%');
    expect(trend.bestScore, 84);
    expect(trend.recentAverageScore, 80);
    expect(trend.chartScores, [76, 81, 84]);
  });

  testWidgets('shows progress trend section metrics', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: ProgressTrendSection(
              sessions: [
                _session(score: 84, createdAt: DateTime(2026, 6, 22)),
                _session(score: 76, createdAt: DateTime(2026, 6, 20)),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('اتجاه التطور'), findsOneWidget);
    expect(find.text('آخر نتيجة'), findsOneWidget);
    expect(find.text('84%'), findsNWidgets(2));
    expect(find.text('+8%'), findsOneWidget);
  });
}

ProgressSession _session({required int score, required DateTime createdAt}) {
  return ProgressSession(
    createdAt: createdAt,
    visualScore: score,
    confidence: 'متوسط',
    postureScore: 80,
    summary: 'ملخص جلسة',
    symmetryLabel: 'جيد',
    comparabilityLabel: 'مقبولة',
    shoulderWaistChange: 4.8,
    recommendation: 'حافظ على نفس ظروف التصوير',
  );
}
