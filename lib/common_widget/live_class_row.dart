import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/models/clase_info_model.dart';

class LiveClassRow extends StatelessWidget {
  final ClaseInfo clase;
  final VoidCallback onJoinNow;

  const LiveClassRow({
    super.key,
    required this.clase,
    required this.onJoinNow,
  });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size; // Lo usaremos para el ancho del botón

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Similar al contenedor de GYM
      decoration: BoxDecoration(
        // Un color de fondo diferente para las clases, o puedes usar un gradiente
        color: TColor.secondaryColor2.withOpacity(0.1), // Ejemplo: un color secundario suave
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(color: TColor.secondaryColor2.withOpacity(0.3)) // Borde sutil
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Para empujar el botón a la derecha
        children: [
          // Sección de Información de la Clase (Izquierda)
          Expanded( // <--- CLAVE: Para que esta columna de texto tome el espacio disponible
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  clase.nombreClase,
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 16, // Tamaño similar al título de "Ingresar al GYM"
                      fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: media.width * 0.01), // Espacio pequeño
                Text(
                  // Formato de fecha y hora
                  "${DateFormat.MMMEd().format(clase.fechaHoraInicio.toLocal())} a las ${DateFormat.Hm().format(clase.fechaHoraInicio.toLocal())}",
                  style: TextStyle(color: TColor.gray, fontSize: 13), // Similar al subtítulo
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                 SizedBox(height: media.width * 0.005),
                 Text(
                  "${clase.duracionMinutos} min - ${clase.tipo}",
                  style: TextStyle(color: TColor.gray, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 15), // Espacio entre el texto y el botón

          // Botón "Unirse Ahora" (Derecha)
          SizedBox(
            width: media.width * 0.35, // Ancho similar al botón "Leer QR"
            height: 45,                // Altura similar
            child: RoundButton(
              title: "Unirse Ahora",
              // Podrías añadir un icono si quieres:
              // icon: "assets/img/join_class_icon.png",
              type: RoundButtonType.bgSGradient, // O el tipo que prefieras
              fontSize: 14, // Similar al botón "Leer QR"
              onPressed: onJoinNow,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Padding ajustado
            ),
          ),
        ],
      ),
    );
  }
}