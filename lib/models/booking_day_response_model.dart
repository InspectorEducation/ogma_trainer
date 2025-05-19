class BookedMachine {
  final int exerciseId;
  final String exerciseName;
  final int machineId;
  final String machineName;
  final int reservationId;
  final DateTime reservedStartTime;
  final DateTime reservedEndTime;

  BookedMachine({
    required this.exerciseId,
    required this.exerciseName,
    required this.machineId,
    required this.machineName,
    required this.reservationId,
    required this.reservedStartTime,
    required this.reservedEndTime,
  });

  factory BookedMachine.fromJson(Map<String, dynamic> json) {
    return BookedMachine(
      exerciseId: json['exerciseId'] as int,
      exerciseName: json['exerciseName'] as String,
      machineId: json['machineId'] as int,
      machineName: json['machineName'] as String,
      reservationId: json['reservationId'] as int,
      reservedStartTime: DateTime.parse(json['reservedStartTime'] as String),
      reservedEndTime: DateTime.parse(json['reservedEndTime'] as String),
    );
  }
}

class BookingDayResponse {
  final int userId;
  final int routineId;
  final int diaNumero;
  final String message;
  final List<BookedMachine> bookedMachines;

  BookingDayResponse({
    required this.userId,
    required this.routineId,
    required this.diaNumero,
    required this.message,
    required this.bookedMachines,
  });

  factory BookingDayResponse.fromJson(Map<String, dynamic> json) {
    var list = json['bookedMachines'] as List;
    List<BookedMachine> machines =
        list.map((i) => BookedMachine.fromJson(i as Map<String, dynamic>)).toList();
    return BookingDayResponse(
      userId: json['userId'] as int,
      routineId: json['routineId'] as int,
      diaNumero: json['diaNumero'] as int,
      message: json['message'] as String,
      bookedMachines: machines,
    );
  }
}