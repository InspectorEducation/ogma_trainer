import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/models/machine_model.dart';
import 'package:ogma_trainer/models/routine_model.dart';
import 'package:ogma_trainer/models/user_routine_assignment_model.dart';
import 'package:ogma_trainer/services/storage_service.dart';

class RoutineService {
  final StorageService _storageService = StorageService();

  Future<List<Routine>> getAllRoutines() async {
    final Uri url = Uri.parse(AppConfig.getEquipmentRutineService("/Routines"));
    final token = await _storageService.getToken();

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",          
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Routine> routines = body.map((dynamic item) => Routine.fromJson(item)).toList();
        return routines;
      } else {
        debugPrint("Error al obtener rutinas (${response.statusCode}): ${response.body}");
        throw Exception("Error al obtener rutinas: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Excepción al obtener rutinas: $e");
      throw Exception("Excepción al obtener rutinas: $e");
    }
  }

  Future<Routine> getRoutineDetails(int rutinaId) async {
    final Uri url = Uri.parse(AppConfig.getEquipmentRutineService("/Routines/$rutinaId"));
    final token = await _storageService.getToken();
    debugPrint("URL DETALLE ENTRENAMIENTO: $url");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",          
        },
      );

      if (response.statusCode == 200) {        
        return Routine.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        debugPrint("Error al obtener detalles de la rutina $rutinaId (${response.statusCode}): ${response.body}");
        throw Exception("Error al obtener detalles de la rutina: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Excepción al obtener detalles de la rutina $rutinaId: $e");
      throw Exception("Excepción al obtener detalles de la rutina: $e");
    }
  }

  Future<List<Machine>> getRequiredMachinesForRoutine(int rutinaId) async {    
    final Uri url = Uri.parse(AppConfig.getEquipmentRutineService("/Routines/$rutinaId/required-machines"));
    final token = await _storageService.getToken(); // Si se necesita token

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",          
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<Machine> machines = body.map((dynamic item) => Machine.fromJson(item)).toList();
        return machines;
      } else {
        debugPrint("Error al obtener máquinas requeridas para rutina $rutinaId (${response.statusCode}): ${response.body}");        
        return [];       
      }
    } catch (e) {
      debugPrint("Excepción al obtener máquinas requeridas para rutina $rutinaId: $e");
      return [];      
    }
  }

  Future<UserRoutineAssignment?> getAssignedAIRoutine(String userId) async {
    final int iaTrainerId = AppConfig.idEntrenadorAsignadorIa;
    final Uri url = Uri.parse(AppConfig.getEquipmentRutineService("/Routines/user/$userId/assigned-by-trainer/$iaTrainerId"));
    final token = await _storageService.getToken();    
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        if (body.isNotEmpty) {          
          return UserRoutineAssignment.fromJson(body.first as Map<String, dynamic>);
        }
        return null;
      } else {
        debugPrint("Error al obtener rutina asignada por IA (${response.statusCode}): ${response.body}");        
        return null;
      }
    } catch (e) {
      debugPrint("Excepción al obtener rutina asignada por IA: $e");
      return null;
    }
  }
}