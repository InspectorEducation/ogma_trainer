import 'package:flutter/material.dart';

class StartExerciseHeader extends StatelessWidget {
  const StartExerciseHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/img/sentadilla.gif', // Puedes reemplazarlo con un `video_player`
          width: double.infinity,
          height: 400,
          fit: BoxFit.cover,
        ),
        const Positioned(
          top: 16,
          left: 16,
          child: CircleAvatar(
            backgroundColor: Colors.white38,
            child: Icon(Icons.arrow_back),
          ),
        ),
        // Otros botones como música, cámara, like/dislike se pueden poner aquí
      ],
    );
  }
}