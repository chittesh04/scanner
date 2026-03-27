import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

class EncryptionService {
  final _algorithm = AesGcm.with256bits();

  Future<SecretBox> encrypt(Uint8List plaintext, SecretKey key) async {
    final nonce = _randomNonce();
    return _algorithm.encrypt(plaintext, secretKey: key, nonce: nonce);
  }

  Future<Uint8List> decrypt(SecretBox box, SecretKey key) async {
    final data = await _algorithm.decrypt(box, secretKey: key);
    return Uint8List.fromList(data);
  }

  List<int> _randomNonce() {
    final random = Random.secure();
    return List<int>.generate(12, (_) => random.nextInt(256));
  }

  static String encodeSecretBox(SecretBox box) => jsonEncode({
        'nonce': base64Encode(box.nonce),
        'cipherText': base64Encode(box.cipherText),
        'mac': base64Encode(box.mac.bytes),
      });

  static SecretBox decodeSecretBox(String encoded) {
    final map = jsonDecode(encoded) as Map<String, dynamic>;
    return SecretBox(
      base64Decode(map['cipherText'] as String),
      nonce: base64Decode(map['nonce'] as String),
      mac: Mac(base64Decode(map['mac'] as String)),
    );
  }
}
