import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/what_train_row.dart';
import 'package:ogma_trainer/common_widget/workout_row.dart';
import 'package:ogma_trainer/models/routine_model.dart';
import 'package:ogma_trainer/services/routine_service.dart';
import 'package:ogma_trainer/view/seguimiento_entrenamiento/calendario_entrenamiento_view.dart';
import 'package:ogma_trainer/view/seguimiento_entrenamiento/detalle_entranamiento_view.dart';

class SeguimientoEntrenamientoView extends StatefulWidget {
  const SeguimientoEntrenamientoView({super.key});

  @override
  State<SeguimientoEntrenamientoView> createState() => _SeguimientoEntrenamientoViewState();
}

class _SeguimientoEntrenamientoViewState extends State<SeguimientoEntrenamientoView> {
    final RoutineService _routineService = RoutineService();

    bool _isLoadingRoutines = true;
    String? _errorLoadingRoutines;
    Map<String, List<Routine>> _groupedRoutinesByObjetivo = {};

    List lastWorkoutArr = [
    {
      "name": "Rutina Levanta Cola",
      "image": "assets/img/Workout1.png",
      "kcal": "180",
      "time": "20",
      "progress": 0.3
    },     
  ];

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    setState(() {
      _isLoadingRoutines = true;
      _errorLoadingRoutines = null;
      _groupedRoutinesByObjetivo = {};
    });
    try {
      final allRoutines = await _routineService.getAllRoutines();
      _groupRoutines(allRoutines);
    } catch (e) {
      _errorLoadingRoutines = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoutines = false;
        });
      }
    }
  }

  void _groupRoutines(List<Routine> routines) {
    Map<String, List<Routine>> tempGrouped = {};
    for (var routine in routines) {      
      tempGrouped.putIfAbsent(routine.objetivo, () => []).add(routine);      
    }

    tempGrouped.forEach((key, value) {
      value.sort((a, b) => a.nombreRutina.compareTo(b.nombreRutina));
    });

    //Ordenar los grupos de objetivos alfabéticamente
    var sortedKeys = tempGrouped.keys.toList()..sort();
    Map<String, List<Routine>> sortedGroupedRoutines = {};
    for (var key in sortedKeys) {
      sortedGroupedRoutines[key] = tempGrouped[key]!;
    }
    _groupedRoutinesByObjetivo = sortedGroupedRoutines;
    
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
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
              // pinned: true,
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
                      color: TColor.lightGray,
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
                "Rutinas Disponibles",
                style: TextStyle(
                    color: TColor.white,
                    fontSize: 16,
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
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/img/seguimiento_man.png",
                  width: media.width * 0.75,
                  height: media.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                      color: TColor.primaryColor2.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Cronograma Entrenamiento",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          width: 70,
                          height: 25,
                          child: RoundButton(
                            title: "Ir",
                            type: RoundButtonType.bgGradient,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            onPressed: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) =>
                                       const CalendarioEntrenamientoView(),
                                 ),
                               );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Rutinas asignadas",
                      style: TextStyle(
                          color: TColor.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Ver Más",
                        style: TextStyle(
                            color: TColor.gray,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      ),
                    )
                  ],
                ),
                ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: lastWorkoutArr.length,
                    itemBuilder: (context, index) {
                      var wObj = lastWorkoutArr[index] as Map? ?? {};
                      return InkWell(
                          onTap: () {
                            //Navigator.push(
                            //  context,
                             // MaterialPageRoute(
                              //  builder: (context) =>
                              //      const FinishedWorkoutView(),
                              //),
                            //);
                          },
                          child: WorkoutRow(wObj: wObj));
                    }),
                  SizedBox(
                    height: media.width * 0.05,
                  ),
                  // --- SECCIÓN "ESCOGE OTRA RUTINA" CON RUTINAS AGRUPADAS Y DESLIZABLES ---
                  if (!_isLoadingRoutines && _groupedRoutinesByObjetivo.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0), // Espacio antes del primer grupo
                      child: Text(
                        "Explora Rutinas por Objetivo", // Título general para la sección de rutinas
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 16, // Un poco más grande
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                   _isLoadingRoutines
                      ? const Padding(padding: EdgeInsets.symmetric(vertical: 50.0), child: Center(child: CircularProgressIndicator()))
                      : _errorLoadingRoutines != null
                          ? Padding(padding: const EdgeInsets.symmetric(vertical: 30.0), child: Center(child: Text("Error al cargar rutinas: $_errorLoadingRoutines", style: const TextStyle(color: Colors.red))))
                          : _groupedRoutinesByObjetivo.isEmpty
                              ? const Padding(padding: EdgeInsets.symmetric(vertical: 30.0), child: Center(child: Text("No hay rutinas disponibles.")))
                              : Column( // Usar Column para apilar los grupos de objetivos
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: _groupedRoutinesByObjetivo.entries.map((entry) {
                                    String objetivo = entry.key;
                                    List<Routine> routinesInObjetivo = entry.value;

                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
                                          child: Text(
                                            objetivo, // Nombre del grupo (ej. "Perder peso", "Hipertrofia")
                                            style: TextStyle(
                                                color: TColor.black,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 150, // Altura fija para la fila horizontal de WhatTrainRow
                                                       // Ajusta esta altura según el alto de tu WhatTrainRow
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal, // DESLIZABLE HORIZONTALMENTE
                                            itemCount: routinesInObjetivo.length,
                                            itemBuilder: (context, index) {
                                              Routine routine = routinesInObjetivo[index];
                                              return Padding( // Añadir padding alrededor de cada WhatTrainRow
                                                padding: const EdgeInsets.only(right: 12.0, top: 4, bottom: 4),
                                                child: SizedBox( // Darle un ancho a cada WhatTrainRow
                                                  width: media.width * 0.8, // Ej: 80% del ancho de pantalla
                                                  child: WhatTrainRow(
                                                    routine: routine,
                                                    onViewMorePressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => DetalleEntranamientoView(routine: routine),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                  SizedBox(
                    height: media.width * 0.1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}