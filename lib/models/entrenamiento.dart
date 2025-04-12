class Entrenamiento {
  final int step;
  final int totalSteps;
  final String name;
  final Duration duration;
  final Duration rest;
  final String imageAsset;

  Entrenamiento({
    required this.step,
    required this.totalSteps,
    required this.name,
    required this.duration,
    required this.rest,
    required this.imageAsset,
  });

  factory Entrenamiento.fromJson(Map<String, dynamic> json) {
    return Entrenamiento(
      step: json['step'],
      totalSteps: json['totalSteps'],
      name: json['name'],
      duration: _parseDuration(json['duration']),
      rest: _parseDuration(json['rest']),
      imageAsset: json['imageAsset'],
    );
  }

  static Duration _parseDuration(String value) {
    final parts = value.split(':').map(int.parse).toList();
    return Duration(minutes: parts[0], seconds: parts[1]);
  }
}