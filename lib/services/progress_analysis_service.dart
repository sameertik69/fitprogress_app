import '../models/analysis_request.dart';
import '../models/analysis_result.dart';
import '../models/muscle_metric.dart';
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
      muscleMetrics: result.muscleMetrics,
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
    final muscleMetrics = _buildMuscleMetrics(
      sessionNumber: sessionNumber,
      visualScore: visualScore,
      postureScore: postureScore,
    );

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
      muscleMetrics: muscleMetrics,
    );
  }

  List<MuscleMetric> _buildMuscleMetrics({
    required int sessionNumber,
    required int visualScore,
    required int postureScore,
  }) {
    final shoulderScore = (visualScore + 4).clamp(0, 100);
    final chestScore = (visualScore + sessionNumber).clamp(0, 100);
    final armsScore = (visualScore - 3 + sessionNumber).clamp(0, 100);
    final coreScore = ((visualScore + postureScore) / 2).round().clamp(0, 100);

    return [
      MuscleMetric(
        name: 'الأكتاف',
        score: shoulderScore,
        status: _statusFor(shoulderScore),
        note: 'قراءة اتساع الجزء العلوي مقارنة بالخصر.',
      ),
      MuscleMetric(
        name: 'الصدر',
        score: chestScore,
        status: _statusFor(chestScore),
        note: 'تقدير امتلاء الصدر من الصورة الأمامية.',
      ),
      MuscleMetric(
        name: 'الذراعين',
        score: armsScore,
        status: _statusFor(armsScore),
        note: 'قراءة تقديرية تتأثر بزاوية الذراعين.',
      ),
      MuscleMetric(
        name: 'الخصر والجذع',
        score: coreScore,
        status: _statusFor(coreScore),
        note: 'يعتمد على ثبات الوقفة ونسبة الكتف إلى الخصر.',
      ),
    ];
  }

  String _statusFor(int score) {
    if (score >= 85) {
      return 'قوي';
    }
    if (score >= 76) {
      return 'جيد';
    }
    if (score >= 68) {
      return 'مقبول';
    }

    return 'بحاجة لمتابعة';
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
