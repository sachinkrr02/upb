import 'dart:convert';
import 'package:crypto/crypto.dart';

class UtilClass {
  // Example of encrypting data using SHA-256 (you can modify this as per your requirement)
  static String encrypt(String data) {
    // Convert the string data to bytes
    List<int> bytes = utf8.encode(data);
    
    // Apply SHA-256 hash
    var digest = sha256.convert(bytes);
    
    // Return the hexadecimal string representation of the hash
    return digest.toString();
  }
}
