class AssociatedMachine {
  final int idMaquina;
  final String nombre;
  final String? urlImagen;

  AssociatedMachine({
    required this.idMaquina,
    required this.nombre,
    this.urlImagen,
  });

  factory AssociatedMachine.fromJson(Map<String, dynamic> json) {
    return AssociatedMachine(
      idMaquina: json['idMaquina'] as int,
      nombre: json['nombre'] as String,
      urlImagen: json['urlImagen'] as String?,
    );
  }
}

class ExerciseDetail {
  final int idEjercicio;
  final String nombre;
  final String descripcion;
  final String musculoObjetivo;
  final String? urlVideoDemostracion;
  final int idCreador;
  final List<AssociatedMachine> maquinasAsociadas;

  ExerciseDetail({
    required this.idEjercicio,
    required this.nombre,
    required this.descripcion,
    required this.musculoObjetivo,
    this.urlVideoDemostracion,
    required this.idCreador,
    required this.maquinasAsociadas,
  });

  factory ExerciseDetail.fromJson(Map<String, dynamic> json) {
    var list = json['maquinasAsociadas'] as List? ?? [];
    List<AssociatedMachine> maquinas =
        list.map((i) => AssociatedMachine.fromJson(i as Map<String, dynamic>)).toList();
    return ExerciseDetail(
      idEjercicio: json['idEjercicio'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      musculoObjetivo: json['musculoObjetivo'] as String,
      urlVideoDemostracion: json['urlVideoDemostracion'] as String?,
      idCreador: json['idCreador'] as int,
      maquinasAsociadas: maquinas,
    );
  }
}