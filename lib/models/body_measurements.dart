class BodyMeasurements {
  const BodyMeasurements({
    this.waistCm,
    this.chestCm,
    this.armCm,
    this.shoulderCm,
  });

  final double? waistCm;
  final double? chestCm;
  final double? armCm;
  final double? shoulderCm;

  bool get hasAny =>
      waistCm != null || chestCm != null || armCm != null || shoulderCm != null;

  factory BodyMeasurements.fromJson(Object? value) {
    if (value is! Map) {
      return const BodyMeasurements();
    }

    final json = Map<String, dynamic>.from(value);
    return BodyMeasurements(
      waistCm: _number(json['waistCm']),
      chestCm: _number(json['chestCm']),
      armCm: _number(json['armCm']),
      shoulderCm: _number(json['shoulderCm']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'waistCm': waistCm,
      'chestCm': chestCm,
      'armCm': armCm,
      'shoulderCm': shoulderCm,
    };
  }

  static double? _number(Object? value) {
    if (value is num) {
      return value.toDouble();
    }

    return null;
  }
}
