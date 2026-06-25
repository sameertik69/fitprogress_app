import 'package:flutter_test/flutter_test.dart';

import 'package:fitprogress_app/models/body_measurements.dart';
import 'package:fitprogress_app/models/progress_session.dart';
import 'package:fitprogress_app/widgets/data_quality_dashboard.dart';

void main() {
  test('builds data quality snapshot from sessions', () {
    final snapshot = DataQualitySnapshot.fromSessions([
      _session(
        postureScore: 90,
        measurements: const BodyMeasurements(waistCm: 82),
        frontPhotoPath: 'user/session/front.jpg',
      ),
      _session(postureScore: 78),
    ]);

    expect(snapshot.sessionCount, 2);
    expect(snapshot.averagePostureScore, 84);
    expect(snapshot.hasEnoughSessions, isTrue);
    expect(snapshot.hasMeasurements, isTrue);
    expect(snapshot.hasPhotos, isTrue);
    expect(snapshot.isAiReady, isTrue);
  });

  test('marks data as incomplete when sessions are missing context', () {
    final snapshot = DataQualitySnapshot.fromSessions([_session()]);

    expect(snapshot.isAiReady, isFalse);
    expect(snapshot.aiReadinessLabel, 'ناقصة');
    expect(snapshot.notice, contains('جلستين'));
  });
}

ProgressSession _session({
  int postureScore = 84,
  BodyMeasurements measurements = const BodyMeasurements(),
  String? frontPhotoPath,
}) {
  return ProgressSession(
    createdAt: DateTime(2026, 6, 21),
    visualScore: 80,
    confidence: 'متوسط',
    postureScore: postureScore,
    summary: 'جلسة اختبار',
    symmetryLabel: 'جيد',
    comparabilityLabel: 'مقبولة',
    shoulderWaistChange: 5.2,
    recommendation: 'حافظ على نفس ظروف التصوير',
    measurements: measurements,
    frontPhotoPath: frontPhotoPath,
  );
}
