import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';

class Encryption {
  /// Converts a base64 URL-safe string to a secret key
  static Future<SecretKey> serializeSecretKey(String base64Key) async {
    List<int> keyBuffer = base64Url.decode(base64Key);
    final algorithm = Chacha20.poly1305Aead();
    final secretKey = await algorithm.newSecretKeyFromBytes(keyBuffer);
    return secretKey;
  }

  /// Converts a secret key to a base64 URL-safe string
  static Future<String> deserializeSecretKey(SecretKey key) async {
    List<int> keyBuffer = await key.extractBytes();
    return base64Url.encode(keyBuffer);
  }

  /// Creates a random secret encryption key
  static Future<SecretKey> createRandomKey() async {
    final algorithm = Chacha20.poly1305Aead();
    final secretKey = await algorithm.newSecretKey();
    return secretKey;
  }

  static Future<String> encryptString(
      SecretKey encryptionKey, String text) async {
    //Get the text as raw bytes and the key as raw bytes
    List<int> textBuffer = utf8.encode(text);

    final algorithm = Chacha20.poly1305Aead();

    //Encrypt the thought
    final secretBox = await algorithm.encrypt(
      textBuffer,
      secretKey: encryptionKey,
    );

    //Return the encrypted thought as a json string
    return jsonEncode({
      'nonce': HEX.encode(secretBox.nonce),
      'cipherText': HEX.encode(secretBox.cipherText),
      'mac': HEX.encode(secretBox.mac.bytes)
    });
  }
}
