import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ogma_trainer/config/app_config.dart'; 

class StorageService {
  final _secureStorage = const FlutterSecureStorage();

  // --- Métodos para el Token JWT ---
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: AppConfig.jwtTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConfig.jwtTokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: AppConfig.jwtTokenKey);
  }

  // --- Métodos para otra información del usuario (opcional pero útil) ---
  Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: AppConfig.userIdKey, value: userId);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: AppConfig.userIdKey);
  }

  Future<void> saveUserEmail(String email) async {
    await _secureStorage.write(key: AppConfig.userEmailKey, value: email);
  }

  Future<String?> getUserEmail() async {
    return await _secureStorage.read(key: AppConfig.userEmailKey);
  }

  // Método para borrar toda la información del usuario al cerrar sesión
  Future<void> clearAllUserData() async {
    await _secureStorage.delete(key: AppConfig.jwtTokenKey);
    await _secureStorage.delete(key: AppConfig.userIdKey);
    await _secureStorage.delete(key: AppConfig.userEmailKey);    
  }
}