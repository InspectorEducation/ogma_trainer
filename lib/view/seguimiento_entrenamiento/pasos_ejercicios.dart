import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/step_detail_row.dart';
import 'package:ogma_trainer/models/exercise_detail_model.dart';
import 'package:ogma_trainer/services/exercise_service.dart';
import 'package:readmore/readmore.dart';

class PasosEjercicios extends StatefulWidget {
  final int exerciseId;
  final String initialExerciseName;

  const PasosEjercicios(
      {super.key, required this.exerciseId, required this.initialExerciseName});

  @override
  State<PasosEjercicios> createState() => _PasosEjerciciosViewState();
}

class _PasosEjerciciosViewState extends State<PasosEjercicios> {
  final ExerciseService _exerciseService = ExerciseService();
  ExerciseDetail? _exerciseDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExerciseDetails();
  }

  Future<void> _loadExerciseDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final details =
          await _exerciseService.getExerciseDetails(widget.exerciseId);
      _exerciseDetail = details;
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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
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
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/closed_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          _exerciseDetail?.nombre ?? widget.initialExerciseName,
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
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
      backgroundColor: TColor.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text("Error: $_errorMessage",
                          style: const TextStyle(color: Colors.red))))
              : _exerciseDetail == null
                  ? const Center(
                      child: Text("No se encontraron detalles del ejercicio."))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // --- SECCIÓN DE GIF ---
                            Container(
                              width: media.width,
                              height: media.width *
                                  0.56, // Proporción 16:9 o la que prefieras para el GIF
                              decoration: BoxDecoration(
                                  color: TColor.lightGray,
                                  borderRadius: BorderRadius.circular(20)),
                              child: ClipRRect(
                                // Para redondear el GIF si el Container tiene bordes
                                borderRadius: BorderRadius.circular(20),
                                child: _exerciseDetail!.urlVideoDemostracion !=
                                            null &&
                                        _exerciseDetail!
                                            .urlVideoDemostracion!.isNotEmpty
                                    ? Image.network(
                                        _exerciseDetail!.urlVideoDemostracion!,
                                        fit: BoxFit
                                            .contain, // O BoxFit.cover, según prefieras
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Fallback si el GIF falla
                                          return Center(
                                              child: Icon(
                                                  Icons.image_not_supported,
                                                  size: 50,
                                                  color: TColor.gray
                                                      .withOpacity(0.5)));
                                        },
                                      )
                                    : Center(
                                        child: Icon(Icons.gif_box_outlined,
                                            size: 50,
                                            color: TColor.gray.withOpacity(
                                                0.5))), // No hay URL de GIF
                              ),
                            ),
                            const SizedBox(height: 20),

                            // --- NOMBRE Y MÚSCULO OBJETIVO ---
                            Text(
                              _exerciseDetail!.nombre,
                              style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Músculo Objetivo: ${_exerciseDetail!.musculoObjetivo}",
                              style:
                                  TextStyle(color: TColor.gray, fontSize: 14),
                            ),
                            const SizedBox(height: 20),

                            // --- DESCRIPCIÓN ---
                            Text(
                              "Descripción",
                              style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 8),
                            ReadMoreText(
                              _exerciseDetail!.descripcion,
                            ),
                            const SizedBox(height: 25),

                            // --- MÁQUINAS ASOCIADAS ---
                            if (_exerciseDetail!
                                .maquinasAsociadas.isNotEmpty) ...[
                              Text(
                                "Equipamiento Necesario",
                                style: TextStyle(
                                    color: TColor.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 150, // Ajusta la altura según necesites
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      _exerciseDetail!.maquinasAsociadas.length,
                                  itemBuilder: (context, index) {
                                    AssociatedMachine maquina = _exerciseDetail!
                                        .maquinasAsociadas[index];
                                    return Container(
                                      width: media.width * 0.35,
                                      margin: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: TColor.lightGray,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              alignment: Alignment.center,
                                              child: maquina.urlImagen !=
                                                          null &&
                                                      maquina
                                                          .urlImagen!.isNotEmpty
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      child: Image.network(
                                                        maquina.urlImagen!,
                                                        fit: BoxFit.cover,
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        errorBuilder:
                                                            (c, e, s) => Icon(
                                                                Icons
                                                                    .broken_image,
                                                                color: TColor
                                                                    .gray
                                                                    .withOpacity(
                                                                        0.5)),
                                                      ),
                                                    )
                                                  : Icon(Icons.fitness_center,
                                                      size: 40,
                                                      color: TColor.gray
                                                          .withOpacity(0.5)),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            maquina.nombre,
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: TColor.black),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 25),
                            ],
                          ],
                        ),
                      ),
                    ),
    );
  }
}
