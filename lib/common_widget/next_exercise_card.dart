import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';

class NextExerciseCard extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String name;
  final String duration;
  final String imageAsset;
  const NextExerciseCard(
      {super.key,
      required this.step,
      required this.totalSteps,
      required this.name,
      required this.duration,
      required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRÓXIMO $step/$totalSteps',
            style: TextStyle(
              color: TColor.primaryColor2,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                duration,
                style: TextStyle(
                  color: TColor.primaryColor2,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 250, // Ajusta este valor según el tamaño que quieras
              width: double.infinity,
              child: Image.asset(
                imageAsset,
                fit: BoxFit
                    .contain, // También puedes usar BoxFit.cover si lo prefieres
              ),
            ),
          ),
        ],
      ),
    );
  }
}
