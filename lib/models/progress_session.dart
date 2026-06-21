class ProgressSession {
  const ProgressSession({
    required this.createdAt,
    required this.visualScore,
    required this.confidence,
    required this.postureScore,
    required this.summary,
  });

  final DateTime createdAt;
  final int visualScore;
  final String confidence;
  final int postureScore;
  final String summary;
}
