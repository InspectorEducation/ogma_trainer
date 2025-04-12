import 'package:flutter/material.dart';

class StartExerciseInfo extends StatelessWidget {
  final String name;
  const StartExerciseInfo({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
   return Column(
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}