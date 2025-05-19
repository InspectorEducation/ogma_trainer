import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/models/exercise_detail_model.dart';
import 'package:ogma_trainer/services/storage_service.dart';

class ExerciseService {
  final StorageService _storageService = StorageService();
  
  Future<ExerciseDetail> getExerciseDetails(int exerciseId) async {    
    final Uri url = Uri.parse(AppConfig.getEquipmentRutineService("/Exercises/$exerciseId"));    
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
        return ExerciseDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        debugPrint("Error al obtener detalles del ejercicio $exerciseId (${response.statusCode}): ${response.body}");
        throw Exception("Error al obtener detalles del ejercicio: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Excepción al obtener detalles del ejercicio $exerciseId: $e");
      throw Exception("Excepción al obtener detalles del ejercicio: $e");
    }
  }
}