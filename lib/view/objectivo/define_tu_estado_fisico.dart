import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';

import '../../common_widget/round_button.dart';

class DefineTuEstadoFisico extends StatefulWidget {
  const DefineTuEstadoFisico({super.key});

  @override
  State<DefineTuEstadoFisico> createState() => _DefineTuEstadoFisicoState();
}

class _DefineTuEstadoFisicoState extends State<DefineTuEstadoFisico> {
  CarouselSliderController buttonCarouselController =
      CarouselSliderController();

  List goalArr = [
    {
      "image": "assets/img/goal_1.png",
      "title": "Sedentario",
      "subtitle":
          "I have a low amount of body fat\nand need / want to build more\nmuscle"
    },
    {
      "image": "assets/img/goal_2.png",
      "title": "Lean & Tone",
      "subtitle":
          "I’m “skinny fat”. look thin but have\nno shape. I want to add learn\nmuscle in the right way"
    },
    {
      "image": "assets/img/goal_3.png",
      "title": "Lose a Fat",
      "subtitle":
          "I have over 20 lbs to lose. I want to\ndrop all this fat and gain muscle\nmass"
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: CarouselSlider(
              items: goalArr
                  .map(
                    (gObj) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: TColor.primaryG,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(
                          vertical: media.width * 0.1, horizontal: 25),
                      alignment: Alignment.center,
                      child: FittedBox(
                        child: Column(
                          children: [
                            Image.asset(
                              gObj["image"].toString(),
                              width: media.width * 0.5,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              height: media.width * 0.1,
                            ),
                            Text(
                              gObj["title"].toString(),
                              style: TextStyle(
                                  color: TColor.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700),
                            ),
                            Container(
                              width: media.width * 0.1,
                              height: 1,
                              color: TColor.white,
                            ),
                            SizedBox(
                              height: media.width * 0.02,
                            ),
                            Text(
                              gObj["subtitle"].toString(),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: TColor.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
              carouselController: buttonCarouselController,
              options: CarouselOptions(
                autoPlay: false,
                enlargeCenterPage: true,
                viewportFraction: 0.7,
                aspectRatio: 0.74,
                initialPage: 0,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            width: media.width,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.75, // Increased progress
                    minHeight: 8,
                    backgroundColor: TColor.gray,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xff55c1ff)),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                Text(
                  "Define tu nivel de actividad",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  "Esto nos ayudara a eligir el mejor entranamiento para ti! ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
                const Spacer(),
                SizedBox(
                  height: media.width * 0.05,
                ),
                RoundButton(
                    title: "Confirm",
                    onPressed: () {
                      //Navigator.push(
                      //    context,
                      //    MaterialPageRoute(
                      //        builder: (context) => const WelcomeView()));
                    }),
              ],
            ),
          )
        ],
      )),
    );
  }
}
