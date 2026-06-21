import 'package:shared_preferences/shared_preferences.dart';

import 'session_storage_interface.dart';

class SharedPreferencesSessionStorage extends SessionStorage {
  const SharedPreferencesSessionStorage();

  @override
  Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    return prefs.getString(key);
  }

  @override
  Future<void> write(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    final didSave = await prefs.setString(key, value);

    if (!didSave) {
      throw StateError('Could not persist sessions');
    }
  }
}

SessionStorage createSessionStorage() {
  return const SharedPreferencesSessionStorage();
}
