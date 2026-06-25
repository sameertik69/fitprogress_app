import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/analysis_request.dart';
import '../models/body_measurements.dart';
import '../models/photo_angle.dart';
import '../models/photo_readiness_report.dart';
import '../models/progress_session.dart';
import '../services/photo_readiness_service.dart';
import '../services/progress_analysis_service.dart';
import '../services/session_storage.dart';
import '../services/supabase_session_service.dart';
import '../widgets/analysis_loading_section.dart';
import '../widgets/data_quality_dashboard.dart';
import '../widgets/intro_section.dart';
import '../widgets/next_session_plan_section.dart';
import '../widgets/photo_capture_section.dart';
import '../widgets/progress_trend_section.dart';
import '../widgets/progress_report_section.dart';
import '../widgets/session_history_section.dart';
import '../widgets/start_button.dart';

const _sessionsStorageKey = 'fitprogress_sessions';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final _imagePicker = ImagePicker();
  final _analysisService = const ProgressAnalysisService();
  final _photoReadinessService = const PhotoReadinessService();
  final _sessionStorage = createSessionStorage();
  final _supabaseSessionService = SupabaseSessionService();
  final _weightController = TextEditingController();
  final _waistController = TextEditingController();
  final _chestController = TextEditingController();
  final _armController = TextEditingController();
  final _shoulderController = TextEditingController();
  final _phaseController = TextEditingController();
  final _noteController = TextEditingController();
  final Map<PhotoAngle, XFile> _photos = {};
  final List<ProgressSession> _sessions = [];
  PhotoReadinessReport? _photoReadinessReport;
  ProgressSession? _currentReport;
  bool _isAnalyzing = false;
  bool _showReport = false;
  bool _currentReportSaved = false;
  bool _showComparison = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _waistController.dispose();
    _chestController.dispose();
    _armController.dispose();
    _shoulderController.dispose();
    _phaseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    await _loadLocalSessions();
    await _syncSessionsFromSupabase();
  }

  Future<void> _loadLocalSessions() async {
    final encodedSessions = await _sessionStorage.read(_sessionsStorageKey);
    final loadedSessions = <ProgressSession>[];

    if (encodedSessions == null || encodedSessions.isEmpty) {
      return;
    }

    final dynamic decodedSessions;
    try {
      decodedSessions = jsonDecode(encodedSessions);
    } on FormatException {
      return;
    }

    if (decodedSessions is! List<dynamic>) {
      return;
    }

    for (final decodedSession in decodedSessions) {
      try {
        loadedSessions.add(
          ProgressSession.fromJson(
            Map<String, dynamic>.from(decodedSession as Map<dynamic, dynamic>),
          ),
        );
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _sessions
        ..clear()
        ..addAll(loadedSessions);
    });
  }

  Future<void> _syncSessionsFromSupabase() async {
    try {
      final remoteSessions = await _supabaseSessionService.fetchSessions();
      if (!mounted || remoteSessions.isEmpty) {
        return;
      }

      setState(() {
        _sessions
          ..clear()
          ..addAll(remoteSessions);
      });

      await _persistSessions();
    } on Object {
      return;
    }
  }

  Future<void> _persistSessions() async {
    final encodedSessions = jsonEncode(
      _sessions.map((session) => session.toJson()).toList(),
    );

    await _sessionStorage.write(_sessionsStorageKey, encodedSessions);
  }

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
      imageQuality: 70,
      maxWidth: 1200,
    );

    if (photo == null) {
      return;
    }

    setState(() {
      _photos[angle] = photo;
      _isAnalyzing = false;
      _showReport = false;
      _currentReportSaved = false;
      _currentReport = null;
    });

    await _refreshPhotoReadiness();
  }

  Future<void> _removePhoto(PhotoAngle angle) async {
    setState(() {
      _photos.remove(angle);
      _isAnalyzing = false;
      _showReport = false;
      _currentReportSaved = false;
      _currentReport = null;
    });

    await _refreshPhotoReadiness();
  }

  Future<void> _refreshPhotoReadiness() async {
    final report = await _photoReadinessService.assess(_photos);
    if (!mounted) {
      return;
    }

    setState(() {
      _photoReadinessReport = report;
    });
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _showReport = false;
      _currentReportSaved = false;
      _currentReport = null;
    });

    final analysisResult = await _analysisService.analyze(
      AnalysisRequest(
        photos: _photos,
        previousSessions: _sessions,
        weightKg: _parseWeight(_weightController.text),
        phaseLabel: _phaseController.text.trim(),
        note: _noteController.text.trim(),
        readinessReport: _photoReadinessReport,
        measurements: _bodyMeasurementsFromInputs(),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isAnalyzing = false;
      _showReport = true;
      _currentReport = _analysisService.createSessionFromResult(analysisResult);
    });
  }

  Future<void> _saveCurrentReport() async {
    if (_currentReportSaved) {
      return;
    }

    final draftReport = _currentReport;
    if (draftReport == null) {
      return;
    }

    final session = draftReport.copyWith(
      createdAt: DateTime.now(),
      weightKg: _parseWeight(_weightController.text),
      phaseLabel: _phaseController.text.trim(),
      note: _noteController.text.trim(),
      measurements: _bodyMeasurementsFromInputs(),
    );

    setState(() {
      _sessions.insert(0, session);
      _currentReportSaved = true;
      _showComparison = false;
      _currentReport = session;
    });

    try {
      await _persistSessions();
      final saveResult = await _supabaseSessionService.insertSession(
        session,
        photos: _photos,
      );
      if (saveResult.isSynced && mounted) {
        setState(() {
          final sessionIndex = _sessions.indexOf(session);
          if (sessionIndex != -1) {
            _sessions[sessionIndex] = saveResult.session!;
            _currentReport = saveResult.session;
          }
        });
        await _persistSessions();
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saveResult.isSynced
                ? 'تم حفظ التقرير والصور في Supabase والسجل المحلي'
                : saveResult.message!,
          ),
        ),
      );
    } on Object {
      if (!mounted) {
        return;
      }

      setState(() {
        _sessions.remove(session);
        _currentReportSaved = false;
        _currentReport = draftReport;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حفظ التقرير، حاول مرة ثانية')),
      );

      return;
    }

    return;
  }

  void _editPhotos() {
    setState(() {
      _isAnalyzing = false;
      _showReport = false;
      _currentReportSaved = false;
      _showComparison = false;
      _currentReport = null;
      _photoReadinessReport = null;
    });
  }

  void _resetScan() {
    setState(() {
      _photos.clear();
      _isAnalyzing = false;
      _showReport = false;
      _currentReportSaved = false;
      _showComparison = false;
      _currentReport = null;
    });
    _weightController.clear();
    _waistController.clear();
    _chestController.clear();
    _armController.clear();
    _shoulderController.clear();
    _phaseController.clear();
    _noteController.clear();
  }

  void _toggleComparison() {
    setState(() {
      _showComparison = !_showComparison;
    });
  }

  Future<void> _deleteSession(ProgressSession session) async {
    final sessionIndex = _sessions.indexOf(session);
    if (sessionIndex == -1) {
      return;
    }

    setState(() {
      _sessions.removeAt(sessionIndex);
      if (_sessions.length < 2) {
        _showComparison = false;
      }
    });

    try {
      await _persistSessions();
      await _supabaseSessionService.deleteSession(session);
    } on Object {
      if (!mounted) {
        return;
      }

      setState(() {
        _sessions.insert(sessionIndex, session);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حذف الجلسة، حاول مرة ثانية')),
      );

      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم حذف الجلسة')));
  }

  Future<void> _clearSessions() async {
    if (_sessions.isEmpty) {
      return;
    }

    final previousSessions = List<ProgressSession>.from(_sessions);
    final previousShowComparison = _showComparison;

    setState(() {
      _sessions.clear();
      _showComparison = false;
    });

    try {
      await _persistSessions();
      await _supabaseSessionService.clearSessions();
    } on Object {
      if (!mounted) {
        return;
      }

      setState(() {
        _sessions.addAll(previousSessions);
        _showComparison = previousShowComparison;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر مسح السجل، حاول مرة ثانية')),
      );

      return;
    }

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم مسح السجل')));
  }

  double? _parseWeight(String value) {
    final normalizedValue = value.trim().replaceAll(',', '.');
    if (normalizedValue.isEmpty) {
      return null;
    }

    return double.tryParse(normalizedValue);
  }

  BodyMeasurements _bodyMeasurementsFromInputs() {
    return BodyMeasurements(
      waistCm: _parseMeasurement(_waistController.text),
      chestCm: _parseMeasurement(_chestController.text),
      armCm: _parseMeasurement(_armController.text),
      shoulderCm: _parseMeasurement(_shoulderController.text),
    );
  }

  double? _parseMeasurement(String value) {
    final normalizedValue = value.trim().replaceAll(',', '.');
    if (normalizedValue.isEmpty) {
      return null;
    }

    final parsedValue = double.tryParse(normalizedValue);
    if (parsedValue == null || parsedValue <= 0) {
      return null;
    }

    return parsedValue;
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
                readinessReport: _photoReadinessReport,
                onPickPhoto: _choosePhotoSource,
                onRemovePhoto: _removePhoto,
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
                  session: _currentReport!,
                  isSaved: _currentReportSaved,
                  weightController: _weightController,
                  waistController: _waistController,
                  chestController: _chestController,
                  armController: _armController,
                  shoulderController: _shoulderController,
                  phaseController: _phaseController,
                  noteController: _noteController,
                  onSaveReport: () {
                    _saveCurrentReport();
                  },
                  onEditPhotos: _editPhotos,
                  onResetScan: _resetScan,
                ),
              ],
              if (_sessions.isNotEmpty) ...[
                const SizedBox(height: 24),
                DataQualityDashboard(sessions: _sessions),
                const SizedBox(height: 24),
                NextSessionPlanSection(sessions: _sessions),
                const SizedBox(height: 24),
                ProgressTrendSection(sessions: _sessions),
                const SizedBox(height: 24),
                SessionHistorySection(
                  sessions: _sessions,
                  showComparison: _showComparison,
                  onToggleComparison: _toggleComparison,
                  onDeleteSession: _deleteSession,
                  onClearSessions: () {
                    _clearSessions();
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
