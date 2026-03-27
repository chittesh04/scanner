import 'package:local_auth/local_auth.dart';

class BiometricGuard {
  BiometricGuard(this._localAuth);
  final LocalAuthentication _localAuth;

  Future<bool> authenticate() {
    return _localAuth.authenticate(
      localizedReason: 'Authenticate to access encrypted SmartScan documents',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }
}
