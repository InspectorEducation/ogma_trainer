import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/models/machine_model.dart';
import 'package:ogma_trainer/models/clase_info_model.dart';
import 'package:ogma_trainer/services/storage_service.dart';


class EquipmentService {
  final StorageService _storageService = StorageService(); // Si necesitas token

  Future<List<Machine>> getAllMachines() async {
    final Uri url = Uri.parse(AppConfig.getEquipmentRutineService("/Equipment/machines"));
    final token = await _storageService.getToken();

    debugPrint("URI: $url");
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
        debugPrint("Error al obtener máquinas (${response.statusCode}): ${response.body}");
        throw Exception("Error al obtener máquinas: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Excepción al obtener máquinas: $e");
      throw Exception("Excepción al obtener máquinas: $e");
    }
  }

  Future<List<ClaseInfo>> getAllClasses() async {
    final Uri url = Uri.parse(AppConfig.getEquipmentRutineService("/Classes"));
    final token = await _storageService.getToken(); 

    debugPrint("URL : $url");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",          
        },
      );
      String codeResponse = response.body; 
      debugPrint("RESPUESTA: $codeResponse");
      

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        List<ClaseInfo> classes = body.map((dynamic item) => ClaseInfo.fromJson(item)).toList();
        return classes;
      } else {
        debugPrint("Error al obtener clases (${response.statusCode}): ${response.body}");
        throw Exception("Error al obtener clases: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Excepción al obtener clases: $e");
      throw Exception("Excepción al obtener clases: $e");
    }
  }

  Future<Machine> getMachineDetails(int machineId) async {    
    final Uri url = Uri.parse(AppConfig.getEquipmentRutineService("/Equipment/machines/$machineId"));
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
        return Machine.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        debugPrint("Error al obtener detalles de la máquina $machineId (${response.statusCode}): ${response.body}");
        throw Exception("Error al obtener detalles de la máquina: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Excepción al obtener detalles de la máquina $machineId: $e");
      throw Exception("Excepción al obtener detalles de la máquina: $e");
    }
  }
}