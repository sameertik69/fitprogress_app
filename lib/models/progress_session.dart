class ProgressSession {
  const ProgressSession({
    this.id,
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
    this.frontPhotoPath,
    this.sidePhotoPath,
    this.backPhotoPath,
  });

  final String? id;
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
  final String? frontPhotoPath;
  final String? sidePhotoPath;
  final String? backPhotoPath;

  List<String> get photoPaths {
    return [?frontPhotoPath, ?sidePhotoPath, ?backPhotoPath];
  }

  bool get hasPhotoPaths => photoPaths.isNotEmpty;

  Map<String, String> get photoPathsByAngle {
    return {
      'front': ?frontPhotoPath,
      'side': ?sidePhotoPath,
      'back': ?backPhotoPath,
    };
  }

  factory ProgressSession.fromJson(Map<String, dynamic> json) {
    return ProgressSession(
      id: json['id'] as String?,
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
      frontPhotoPath: json['frontPhotoPath'] as String?,
      sidePhotoPath: json['sidePhotoPath'] as String?,
      backPhotoPath: json['backPhotoPath'] as String?,
    );
  }

  factory ProgressSession.fromSupabase(Map<String, dynamic> row) {
    return ProgressSession(
      id: row['id'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
      visualScore: row['visual_score'] as int,
      confidence: row['confidence'] as String,
      postureScore: row['posture_score'] as int,
      summary: row['summary'] as String,
      symmetryLabel: row['symmetry_label'] as String? ?? 'جيد',
      comparabilityLabel: row['comparability_label'] as String? ?? 'مقبولة',
      shoulderWaistChange:
          (row['shoulder_waist_change'] as num?)?.toDouble() ?? 4.8,
      recommendation:
          row['recommendation'] as String? ??
          'استمر بنفس طريقة التصوير: نفس المسافة، نفس الإضاءة، ونفس الوقفة.',
      weightKg: (row['weight_kg'] as num?)?.toDouble(),
      note: row['note'] as String? ?? '',
      phaseLabel: row['phase_label'] as String? ?? '',
      frontPhotoPath: row['front_photo_path'] as String?,
      sidePhotoPath: row['side_photo_path'] as String?,
      backPhotoPath: row['back_photo_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'frontPhotoPath': frontPhotoPath,
      'sidePhotoPath': sidePhotoPath,
      'backPhotoPath': backPhotoPath,
    };
  }

  Map<String, dynamic> toSupabaseInsert({
    String? frontPhotoPath,
    String? sidePhotoPath,
    String? backPhotoPath,
  }) {
    return {
      'created_at': createdAt.toIso8601String(),
      'visual_score': visualScore,
      'confidence': confidence,
      'posture_score': postureScore,
      'summary': summary,
      'symmetry_label': symmetryLabel,
      'comparability_label': comparabilityLabel,
      'shoulder_waist_change': shoulderWaistChange,
      'recommendation': recommendation,
      'weight_kg': weightKg,
      'note': note,
      'phase_label': phaseLabel,
      'front_photo_path': frontPhotoPath ?? this.frontPhotoPath,
      'side_photo_path': sidePhotoPath ?? this.sidePhotoPath,
      'back_photo_path': backPhotoPath ?? this.backPhotoPath,
    };
  }

  ProgressSession copyWith({
    String? id,
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
    String? frontPhotoPath,
    String? sidePhotoPath,
    String? backPhotoPath,
  }) {
    return ProgressSession(
      id: id ?? this.id,
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
      frontPhotoPath: frontPhotoPath ?? this.frontPhotoPath,
      sidePhotoPath: sidePhotoPath ?? this.sidePhotoPath,
      backPhotoPath: backPhotoPath ?? this.backPhotoPath,
    );
  }
}
