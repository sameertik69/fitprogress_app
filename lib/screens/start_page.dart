import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/photo_angle.dart';
import '../models/progress_session.dart';
import '../services/session_storage.dart';
import '../widgets/analysis_loading_section.dart';
import '../widgets/intro_section.dart';
import '../widgets/photo_capture_section.dart';
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
  final _sessionStorage = createSessionStorage();
  final _weightController = TextEditingController();
  final _phaseController = TextEditingController();
  final _noteController = TextEditingController();
  final Map<PhotoAngle, XFile> _photos = {};
  final List<ProgressSession> _sessions = [];
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
    _phaseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
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
      _currentReport = null;
    });
  }

  void _removePhoto(PhotoAngle angle) {
    setState(() {
      _photos.remove(angle);
      _isAnalyzing = false;
      _showReport = false;
      _currentReportSaved = false;
      _currentReport = null;
    });
  }

  Future<void> _startAnalysis() async {
    setState(() {
      _isAnalyzing = true;
      _showReport = false;
      _currentReportSaved = false;
      _currentReport = null;
    });

    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) {
      return;
    }

    setState(() {
      _isAnalyzing = false;
      _showReport = true;
      _currentReport = _createDraftSession();
    });
  }

  Future<void> _saveCurrentReport() async {
    if (_currentReportSaved) {
      return;
    }

    final draftReport = _currentReport ?? _createDraftSession();
    final session = draftReport.copyWith(
      createdAt: DateTime.now(),
      weightKg: _parseWeight(_weightController.text),
      phaseLabel: _phaseController.text.trim(),
      note: _noteController.text.trim(),
    );

    setState(() {
      _sessions.insert(0, session);
      _currentReportSaved = true;
      _showComparison = false;
      _currentReport = session;
    });

    try {
      await _persistSessions();
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

    if (!mounted) {
      return;
    }

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
      _currentReport = null;
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

  ProgressSession _createDraftSession() {
    final sessionNumber = _sessions.length + 1;
    final visualScore = (70 + sessionNumber * 3).clamp(70, 92).toInt();
    final postureScore = (79 + (_photos.length * 2) + sessionNumber)
        .clamp(78, 95)
        .toInt();
    final shoulderWaistChange = 3.4 + sessionNumber * 0.7;
    final confidence = postureScore >= 88
        ? 'مرتفع'
        : postureScore >= 82
        ? 'متوسط'
        : 'بحاجة لتحسين';
    final symmetryLabel = visualScore >= 84
        ? 'ممتاز'
        : visualScore >= 76
        ? 'جيد'
        : 'مقبول';
    final comparabilityLabel = postureScore >= 86
        ? 'قوية'
        : postureScore >= 81
        ? 'مقبولة'
        : 'ضعيفة';

    return ProgressSession(
      createdAt: DateTime.now(),
      visualScore: visualScore,
      confidence: confidence,
      postureScore: postureScore,
      symmetryLabel: symmetryLabel,
      comparabilityLabel: comparabilityLabel,
      shoulderWaistChange: double.parse(shoulderWaistChange.toStringAsFixed(1)),
      summary:
          'الجلسة رقم $sessionNumber تظهر قراءة بصرية $symmetryLabel مع قابلية مقارنة $comparabilityLabel. ثبات الصور يؤثر مباشرة على دقة متابعة تطور الجسم والعضلات.',
      recommendation:
          'للجلسة القادمة حافظ على نفس المسافة والإضاءة والوقفة، واكتب الوزن أو مرحلة التمرين حتى تصبح المقارنة أوضح.',
    );
  }

  double? _parseWeight(String value) {
    final normalizedValue = value.trim().replaceAll(',', '.');
    if (normalizedValue.isEmpty) {
      return null;
    }

    return double.tryParse(normalizedValue);
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
                  session: _currentReport ?? _createDraftSession(),
                  isSaved: _currentReportSaved,
                  weightController: _weightController,
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
