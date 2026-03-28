
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

  static Uint8List encodeSecretBox(SecretBox box) {
    final builder = BytesBuilder(copy: false);
    builder.add(box.nonce);
    builder.add(box.mac.bytes);
    builder.add(box.cipherText);
    return builder.takeBytes();
  }

  static SecretBox decodeSecretBox(Uint8List bytes) {
    if (bytes.length < 28) {
      throw FormatException('Invalid or corrupted encrypted payload.');
    }
    final nonce = bytes.sublist(0, 12);
    final mac = Mac(bytes.sublist(12, 28));
    final cipherText = bytes.sublist(28);
    return SecretBox(cipherText, nonce: nonce, mac: mac);
  }
}
