import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/models/routine_model.dart';
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
}