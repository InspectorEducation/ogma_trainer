import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/next_exercise_card.dart';
import 'package:ogma_trainer/common_widget/rest_timer_buttons.dart';
import 'package:ogma_trainer/common_widget/rest_timer_header.dart';
import 'package:ogma_trainer/common_widget/start_exercise_control.dart';
import 'package:ogma_trainer/common_widget/start_exercise_header.dart';
import 'package:ogma_trainer/common_widget/start_exercise_info.dart';
import 'package:ogma_trainer/common_widget/start_exercise_timer.dart';
import 'package:ogma_trainer/models/entrenamiento.dart';

class EntrenamientoFlowView extends StatefulWidget {
  const EntrenamientoFlowView({super.key});

  @override
  State<EntrenamientoFlowView> createState() => _EntrenamientoFlowViewState();
}

class _EntrenamientoFlowViewState extends State<EntrenamientoFlowView> {
  final List<Entrenamiento> entrenamientos = (jsonDecode(jsonString) as List)
      .map((e) => Entrenamiento.fromJson(e))
      .toList();

  int currentIndex = 0;
  bool isResting = false;
  late Duration remaining;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    remaining = entrenamientos[currentIndex].duration;
  }

  void _nextStep() {
    setState(() {
      _isPaused = false;
      if (isResting) {
        // Siguiente ejercicio
        if (currentIndex + 1 < entrenamientos.length) {
          currentIndex++;
          remaining = entrenamientos[currentIndex].duration;
          isResting = false;
        } else {
          debugPrint("Entrenamiento completado");
        }
      } else {
        // Pasar a descanso
        remaining = entrenamientos[currentIndex].rest;
        isResting = true;
      }
    });
  }

  void _addTime() {
    setState(() {
      remaining += const Duration(seconds: 20);
    });
  }

  void _pausarTemporizador() {
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _irAlEjercicioAnterior() {
    setState(() {
      _isPaused = false;
      if (currentIndex > 0) {
        currentIndex--;
        remaining = entrenamientos[currentIndex].duration;
        isResting = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ejercicio = entrenamientos[currentIndex];

    return Scaffold(
      backgroundColor: isResting ? null : Colors.white,
      body: SafeArea(
        child: isResting
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    RestTimerHeader(remainingSeconds: remaining.inSeconds, 
                    onFinish: _nextStep
                    ),
                    const SizedBox(height: 24),
                    RestTimerButtons(
                      onAddTime: _addTime,
                      onSkip: _nextStep,
                    ),
                    const Spacer(),
                    NextExerciseCard(
                      step: ejercicio.step,
                      totalSteps: ejercicio.totalSteps,
                      name: ejercicio.name,
                      duration: _formatDuration(ejercicio.duration),
                      imageAsset: ejercicio.imageAsset,
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  const StartExerciseHeader(),
                  const Spacer(),
                  StartExerciseInfo(name: ejercicio.name),
                  StartExerciseTimer(
                    duration: remaining,
                    isPaused: _isPaused,
                    onFinish: _nextStep,
                  ),
                  StartExerciseControl(
                    onPause: _pausarTemporizador,
                    onNext: _nextStep,
                    onPrevious: _irAlEjercicioAnterior, 
                    isPaused: _isPaused,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final m = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }
}

const String jsonString = '''
[
   {
      "step":1,
      "totalSteps":3,
      "name":"Sentadillas con peso",
      "duration":"02:30",
      "rest":"00:30",
      "imageAsset":"assets/img/sentadilla.gif"
   },
   {
      "step":2,
      "totalSteps":3,
      "name":"Flexion de pecho",
      "duration":"01:30",
      "rest":"00:30",
      "imageAsset":"assets/img/sentadilla.gif"
   },
   {
      "step":3,
      "totalSteps":3,
      "name":"Martillos",
      "duration":"01:30",
      "rest":"00:30",
      "imageAsset":"assets/img/sentadilla.gif"
   }
]
''';
