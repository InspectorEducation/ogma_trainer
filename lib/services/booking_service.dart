import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Para formatear la fecha para la API
import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/models/availability_check_response_model.dart';
import 'package:ogma_trainer/models/booking_day_response_model.dart';
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:ogma_trainer/models/booking_model.dart'; // Crearemos este modelo

class BookingService {
  final StorageService _storageService = StorageService();

  Future<List<Booking>> getUserBookingsForDay(
      String userId, DateTime date) async {
    // Formatear la fecha a YYYY-MM-DD para la API
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final Uri url = Uri.parse(AppConfig.getBookingServiceUrl(
        "/Bookings/user/$userId/day/$formattedDate"));
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
        List<Booking> bookings =
            body.map((dynamic item) => Booking.fromJson(item)).toList();
        return bookings;
      } else {
        // Manejar errores de la API (ej. 404 si no hay reservas, u otros errores)
        debugPrint(
            "Error al obtener reservas (${response.statusCode}): ${response.body}");
        return []; // Devolver lista vacía en caso de error para no romper la UI
      }
    } catch (e) {
      debugPrint("Excepción al obtener reservas: $e");
      return []; // Devolver lista vacía en caso de excepción
    }
  }

  Future<List<Booking>> getBookingsForDay(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final Uri url = Uri.parse(
        AppConfig.getBookingServiceUrl("/Bookings/day/$formattedDate"));
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
        return body.map((dynamic item) => Booking.fromJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Excepción en getBookingsForDay: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> _cancelBookingGeneric({
    required String endpoint,
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
        String errorMessage =
            "Error al cancelar la reserva (${response.statusCode}).";
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
        return {
          "success": false,
          "message": errorMessage,
          "statusCode": response.statusCode
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error de conexión al cancelar reserva: $e"
      };
    }
  }

  Future<Map<String, dynamic>> bookMachine({
    required int userId,
    required int machineId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final Uri url =
        Uri.parse(AppConfig.getBookingServiceUrl("/Bookings/machines"));
    final token = await _storageService.getToken();
    if (token == null) return {"success": false, "message": "No autenticado."};

    String formattedStartTime = startTime.toIso8601String();
    String formattedEndTime = endTime.toIso8601String();
    debugPrint("DIA Y HORA A RESERVAR FORMATED: $formattedStartTime");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "idUsuario": userId,
          "idMaquina": machineId,
          "fechaHoraInicio": formattedStartTime,
          "fechaHoraFin": formattedEndTime,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {"success": true, "message": "Máquina reservada exitosamente."};
      } else {
        String errorMessage =
            "Error al reservar máquina (${response.statusCode}).";
        try {
          final responseBody = jsonDecode(response.body);
          errorMessage =
              responseBody['message'] ?? responseBody['title'] ?? response.body;
        } catch (e) {
          if (response.body.isNotEmpty) errorMessage = response.body;
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
        "message": "Error de conexión al reservar máquina: $e"
      };
    }
  }

  Future<Map<String, dynamic>> cancelMachineBooking(int reservationId) async {
    return _cancelBookingGeneric(endpoint: "/Bookings/machines/$reservationId");
  }

  Future<Map<String, dynamic>> cancelTrainerBooking(int reservationId) async {
    return _cancelBookingGeneric(endpoint: "/Bookings/trainers/$reservationId");
  }

  Future<Map<String, dynamic>> cancelClassBookingRegistration(
      int registrationId) async {
    return _cancelBookingGeneric(
        endpoint: "/Bookings/classes/registrations/$registrationId");
  }

  Future<AvailabilityCheckResponse> validateRoutineDayAvailability({
    required int routineId,
    required int diaNumero,
    required DateTime desiredStartDateTime,
  }) async {
    final Uri url = Uri.parse(AppConfig.getBookingServiceUrl(
        "/Bookings/routines/validate-availability"));
    final token = await _storageService.getToken();

    try {
      final response = await http.post(
        // POST
        url,
        headers: {
          "Content-Type": "application/json",
          if (token != null) "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "routineId": routineId,
          "diaNumero": diaNumero,
          "desiredStartDateTime": desiredStartDateTime.toIso8601String(),
        }),
      );
      String horaReserva = desiredStartDateTime.toIso8601String();
      debugPrint("HORA DE LA RESERVA: $horaReserva");
      if (response.statusCode == 200) {
        return AvailabilityCheckResponse.fromJson(jsonDecode(response.body));
      } else {
        debugPrint(
            "Error al validar disponibilidad (${response.statusCode}): ${response.body}");        
        String errorMessage = "Error al validar disponibilidad.";
        try {
          final responseBody = jsonDecode(response.body);
          errorMessage =
              responseBody['message'] ?? responseBody['title'] ?? response.body;
        } catch (e) {
          if (response.body.isNotEmpty) errorMessage = response.body;
        }

        return AvailabilityCheckResponse(
            isOverallAvailable: false,
            message: errorMessage,
            originalRequestedStartTime:
                desiredStartDateTime,
            exerciseAvailabilities: []);
      }
    } catch (e) {
      debugPrint("Excepción al validar disponibilidad: $e");
      return AvailabilityCheckResponse(
          isOverallAvailable: false,
          message: "Error de conexión al validar disponibilidad: $e",
          originalRequestedStartTime: desiredStartDateTime,
          exerciseAvailabilities: []);
    }
  }

  Future<BookingDayResponse> bookRoutineDay({
    required int userId,
    required int routineId,
    required int diaNumero,
    required DateTime startDateTime,
  }) async {
    final Uri url = Uri.parse(AppConfig.getBookingServiceUrl("/Bookings/routines/book-day"));
    final token = await _storageService.getToken();
    if (token == null) throw Exception("Usuario no autenticado.");


    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "userId": userId,
          "routineId": routineId,
          "diaNumero": diaNumero,
          "startDateTime": startDateTime.toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingDayResponse.fromJson(jsonDecode(response.body));
      } else {
         debugPrint("Error al programar día de rutina (${response.statusCode}): ${response.body}");
        String errorMessage = "Error al programar día de rutina.";
         try {
            final responseBody = jsonDecode(response.body);
            errorMessage = responseBody['message'] ?? responseBody['title'] ?? response.body;
        } catch (e) { if(response.body.isNotEmpty) errorMessage = response.body; }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint("Excepción al programar día de rutina: $e");
      throw Exception("Excepción al programar día de rutina: $e");
    }
  }

  Future<Map<String, dynamic>> registerForClass({
  required int classId,
  required int userId,
}) async {
  final Uri url = Uri.parse(AppConfig.getBookingServiceUrl("/Bookings/classes/$classId/register"));
  final token = await _storageService.getToken();
  if (token == null) return {"success": false, "message": "No autenticado."};

  try {
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"idUsuario": userId}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {      
      // final responseBody = jsonDecode(response.body);
      return {"success": true, "message": "Inscripción a clase exitosa." /*, "data": responseBody */};
    } else {
      String errorMessage = "Error al inscribirse a clase (${response.statusCode}).";
      try {
          final responseBody = jsonDecode(response.body);
          errorMessage = responseBody['message'] ?? responseBody['title'] ?? response.body;
      } catch (e) { if(response.body.isNotEmpty) errorMessage = response.body; }
      return {"success": false, "message": errorMessage, "statusCode": response.statusCode};
    }
  } catch (e) {
    return {"success": false, "message": "Error de conexión al inscribirse a clase: $e"};
  }
}
}
