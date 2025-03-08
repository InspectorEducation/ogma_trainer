import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/view/on_boarding/on_boarding_view.dart';
import 'package:ogma_trainer/view/on_boarding/started_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ogma Trainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
       
      primaryColor: TColor.primaryColor1,
      fontFamily: "Poppins"
      ),
      home: const StartedView(),
    );
  }
}

