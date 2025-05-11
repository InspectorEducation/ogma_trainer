import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/models/user_profile_data.dart';
import 'package:ogma_trainer/services/storage_service.dart';

class AuthService {
 final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final Uri url = Uri.parse(AppConfig.getUserManagementUrl("/Auth/login"));

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {        
        final String token = responseBody['token'];
        final String userId = responseBody['userId']?.toString() ?? '';
        final String userEmail = responseBody['email'] ?? '';

        await _storageService.saveToken(token);
        if (userId.isNotEmpty) await _storageService.saveUserId(userId);
        if (userEmail.isNotEmpty) await _storageService.saveUserEmail(userEmail);

        return {
          "success": true,
          "data": responseBody,
          "message": "Login exitoso"
        };
      } else {
        // Error desde el backend (ej. 400, 401, 404)
        String errorMessage = "Error en el login.";
        if (responseBody != null && responseBody['message'] != null) {
          errorMessage = responseBody['message'];
        } else if (responseBody != null && responseBody['error'] != null) {
           errorMessage = responseBody['error'];
        } else if (response.statusCode == 401) {
          errorMessage = "Credenciales incorrectas.";
        }
        return {
          "success": false,
          "message": errorMessage,
          "statusCode": response.statusCode
        };
      }
    } catch (e) {      
      return {
        "success": false,
        "message": "No se pudo conectar al servidor. Inténtalo de nuevo. ($e)"
      };
    }
  }

  Future<void> logout() async {
    await _storageService.clearAllUserData();    
  }

  Future<bool> isLoggedIn() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<Map<String, dynamic>> registerUser({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    required String fechaNacimiento,
    required String genero,
    required String telefono,
    List<String> roles = const ["Cliente"],
  }) async {
    final Uri url = Uri.parse(AppConfig.getUserManagementUrl("/Users"));

    String generoApi = genero;
    if (genero == "Hombre") generoApi = "Masculino";
    if (genero == "Mujer") generoApi = "Femenino";
    if (genero == "Prefiero no especificar") generoApi = "Otro";

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",          
        },
        body: jsonEncode({
          "nombre": nombre,
          "apellido": apellido,
          "email": email,
          "password": password,
          "roles": roles,
          "fechaNacimiento": fechaNacimiento,
          "genero": generoApi,
          "telefono": telefono,
        }),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 201) {    
        final String userId = responseBody['userId']?.toString() ?? '';
        await _storageService.saveUserId(userId);
        return {
          "success": true,
          "message": "Usuario creado exitosamente.",          
        };
      } else {
        String errorMessage = "Error al registrar el usuario.";
        try {
            
            if (responseBody != null) {
                if (responseBody['message'] is String) {
                    errorMessage = responseBody['message'];
                } else if (responseBody['errors'] != null) {                  
                    var errors = responseBody['errors'];
                    if (errors is Map) {
                        errorMessage = errors.values.map((e) => e is List ? e.join(", ") : e.toString()).join("\n");
                    } else if (errors is List) {
                        errorMessage = errors.join("\n");
                    }
                } else if (responseBody['title'] is String && response.statusCode == 400) { // ASP.NET Core validation problem details
                    errorMessage = responseBody['title'];
                }
            }
        } catch (e) {
            if (response.body.isNotEmpty) {
                errorMessage = response.body;
            }
        }      
        return {
          "success": false,
          "message": errorMessage,
          "statusCode": response.statusCode
        };
      }
    } catch (e) {      
      return {
        "success": false,
        "message": "No se pudo conectar al servidor para el registro. ($e)"
      };
    }
  }

  Future<Map<String, dynamic>> updateUserPersonalInformation({
    required String userId,
    required UserProfileData data,
  }) async {
    final Uri url = Uri.parse(AppConfig.getUserManagementUrl("/Users/$userId/personal-information"));
    final token = await _storageService.getToken();

    if (token == null) {
      return {"success": false, "message": "No autenticado. Por favor, inicia sesión."};
    }

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Añade el token JWT          
        },
        body: jsonEncode(data.toJson()), // Usa el método toJson del modelo
      );

      if (response.statusCode == 200 || response.statusCode == 204) { // 200 OK o 204 No Content para éxito
        return {
          "success": true,
          "message": "Información personal actualizada exitosamente."
        };
      } else {
        String errorMessage = "Error al actualizar la información personal.";
         try {
            final responseBody = jsonDecode(response.body);
            if (responseBody != null && responseBody['message'] != null) {
                errorMessage = responseBody['message'];
            } else if (responseBody != null && responseBody['errors'] != null) {
                var errors = responseBody['errors'];
                if (errors is Map) {
                    errorMessage = errors.values.map((e) => e is List ? e.join(", ") : e.toString()).join("\n");
                } else if (errors is List) {
                    errorMessage = errors.join("\n");
                }
            }
        } catch (e) {
            print("Error al parsear cuerpo de error de actualización: $e");
             if (response.body.isNotEmpty) errorMessage = response.body;
        }
        return {
          "success": false,
          "message": errorMessage,
          "statusCode": response.statusCode
        };
      }
    } catch (e) {
      print("Error en AuthService.updateUserPersonalInformation: $e");
      return {
        "success": false,
        "message": "No se pudo conectar al servidor. ($e)"
      };
    }
  }
}