import 'package:image_picker/image_picker.dart';

import '../models/photo_angle.dart';
import '../models/photo_readiness_report.dart';

class PhotoReadinessService {
  const PhotoReadinessService();

  static const _largePhotoBytes = 2.5 * 1024 * 1024;
  static const _largeTotalBytes = 7.5 * 1024 * 1024;

  Future<PhotoReadinessReport> assess(Map<PhotoAngle, XFile> photos) async {
    if (photos.length < PhotoAngle.values.length) {
      final remaining = PhotoAngle.values.length - photos.length;
      return PhotoReadinessReport(
        level: PhotoReadinessLevel.incomplete,
        title: 'الصور غير مكتملة',
        message: 'باقي $remaining صورة قبل بدء التحليل.',
        selectedCount: photos.length,
        totalBytes: 0,
        largeAngles: const [],
      );
    }

    var totalBytes = 0;
    final largeAngles = <PhotoAngle>[];

    for (final entry in photos.entries) {
      final size = await entry.value.length();
      totalBytes += size;
      if (size > _largePhotoBytes) {
        largeAngles.add(entry.key);
      }
    }

    if (largeAngles.isNotEmpty || totalBytes > _largeTotalBytes) {
      return PhotoReadinessReport(
        level: PhotoReadinessLevel.attention,
        title: 'الصور جاهزة مع ملاحظة',
        message:
            'الصور مكتملة، لكن حجمها كبير نسبيًا. التطبيق سيضغط الصور عند الاختيار، وحافظ على إضاءة ومسافة ثابتة.',
        selectedCount: photos.length,
        totalBytes: totalBytes,
        largeAngles: largeAngles,
      );
    }

    return PhotoReadinessReport(
      level: PhotoReadinessLevel.ready,
      title: 'الصور جاهزة للتحليل',
      message: 'الزوايا الثلاث مكتملة وبحجم مناسب للتجربة الحالية.',
      selectedCount: photos.length,
      totalBytes: totalBytes,
      largeAngles: const [],
    );
  }
}
