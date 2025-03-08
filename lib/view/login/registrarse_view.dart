import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/round_textfield.dart';
import 'package:ogma_trainer/view/login/complete_perfil_view.dart';
import 'package:ogma_trainer/view/login/login_view.dart';

class RegistrarseView extends StatefulWidget {
  const RegistrarseView({super.key});

  @override
  State<RegistrarseView> createState() => _RegistrarseViewState();
}

class _RegistrarseViewState extends State<RegistrarseView> {
  bool isCheck = false;
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
          child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: media.width * 0.09,
              ),
              Text(
                "HOLA 👋",
                style: TextStyle(color: TColor.gray, fontSize: 20),
              ),
              Text(
                "Create una cuenta",
                style: TextStyle(
                    color: TColor.gray,
                    fontSize: 25,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              const RoundTextfield(
                  hitText: "Primer nombre", icon: "assets/img/user_text.png"),
              SizedBox(
                height: media.width * 0.02,
              ),
              const RoundTextfield(
                  hitText: "Primer apellido", icon: "assets/img/user_text.png"),
              SizedBox(
                height: media.width * 0.02,
              ),
              const RoundTextfield(
                hitText: "Correo electronico",
                icon: "assets/img/email.png",
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: media.width * 0.02,
              ),
              RoundTextfield(
                hitText: "Contraseña",
                icon: "assets/img/lock.png",
                obscureText: true,
                rightIcon: TextButton(
                    onPressed: () {},
                    child: Container(
                        alignment: Alignment.center,
                        width: 20,
                        height: 20,
                        child: Image.asset(
                          "assets/img/show_password.png",
                          width: 20,
                          height: 20,
                          fit: BoxFit.contain,
                          color: TColor.gray,
                        ))),
              ),
              SizedBox(
                height: media.width * 0.08,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isCheck = !isCheck;
                      });
                    },
                    icon: Icon(
                      isCheck
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank_outlined,
                      color: TColor.gray,
                      size: 25,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "Para continuar acepta nuestra Politica de Privacidad y Terminos de Uso",
                      style: TextStyle(color: TColor.gray, fontSize: 16),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: media.width * 0.2,
              ),
              RoundButton(title: "Registrarse", onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CompletePerfilView()));
              }),
              SizedBox(
                height: media.width * 0.04,
              ),
              Row(
                children: [
                  Expanded(
                      child: Container(
                    height: 1,
                    color: TColor.gray.withOpacity(0.5),
                  )),
                  Text(
                    "  O  ",
                    style: TextStyle(color: TColor.gray, fontSize: 16),
                  ),
                  Expanded(
                      child: Container(
                    height: 1,
                    color: TColor.gray.withOpacity(0.5),
                  )),
                ],
              ),

              //Registrarse por google

              SizedBox(
                height: media.width * 0.04,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginView()));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "🙋 Ya tienes una cueta?",
                        style: TextStyle(
                            color: TColor.black, 
                            fontSize: 20),
                      ),
                      Text(
                        " Iniciar Sesión",
                        style: TextStyle(color: TColor.black, fontSize: 20, fontWeight: FontWeight.w700),
                      )
                    ],
                  )),
              SizedBox(
                height: media.width * 0.04,
              ),
            ],
          ),
        ),
      )),
    );
  }
}
