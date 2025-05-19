import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart'; // Asegúrate que esta ruta sea correcta

enum RoundButtonType { bgGradient, bgSGradient, textGradient }

class RoundButton extends StatelessWidget {
  final String title;
  final RoundButtonType type;
  final VoidCallback? onPressed;
  final double fontSize;
  final double elevation;
  final FontWeight fontWeight;
  final String? icon; // Ruta del asset para el icono (opcional)
  final Color? iconColor; // Color del icono (opcional, por defecto blanco o según el tipo)
  final double iconSize; // Tamaño del icono (opcional)
  final EdgeInsetsGeometry? padding;

  const RoundButton({
    super.key,
    required this.title,
    this.type = RoundButtonType.bgGradient,
    this.onPressed,
    this.fontSize = 16,
    this.elevation = 1,
    this.fontWeight = FontWeight.w700,
    this.icon,
    this.iconColor,
    this.iconSize = 20.0,
    this.padding // Tamaño por defecto para el icono
  });

  @override
  Widget build(BuildContext context) {
    // Determinar el color del texto y del icono basado en el tipo de botón
    Color currentTextColor;
    Color currentIconColor;

    if (type == RoundButtonType.textGradient) {
      currentTextColor = TColor.primaryColor1; // El ShaderMask se encarga del gradiente
      currentIconColor = iconColor ?? TColor.primaryColor1; // Ícono toma color primario o el especificado
    } else {
      currentTextColor = TColor.white;
      currentIconColor = iconColor ?? TColor.white; // Ícono blanco o el especificado
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: type == RoundButtonType.bgSGradient
              ? TColor.secondaryG // Asegúrate que TColor.secondaryG sea List<Color>
              : TColor.primaryG,  // Asegúrate que TColor.primaryG sea List<Color>
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: type == RoundButtonType.bgGradient || type == RoundButtonType.bgSGradient
            ? const [
                BoxShadow(
                    color: Colors.black26,
                    blurRadius: 0.5,
                    offset: Offset(0, 0.5))
              ]
            : null,
      ),
      child: MaterialButton(
        onPressed: onPressed,
        height: 50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        // textColor es manejado por el Text widget interno o ShaderMask
        minWidth: double.maxFinite,
        elevation: type == RoundButtonType.bgGradient || type == RoundButtonType.bgSGradient ? 0 : elevation,
        color: type == RoundButtonType.bgGradient || type == RoundButtonType.bgSGradient
            ? Colors.transparent // El gradiente del Container se ve a través
            : TColor.white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row( // Usar Row para acomodar icono y texto
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe más de lo necesario si el botón no es double.maxFinite
          children: [
            if (icon != null && icon!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0), // Espacio entre icono y texto
                child: Image.asset(
                  icon!,
                  width: iconSize,
                  height: iconSize,
                  color: currentIconColor, // Aplicar color al icono
                  // Considera usar fit: BoxFit.contain si los iconos no son cuadrados
                ),
              ),
            // Lógica para el texto (con o sin ShaderMask)
            if (type == RoundButtonType.textGradient)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  return LinearGradient(
                          colors: TColor.primaryG,
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight)
                      .createShader(
                          Rect.fromLTRB(0, 0, bounds.width, bounds.height));
                },
                child: Text(
                  title,
                  style: TextStyle(
                      // El color aquí es ignorado por el ShaderMask, pero se define por completitud
                      color: currentTextColor,
                      fontSize: fontSize,
                      fontWeight: fontWeight),
                ),
              )
            else
              Text(
                title,
                style: TextStyle(
                    color: currentTextColor,
                    fontSize: fontSize,
                    fontWeight: fontWeight),
              ),
          ],
        ),
      ),
    );
  }
}