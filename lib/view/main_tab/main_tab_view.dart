import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/tab_button.dart';
import 'package:ogma_trainer/view/mapa_maquinas/mapa_maquinas_view.dart';
import 'package:ogma_trainer/view/perfil/perfil_view.dart';
import 'package:ogma_trainer/view/seguimiento_entrenamiento/calendario_entrenamiento_view.dart';
import 'package:ogma_trainer/view/seguimiento_entrenamiento/seguimiento_entrenamiento_view.dart';

import '../home/home_view.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;
  final PageStorageBucket pageBucket = PageStorageBucket(); 
  Widget currentTab = const HomeView();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: PageStorage(bucket: pageBucket, child: currentTab),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 70,
        height: 70,
        child: InkWell(
          onTap: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CalendarioEntrenamientoView()),
            );
          },
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: TColor.primaryG,
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 2,)
                ]),
            child: Icon(Icons.calendar_month,color: TColor.white, size: 35, ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Container(
        decoration: BoxDecoration(color: TColor.white, boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, -2))
        ]),
        height: kToolbarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TabButton(
                icon: "assets/img/home.png",
                selectIcon: "assets/img/home_activo.png",
                isActive: selectTab == 0,
                onTap: () {
                  selectTab = 0;
                  currentTab = const HomeView();
                  if (mounted) {
                    setState(() {});
                  }
                }),
            TabButton(
                icon: "assets/img/personal_trainer.png",
                selectIcon: "assets/img/personal_trainer_activo.png",
                isActive: selectTab == 1,
                onTap: () {
                  selectTab = 1;
                  currentTab = const SeguimientoEntrenamientoView();
                  if (mounted) {
                    setState(() {});
                  }
                }),

              const  SizedBox(width: 40,),
            TabButton(
                icon: "assets/img/gym_equipment.png",
                selectIcon: "assets/img/gym_equipment_activo.png",
                isActive: selectTab == 2,
                onTap: () {
                  selectTab = 2;
                   currentTab = const MapaMaquinasView();
                  if (mounted) {
                    setState(() {});
                  }
                }),
            TabButton(
                icon: "assets/img/usuario.png",
                selectIcon: "assets/img/usuario_activo.png",
                isActive: selectTab == 3,
                onTap: () {
                  selectTab = 3;
                   currentTab = const PerfilView();
                  if (mounted) {
                    setState(() {});
                  }
                })
          ],
        ),
      )),
    );
  }
}
