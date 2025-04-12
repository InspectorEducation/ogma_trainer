import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/next_exercise_card.dart';
import 'package:ogma_trainer/common_widget/rest_timer_buttons.dart';
import 'package:ogma_trainer/common_widget/rest_timer_header.dart';

class DescansoEntrenamientoView extends StatefulWidget {
  const DescansoEntrenamientoView({super.key});

  @override
  State<DescansoEntrenamientoView> createState() =>
      _DescansoEntrenamientoViewState();
}

class _DescansoEntrenamientoViewState extends State<DescansoEntrenamientoView> {
  int remainingSeconds = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        if (remainingSeconds > 0) {
          remainingSeconds--;
          // print('Segundos restantes: $remainingSeconds');
        } else {
          timer.cancel();
          _onRestFinished();
        }
      });
    });
  }

  void _addTime() {
    setState(() {
      remainingSeconds += 20;
    });
  }

  void _skipRest() {
    setState(() {
      remainingSeconds = 0;
    });
    // También podrías navegar automáticamente o hacer otra acción
  }

  void _onRestFinished() {
    // Acción cuando finaliza el descanso
    debugPrint("Descanso finalizado");
    // Puedes hacer una navegación aquí si lo necesitas:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => SiguienteEjercicio()));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: TColor.primaryG,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 60),
              RestTimerHeader(remainingSeconds: remainingSeconds),
              const SizedBox(height: 24),
              RestTimerButtons(
                onAddTime: _addTime,
                onSkip: _skipRest,
              ),
              const Spacer(),
              const NextExerciseCard(
                step: 3,
                totalSteps: 7,
                name: 'Toy soldiers',
                duration: '00:30',
                imageAsset: 'assets/img/sentadilla.gif',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
