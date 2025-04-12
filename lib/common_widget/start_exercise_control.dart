import 'package:flutter/material.dart';
import 'package:ogma_trainer/common_widget/gradient_icon_button.dart';
import 'package:ogma_trainer/common_widget/white_icon_button.dart';

class StartExerciseControl extends StatelessWidget {
  final VoidCallback onPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final bool isPaused;

  const StartExerciseControl({
    super.key,
    required this.onPause,
    required this.onNext,
    required this.onPrevious,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GradientIconButton(
          label: isPaused ? 'RENAUDAR' : 'PAUSA',
          icon: isPaused ? Icons.play_arrow : Icons.pause,
          onPressed: onPause,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            WhiteIconButton(
              label: 'ANTERIOR',
              icon: Icons.skip_previous,
              onPressed: onPrevious,
            ),
            WhiteIconButton(
              label: 'OMITIR',
              icon: Icons.skip_next,
              onPressed: onNext,
            ),
          ],
        ),
      ],
    );
  }
}
