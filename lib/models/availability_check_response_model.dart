class ExerciseAvailability {
  final int exerciseId;
  final String exerciseName;
  final bool isAvailable;
  final int? availableMachineId;
  final String? availableMachineName;
  final DateTime? suggestedStartTime;
  final String? reasonIfNotAvailable;

  ExerciseAvailability({
    required this.exerciseId,
    required this.exerciseName,
    required this.isAvailable,
    this.availableMachineId,
    this.availableMachineName,
    this.suggestedStartTime,
    this.reasonIfNotAvailable,
  });

  factory ExerciseAvailability.fromJson(Map<String, dynamic> json) {
    return ExerciseAvailability(
      exerciseId: json['exerciseId'] as int,
      exerciseName: json['exerciseName'] as String,
      isAvailable: json['isAvailable'] as bool,
      availableMachineId: json['availableMachineId'] as int?,
      availableMachineName: json['availableMachineName'] as String?,
      suggestedStartTime: json['suggestedStartTime'] != null
          ? DateTime.parse(json['suggestedStartTime'] as String)
          : null,
      reasonIfNotAvailable: json['reasonIfNotAvailable'] as String?,
    );
  }
}

class AvailabilityCheckResponse {
  final bool isOverallAvailable;
  final String message;
  final DateTime originalRequestedStartTime;
  final DateTime? actualPossibleStartTime;
  final List<ExerciseAvailability> exerciseAvailabilities;

  AvailabilityCheckResponse({
    required this.isOverallAvailable,
    required this.message,
    required this.originalRequestedStartTime,
    this.actualPossibleStartTime,
    required this.exerciseAvailabilities,
  });

  factory AvailabilityCheckResponse.fromJson(Map<String, dynamic> json) {
    var list = json['exerciseAvailabilities'] as List;
    List<ExerciseAvailability> availabilities =
        list.map((i) => ExerciseAvailability.fromJson(i as Map<String, dynamic>)).toList();
    return AvailabilityCheckResponse(
      isOverallAvailable: json['isOverallAvailable'] as bool,
      message: json['message'] as String,
      originalRequestedStartTime: DateTime.parse(json['originalRequestedStartTime'] as String),
      actualPossibleStartTime: json['actualPossibleStartTime'] != null
          ? DateTime.parse(json['actualPossibleStartTime'] as String)
          : DateTime.parse(json['originalRequestedStartTime'] as String),
      exerciseAvailabilities: availabilities,
    );
  }
}