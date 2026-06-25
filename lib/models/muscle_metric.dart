class MuscleMetric {
  const MuscleMetric({
    required this.name,
    required this.score,
    required this.status,
    required this.note,
  });

  final String name;
  final int score;
  final String status;
  final String note;

  factory MuscleMetric.fromJson(Map<String, dynamic> json) {
    return MuscleMetric(
      name: json['name'] as String? ?? 'منطقة غير محددة',
      score: ((json['score'] as num?) ?? 0).clamp(0, 100).toInt(),
      status: json['status'] as String? ?? 'غير محدد',
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'score': score, 'status': status, 'note': note};
  }
}

const defaultMuscleMetrics = [
  MuscleMetric(
    name: 'الأكتاف',
    score: 72,
    status: 'جيد',
    note: 'تقدير مبدئي لاتساع الجزء العلوي.',
  ),
  MuscleMetric(
    name: 'الصدر',
    score: 70,
    status: 'مقبول',
    note: 'تحتاج جلسات أكثر لإظهار اتجاه واضح.',
  ),
  MuscleMetric(
    name: 'الذراعين',
    score: 68,
    status: 'مقبول',
    note: 'الصور الجانبية تساعد على قراءة أوضح.',
  ),
  MuscleMetric(
    name: 'الخصر والجذع',
    score: 74,
    status: 'جيد',
    note: 'يتأثر كثيرًا بثبات الوقفة والإضاءة.',
  ),
];
