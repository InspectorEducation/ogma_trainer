import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Para formatear la fecha para la API
import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:ogma_trainer/models/booking_model.dart'; // Crearemos este modelo

class BookingService {
  final StorageService _storageService = StorageService();

  Future<List<Booking>> getUserBookingsForDay(String userId, DateTime date) async {
    // Formatear la fecha a YYYY-MM-DD para la API
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final Uri url = Uri.parse(AppConfig.getBookingServiceUrl("/Bookings/user/$userId/day/$formattedDate"));
    debugPrint("URL: $url");
    final token = await _storageService.getToken();

    if (token == null) {    
       throw Exception("Usuario no autenticado.");
    }

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
        List<Booking> bookings = body.map((dynamic item) => Booking.fromJson(item)).toList();
        return bookings;
      } else {
        // Manejar errores de la API (ej. 404 si no hay reservas, u otros errores)
        debugPrint("Error al obtener reservas (${response.statusCode}): ${response.body}");
        return []; // Devolver lista vacía en caso de error para no romper la UI
      }
    } catch (e) {
      debugPrint("Excepción al obtener reservas: $e");
      return []; // Devolver lista vacía en caso de excepción
    }
  }

  Future<Map<String, dynamic>> _cancelBookingGeneric({
    required String endpoint, // Ej: "/api/Bookings/machines/123"
  }) async {
    final Uri url = Uri.parse(AppConfig.getBookingServiceUrl(endpoint));
    final token = await _storageService.getToken();
    if (token == null) return {"success": false, "message": "No autenticado."};

    try {
      final response = await http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",          
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {"success": true, "message": "Reserva cancelada exitosamente."};
      } else {
        String errorMessage = "Error al cancelar la reserva (${response.statusCode}).";
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
      return {"success": false, "message": "Error de conexión al cancelar reserva: $e"};
    }
  }

  Future<Map<String, dynamic>> cancelMachineBooking(int reservationId) async {
    return _cancelBookingGeneric(endpoint: "/Bookings/machines/$reservationId");
  }

  Future<Map<String, dynamic>> cancelTrainerBooking(int reservationId) async {
    return _cancelBookingGeneric(endpoint: "/Bookings/trainers/$reservationId");
  }

  Future<Map<String, dynamic>> cancelClassBookingRegistration(int registrationId) async {    
    return _cancelBookingGeneric(endpoint: "/Bookings/classes/registrations/$registrationId");
  }
}