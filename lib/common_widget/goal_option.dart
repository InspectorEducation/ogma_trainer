import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';

class GoalOption extends StatelessWidget {
  final String title;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const GoalOption({
    Key? key,
    required this.title,
    required this.description,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
                            colors: TColor.primaryG,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(8),
          border: isSelected
            ? Border.all(color: TColor.primaryColor2, width: 2)
            : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700               
              ),
            ),
            const SizedBox(height: 5),
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: TColor.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}