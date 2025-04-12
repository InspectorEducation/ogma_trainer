import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/round_textfield.dart';
import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/view/login/bienvenido_view.dart';
import 'package:ogma_trainer/view/login/complete_perfil_view.dart';
import 'package:ogma_trainer/view/main_tab/main_tab_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isCheck = false;
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: media.height * 0.9,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Hey,",
                  style: TextStyle(color: TColor.gray, fontSize: 20),
                ),
                Text(
                  "Bienvenid@ de vuelta 👊",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                const RoundTextfield(
                  hitText: "Correo",
                  icon: "assets/img/email.png",
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: media.width * 0.04,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: media.width * 0.3,
                    ),
                    Text(
                      "¿Olvidaste tu contraseña?",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 14,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
                const Spacer(),
                RoundButton(
                    title: "Login",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const MainTabView()));
                    }),
                SizedBox(
                  height: media.width * 0.04,
                ),
                Row(
                  // crossAxisAlignment: CrossAxisAlignment.,
                  children: [
                    Expanded(
                        child: Container(
                      height: 1,
                      color: TColor.gray.withOpacity(0.5),
                    )),
                    Text(
                      "  Or  ",
                      style: TextStyle(color: TColor.black, fontSize: 12),
                    ),
                    Expanded(
                        child: Container(
                      height: 1,
                      color: TColor.gray.withOpacity(0.5),
                    )),
                  ],
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: media.width * 0.04,
                    ),
                    //se puede colocar login por google
                  ],
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "¿No tienes una cuenta aún? ",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "Registrarse",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
