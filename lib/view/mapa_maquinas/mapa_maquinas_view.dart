import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/machines_row.dart';

class MapaMaquinasView extends StatefulWidget {
  const MapaMaquinasView({super.key});

  @override
  State<MapaMaquinasView> createState() => _MapaMaquinasViewState();
}

class _MapaMaquinasViewState extends State<MapaMaquinasView> {
  List youArr = [
    {"image": "assets/img/maquina_abdominales_inclinada.png", "title": "Barbell"},
    {"image": "assets/img/maquina_abdominal_cable.jpg", "title": "Skipping Rope"},
    {"image": "assets/img/bottle.png", "title": "Bottle 1 Liters"},
  ];

  List youArr2 = [
    {"image": "assets/img/barbell.png", "title": "Barbell"},
    {"image": "assets/img/skipping_rope.png", "title": "Skipping Rope"},
    {"image": "assets/img/bottle.png", "title": "Bottle 1 Liters"},
  ];

  List youArr3 = [
    {"image": "assets/img/maquina_prensa_piernas.jpg", "title": "Barbell"},
    {"image": "assets/img/maquina_patada_gluteo.png", "title": "Skipping Rope"},
    {"image": "assets/img/maquina_escalera_sin_fin.jpg", "title": "Bottle 1 Liters"},
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;    
    return Container(
        decoration:
            BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
        child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  elevation: 0,
                  // pinned: true,
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(10)),
                      child: Image.asset(
                        "assets/img/black_btn.png",
                        width: 15,
                        height: 15,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  title: Text(
                    "Reserva tu Maquina",
                    style: TextStyle(
                        color: TColor.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                  ),
                  actions: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: TColor.lightGray,
                            borderRadius: BorderRadius.circular(10)),
                        child: Image.asset(
                          "assets/img/more_btn.png",
                          width: 15,
                          height: 15,
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  ],
                ),
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  centerTitle: true,
                  elevation: 0,
                  leadingWidth: 0,
                  leading: Container(),
                  expandedHeight: media.width * 0.5,
                  flexibleSpace: Align(
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/img/detail_top.png",
                      width: media.width * 0.75,
                      height: media.width * 0.8,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ];
            },
            body: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25))),
                child: Scaffold(
                    backgroundColor: Colors.transparent,
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 50,
                            height: 4,
                            decoration: BoxDecoration(
                                color: TColor.gray.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(3)),
                          ),
                          SizedBox(
                            height: media.width * 0.05,
                          ),
                          
                          MachinesRow(equipment: youArr, name: "Maquinas para ABS"),                                       
                          SizedBox(
                            height: media.width * 0.01,
                          ),
                          MachinesRow(equipment: youArr2, name: "Maquinas para Cardio"),
                          SizedBox(
                            height: media.width * 0.01,
                          ),
                          MachinesRow(equipment: youArr3, name: "Maquinas para tren inferior")
                        ],
                      ),
                    )))));
  }
}
