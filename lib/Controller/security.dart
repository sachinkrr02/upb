import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'dart:typed_data';

class AesEncryptionHelper {
  static final String _keyBase64 =
      "4qxz3F9gLT3Pg54XG8iFqROKsE6rZc0oUjWPKY7m2XM="; // 32-byte Base64 key

  /// **Encrypts data using AES and returns a Base64 encoded string**
  static String encryptData(String data) {
    final keyBytes = base64Decode(_keyBase64);
    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV.fromLength(16); // Random IV

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"),
    );

    final encrypted = encrypter.encrypt(data, iv: iv);

    // Combine IV + Encrypted Data
    final combined = Uint8List.fromList(iv.bytes + encrypted.bytes);
    return base64Encode(combined);
  }

  /// **Decrypts a Base64 encoded string containing IV + encrypted data**
  static String decryptData(String encryptedData) {
    try {
      final keyBytes = base64Decode(_keyBase64);
      final key = encrypt.Key(Uint8List.fromList(keyBytes));

      final encryptedBytes = base64Decode(encryptedData.trim());

      // Extract IV (first 16 bytes) and encrypted text (remaining bytes)
      final iv = encrypt.IV(Uint8List.fromList(encryptedBytes.sublist(0, 16)));
      final encryptedText = Uint8List.fromList(encryptedBytes.sublist(16));

      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"),
      );

      final decrypted = encrypter.decrypt(
        encrypt.Encrypted(encryptedText),
        iv: iv,
      );
      print(">>>Decrypted data: $decrypted");

      return decrypted;
    } catch (e) {
      return "Decryption failed!";
    }
  }
}
