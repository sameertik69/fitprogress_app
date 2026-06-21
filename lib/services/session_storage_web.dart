import 'package:web/web.dart' as web;

import 'session_storage_interface.dart';

class WebSessionStorage extends SessionStorage {
  const WebSessionStorage();

  @override
  Future<String?> read(String key) async {
    return web.window.localStorage.getItem(key);
  }

  @override
  Future<void> write(String key, String value) async {
    web.window.localStorage.setItem(key, value);

    if (web.window.localStorage.getItem(key) != value) {
      throw StateError('Could not persist sessions');
    }
  }
}

SessionStorage createSessionStorage() {
  return const WebSessionStorage();
}
