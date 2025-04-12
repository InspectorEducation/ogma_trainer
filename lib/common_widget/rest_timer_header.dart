import 'dart:async';

import 'package:flutter/material.dart';

class RestTimerHeader extends StatefulWidget {
  final int remainingSeconds;
  final VoidCallback onFinish;

  const RestTimerHeader({super.key, required this.remainingSeconds, required this.onFinish});

  @override
  State<RestTimerHeader> createState() => _RestTimerHeaderState();
}

class _RestTimerHeaderState extends State<RestTimerHeader> {  
  Timer? _timer;
  late int _currentSeconds;

  @override
  void initState() {
    super.initState();
    _currentSeconds = widget.remainingSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_currentSeconds > 0) {
        setState(() {
          _currentSeconds--;
        });
      } else {
        _timer?.cancel();
        widget.onFinish();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'DESCANSO',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _formatTime(_currentSeconds),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
