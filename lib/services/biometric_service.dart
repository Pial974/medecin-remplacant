import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Clés de stockage
  static const String _keyEmail = 'biometric_email';
  static const String _keyPassword = 'biometric_password';
  static const String _keyEnabled = 'biometric_enabled';

  // Vérifier si le device supporte la biométrie
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  // Vérifier si la biométrie est disponible (configurée sur le device)
  Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Obtenir les types de biométrie disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Vérifier si la biométrie est activée dans l'app
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyEnabled) ?? false;
  }

  // Activer la biométrie
  Future<bool> enableBiometric(String email, String password) async {
    try {
      // Stocker les credentials de manière sécurisée
      await _secureStorage.write(key: _keyEmail, value: email);
      await _secureStorage.write(key: _keyPassword, value: password);

      // Marquer comme activé
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyEnabled, true);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Désactiver la biométrie
  Future<void> disableBiometric() async {
    try {
      await _secureStorage.delete(key: _keyEmail);
      await _secureStorage.delete(key: _keyPassword);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyEnabled, false);
    } catch (e) {
      // Silencieux
    }
  }

  // Authentifier avec la biométrie
  Future<BiometricAuthResult> authenticateWithBiometric() async {
    try {
      // Vérifier si activé
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        return BiometricAuthResult(
          success: false,
          error: 'Biométrie non activée',
        );
      }

      // Demander l'authentification biométrique
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authentifiez-vous pour accéder à l\'application',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (!authenticated) {
        return BiometricAuthResult(
          success: false,
          error: 'Authentification annulée',
        );
      }

      // Récupérer les credentials
      final email = await _secureStorage.read(key: _keyEmail);
      final password = await _secureStorage.read(key: _keyPassword);

      if (email == null || password == null) {
        return BiometricAuthResult(
          success: false,
          error: 'Credentials non trouvés',
        );
      }

      return BiometricAuthResult(
        success: true,
        email: email,
        password: password,
      );
    } catch (e) {
      return BiometricAuthResult(
        success: false,
        error: 'Erreur: ${e.toString()}',
      );
    }
  }

  // Obtenir le nom de la biométrie disponible
  Future<String> getBiometricName() async {
    final biometrics = await getAvailableBiometrics();

    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Touch ID';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (biometrics.contains(BiometricType.strong)) {
      return 'Biométrie';
    } else if (biometrics.contains(BiometricType.weak)) {
      return 'Biométrie';
    }

    return 'Biométrie';
  }
}

class BiometricAuthResult {
  final bool success;
  final String? email;
  final String? password;
  final String? error;

  BiometricAuthResult({
    required this.success,
    this.email,
    this.password,
    this.error,
  });
}
