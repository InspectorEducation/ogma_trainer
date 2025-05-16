class Booking {
  final int reservationId;
  final String reservationType; // "Machine", "Trainer", "Class"
  final int userId;
  final String itemName;
  final int itemId;
  final DateTime startTime;
  final DateTime endTime;
  final String status;
  final bool? attended; // Puede ser null

  Booking({
    required this.reservationId,
    required this.reservationType,
    required this.userId,
    required this.itemName,
    required this.itemId,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.attended,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      reservationId: json['reservationId'] as int,
      reservationType: json['reservationType'] as String,
      userId: json['userId'] as int,
      itemName: json['itemName'] as String,
      itemId: json['itemId'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      status: json['status'] as String,
      attended: json['attended'] as bool?,
    );
  }

  // Para facilitar la visualización en el timeline (agrupado por hora)
  int get startHour => startTime.hour;
  int get startMinute => startTime.minute;
}