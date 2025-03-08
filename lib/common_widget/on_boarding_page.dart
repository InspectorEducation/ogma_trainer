import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';

class OnBoardingPage extends StatelessWidget {
  final Map pObj;
  const OnBoardingPage({super.key, required this.pObj});

  @override
  Widget build(BuildContext context) {

    var media = MediaQuery.of(context).size;

    return Container(
        width: media.width,
        height: media.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              pObj["imagen"].toString(),
              width: media.width,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
              height: media.width * 0.1,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(pObj["titulo"].toString(),
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 24,
                      fontWeight: FontWeight.w700)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(pObj["subtitulo"].toString(),
                  style: TextStyle(color: TColor.gray, fontSize: 14)),
            )
          ],
        ));
  }
}
