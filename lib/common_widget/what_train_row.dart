import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/models/routine_model.dart'; // Asegúrate que la ruta es correcta

class WhatTrainRow extends StatelessWidget {
  final Routine routine;
  final VoidCallback? onViewMorePressed;

  const WhatTrainRow({
    super.key,
    required this.routine,
    this.onViewMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size; // Para tamaños responsivos si es necesario

    // Determinar la imagen a mostrar
    String? imagePath = routine.urlImagen; // Puede ser null

    return Card( // Usar Card para elevación y bordes redondeados consistentes
      margin: EdgeInsets.zero, // El padding se maneja en el ListView padre
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias, // Para que el Stack respete el borde redondeado
      child: InkWell( // Hacer toda la tarjeta clickeable
        onTap: onViewMorePressed, // El botón "Ver más" también puede tener esta acción, o una específica
        child: Container(
          // Altura y Ancho se definen en el ListView.builder padre
          //width: media.width * 0.5, // Ejemplo, pero mejor definido por el padre
          // height: 200, // Ejemplo, pero mejor definido por el padre
          decoration: BoxDecoration(
            // El color de fondo se mostrará si la imagen no carga o no existe
            color: TColor.lightGray.withOpacity(0.1),
          ),
          child: Stack(
            children: [
              // --- IMAGEN DE FONDO ---
              if (imagePath != null && imagePath.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                          child: CircularProgressIndicator(
                        strokeWidth: 2,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback si la imagen de red falla (se verá el color de fondo del Container)
                      return Center(child: Icon(Icons.broken_image, color: TColor.gray.withOpacity(0.5), size: 40));
                    },
                  ),
                ),
              // --- SUPERPOSICIÓN DE COLOR (OVERLAY) PARA LEGIBILIDAD DEL TEXTO ---
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6), // Más oscuro abajo
                        Colors.black.withOpacity(0.4),
                        Colors.transparent.withOpacity(0.0), // Más transparente arriba
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center, // Termina el gradiente a la mitad o un poco más arriba
                      stops: const [0.0, 0.5, 1.0]
                    ),
                  ),
                ),
              ),

              // --- CONTENIDO DE TEXTO Y BOTÓN ---
              Positioned( // Posicionar el contenido para que no sea tapado completamente por la imagen
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        routine.nombreRutina,
                        style: TextStyle(
                            color: Colors.white, // Texto blanco para contraste
                            fontSize: 16, // Un poco más grande
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 2, color: Colors.black.withOpacity(0.7))]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${routine.totalEjercicios} Ejercicios | ${routine.tiempoEstimado}",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.9), // Ligeramente menos opaco
                            fontSize: 12,
                            shadows: [Shadow(blurRadius: 1, color: Colors.black.withOpacity(0.5))]),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 110, // Ancho ajustado para el botón
                        height: 35, // Altura ajustada
                        child: ElevatedButton( // Cambiado a ElevatedButton para un look más estándar
                          onPressed: onViewMorePressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.secondaryColor1.withOpacity(0.85), // Color con opacidad
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )
                          ),
                          child: const Text("Ver Rutina"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Opcional: Un icono o badge en una esquina si es necesario
              // Positioned(top: 10, right:10, child: Icon(Icons.fitness_center, color: Colors.white70))
            ],
          ),
        ),
      ),
    );
  }
}