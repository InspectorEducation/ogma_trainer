import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/siguiente_entrenamiento_row.dart';
import 'package:ogma_trainer/common_widget/what_train_row.dart';
import 'package:ogma_trainer/view/seguimiento_entrenamiento/detalle_entranamiento_view.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  List latestArr = [
    {
      "image": "assets/img/Workout1.png",
      "title": "Entrenamiento Personalizado DIA 1",
      "time": "Hoy, 02:00 pm"
    }
  ];

  List whatArr = [
    {
      "image": "assets/img/what_1.png",
      "title": "Entranamiento Cuerpo Completo",
      "exercises": "11 Ejercicios",
      "time": "32 minutos"
    },
    {
      "image": "assets/img/what_2.png",
      "title": "Entramiento Tren Inferior",
      "exercises": "12 Ejercicios",
      "time": "40 minutos"
    },
    {
      "image": "assets/img/what_3.png",
      "title": "Entranamiento Abdominales",
      "exercises": "14 Ejercicios",
      "time": "20 minutos"
    }
  ];

  bool workoutNow = true;

  @override
  void initState() {
    super.initState();
    if (workoutNow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWorkoutAlert(context);
      });
    }
  }

  void _showWorkoutAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¡Entrenamiento Próximo!"),
          content: const Text(
              "Tienes un entrenamiento programado, empieza en 15 minutos"),              
          actions: <Widget>[
            RoundButton(
                title: "¡Entendido!",
                type: RoundButtonType.bgSGradient,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bienvenido de nuevo,",
                        style: TextStyle(color: TColor.gray, fontSize: 20),
                      ),
                      Text(
                        "Ivan Pulido",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 25,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            "assets/img/calendar.png",
                            width: 25,
                            height: 25,
                            fit: BoxFit.fitHeight,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            "assets/img/notification_active.png",
                            width: 25,
                            height: 25,
                            fit: BoxFit.fitHeight,
                          ))
                    ],
                  )
                ],
              ),
              SizedBox(
                height: media.width * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tu entramiento personalizado",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(
                height: media.width * 0.02,
              ),
              Container(
                height: media.width * 0.4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: TColor.primaryG),
                  borderRadius: BorderRadius.circular(media.width * 0.075),
                ),
                child: Stack(clipBehavior: Clip.none, children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Reto 7 días",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: media.width * 0.01,
                        ),
                        Row(
                          children: const [
                            Icon(Icons.timer, size: 16),
                            SizedBox(width: 4),
                            Text("7 días"),
                            SizedBox(width: 8),
                            Icon(Icons.star, size: 16),
                            SizedBox(width: 4),
                            Text("2100 kcal"),
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.01,
                        ),
                        const Text("30% completado"),
                        SizedBox(
                          height: media.width * 0.01,
                        ),
                        SimpleAnimationProgressBar(
                          height: 10,
                          width: media.width * 0.5,
                          backgroundColor: Colors.grey.shade100,
                          foregrondColor: Colors.purple,
                          ratio: 0.3 as double? ?? 0.0,
                          direction: Axis.horizontal,
                          curve: Curves.fastLinearToSlowEaseIn,
                          duration: const Duration(seconds: 3),
                          borderRadius: BorderRadius.circular(7.5),
                          gradientColor: LinearGradient(
                              colors: TColor.secondaryG,
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight),
                        ),
                        SizedBox(
                          height: media.width * 0.03,
                        ),
                        SizedBox(
                            width: 120,
                            height: 35,
                            child: RoundButton(
                                title: "Ver más",
                                type: RoundButtonType.bgSGradient,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                onPressed: () {}))
                      ],
                    ),
                  ),
                  Positioned(
                    // Position the image
                    right: -30,
                    top: -20,
                    child: Image.asset(
                      "assets/img/man_1.png",
                      height: media.width * 0.45,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ]),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Proximo entrenamiento",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Ver Más",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  color: TColor.primaryColor2.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Revisa tu calendario",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 70,
                      height: 25,
                      child: RoundButton(
                        title: "Revisar",
                        type: RoundButtonType.bgGradient,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: latestArr.length,
                  itemBuilder: (context, index) {
                    var wObj = latestArr[index] as Map? ?? {};
                    return SiguienteEntrenamientoRow(wObj: wObj);
                  }),
              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Escoge otro entrenamiento",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "ver más",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: whatArr.length,
                  itemBuilder: (context, index) {
                    var wObj = whatArr[index] as Map? ?? {};
                    return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      DetalleEntranamientoView(
                                        dObj: wObj,
                                      )));
                        },
                        child: WhatTrainRow(wObj: wObj));
                  }),
              SizedBox(
                height: media.width * 0.1,
              ),
            ],
          ),
        )),
      ),
    );
  }
}
