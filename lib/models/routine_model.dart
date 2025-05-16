class RoutineExerciseDetail {
  final int idRutinaDiaEjercicio;
  final int diaNumero;
  final int idEjercicio;
  final String ejercicioNombre;
  final int ordenEnDia;
  final String series;
  final String repeticiones;
  final int descansoSegundos;
  final String? notasEjercicio;

  RoutineExerciseDetail({
    required this.idRutinaDiaEjercicio,
    required this.diaNumero,
    required this.idEjercicio,
    required this.ejercicioNombre,
    required this.ordenEnDia,
    required this.series,
    required this.repeticiones,
    required this.descansoSegundos,
    this.notasEjercicio,
  });

  factory RoutineExerciseDetail.fromJson(Map<String, dynamic> json) {
    return RoutineExerciseDetail(
      idRutinaDiaEjercicio: json['idRutinaDiaEjercicio'] as int,
      diaNumero: json['diaNumero'] as int,
      idEjercicio: json['idEjercicio'] as int,
      ejercicioNombre: json['ejercicioNombre'] as String,
      ordenEnDia: json['ordenEnDia'] as int,
      series: json['series'] as String,
      repeticiones: json['repeticiones'] as String,
      descansoSegundos: json['descansoSegundos'] as int,
      notasEjercicio: json['notasEjercicio'] as String?,
    );
  }
}

class Routine {
  final int idRutina;
  final int idEntrenadorCreador;
  final String nombreRutina;
  final String descripcion;
  final String nivel;
  final String objetivo;
  final DateTime fechaCreacion;
  final int numeroDias;
  final List<RoutineExerciseDetail> diasEjercicios;
  final String? urlImagen; // NUEVO: Añadir si la API lo provee o si tienes un placeholder

  Routine({
    required this.idRutina,
    required this.idEntrenadorCreador,
    required this.nombreRutina,
    required this.descripcion,
    required this.nivel,
    required this.objetivo,
    required this.fechaCreacion,
    required this.numeroDias,
    required this.diasEjercicios,
    this.urlImagen, // NUEVO
  });

  factory Routine.fromJson(Map<String, dynamic> json) {
    var ejerciciosList = json['diasEjercicios'] as List;
    List<RoutineExerciseDetail> ejercicios = ejerciciosList
        .map((i) => RoutineExerciseDetail.fromJson(i as Map<String, dynamic>))
        .toList();

    return Routine(
      idRutina: json['idRutina'] as int,
      idEntrenadorCreador: json['idEntrenadorCreador'] as int,
      nombreRutina: json['nombreRutina'] as String,
      descripcion: json['descripcion'] as String,
      nivel: json['nivel'] as String,
      objetivo: json['objetivo'] as String,
      fechaCreacion: DateTime.parse(json['fechaCreacion'] as String),
      numeroDias: json['numeroDias'] as int,
      diasEjercicios: ejercicios,
      urlImagen: json['urlImagen'] as String?, // NUEVO: Parsea la imagen si existe
    );
  }

  // Helper para obtener el número total de ejercicios (sumando todos los días)
  int get totalEjercicios {
    return diasEjercicios.length;
  }

  // Helper para estimar un tiempo total (muy simplificado)
  // Podrías calcular esto de forma más precisa si tienes datos de duración por ejercicio
  String get tiempoEstimado {
    // Estimación: (num ejercicios * (series promedio * tiempo por serie + descanso promedio))
    // Esto es muy básico.
    if (diasEjercicios.isEmpty) return "0 min";
    int totalSets = 0;
    int totalDescanso = 0;
    diasEjercicios.forEach((ej) {
        try {
            totalSets += int.parse(ej.series); // Asume que 'series' es un número
            totalDescanso += int.parse(ej.series) * ej.descansoSegundos;
        } catch (e) {
            // Manejar si 'series' no es un número parseable
        }
    });
    // Asumir 1 min por set (ejercicio + breve descanso)
    double tiempoMinutos = (totalSets * 60 + totalDescanso) / 60.0;
    return "${tiempoMinutos.round()} minutos";
  }
}