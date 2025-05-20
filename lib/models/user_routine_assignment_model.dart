import 'package:ogma_trainer/models/routine_model.dart';

class UserRoutineAssignment {
  final int idUsuarioRutina;
  final int idUsuario;
  final int idEntrenadorAsignador;
  final DateTime fechaAsignacion;
  final bool activa;
  final Routine rutinaDetalles;

  UserRoutineAssignment({
    required this.idUsuarioRutina,
    required this.idUsuario,
    required this.idEntrenadorAsignador,
    required this.fechaAsignacion,
    required this.activa,
    required this.rutinaDetalles,
  });

  factory UserRoutineAssignment.fromJson(Map<String, dynamic> json) {
    return UserRoutineAssignment(
      idUsuarioRutina: json['idUsuarioRutina'] as int,
      idUsuario: json['idUsuario'] as int,
      idEntrenadorAsignador: json['idEntrenadorAsignador'] as int,
      fechaAsignacion: DateTime.parse(json['fechaAsignacion'] as String),
      activa: json['activa'] as bool,
      rutinaDetalles: Routine.fromJson(json['rutinaDetalles'] as Map<String, dynamic>),
    );
  }
}