import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A robust, extensible service for secure and plain shared preferences storage.
/// Supports Map, String, int, double, bool. Use [saveEncryptedMap] for sensitive data.
class SharedPrefsService {
  static final SharedPrefsService _instance = SharedPrefsService._internal();
  factory SharedPrefsService() => _instance;
  SharedPrefsService._internal();

  static const String _defaultEncryptionKey = 'PeShVmYq3t6w9z@C';
  static final IV _defaultIV = IV.fromLength(16);

  /// Save a Map<String, dynamic> securely (AES encrypted)
  Future<void> saveEncryptedMap(String key, Map<String, dynamic> data, {String? encryptionKey, IV? iv}) async {
    final prefs = await SharedPreferences.getInstance();
    final mapString = json.encode(data);
    final encrypted = _encryptString(mapString, encryptionKey: encryptionKey, iv: iv);
    await prefs.setString(key, encrypted);
  }

  /// Retrieve a securely saved Map<String, dynamic> (AES encrypted)
  Future<Map<String, dynamic>?> getEncryptedMap(String key, {String? encryptionKey, IV? iv}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) return null;
    final encrypted = prefs.getString(key);
    if (encrypted == null) return null;
    final decrypted = _decryptString(encrypted, encryptionKey: encryptionKey, iv: iv);
    return json.decode(decrypted) as Map<String, dynamic>;
  }

  /// Save a Map<String, dynamic> as plain text (not encrypted)
  Future<void> saveMap(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(data));
  }

  /// Retrieve a plain Map<String, dynamic>
  Future<Map<String, dynamic>?> getMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(key)) return null;
    final mapString = prefs.getString(key);
    if (mapString == null) return null;
    return json.decode(mapString) as Map<String, dynamic>;
  }

  /// Save a String value
  Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Retrieve a String value
  Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Save an int value
  Future<void> saveInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  /// Retrieve an int value
  Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  /// Save a double value
  Future<void> saveDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  /// Retrieve a double value
  Future<double?> getDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key);
  }

  /// Save a bool value
  Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Retrieve a bool value
  Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  /// Remove a value by key
  Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Clear all preferences (use with caution)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // --- Encryption helpers ---
  String _encryptString(String plainText, {String? encryptionKey, IV? iv}) {
    final key = Key.fromUtf8(encryptionKey ?? _defaultEncryptionKey);
    final encrypter = Encrypter(AES(key));
    return encrypter.encrypt(plainText, iv: iv ?? _defaultIV).base64;
  }

  String _decryptString(String base64String, {String? encryptionKey, IV? iv}) {
    final key = Key.fromUtf8(encryptionKey ?? _defaultEncryptionKey);
    final encrypter = Encrypter(AES(key));
    return encrypter.decrypt(Encrypted.from64(base64String), iv: iv ?? _defaultIV);
  }
} 