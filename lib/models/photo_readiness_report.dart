import 'photo_angle.dart';

enum PhotoReadinessLevel { incomplete, ready, attention }

class PhotoReadinessReport {
  const PhotoReadinessReport({
    required this.level,
    required this.title,
    required this.message,
    required this.selectedCount,
    required this.totalBytes,
    required this.largeAngles,
  });

  final PhotoReadinessLevel level;
  final String title;
  final String message;
  final int selectedCount;
  final int totalBytes;
  final List<PhotoAngle> largeAngles;

  bool get canAnalyze => selectedCount == PhotoAngle.values.length;

  String get totalSizeLabel {
    if (totalBytes <= 0) {
      return '0 MB';
    }

    final megabytes = totalBytes / (1024 * 1024);
    return '${megabytes.toStringAsFixed(1)} MB';
  }
}
