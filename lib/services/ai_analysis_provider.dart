import '../models/ai_analysis_response.dart';
import '../models/analysis_request.dart';
import '../models/analysis_result.dart';
import '../models/photo_angle.dart';
import '../models/progress_session.dart';
import 'ai_analysis_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AiAnalysisProvider {
  const AiAnalysisProvider();

  Future<AnalysisResult> analyze(AnalysisRequest request);
}

class EdgeFunctionAiAnalysisProvider extends AiAnalysisProvider {
  const EdgeFunctionAiAnalysisProvider([this._client]);

  final SupabaseClient? _client;

  SupabaseClient get _supabaseClient => _client ?? Supabase.instance.client;

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    if (!hasAiAnalysisFunctionName) {
      throw const AiAnalysisUnavailableException(
        'AI analysis function is not configured yet.',
      );
    }

    try {
      final response = await _supabaseClient.functions.invoke(
        aiAnalysisFunctionName,
        body: await const AiAnalysisPayloadBuilder().build(request),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final result = data['result'];
        return AiAnalysisResponse.fromJson(
          result is Map<String, dynamic> ? result : data,
        ).toAnalysisResult();
      }

      throw const FormatException('AI response must be a JSON object.');
    } on AiAnalysisUnavailableException {
      rethrow;
    } on FormatException catch (error) {
      throw AiAnalysisUnavailableException(error.message);
    } on Object {
      throw const AiAnalysisUnavailableException(
        'AI analysis function call failed.',
      );
    }
  }
}

class AiAnalysisPayloadBuilder {
  const AiAnalysisPayloadBuilder();

  Future<Map<String, dynamic>> build(AnalysisRequest request) async {
    return {
      'photos': await _photoPayload(request),
      'previousSessions': request.previousSessions
          .take(3)
          .map(_sessionPayload)
          .toList(),
      'context': {
        'weightKg': request.weightKg,
        'phaseLabel': request.phaseLabel,
        'note': request.note,
        'measurements': request.measurements.toJson(),
      },
      'readiness': request.readinessReport == null
          ? null
          : {
              'level': request.readinessReport!.level.name,
              'title': request.readinessReport!.title,
              'message': request.readinessReport!.message,
              'selectedCount': request.readinessReport!.selectedCount,
              'totalBytes': request.readinessReport!.totalBytes,
              'largeAngles': request.readinessReport!.largeAngles
                  .map((angle) => angle.storageName)
                  .toList(),
            },
    };
  }

  Future<List<Map<String, dynamic>>> _photoPayload(
    AnalysisRequest request,
  ) async {
    final photos = <Map<String, dynamic>>[];
    for (final angle in PhotoAngle.values) {
      final photo = request.photos[angle];
      if (photo == null) {
        continue;
      }

      photos.add({
        'angle': angle.storageName,
        'name': photo.name,
        'mimeType': photo.mimeType,
        'sizeBytes': await photo.length(),
      });
    }

    return photos;
  }

  Map<String, dynamic> _sessionPayload(ProgressSession session) {
    return {
      'createdAt': session.createdAt.toIso8601String(),
      'visualScore': session.visualScore,
      'confidence': session.confidence,
      'postureScore': session.postureScore,
      'symmetryLabel': session.symmetryLabel,
      'comparabilityLabel': session.comparabilityLabel,
      'shoulderWaistChange': session.shoulderWaistChange,
      'weightKg': session.weightKg,
      'phaseLabel': session.phaseLabel,
      'note': session.note,
      'measurements': session.measurements.toJson(),
      'photoPathsByAngle': session.photoPathsByAngle,
    };
  }
}

class StaticAiAnalysisProvider extends AiAnalysisProvider {
  const StaticAiAnalysisProvider(this.response);

  final AiAnalysisResponse response;

  @override
  Future<AnalysisResult> analyze(AnalysisRequest request) async {
    return response.toAnalysisResult();
  }
}

class AiAnalysisUnavailableException implements Exception {
  const AiAnalysisUnavailableException(this.message);

  final String message;

  @override
  String toString() => message;
}
