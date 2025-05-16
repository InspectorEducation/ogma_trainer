class ClaseInfo {
  final int idClase;
  final int idEspacio;
  final int idEntrenador;
  final String nombreClase;
  final String descripcion;
  final String tipo;
  final String? urlClase;
  final String? urlImagen;
  final DateTime fechaHoraInicio;
  final int duracionMinutos;
  final int capacidadMaxima;
  final bool activa;

  ClaseInfo({
    required this.idClase,
    required this.idEspacio,
    required this.idEntrenador,
    required this.nombreClase,
    required this.descripcion,
    required this.tipo,
    this.urlClase,
    this.urlImagen,
    required this.fechaHoraInicio,
    required this.duracionMinutos,
    required this.capacidadMaxima,
    required this.activa,
  });

  factory ClaseInfo.fromJson(Map<String, dynamic> json) {
    return ClaseInfo(
      idClase: json['idClase'] as int,
      idEspacio: json['idGimnasio'] as int,
      idEntrenador: json['idEntrenador'] as int,      
      nombreClase: json['nombreClase'] as String,
      descripcion: json['descripcion'] as String,
      tipo: json['tipo'] as String,
      urlClase: json['urlClase'] as String?,
      urlImagen: json['urlImagen'] as String?, 
      fechaHoraInicio: DateTime.parse(json['fechaHoraInicio'] as String),
      duracionMinutos: json['duracionMinutos'] as int,
      capacidadMaxima: json['capacidadMaxima'] as int,
      activa: json['activa'] as bool,
    );
  }
}