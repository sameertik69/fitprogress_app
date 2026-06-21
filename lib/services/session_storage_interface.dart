abstract class SessionStorage {
  const SessionStorage();

  Future<String?> read(String key);

  Future<void> write(String key, String value);
}
