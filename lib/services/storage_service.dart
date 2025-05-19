import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ogma_trainer/config/app_config.dart'; 

class StorageService {
  final _secureStorage = const FlutterSecureStorage();
  static const String _checkInIdKey = "current_check_in_id";
  static const String _checkedInGymIdKey = "current_checked_in_gym_id";

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

  Future<void> saveCheckInData({required String checkInId, required String gymId}) async {
    await _secureStorage.write(key: _checkInIdKey, value: checkInId);
    await _secureStorage.write(key: _checkedInGymIdKey, value: gymId);
  }

  Future<String?> getCheckInId() async {
    return await _secureStorage.read(key: _checkInIdKey);
  }

  Future<String?> getCheckedInGymId() async {
    return await _secureStorage.read(key: _checkedInGymIdKey);
  }

  Future<void> clearCheckInData() async {
    await _secureStorage.delete(key: _checkInIdKey);
    await _secureStorage.delete(key: _checkedInGymIdKey);
  }

  // Método para borrar toda la información del usuario al cerrar sesión
  Future<void> clearAllUserData() async {
    await _secureStorage.delete(key: AppConfig.jwtTokenKey);
    await _secureStorage.delete(key: AppConfig.userIdKey);
    await _secureStorage.delete(key: AppConfig.userEmailKey);    
    await clearCheckInData();
  }
  
  Future<String?> getAppId() async {    
    return await _secureStorage.read(key: AppConfig.appId);
  }

  Future<String?> getAppSign() async {
    return await _secureStorage.read(key: AppConfig.appSign);
  }
}