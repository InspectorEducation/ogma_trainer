import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/round_textfield.dart';
import 'package:ogma_trainer/view/login/cual_es_tu_objectivo_view.dart';

class CompletePerfilView extends StatefulWidget {
  const CompletePerfilView({super.key});

  @override
  State<CompletePerfilView> createState() => _CompletePerfilViewState();
}

class _CompletePerfilViewState extends State<CompletePerfilView> {
  TextEditingController txtDate = TextEditingController();
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Image.asset(
                "assets/img/complete_profile.png",
                width: media.width,
                fit: BoxFit.fitWidth,
              ),
              SizedBox(
                height: media.width * 0.04,
              ),
              Text(
                "Vamos a completar tu perfil",
                style: TextStyle(
                    color: TColor.gray,
                    fontSize: 25,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                "¡Nos ayudara a conocer mas sobre ti! 😉",
                style: TextStyle(
                  color: TColor.gray,
                  fontSize: 20,
                ),
              ),
              SizedBox(
                height: media.width * 0.04,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: TColor.lightGray,
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        children: [
                          Container(
                              alignment: Alignment.center,
                              width: 50,
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 15),
                              child: Image.asset(
                                "assets/img/gender.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: TColor.gray,
                              )),
                          Expanded(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton(
                                value: selectedGender,
                                items: [
                                  "Hombre",
                                  "Mujer",
                                  "Prefiero no especificar"
                                ]
                                    .map((name) => DropdownMenuItem(
                                          value: name,
                                          child: Text(
                                            name,
                                            style: TextStyle(
                                                color: TColor.gray,
                                                fontSize: 16),
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value;
                                  });
                                },
                                isExpanded: true,
                                hint: Text(
                                  "Selecciona tu genero",
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: media.width * 0.04,
                    ),
                    RoundTextfield(
                      controller: txtDate,
                      hitText: "Fecha de nacimiento",
                      icon: "assets/img/date.png",
                    ),
                    SizedBox(
                      height: media.width * 0.04,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RoundTextfield(
                            controller: txtDate,
                            hitText: "Tu peso",
                            icon: "assets/img/weight.png",
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          width: 45,
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: TColor.secondaryG,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "KG",
                            style: TextStyle(color: TColor.white, fontSize: 12),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: media.width * 0.04,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: RoundTextfield(
                            controller: txtDate,
                            hitText: "Tu altura",
                            icon: "assets/img/hight.png",
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          width: 45,
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: TColor.secondaryG,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            "CM",
                            style: TextStyle(color: TColor.white, fontSize: 12),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: media.width * 0.04,
                    ),
                    RoundButton(
                        title: "Continuar",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const CualEsTuObjectivoView()));
                        }),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
