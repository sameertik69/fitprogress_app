import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/progress_session.dart';

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

  Future<SupabaseSaveResult> insertSession(ProgressSession session) async {
    try {
      final isReady = await ensureReady();
      if (!isReady) {
        return const SupabaseSaveResult.localOnly(
          'تم الحفظ محليًا فقط: Anonymous Auth غير جاهز',
        );
      }

      final row = await _supabaseClient
          .from('progress_sessions')
          .insert(session.toSupabaseInsert())
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

  Future<void> deleteSession(ProgressSession session) async {
    final isReady = await ensureReady();
    if (!isReady || session.id == null) {
      return;
    }

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

    await _supabaseClient
        .from('progress_sessions')
        .delete()
        .eq('user_id', userId);
  }
}
