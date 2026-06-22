import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/photo_angle.dart';
import '../models/progress_session.dart';

const _progressPhotosBucket = 'progress-photos';

class SupabaseSaveResult {
  const SupabaseSaveResult.synced(this.session) : message = null;

  const SupabaseSaveResult.localOnly(this.message) : session = null;

  final ProgressSession? session;
  final String? message;

  bool get isSynced => session != null;
}

class SupabaseSessionService {
  const SupabaseSessionService([this._client]);

  final SupabaseClient? _client;

  SupabaseClient get _supabaseClient => _client ?? Supabase.instance.client;

  Future<bool> ensureReady() async {
    try {
      final client = _supabaseClient;
      if (client.auth.currentSession == null) {
        await client.auth.signInAnonymously();
      }

      return client.auth.currentUser != null;
    } on Object {
      return false;
    }
  }

  Future<List<ProgressSession>> fetchSessions() async {
    final isReady = await ensureReady();
    if (!isReady) {
      return const [];
    }

    final rows = await _supabaseClient
        .from('progress_sessions')
        .select()
        .order('created_at', ascending: false);

    return rows
        .map(
          (row) => ProgressSession.fromSupabase(Map<String, dynamic>.from(row)),
        )
        .toList();
  }

  Future<SupabaseSaveResult> insertSession(
    ProgressSession session, {
    Map<PhotoAngle, XFile> photos = const {},
  }) async {
    try {
      final isReady = await ensureReady();
      if (!isReady) {
        return const SupabaseSaveResult.localOnly(
          'تم الحفظ محليًا فقط: Anonymous Auth غير جاهز',
        );
      }

      final photoPaths = photos.isEmpty
          ? const <PhotoAngle, String>{}
          : await _uploadSessionPhotos(session, photos);

      final row = await _supabaseClient
          .from('progress_sessions')
          .insert(
            session.toSupabaseInsert(
              frontPhotoPath: photoPaths[PhotoAngle.front],
              sidePhotoPath: photoPaths[PhotoAngle.side],
              backPhotoPath: photoPaths[PhotoAngle.back],
            ),
          )
          .select()
          .single();

      return SupabaseSaveResult.synced(
        ProgressSession.fromSupabase(Map<String, dynamic>.from(row)),
      );
    } on PostgrestException catch (error) {
      return SupabaseSaveResult.localOnly(
        'تم الحفظ محليًا فقط: ${error.message}',
      );
    } on AuthException catch (error) {
      return SupabaseSaveResult.localOnly(
        'تم الحفظ محليًا فقط: ${error.message}',
      );
    } on Object {
      return const SupabaseSaveResult.localOnly(
        'تم الحفظ محليًا فقط: تعذر الاتصال بـ Supabase',
      );
    }
  }

  Future<Map<PhotoAngle, String>> _uploadSessionPhotos(
    ProgressSession session,
    Map<PhotoAngle, XFile> photos,
  ) async {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException('Missing authenticated user');
    }

    final sessionFolder = session.createdAt.microsecondsSinceEpoch.toString();
    final paths = <PhotoAngle, String>{};

    for (final entry in photos.entries) {
      final bytes = await entry.value.readAsBytes();
      final extension = _extensionFor(entry.value);
      final path = '$userId/$sessionFolder/${entry.key.storageName}$extension';

      await _supabaseClient.storage
          .from(_progressPhotosBucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: entry.value.mimeType ?? _contentTypeFor(extension),
              upsert: true,
            ),
          );

      paths[entry.key] = path;
    }

    return paths;
  }

  String _extensionFor(XFile photo) {
    final name = photo.name.toLowerCase();
    if (name.endsWith('.png')) {
      return '.png';
    }
    if (name.endsWith('.webp')) {
      return '.webp';
    }

    return '.jpg';
  }

  String _contentTypeFor(String extension) {
    return switch (extension) {
      '.png' => 'image/png',
      '.webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }

  Future<List<String>> createSignedPhotoUrls(ProgressSession session) async {
    final urlsByAngle = await createSignedPhotoUrlsByAngle(session);
    return urlsByAngle.values.toList();
  }

  Future<Map<String, String>> createSignedPhotoUrlsByAngle(
    ProgressSession session,
  ) async {
    try {
      final isReady = await ensureReady();
      if (!isReady || !session.hasPhotoPaths) {
        return const {};
      }

      final urls = <String, String>{};
      for (final entry in session.photoPathsByAngle.entries) {
        final signedUrl = await _supabaseClient.storage
            .from(_progressPhotosBucket)
            .createSignedUrl(entry.value, 60 * 30);
        urls[entry.key] = signedUrl;
      }

      return urls;
    } on Object {
      return const {};
    }
  }

  Future<void> deleteSession(ProgressSession session) async {
    final isReady = await ensureReady();
    if (!isReady || session.id == null) {
      return;
    }

    await _deleteSessionPhotos(session);

    await _supabaseClient
        .from('progress_sessions')
        .delete()
        .eq('id', session.id!);
  }

  Future<void> clearSessions() async {
    final isReady = await ensureReady();
    if (!isReady) {
      return;
    }

    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    final sessions = await fetchSessions();
    for (final session in sessions) {
      await _deleteSessionPhotos(session);
    }

    await _supabaseClient
        .from('progress_sessions')
        .delete()
        .eq('user_id', userId);
  }

  Future<void> _deleteSessionPhotos(ProgressSession session) async {
    if (!session.hasPhotoPaths) {
      return;
    }

    await _supabaseClient.storage
        .from(_progressPhotosBucket)
        .remove(session.photoPaths);
  }
}
