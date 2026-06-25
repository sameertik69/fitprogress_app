import 'analysis_result.dart';
import 'muscle_metric.dart';

class AiAnalysisResponse {
  const AiAnalysisResponse({
    required this.visualScore,
    required this.confidence,
    required this.postureScore,
    required this.summary,
    required this.symmetryLabel,
    required this.comparabilityLabel,
    required this.shoulderWaistChange,
    required this.recommendation,
    required this.muscleMetrics,
  });

  final int visualScore;
  final String confidence;
  final int postureScore;
  final String summary;
  final String symmetryLabel;
  final String comparabilityLabel;
  final double shoulderWaistChange;
  final String recommendation;
  final List<MuscleMetric> muscleMetrics;

  factory AiAnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResponse(
      visualScore: _score(json['visualScore']),
      confidence: _text(json['confidence']),
      postureScore: _score(json['postureScore']),
      summary: _text(json['summary']),
      symmetryLabel: _text(json['symmetryLabel']),
      comparabilityLabel: _text(json['comparabilityLabel']),
      shoulderWaistChange: _number(json['shoulderWaistChange']),
      recommendation: _text(json['recommendation']),
      muscleMetrics: _muscleMetrics(json['muscleMetrics']),
    );
  }

  AnalysisResult toAnalysisResult() {
    return AnalysisResult(
      visualScore: visualScore,
      confidence: confidence,
      postureScore: postureScore,
      summary: summary,
      symmetryLabel: symmetryLabel,
      comparabilityLabel: comparabilityLabel,
      shoulderWaistChange: shoulderWaistChange,
      recommendation: recommendation,
      muscleMetrics: muscleMetrics,
    );
  }

  static List<MuscleMetric> _muscleMetrics(Object? value) {
    if (value is! List) {
      return defaultMuscleMetrics;
    }

    final metrics = <MuscleMetric>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        metrics.add(MuscleMetric.fromJson(item));
      } else if (item is Map) {
        metrics.add(MuscleMetric.fromJson(Map<String, dynamic>.from(item)));
      }
    }

    return metrics.isEmpty ? defaultMuscleMetrics : metrics;
  }

  static int _score(Object? value) {
    if (value is num) {
      return value.clamp(0, 100).toInt();
    }

    throw const FormatException('AI score must be a number.');
  }

  static double _number(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    throw const FormatException('AI numeric field must be a number.');
  }

  static String _text(Object? value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    throw const FormatException('AI text field must be a non-empty string.');
  }
}
