import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';

class RestTimerButtons extends StatelessWidget {
  final VoidCallback onAddTime;
  final VoidCallback onSkip;
  const RestTimerButtons({super.key, required this.onAddTime, required this.onSkip});

  @override
  Widget build(BuildContext context) {
     return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RestButton(
          label: '+20s',
          backgroundColor: Colors.white.withOpacity(0.2),
          textColor: Colors.white,
          onPressed: onAddTime,
        ),
        const SizedBox(width: 16),
        _RestButton(
          label: 'Omitir',
          backgroundColor: Colors.white,
          textColor: TColor.primaryColor1,
          onPressed: onSkip,
        ),
      ],
    );
  }
}

class _RestButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  const _RestButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}