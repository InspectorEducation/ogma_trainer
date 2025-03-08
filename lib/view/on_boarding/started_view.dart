import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/view/on_boarding/on_boarding_view.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {
  bool isChangeColor = true;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Container(
          width: media.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: TColor.primaryG,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Spacer(),
            Text(
              "Omga Trainer",
              style: TextStyle(
                  color: TColor.black,
                  fontSize: 36,
                  fontWeight: FontWeight.w700),
            ),
            Text(
              "Libera tu estado físico",
              style: TextStyle(
                color: TColor.gray,
                fontSize: 19,
              ),
            ),
            Spacer(),
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: RoundButton(
                    title: "Iniciemos",
                    type: isChangeColor
                        ? RoundButtonType.textGradient
                        : RoundButtonType.bgGradient,
                    onPressed: () {
                      if(isChangeColor) {
                      }
                      Navigator.push(
                        context, 
                        MaterialPageRoute(
                          builder: (context) => const OnBoardingView()));
                    }),
              ),
            )
          ])),
    );
  }
}
