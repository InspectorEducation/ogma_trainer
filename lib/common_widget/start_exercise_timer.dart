import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

class StartExerciseTimer extends StatefulWidget {
  final Duration duration;
  final bool isPaused;
  final VoidCallback onFinish;
  const StartExerciseTimer(
      {super.key,
      required this.duration,
      required this.isPaused,
      required this.onFinish});

  @override
  State<StartExerciseTimer> createState() => _StartExerciseTimerState();
}

class _StartExerciseTimerState extends State<StartExerciseTimer> {
  Timer? _timer;
  late int _remainingSeconds;
  late int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.duration.inSeconds;
    _remainingSeconds =
        _totalSeconds > 0 ? _totalSeconds : 1; // Evita división por cero
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || widget.isPaused) return;
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        widget.onFinish();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _restartTimer() {
    _timer?.cancel();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  double get progress {
    if (_totalSeconds <= 0) return 1.0;
    final p = 1 - (_remainingSeconds / _totalSeconds);
    return p.clamp(0.0, 1.0); // Asegura que esté entre 0 y 1
  }

  @override
  void didUpdateWidget(covariant StartExerciseTimer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _totalSeconds = widget.duration.inSeconds;
      _remainingSeconds = _totalSeconds > 0 ? _totalSeconds : 1;
      _restartTimer();
    } else if (oldWidget.isPaused != widget.isPaused) {
      if (widget.isPaused) {
        _pauseTimer();
      } else {
        _startTimer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    return Column(
      children: [
        Text(
          _formatTime(_remainingSeconds),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SimpleAnimationProgressBar(
          height: 18,
          width: media.width * 0.8,
          backgroundColor: Colors.grey.shade100,
          foregrondColor: Colors.purple,
          ratio: progress,
          direction: Axis.horizontal,
          curve: Curves.fastLinearToSlowEaseIn,
          duration: const Duration(seconds: 3),
          borderRadius: BorderRadius.circular(7.5),
          gradientColor: LinearGradient(
            colors: TColor.primaryG,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }
}
