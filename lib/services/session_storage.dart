import 'session_storage_interface.dart';
import 'session_storage_stub.dart'
    if (dart.library.html) 'session_storage_web.dart'
    as platform_storage;

export 'session_storage_interface.dart';

SessionStorage createSessionStorage() {
  return platform_storage.createSessionStorage();
}
