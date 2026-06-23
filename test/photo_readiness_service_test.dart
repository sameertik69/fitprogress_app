import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:fitprogress_app/models/photo_angle.dart';
import 'package:fitprogress_app/models/photo_readiness_report.dart';
import 'package:fitprogress_app/services/photo_readiness_service.dart';

void main() {
  test('reports incomplete when not all photo angles are selected', () async {
    const service = PhotoReadinessService();

    final report = await service.assess(const {});

    expect(report.level, PhotoReadinessLevel.incomplete);
    expect(report.canAnalyze, isFalse);
    expect(report.selectedCount, 0);
  });

  test('reports ready when all photos are selected with small size', () async {
    const service = PhotoReadinessService();

    final report = await service.assess({
      PhotoAngle.front: XFile.fromData(Uint8List(10), name: 'front.jpg'),
      PhotoAngle.side: XFile.fromData(Uint8List(10), name: 'side.jpg'),
      PhotoAngle.back: XFile.fromData(Uint8List(10), name: 'back.jpg'),
    });

    expect(report.level, PhotoReadinessLevel.ready);
    expect(report.canAnalyze, isTrue);
    expect(report.selectedCount, 3);
  });
}
