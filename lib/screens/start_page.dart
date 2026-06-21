import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/photo_angle.dart';
import '../models/progress_session.dart';
import '../widgets/analysis_loading_section.dart';
import '../widgets/intro_section.dart';
import '../widgets/photo_capture_section.dart';
import '../widgets/progress_report_section.dart';
import '../widgets/session_history_section.dart';
import '../widgets/start_button.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final _imagePicker = ImagePicker();
  final Map<PhotoAngle, XFile> _photos = {};
  final List<ProgressSession> _sessions = [];
  bool _isAnalyzing = false;
  bool _showReport = false;
  bool _currentReportSaved = false;
  bool _showComparison = false;

  Future<void> _choosePhotoSource(PhotoAngle angle) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'اختر مصدر الصورة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    leading: const Icon(Icons.photo_camera_outlined),
                    title: const Text('التقاط بالكاميرا'),
                    subtitle: const Text('مناسب للتجربة على الموبايل'),
                    onTap: () => Navigator.of(context).pop(ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('اختيار من المعرض'),
                    subtitle: const Text('استخدم صورة محفوظة على الجهاز'),
                    onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    await _pickPhoto(angle, source);
  }

  Future<void> _pickPhoto(PhotoAngle angle, ImageSource source) async {
    final photo = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (photo == null) {
      return;
    }

    setState(() {
      _photos[angle] = photo;
      _isAnalyzing = false;
      _showReport = false;
      _currentReportSaved = false;
    });
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _showReport = false;
      _currentReportSaved = false;
    });

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    setState(() {
      _isAnalyzing = false;
      _showReport = true;
    });
  }

  void _saveCurrentReport() {
    if (_currentReportSaved) {
      return;
    }

    final score = 72 + (_sessions.length % 4) * 3;
    final postureScore = 81 + (_sessions.length % 3) * 2;

    setState(() {
      _sessions.insert(
        0,
        ProgressSession(
          createdAt: DateTime.now(),
          visualScore: score,
          confidence: 'متوسط',
          postureScore: postureScore,
          summary:
              'تحسن بصري جيد في تناسق الجزء العلوي مع حاجة بسيطة لتثبيت ظروف التصوير في الجلسات القادمة.',
        ),
      );
      _currentReportSaved = true;
      _showComparison = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ التقرير في سجل الجلسات')),
    );
  }

  void _editPhotos() {
    setState(() {
      _isAnalyzing = false;
      _showReport = false;
      _currentReportSaved = false;
      _showComparison = false;
    });
  }

  void _resetScan() {
    setState(() {
      _photos.clear();
      _isAnalyzing = false;
      _showReport = false;
      _currentReportSaved = false;
      _showComparison = false;
    });
  }

  void _toggleComparison() {
    setState(() {
      _showComparison = !_showComparison;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('FitProgress AI'), centerTitle: true),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const IntroSection(),
              const SizedBox(height: 28),
              PhotoCaptureSection(
                photos: _photos,
                onPickPhoto: _choosePhotoSource,
              ),
              const SizedBox(height: 24),
              StartButton(
                enabled: _photos.length == PhotoAngle.values.length,
                isAnalyzing: _isAnalyzing,
                onPressed: _startAnalysis,
              ),
              if (_isAnalyzing) ...[
                const SizedBox(height: 24),
                const AnalysisLoadingSection(),
              ],
              if (_showReport) ...[
                const SizedBox(height: 24),
                ProgressReportSection(
                  isSaved: _currentReportSaved,
                  onSaveReport: _saveCurrentReport,
                  onEditPhotos: _editPhotos,
                  onResetScan: _resetScan,
                ),
              ],
              if (_sessions.isNotEmpty) ...[
                const SizedBox(height: 24),
                SessionHistorySection(
                  sessions: _sessions,
                  showComparison: _showComparison,
                  onToggleComparison: _toggleComparison,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
