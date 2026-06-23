import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitprogress_app/models/analysis_request.dart';
import 'package:fitprogress_app/models/photo_angle.dart';
import 'package:fitprogress_app/services/progress_analysis_service.dart';

void main() {
  test('returns a structured mock analysis result', () async {
    const service = ProgressAnalysisService();

    final result = await service.analyze(
      const AnalysisRequest(photos: {}, previousSessions: []),
    );

    expect(result.visualScore, 73);
    expect(result.postureScore, 80);
    expect(result.confidence, 'بحاجة لتحسين');
    expect(result.symmetryLabel, 'مقبول');
    expect(result.comparabilityLabel, 'ضعيفة');
    expect(result.summary, contains('الجلسة رقم 1'));
  });

  test('uses photo count and previous sessions to shape the result', () async {
    const service = ProgressAnalysisService();

    final firstSession = service.createSessionFromResult(
      await service.analyze(
        const AnalysisRequest(photos: {}, previousSessions: []),
      ),
    );
    final result = await service.analyze(
      AnalysisRequest(
        photos: {
          PhotoAngle.front: XFile.fromData(Uint8List(0), name: 'front.jpg'),
          PhotoAngle.side: XFile.fromData(Uint8List(0), name: 'side.jpg'),
          PhotoAngle.back: XFile.fromData(Uint8List(0), name: 'back.jpg'),
        },
        previousSessions: [firstSession],
      ),
    );

    expect(result.visualScore, 76);
    expect(result.postureScore, 87);
    expect(result.confidence, 'متوسط');
    expect(result.comparabilityLabel, 'قوية');
  });

  test('ai mode is explicit but not connected yet', () async {
    const service = ProgressAnalysisService(mode: AnalysisMode.ai);

    expect(
      () => service.analyze(
        const AnalysisRequest(photos: {}, previousSessions: []),
      ),
      throwsA(isA<UnimplementedError>()),
    );
  });
}
