import 'package:image_picker/image_picker.dart';

import 'photo_angle.dart';
import 'photo_readiness_report.dart';
import 'progress_session.dart';

enum AnalysisMode { mock, ai }

class AnalysisRequest {
  const AnalysisRequest({
    required this.photos,
    required this.previousSessions,
    this.weightKg,
    this.phaseLabel = '',
    this.note = '',
    this.readinessReport,
  });

  final Map<PhotoAngle, XFile> photos;
  final List<ProgressSession> previousSessions;
  final double? weightKg;
  final String phaseLabel;
  final String note;
  final PhotoReadinessReport? readinessReport;
}
