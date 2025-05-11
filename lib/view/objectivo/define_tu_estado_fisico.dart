import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/models/user_profile_data.dart';
import 'package:ogma_trainer/view/objectivo/datos_fisicos_view.dart';

import '../../common_widget/round_button.dart';

class DefineTuEstadoFisico extends StatefulWidget {
  final UserProfileData profileData;
  const DefineTuEstadoFisico({super.key, required this.profileData});

  @override
  State<DefineTuEstadoFisico> createState() => _DefineTuEstadoFisicoState();
}

class _DefineTuEstadoFisicoState extends State<DefineTuEstadoFisico> {
  CarouselSliderController buttonCarouselController =
      CarouselSliderController(); 
  int _currentIndex = 0; 

  final List<Map<String, String>> goalArr = [
    {
      "image": "assets/img/goal_1.png",
      "title": "Sedentario",
      "subtitle":
          "No realizo actividad física regularmente, \npaso la mayor parte del día sentado o inactivo." // Texto traducido y ajustado
    },
    {
      "image": "assets/img/goal_2.png",
      "title": "Ligero",
      "subtitle":
          "Realizo actividades físicas leves 1-2 veces por semana (como caminar, estiramientos o tareas del hogar)."
    },
    {
      "image": "assets/img/goal_3.png",
      "title": "Moderado",
      "subtitle":
          "Realizo ejercicio físico moderado 3-5 veces \npor semana (como trotar, andar en bicicleta, \nclases grupales, etc.)."
    },
    {
      "image": "assets/img/goal_3.png",
      "title": "Activo",
      "subtitle":
          "Entreno intensamente entre 5 y 6 días \npor semana, combinando cardio y fuerza."
    },
    {
      "image": "assets/img/goal_3.png",
      "title": "Muy Activo",
      "subtitle":
          "Realizo actividad física diaria \nintensa o entreno dos veces al día, \nideal para deportistas o personas \ncon alta exigencia física."
    },
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mi perfil',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700), // Tamaño un poco mayor
        ),
        centerTitle: true,
        elevation: 0, // Quitar sombra si prefieres
        backgroundColor: TColor.white, // Fondo del AppBar igual al scaffold
        foregroundColor: TColor.black, // Color de iconos y texto del AppBar
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: CarouselSlider(
              items: goalArr.map((gObj) {
                bool isSelected = goalArr.indexOf(gObj) ==
                    _currentIndex; // Para estilos diferentes si está seleccionado
                return Container(
                  width: media.width * 0.7, // Ancho explícito para la tarjeta
                  margin: const EdgeInsets.symmetric(
                      horizontal: 8.0), // Pequeño margen entre tarjetas
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: TColor
                              .primaryG, // Asegúrate que TColor.primaryG sea una lista de colores
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        // Sombra sutil para dar profundidad
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        )
                      ]),
                  // Ajustar padding para que el contenido tenga espacio pero no sea excesivo
                  padding: EdgeInsets.symmetric(
                      vertical: media.width * 0.05,
                      horizontal: 20), // Reducido vertical, horizontal fijo
                  alignment: Alignment.center,
                  child: Column(
                    // Quitado FittedBox por ahora para controlar tamaños directamente
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centrar contenido verticalmente
                    mainAxisSize: MainAxisSize
                        .min, // Para que la columna no intente ocupar todo el alto disponible
                    children: [
                      Image.asset(
                        gObj["image"].toString(),
                        width: media.width * 0.35, // Ancho de la imagen
                        height: media.width *
                            0.35, // Altura de la imagen (ajusta según el aspect ratio de tus imágenes)
                        fit:
                            BoxFit.contain, // Usar contain para no distorsionar
                      ),
                      SizedBox(
                        height: media.width * 0.04, // Reducido espacio
                      ),
                      Text(
                        gObj["title"].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: TColor.white,
                            fontSize: 18, // Ligeramente más grande
                            fontWeight: FontWeight.w700),
                      ),
                      Container(
                        // Línea decorativa
                        width: media.width * 0.15, // Un poco más ancha
                        height: 2, // Un poco más gruesa
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0), // Margen para la línea
                        decoration: BoxDecoration(
                            color: TColor.white.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(1)),
                      ),
                      // SizedBox(
                      //   height: media.width * 0.01, // Reducido
                      // ),
                      Text(
                        gObj["subtitle"].toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: TColor.white,
                            fontSize: 13, // Ligeramente más pequeño
                            height: 1.3 // Interlineado
                            ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              carouselController: buttonCarouselController,
              options: CarouselOptions(
                  autoPlay: false,
                  enlargeCenterPage: true,
                  viewportFraction:
                      0.75, 
                  aspectRatio: media.width /
                      (media.height *
                          0.55),
                  initialPage: _currentIndex,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentIndex = index;
                    });
                  }),
            ),
          ),
          Align(
            // Colocar el contenido de la UI (texto y botón)
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min, // Para que no ocupe todo el alto
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.75, // Increased progress
                      minHeight: 8,
                      backgroundColor: TColor.gray,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xff55c1ff)),
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                  Text(
                    "Define tu nivel de actividad",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20, // Más grande
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: media.width * 0.02),
                  Text(
                    "Esto nos ayudará a elegir el mejor entrenamiento para ti.", // Texto ajustado
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: TColor.gray, fontSize: 14, height: 1.3),
                  ),
                ],
              ),
            ),
          ),
          Align(
            // Botón en la parte inferior
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                  left: 25, right: 25, bottom: media.height * 0.02),
              child: RoundButton(
                  title: "Continuar", // Traducido
                  onPressed: () {
                    widget.profileData.nivelActividadDiaria = goalArr[_currentIndex]["tittle"];
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DatosFisicosView(profileData: widget.profileData),
                      ),
                    );
                  }),
            ),
          )
        ],
      )),
    );
  }
}
