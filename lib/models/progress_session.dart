class ProgressSession {
  const ProgressSession({
    required this.createdAt,
    required this.visualScore,
    required this.confidence,
    required this.postureScore,
    required this.summary,
    required this.symmetryLabel,
    required this.comparabilityLabel,
    required this.shoulderWaistChange,
    required this.recommendation,
    this.weightKg,
    this.note = '',
    this.phaseLabel = '',
  });

  final DateTime createdAt;
  final int visualScore;
  final String confidence;
  final int postureScore;
  final String summary;
  final String symmetryLabel;
  final String comparabilityLabel;
  final double shoulderWaistChange;
  final String recommendation;
  final double? weightKg;
  final String note;
  final String phaseLabel;

  factory ProgressSession.fromJson(Map<String, dynamic> json) {
    return ProgressSession(
      createdAt: DateTime.parse(json['createdAt'] as String),
      visualScore: json['visualScore'] as int,
      confidence: json['confidence'] as String,
      postureScore: json['postureScore'] as int,
      summary: json['summary'] as String,
      symmetryLabel: json['symmetryLabel'] as String? ?? 'جيد',
      comparabilityLabel: json['comparabilityLabel'] as String? ?? 'مقبولة',
      shoulderWaistChange:
          (json['shoulderWaistChange'] as num?)?.toDouble() ?? 4.8,
      recommendation:
          json['recommendation'] as String? ??
          'استمر بنفس طريقة التصوير: نفس المسافة، نفس الإضاءة، ونفس الوقفة.',
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      note: json['note'] as String? ?? '',
      phaseLabel: json['phaseLabel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'createdAt': createdAt.toIso8601String(),
      'visualScore': visualScore,
      'confidence': confidence,
      'postureScore': postureScore,
      'summary': summary,
      'symmetryLabel': symmetryLabel,
      'comparabilityLabel': comparabilityLabel,
      'shoulderWaistChange': shoulderWaistChange,
      'recommendation': recommendation,
      'weightKg': weightKg,
      'note': note,
      'phaseLabel': phaseLabel,
    };
  }

  ProgressSession copyWith({
    DateTime? createdAt,
    int? visualScore,
    String? confidence,
    int? postureScore,
    String? summary,
    String? symmetryLabel,
    String? comparabilityLabel,
    double? shoulderWaistChange,
    String? recommendation,
    double? weightKg,
    String? note,
    String? phaseLabel,
  }) {
    return ProgressSession(
      createdAt: createdAt ?? this.createdAt,
      visualScore: visualScore ?? this.visualScore,
      confidence: confidence ?? this.confidence,
      postureScore: postureScore ?? this.postureScore,
      summary: summary ?? this.summary,
      symmetryLabel: symmetryLabel ?? this.symmetryLabel,
      comparabilityLabel: comparabilityLabel ?? this.comparabilityLabel,
      shoulderWaistChange: shoulderWaistChange ?? this.shoulderWaistChange,
      recommendation: recommendation ?? this.recommendation,
      weightKg: weightKg ?? this.weightKg,
      note: note ?? this.note,
      phaseLabel: phaseLabel ?? this.phaseLabel,
    );
  }
}
