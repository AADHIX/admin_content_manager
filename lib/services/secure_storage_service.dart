import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

class SecureStorageService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final Encrypter _encrypter;

  // Replace these with your own encryption key and IV
  final Key _key = Key.fromUtf8('12345678901234567890123456789012'); // 32 bytes key
  final IV _iv = IV.fromLength(16);

  SecureStorageService() : _encrypter = Encrypter(AES(_key));

  Future<void> writeSecureData(String key, String value) async {
    final encryptedValue = _encrypter.encrypt(value, iv: _iv);
    await _secureStorage.write(key: key, value: encryptedValue.base64);
  }

  Future<String?> readSecureData(String key) async {
    final encryptedData = await _secureStorage.read(key: key);
    if (encryptedData == null) return null;
    final decryptedValue = _encrypter.decrypt(Encrypted.fromBase64(encryptedData), iv: _iv);
    return decryptedValue;
  }

  Future<void> deleteSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }
}