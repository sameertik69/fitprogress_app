import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitprogress_app/models/ai_analysis_response.dart';
import 'package:fitprogress_app/models/analysis_request.dart';
import 'package:fitprogress_app/models/photo_angle.dart';
import 'package:fitprogress_app/models/photo_readiness_report.dart';
import 'package:fitprogress_app/services/ai_analysis_provider.dart';
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
      throwsA(isA<AiAnalysisUnavailableException>()),
    );
  });

  test('ai mode can consume a provider response', () async {
    const service = ProgressAnalysisService(
      mode: AnalysisMode.ai,
      aiProvider: StaticAiAnalysisProvider(
        AiAnalysisResponse(
          visualScore: 91,
          confidence: 'مرتفع',
          postureScore: 89,
          summary: 'تحليل AI تجريبي',
          symmetryLabel: 'ممتاز',
          comparabilityLabel: 'قوية',
          shoulderWaistChange: 7.4,
          recommendation: 'استمر بنفس ظروف التصوير',
        ),
      ),
    );

    final result = await service.analyze(
      const AnalysisRequest(photos: {}, previousSessions: []),
    );

    expect(result.visualScore, 91);
    expect(result.summary, 'تحليل AI تجريبي');
  });

  test('ai response parser clamps scores and validates fields', () {
    final response = AiAnalysisResponse.fromJson({
      'visualScore': 120,
      'confidence': 'مرتفع',
      'postureScore': 88,
      'summary': 'نتيجة منظمة',
      'symmetryLabel': 'ممتاز',
      'comparabilityLabel': 'قوية',
      'shoulderWaistChange': 6.5,
      'recommendation': 'حافظ على نفس المسافة',
    });

    expect(response.visualScore, 100);
    expect(response.toAnalysisResult().recommendation, 'حافظ على نفس المسافة');
  });

  test(
    'builds an edge function payload without embedding image bytes',
    () async {
      const builder = AiAnalysisPayloadBuilder();
      const service = ProgressAnalysisService();
      final previousSession = service.createSessionFromResult(
        await service.analyze(
          const AnalysisRequest(photos: {}, previousSessions: []),
        ),
      );

      final payload = await builder.build(
        AnalysisRequest(
          photos: {
            PhotoAngle.front: XFile.fromData(Uint8List(12), name: 'front.jpg'),
          },
          previousSessions: [previousSession],
          weightKg: 82.5,
          phaseLabel: 'تنشيف',
          note: 'أسبوع جيد',
          readinessReport: const PhotoReadinessReport(
            level: PhotoReadinessLevel.ready,
            title: 'جاهز',
            message: 'الصور مناسبة',
            selectedCount: 3,
            totalBytes: 12,
            largeAngles: [],
          ),
        ),
      );

      final photos = payload['photos'] as List<Map<String, dynamic>>;
      final context = payload['context'] as Map<String, dynamic>;

      expect(photos.single['angle'], 'front');
      expect(photos.single['sizeBytes'], 12);
      expect(photos.single.containsKey('bytes'), isFalse);
      expect(context['weightKg'], 82.5);
      expect((payload['previousSessions'] as List).length, 1);
    },
  );
}
