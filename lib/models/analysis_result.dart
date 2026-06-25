import 'muscle_metric.dart';

class AnalysisResult {
  const AnalysisResult({
    required this.visualScore,
    required this.confidence,
    required this.postureScore,
    required this.summary,
    required this.symmetryLabel,
    required this.comparabilityLabel,
    required this.shoulderWaistChange,
    required this.recommendation,
    this.muscleMetrics = defaultMuscleMetrics,
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
}
