import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/on_boarding_page.dart';
import 'package:ogma_trainer/view/login/registrarse_view.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.addListener(() {
      selectPage = controller.page?.round() ?? 0;
      setState(() {
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    List pageArray = [
      {
        "titulo": "!Consigue tu meta!",
        "subtitulo": "Escoge tu meta e inicia el cambio",
        "imagen": "assets/img/on_1.png"
      },
      {
        "titulo": "Escoge una rutina",
        "subtitulo": "Nosotros reservaremos las maquinas",
        "imagen": "assets/img/on_2.png"
      },
      {
        "titulo": "Entrenamiento personalizado ",
        "subtitulo":
            "Nuestro algoritmos especializados diseñaran un entramiento a tu medida, que se ajustara a tus metas y el estado fisico actual",
        "imagen": "assets/img/on_3.png"
      }
    ];

    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.bottomRight,
        children: [
          PageView.builder(
              controller: controller,
              itemCount: pageArray.length,
              itemBuilder: (context, index) {
                var pObj = pageArray[index] as Map? ?? {};
                return OnBoardingPage(pObj: pObj);
              }),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            width: 70,
            height: 70,
            decoration: BoxDecoration(
                color: TColor.primaryColor1,
                borderRadius: BorderRadius.circular(35)),
            child: IconButton(
              icon: Icon(
                Icons.navigate_next,
                color: TColor.white,
              ),
              onPressed: () {
                if(selectPage < pageArray.length -1) {
                  selectPage = selectPage + 1;
                  controller.animateToPage(selectPage, duration: Duration(milliseconds: 600), curve:Curves.decelerate);                  
                  //controller.jumpToPage(selectPage);
                } else {
                  print("Welcome");
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrarseView()));
                }  
                
              },
            ),
          )
        ],
      ),
    );
  }
}
