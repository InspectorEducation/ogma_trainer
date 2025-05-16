import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/services/storage_service.dart';

class CapacityService {

  final StorageService _storageService = StorageService();  

  Future<Map<String, dynamic>> checkInToGym({
    required int userId,
    required int gymId,
  }) async {
    final Uri url = Uri.parse(AppConfig.getCapacityControlUrl("/Attendance/checkin"));
    final token = await _storageService.getToken();

    if (token == null) {
      return {"success": false, "message": "No autenticado."};
    }

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",          
        },
        body: jsonEncode({
          "userId": userId,
          "gymId": gymId,
        }),
      );
      final responseBody = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {       
        final responseBody = jsonDecode(response.body);
        final dynamic checkInIdFromResponse = responseBody['checkInId']; 
        
        if (checkInIdFromResponse != null && checkInIdFromResponse is int) { // Verificar que sea int
          return {
            "success": true,
            "message": "Check-in realizado exitosamente.",
            "data": { // Asegurar que 'data' existe y tiene 'checkInId'
                "checkInId": checkInIdFromResponse,
                "gymId": gymId, // También puedes tomar gymId de responseBody si la API lo devuelve
                "requiresSymptomForm": responseBody['requiresSymptomForm'] ?? false,
            }
          };
        } else {
           debugPrint("Respuesta de check-in exitosa (status ${response.statusCode}) pero 'checkInId' falta o no es un entero en la respuesta: $responseBody");
           return {
                "success": false, // Marcar como no exitoso si falta el checkInId
                "message": "Respuesta del servidor incompleta (falta checkInId)."
           };
        }
      } else if(response.statusCode == 400 && responseBody['detail'] == "User is already checked in at this gym.") {
        return {
          "success": false,
          "message": "El usuario tiene un registo activo dentro del GYM",
          "statusCode": response.statusCode,
        };
      }
      else {
        String errorMessage = "Error al realizar el check-in. (Status: ${response.statusCode}).";
        try {
            final responseBody = jsonDecode(response.body);
            if (responseBody != null) {
                  if (responseBody['message'] is String) {
                      errorMessage = responseBody['message'];
                  } else if (responseBody['title'] is String) {
                      errorMessage = responseBody['title'];
                  } else if (responseBody is Map && responseBody.isNotEmpty) {
                      errorMessage = responseBody.toString(); // fallback
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
      return {
        "success": false,
        "message": "No se pudo conectar al servidor para el check-in. ($e)"
      };
    }
  }

  Future<Map<String, dynamic>> checkOutFromGym({
    required int userId,
    required int gymId, 
  }) async {
    final Uri url = Uri.parse(AppConfig.getCapacityControlUrl("/Attendance/checkout"));
    final token = await _storageService.getToken();
    if (token == null) return {"success": false, "message": "No autenticado."};

    try {
       final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",          
        },
        body: jsonEncode({
          "userId": userId,
          "gymId": gymId,
        }),
      );

      if (response.statusCode == 204) {
         return {"success": true, "message": "Check-out realizado exitosamente."};
      } else {
        String errorMessage = "Error al realizar el check-out.";
        try {
            final responseBody = jsonDecode(response.body);
             if (responseBody != null && responseBody['message'] != null) {
                errorMessage = responseBody['message'];
            } else if (responseBody != null && responseBody['title'] != null) {
                errorMessage = responseBody['title'];
            }
        } catch (e) {
             if (response.body.isNotEmpty) errorMessage = response.body;
        }
        return {"success": false, "message": errorMessage, "statusCode": response.statusCode};
      }

    } catch (e) {      
       return {"success": false, "message": "No se pudo conectar al servidor para el check-out. ($e)"};
    }
  }

  Future<Map<String, dynamic>> submitFormSymptoms({
    required int checkInId,
    required int userId,
    required bool hasSymptoms,
    required bool hasRecentContact
  }) async {
    final Uri url = Uri.parse(AppConfig.getCapacityControlUrl("/Symptoms/forms"));
    final token = await _storageService.getToken();
    if (token == null) return {"success": false, "message": "No autenticado."};    
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",          
        },
        body: jsonEncode({
          "checkInId": checkInId,
          "userId": userId,
          "hasSymptoms": hasSymptoms,
          "hasRecentContact": hasRecentContact
        }),
      );

      final responseBody = jsonDecode(response.body);
      if(response.statusCode == 201 && responseBody["evaluationResult"] == "Aprobado") {
        return {"success": true, "message": "Formulario enviado correctamente"};
      } else if(response.statusCode == 201 && responseBody["evaluationResult"] == "Rechazado") {
        return {"succes": false, "message": "El usuario presenta síntomas"};
      } else {
         String errorMessage = "Error al enviar el formulario de síntomas";
        try {
            final responseBody = jsonDecode(response.body);
             if (responseBody != null && responseBody['message'] != null) {
                errorMessage = responseBody['message'];
            } else if (responseBody != null && responseBody['title'] != null) {
                errorMessage = responseBody['title'];
            }
        } catch (e) {
             if (response.body.isNotEmpty) errorMessage = response.body;
        }
        return {"success": false, "message": errorMessage, "statusCode": response.statusCode};
      }
    }catch (e) {
       return {"success": false, "message": "No se pudo conectar al servidor para el envio de síntomas. ($e)"};
    }
  }
}