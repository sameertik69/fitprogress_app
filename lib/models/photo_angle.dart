enum PhotoAngle {
  front,
  side,
  back;

  String get storageName {
    return switch (this) {
      PhotoAngle.front => 'front',
      PhotoAngle.side => 'side',
      PhotoAngle.back => 'back',
    };
  }

  String get arabicLabel {
    return switch (this) {
      PhotoAngle.front => 'الصورة الأمامية',
      PhotoAngle.side => 'الصورة الجانبية',
      PhotoAngle.back => 'الصورة الخلفية',
    };
  }
}
