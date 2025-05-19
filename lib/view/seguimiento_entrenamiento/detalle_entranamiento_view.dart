import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/exercises_set_section.dart';
import 'package:ogma_trainer/common_widget/icon_title_next_row.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/models/machine_model.dart';
import 'package:ogma_trainer/models/routine_model.dart';
import 'package:ogma_trainer/services/routine_service.dart';
import 'package:ogma_trainer/view/paso_a_paso/estoy_listo_qr_view.dart';
import 'package:ogma_trainer/view/seguimiento_entrenamiento/pasos_ejercicios.dart';
import 'package:ogma_trainer/view/seguimiento_entrenamiento/programar_rutina_view.dart';

class DetalleEntranamientoView extends StatefulWidget {
  final Routine routine;
  const DetalleEntranamientoView({super.key, required this.routine});

  @override
  State<DetalleEntranamientoView> createState() =>
      _DetalleEntranamientoViewState();
}

class _DetalleEntranamientoViewState extends State<DetalleEntranamientoView> {
  final RoutineService _routineService = RoutineService();

  Routine? _detailedRoutine; // Para almacenar la rutina con todos los detalles
  bool _isLoading = true;
  String? _errorMessage;

  // Lista para agrupar ejercicios por día
  Map<int, List<RoutineExerciseDetail>> _exercisesByDay = {};

  List<Machine> _requiredMachines = [];

  @override
  void initState() {
    super.initState();
    _detailedRoutine = widget.routine;
    _loadRoutineDetails();
  }

  Future<void> _loadRoutineDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _requiredMachines = [];
    });
    try {
      final routineDetails =
          await _routineService.getRoutineDetails(widget.routine.idRutina);
      _detailedRoutine = routineDetails;
      _groupExercisesByDay();

      if (_detailedRoutine != null) {
        _requiredMachines = await _routineService
            .getRequiredMachinesForRoutine(_detailedRoutine!.idRutina);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _groupExercisesByDay() {
    if (_detailedRoutine == null) return;
    _exercisesByDay = {};
    for (var exerciseDetail in _detailedRoutine!.diasEjercicios) {
      _exercisesByDay
          .putIfAbsent(exerciseDetail.diaNumero, () => [])
          .add(exerciseDetail);
    }
    _exercisesByDay.forEach((dia, ejercicios) {
      ejercicios.sort((a, b) => a.ordenEnDia.compareTo(b.ordenEnDia));
    });
  }

  Widget _buildExerciseItem(RoutineExerciseDetail exercise) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      elevation: 1.0,
      child: ListTile(
        //leading: Image.asset("assets/img/img_1.png",width: 40, height: 40), // Necesitarías imágenes para ejercicios
        leading: CircleAvatar(
            backgroundColor: TColor.lightGray,
            child: Text(exercise.ordenEnDia.toString())),
        title: Text(exercise.ejercicioNombre,
            style: TextStyle(fontWeight: FontWeight.w500, color: TColor.black)),
        subtitle: Text(
          "Series: ${exercise.series}, Reps: ${exercise.repeticiones}, Descanso: ${exercise.descansoSegundos}s",
          style: TextStyle(fontSize: 12, color: TColor.gray),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PasosEjercicios(
                exerciseId: exercise.idEjercicio,
                initialExerciseName: exercise
                    .ejercicioNombre,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRequiredMachineItem(Machine machine, Size media) {
    return Container(
      width: media.width * 0.38,
      margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
      decoration: BoxDecoration(
          color: TColor.lightGray.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 3,
                offset: const Offset(0, 1))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 2,
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
              child: machine.urlImagen != null && machine.urlImagen!.isNotEmpty
                  ? Image.network(
                      machine.urlImagen!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                            child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                )));
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: TColor.gray.withOpacity(0.1),
                          alignment: Alignment.center,
                          child: Icon(Icons.fitness_center,
                              size: 30, color: TColor.gray.withOpacity(0.4)),
                        );
                      },
                    )
                  : Container(
                      color: TColor.gray.withOpacity(0.1),
                      alignment: Alignment.center,
                      child: Icon(Icons.fitness_center,
                          size: 30, color: TColor.gray.withOpacity(0.4)),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              machine.nombre,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TColor.black,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final currentRoutine = _detailedRoutine ?? widget.routine;

    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(8),
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: TColor.lightGray.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10)),
                  child: Image.asset(
                    "assets/img/black_btn.png",
                    width: 15,
                    height: 15,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              title: Text(
                _detailedRoutine?.nombreRutina ?? "Detalle de Rutina",
                style: TextStyle(
                    color: TColor.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700),
              ),
              actions: [
                InkWell(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: TColor.lightGray,
                        borderRadius: BorderRadius.circular(10)),
                    child: Image.asset(
                      "assets/img/more_btn.png",
                      width: 15,
                      height: 15,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _MySliverAppBarDelegate(
                minHeight: 0.0,
                maxHeight: media.width * 0.65,
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30.0)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      currentRoutine.urlImagen != null &&
                              currentRoutine.urlImagen!.isNotEmpty
                          ? Image.network(
                              currentRoutine.urlImagen!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildFallbackImage(media),
                            )
                          : _buildFallbackImage(media),
                      //Un gradiente sutil sobre la imagen para mejorar el contraste con el AppBar
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: TColor.white,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: _isLoading && _detailedRoutine == widget.routine
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Text("Error: $_errorMessage",
                            style: const TextStyle(color: Colors.red)))
                    : Stack(
                        children: [
                          SingleChildScrollView(
                            padding:
                                EdgeInsets.only(bottom: media.height * 0.12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: 50,
                                  height: 4,
                                  decoration: BoxDecoration(
                                      color: TColor.gray.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(3)),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              currentRoutine.nombreRutina,
                                              style: TextStyle(
                                                  color: TColor.black,
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w700),
                                            ),
                                            Text(
                                              "${currentRoutine.nivel} | ${currentRoutine.objetivo} | ${currentRoutine.numeroDias} Día(s)",
                                              style: TextStyle(
                                                  color: TColor.gray,
                                                  fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: Image.asset(
                                          "assets/img/fav.png",
                                          width: 15,
                                          height: 15,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                if (currentRoutine.descripcion.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Text(currentRoutine.descripcion,
                                        style: TextStyle(
                                            color: TColor.black, fontSize: 14)),
                                  ),
                                SizedBox(height: media.width * 0.05),
                                if (_exercisesByDay.isNotEmpty)
                                  ..._exercisesByDay.entries.map((dayEntry) {
                                    int diaNumero = dayEntry.key;
                                    List<RoutineExerciseDetail>
                                        ejerciciosDelDia = dayEntry.value;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 5.0),
                                          child: Text(
                                            "Día $diaNumero",
                                            style: TextStyle(
                                                color: TColor.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        ListView.builder(
                                          padding: EdgeInsets.zero,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: ejerciciosDelDia.length,
                                          itemBuilder: (context, index) {
                                            return _buildExerciseItem(
                                                ejerciciosDelDia[index]);
                                          },
                                        ),
                                        const SizedBox(height: 15),
                                      ],
                                    );
                                  }).toList()
                                else if (!_isLoading)
                                  const Center(
                                      child: Text(
                                          "No hay ejercicios detallados para esta rutina.")),
                                SizedBox(
                                  height: media.width * 0.05,
                                ),
                                if (_requiredMachines.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Tú necesitas",
                                          style: TextStyle(
                                              color: TColor.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        TextButton(
                                          onPressed: () {},
                                          child: Text(
                                            "${_requiredMachines.length} equipos",
                                            style: TextStyle(
                                                color: TColor.gray,
                                                fontSize: 12),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                if (_requiredMachines.isNotEmpty)
                                  SizedBox(
                                    height: media.width *
                                        0.45, // Altura para la lista horizontal de máquinas
                                    child: ListView.builder(
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            top: 5,
                                            bottom:
                                                5), // Añadir padding izquierdo para la primera tarjeta
                                        scrollDirection: Axis.horizontal,
                                        itemCount: _requiredMachines.length,
                                        itemBuilder: (context, index) {
                                          return _buildRequiredMachineItem(
                                              _requiredMachines[index], media);
                                        }),
                                  ),
                                if (_requiredMachines.isEmpty && !_isLoading)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 5.0),
                                    child: Text(
                                      "No se especificó equipamiento para esta rutina.",
                                      style: TextStyle(
                                          color: TColor.gray, fontSize: 13),
                                    ),
                                  ),
                                SizedBox(
                                  height: media.width * 0.05,
                                )
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              color: TColor
                                  .white, // Fondo para que no se transparente
                              child: RoundButton(
                                title: "Programar Rutina en Calendario",
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProgramarRutinaView(
                                                routine: widget.routine)),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}

Widget _buildFallbackImage(Size media) {
  return Image.asset(
    "assets/img/detail_top.png",
    width: media.width,
    fit: BoxFit.cover,
  );
}

class _MySliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _MySliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_MySliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
