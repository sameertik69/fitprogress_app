import '../models/analysis_request.dart';
import '../models/analysis_result.dart';
import '../models/photo_readiness_report.dart';
import '../models/progress_session.dart';
import 'analysis_config.dart';
import 'ai_analysis_provider.dart';

abstract class AnalysisEngine {
  const AnalysisEngine();

  Future<AnalysisResult> analyze(AnalysisRequest request);
}

class ProgressAnalysisService {
  const ProgressAnalysisService({
    this.mode = analysisMode,
    this.aiProvider = const EdgeFunctionAiAnalysisProvider(),
  });

  final AnalysisMode mode;
  final AiAnalysisProvider aiProvider;

  Future<AnalysisResult> analyze(AnalysisRequest request) {
    return _engine.analyze(request);
  }

  AnalysisEngine get _engine {
    return switch (mode) {
      AnalysisMode.mock => const MockAnalysisEngine(),
      AnalysisMode.ai => AiAnalysisEngine(aiProvider),
    };
  }

  ProgressSession createSessionFromResult(AnalysisResult result) {
    return ProgressSession(
      createdAt: DateTime.now(),
      visualScore: result.visualScore,
      confidence: result.confidence,
      postureScore: result.postureScore,
      summary: result.summary,
      symmetryLabel: result.symmetryLabel,
      comparabilityLabel: result.comparabilityLabel,
      shoulderWaistChange: result.shoulderWaistChange,
      recommendation: result.recommendation,
    );
  }
}

class MockAnalysisEngine extends AnalysisEngine {
  const MockAnalysisEngine();

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    await Future<void>.delayed(const Duration(seconds: 2));

    final sessionNumber = request.previousSessions.length + 1;
    final visualScore = (70 + sessionNumber * 3).clamp(70, 92).toInt();
    final postureScore = (79 + (request.photos.length * 2) + sessionNumber)
        .clamp(78, 95)
        .toInt();
    final shoulderWaistChange = 3.4 + sessionNumber * 0.7;
    final confidence = postureScore >= 88
        ? 'مرتفع'
        : postureScore >= 82
        ? 'متوسط'
        : 'بحاجة لتحسين';
    final symmetryLabel = visualScore >= 84
        ? 'ممتاز'
        : visualScore >= 76
        ? 'جيد'
        : 'مقبول';
    final comparabilityLabel = postureScore >= 86
        ? 'قوية'
        : postureScore >= 81
        ? 'مقبولة'
        : 'ضعيفة';
    final noteContext = request.note.trim().isEmpty
        ? ''
        : ' ملاحظة المستخدم أخذت بعين الاعتبار كسياق للجلسة.';
    final readinessContext =
        request.readinessReport?.level == PhotoReadinessLevel.attention
        ? ' هناك ملاحظة على حجم الصور أو جاهزيتها، لذلك يفضل تثبيت ظروف التصوير في الجلسة القادمة.'
        : '';

    return AnalysisResult(
      visualScore: visualScore,
      confidence: confidence,
      postureScore: postureScore,
      symmetryLabel: symmetryLabel,
      comparabilityLabel: comparabilityLabel,
      shoulderWaistChange: double.parse(shoulderWaistChange.toStringAsFixed(1)),
      summary:
          'الجلسة رقم $sessionNumber تظهر قراءة بصرية $symmetryLabel مع قابلية مقارنة $comparabilityLabel. ثبات الصور يؤثر مباشرة على دقة متابعة تطور الجسم والعضلات.$noteContext$readinessContext',
      recommendation:
          'للجلسة القادمة حافظ على نفس المسافة والإضاءة والوقفة، واكتب الوزن أو مرحلة التمرين حتى تصبح المقارنة أوضح.',
    );
  }
}

class AiAnalysisEngine extends AnalysisEngine {
  const AiAnalysisEngine(this.provider);

  final AiAnalysisProvider provider;

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) {
    return provider.analyze(request);
  }
}
