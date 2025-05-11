class UserProfileData {
  double? alturaCm;
  double? pesoInicialKg; // Este podría ser el peso actual al momento de registrar estos datos
  double? pesoActualKg;  // O podrías pedir peso actual y peso inicial por separado
  double? pesoObjetivoKg;
  String? objetivoPrincipal;
  String? experienciaEntrenamiento;
  String? nivelActividadDiaria; // De define_tu_estado_fisico.dart
  String? condicionesMedicas;
  List<String> diasDisponibles; // Ej: ["Lunes", "Miércoles"]
  String? horaInicioDisponible; // Ej: "18:00"
  String? horaFinDisponible;    // Ej: "20:00"
  String? preferenciaLugarEntrenamiento; // "Gimnasio", "Casa", "Ambos"

  UserProfileData({
    this.alturaCm,
    this.pesoInicialKg,
    this.pesoActualKg,
    this.pesoObjetivoKg,
    this.objetivoPrincipal,
    this.experienciaEntrenamiento,
    this.nivelActividadDiaria,
    this.condicionesMedicas,
    this.diasDisponibles = const [],
    this.horaInicioDisponible,
    this.horaFinDisponible,
    this.preferenciaLugarEntrenamiento,
  });

  // Método para convertir a JSON para la API
  Map<String, dynamic> toJson() {
    // Construir la disponibilidad como un string si la API lo espera así
    String disponibilidadEntrenamiento = "";
    if (diasDisponibles.isNotEmpty && horaInicioDisponible != null && horaFinDisponible != null) {
      disponibilidadEntrenamiento = "${diasDisponibles.join(', ')} ($horaInicioDisponible - $horaFinDisponible)";
    } else if (diasDisponibles.isNotEmpty) {
      disponibilidadEntrenamiento = diasDisponibles.join(', ');
    }

    return {
      if (alturaCm != null) "alturaCm": alturaCm,
      // Si pesoInicialKg y pesoActualKg son lo mismo al inicio, decide cuál enviar o si la API maneja ambos.
      // Asumo que pesoActualKg es el que se actualiza y pesoInicialKg se establece una vez.
      if (pesoInicialKg != null) "pesoInicialKg": pesoInicialKg,
      if (pesoActualKg != null) "pesoActualKg": pesoActualKg,
      if (pesoObjetivoKg != null) "pesoObjetivoKg": pesoObjetivoKg,
      if (objetivoPrincipal != null) "objetivoPrincipal": objetivoPrincipal,
      if (experienciaEntrenamiento != null) "experienciaEntrenamiento": experienciaEntrenamiento,
      if (nivelActividadDiaria != null) "nivelActividadDiaria": nivelActividadDiaria,
      if (condicionesMedicas != null && condicionesMedicas!.isNotEmpty) 
        "condicionesMedicas": condicionesMedicas,      
      if (disponibilidadEntrenamiento.isNotEmpty)
        "disponibilidadEntrenamiento": disponibilidadEntrenamiento,
      if (preferenciaLugarEntrenamiento != null)
        "preferenciaLugarEntrenamiento": preferenciaLugarEntrenamiento,
    };
  }

  // Opcional: Método para crear una copia y actualizarla (patrón inmutable)
  UserProfileData copyWith({
    double? alturaCm,
    double? pesoInicialKg,
    double? pesoActualKg,
    double? pesoObjetivoKg,
    String? objetivoPrincipal,
    String? experienciaEntrenamiento,
    String? nivelActividadDiaria,
    String? condicionesMedicas,
    List<String>? diasDisponibles,
    String? horaInicioDisponible,
    String? horaFinDisponible,
    String? preferenciaLugarEntrenamiento,
  }) {
    return UserProfileData(
      alturaCm: alturaCm ?? this.alturaCm,
      pesoInicialKg: pesoInicialKg ?? this.pesoInicialKg,
      pesoActualKg: pesoActualKg ?? this.pesoActualKg,
      pesoObjetivoKg: pesoObjetivoKg ?? this.pesoObjetivoKg,
      objetivoPrincipal: objetivoPrincipal ?? this.objetivoPrincipal,
      experienciaEntrenamiento: experienciaEntrenamiento ?? this.experienciaEntrenamiento,
      nivelActividadDiaria: nivelActividadDiaria ?? this.nivelActividadDiaria,
      condicionesMedicas: condicionesMedicas ?? this.condicionesMedicas,
      diasDisponibles: diasDisponibles ?? this.diasDisponibles,
      horaInicioDisponible: horaInicioDisponible ?? this.horaInicioDisponible,
      horaFinDisponible: horaFinDisponible ?? this.horaFinDisponible,
      preferenciaLugarEntrenamiento: preferenciaLugarEntrenamiento ?? this.preferenciaLugarEntrenamiento,
    );
  }
}