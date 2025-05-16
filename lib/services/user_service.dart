import 'dart:convert';

import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:http/http.dart' as http;

class UserService {
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final Uri url = Uri.parse(AppConfig.getUserManagementUrl("/Users/$userId"));
    final token = await _storageService.getToken();

    if (token == null) return {"success": false, "message": "No autenticado."};

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",          
        },
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {
          "success": false,
          "message": "Error al obtener perfil (${response.statusCode}): ${response.body}",
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión al obtener perfil: $e"};
    }
  }

  Future<Map<String, dynamic>> getUserPersonalInformation(String userId) async {    
    final Uri url = Uri.parse(AppConfig.getUserManagementUrl("/users/$userId/personal-information"));
    final token = await _storageService.getToken();

    if (token == null) return {"success": false, "message": "No autenticado."};

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",         
        },
      );

      if (response.statusCode == 200) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {
          "success": false,
          "message": "Error al obtener información personal (${response.statusCode}): ${response.body}",
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión al obtener info. personal: $e"};
    }
  }

  Future<Map<String, dynamic>> updateUserProfile({
    required String userId,
    required String nombre,
    required String apellido,
    required String email,
    String? password,
    required String fechaNacimiento,
    required String genero,
    required String telefono,
    List<String> roles = const ["Cliente"],
  }) async {
    final Uri url = Uri.parse(AppConfig.getUserManagementUrl("/Users/$userId"));
    final token = await _storageService.getToken();

    if (token == null) return {"success": false, "message": "No autenticado."};
    
    Map<String, dynamic> body = {
      "nombre": nombre,
      "apellido": apellido,
      "email": email,
      "roles": roles,
      "fechaNacimiento": fechaNacimiento,
      "genero": genero,
      "telefono": telefono,
    };

    // Añadir contraseña solo si se proporcionó una nueva
    if (password != null && password.isNotEmpty) {
      body["password"] = password;
    }

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",          
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {        
        return {
          "success": true,
          "message": "Perfil actualizado exitosamente.",          
        };
      } else {
        String errorMessage = "Error al actualizar el perfil (${response.statusCode}).";
        try {
            final responseBody = jsonDecode(response.body);
            if (responseBody != null) {
                if (responseBody['message'] is String) {
                    errorMessage = responseBody['message'];
                } else if (responseBody['errors'] is Map) {
                    var errors = responseBody['errors'] as Map;
                    errorMessage = errors.entries.map((e) => "${e.key}: ${(e.value as List).join(', ')}").join("\n");
                } else if (responseBody['title'] is String) {
                    errorMessage = responseBody['title'];
                }
            } else if (response.body.isNotEmpty) {
                errorMessage = response.body;
            }
        } catch (e) {
            if (response.body.isNotEmpty) errorMessage = response.body;
        }
        return {
          "success": false,
          "message": errorMessage,
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error de conexión al actualizar perfil: $e"};
    }
  }
}