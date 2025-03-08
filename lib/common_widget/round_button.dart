import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';

enum RoundButtonType { bgGradient, textGradient }

class RoundButton extends StatelessWidget {
  final String title;
  final RoundButtonType type;
  final VoidCallback onPressed;
  const RoundButton(
      {super.key,
      required this.title,
      this.type = RoundButtonType.bgGradient,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      height: 50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      textColor: TColor.primaryColor1,
      minWidth: double.maxFinite,
      color: TColor.white,
      child: ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (bounds) {
          return LinearGradient(
                  colors: TColor.primaryG,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight)
              .createShader(Rect.fromLTRB(0, 0, bounds.width, bounds.height));
        },
        child: Text(
          title,
          style: TextStyle(
              color: TColor.primaryColor1,
              fontSize: 19,
              fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
