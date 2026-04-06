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
    final cached = _cachedKey;
    if (cached != null) return cached;

    final stored = await _storage.read(key: _storageKey);
    if (stored != null) {
      final restored = SecretKey(base64Decode(stored));
      _cachedKey = restored;
      return restored;
    }

    // First launch: generate a secure random 256-bit key.
    final newKey = await AesGcm.with256bits().newSecretKey();
    final keyBytes = await newKey.extractBytes();
    await _storage.write(key: _storageKey, value: base64Encode(keyBytes));

    _cachedKey = newKey;
    return newKey;
  }

  /// Retrieves the cached key. Throws if [getOrGenerateMasterKey] hasn't
  /// been called yet (i.e. bootstrap hasn't completed).
  static SecretKey get currentKey {
    final cached = _cachedKey;
    if (cached == null) {
      throw StateError(
        'KeyManager.getOrGenerateMasterKey() must be called during bootstrap '
        'before accessing currentKey.',
      );
    }
    return cached;
  }
}
