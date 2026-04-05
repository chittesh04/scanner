import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the app's master AES-256 encryption key using the Android Keystore
/// (hardware-backed security via [FlutterSecureStorage]).
///
/// On first launch, a cryptographically secure random key is generated and
/// stored. On subsequent launches, the existing key is loaded. The key never
/// leaves the secure enclave in plaintext.
class KeyManager {
  static const _storageKey = 'smartscan_master_aes_key';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static SecretKey? _cachedKey;

  /// Returns the master encryption key, generating one on first launch.
  ///
  /// The key is cached in memory after the first call to avoid repeated
  /// Keystore lookups during the app session.
  static Future<SecretKey> getOrGenerateMasterKey() async {
    if (_cachedKey != null) return _cachedKey!;

    final stored = await _storage.read(key: _storageKey);
    if (stored != null) {
      _cachedKey = SecretKey(base64Decode(stored));
      return _cachedKey!;
    }

    // First launch: generate a secure random 256-bit key.
    final newKey = await AesGcm.with256bits().newSecretKey();
    final keyBytes = await newKey.extractBytes();
    await _storage.write(key: _storageKey, value: base64Encode(keyBytes));

    _cachedKey = newKey;
    return _cachedKey!;
  }

  /// Retrieves the cached key. Throws if [getOrGenerateMasterKey] hasn't
  /// been called yet (i.e. bootstrap hasn't completed).
  static SecretKey get currentKey {
    if (_cachedKey == null) {
      throw StateError(
        'KeyManager.getOrGenerateMasterKey() must be called during bootstrap '
        'before accessing currentKey.',
      );
    }
    return _cachedKey!;
  }
}
