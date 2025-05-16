class Machine {
  final int idMaquina;
  final int idEspacio;
  final String nombre;
  final String tipoMaquina;
  final String descripcion;
  final DateTime fechaAdquisicion;
  final String estado; // "Disponible", "En Mantenimiento", "Ocupada"
  final bool reservable;
  final String? codigoQrBase64;
  final String? urlImagen;

  Machine({
    required this.idMaquina,
    required this.idEspacio,
    required this.nombre,
    required this.tipoMaquina,
    required this.descripcion,
    required this.fechaAdquisicion,
    required this.estado,
    required this.reservable,
    this.codigoQrBase64,
    this.urlImagen
  });

  factory Machine.fromJson(Map<String, dynamic> json) {
    return Machine(
      idMaquina: json['idMaquina'] as int,
      idEspacio: json['idEspacio'] as int,
      nombre: json['nombre'] as String,
      tipoMaquina: json['tipoMaquina'] as String,
      descripcion: json['descripcion'] as String,
      fechaAdquisicion: DateTime.parse(json['fechaAdquisicion'] as String),
      estado: json['estado'] as String,
      reservable: json['reservable'] as bool,
      codigoQrBase64: json['codigoQrBase64'] as String?,
      urlImagen: json['urlImagen'] as String?
    );
  }
}