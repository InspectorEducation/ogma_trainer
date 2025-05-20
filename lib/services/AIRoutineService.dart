import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/models/user_profile_data.dart';
import 'package:ogma_trainer/models/routine_model.dart';
import 'package:ogma_trainer/services/storage_service.dart';


class AIRoutineService {
  final StorageService _storageService = StorageService();

  Future<Map<String, dynamic>> generatePersonalizedRoutine({
    required UserProfileData userProfileData,   
  }) async {
    final Uri url = Uri.parse(AppConfig.getEquipmentRutineService("/ai-routines/generate-personalized"));
    final token = await _storageService.getToken();

    if (token == null) {
      return {"success": false, "message": "No autenticado."};
    }

   
    Map<String, dynamic> requestBody = userProfileData.toJson();
    
    debugPrint("Enviando a AI para generar rutina: ${jsonEncode(requestBody)}");


    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",          
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {        
        final routineData = Routine.fromJson(jsonDecode(response.body));
        return {
            "success": true,
            "message": "Rutina personalizada generada exitosamente.",
            "data": routineData
        };
      } else {
        String errorMessage = "Error al generar rutina (${response.statusCode}).";
        try {
            final responseBody = jsonDecode(response.body);
            errorMessage = responseBody['message'] ?? responseBody['title'] ?? response.body;
        } catch (e) { if(response.body.isNotEmpty) errorMessage = response.body; }
        return {"success": false, "message": errorMessage, "statusCode": response.statusCode};
      }
    } catch (e) {
      debugPrint("Excepción al generar rutina: $e");
      return {"success": false, "message": "Error de conexión al generar rutina: $e"};
    }
  }

  Future<Map<String, dynamic>> assignRoutineToUser({
    required int idUsuario,
    required int idRutina,
    int idEntrenadorAsignador = AppConfig.idEntrenadorAsignadorIa,
  }) async {
    
    final Uri url = Uri.parse(AppConfig.getEquipmentRutineService("/Routines/assign"));
    final token = await _storageService.getToken();

    if (token == null) {
      return {"success": false, "message": "No autenticado para asignar rutina."};
    }

    Map<String, dynamic> requestBody = {
      "idUsuario": idUsuario,
      "idRutina": idRutina,
      "idEntrenadorAsignador": idEntrenadorAsignador,
    };

    debugPrint("Asignando rutina: ${jsonEncode(requestBody)}");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",          
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return {
            "success": true,
            "message": "Rutina asignada exitosamente al usuario."            
        };
      } else {
        String errorMessage = "Error al asignar rutina (${response.statusCode}).";
         try {
            final responseBody = jsonDecode(response.body);
            errorMessage = responseBody['message'] ?? responseBody['title'] ?? response.body;
        } catch (e) { if(response.body.isNotEmpty) errorMessage = response.body; }
        return {"success": false, "message": errorMessage, "statusCode": response.statusCode};
      }
    } catch (e) {
      debugPrint("Excepción al asignar rutina: $e");
      return {"success": false, "message": "Error de conexión al asignar rutina: $e"};
    }
  }
}