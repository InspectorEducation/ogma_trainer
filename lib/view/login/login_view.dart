import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/round_textfield.dart';
import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/services/auth_service.dart';
import 'package:ogma_trainer/view/main_tab/main_tab_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // Instancia del servicio

  bool _isPasswordVisible = false; // Para el toggle de visibilidad de contraseña
  bool _isLoading = false; // Para mostrar un indicador de carga

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _performLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingresa correo y contraseña.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) { // Verificar si el widget sigue en el árbol
      if (result["success"] == true) {
        // Login exitoso
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Login exitoso!")),
        );        

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainTabView()),
        );
      } else {
        // Error en el login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Error al iniciar sesión")),
        );
      }
    }
  }

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
                const SizedBox(height: 20),
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
                RoundTextfield(
                  hitText: "Correo",
                  icon: "assets/img/email.png",
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                SizedBox(
                  height: media.width * 0.04,
                ),
                RoundTextfield(
                  hitText: "Contraseña",
                  icon: "assets/img/lock.png",
                  obscureText: !_isPasswordVisible,
                  controller: _passwordController,
                  rightIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: TColor.gray,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextButton(
                        onPressed: () {                          
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Funcionalidad 'Olvidé contraseña' no implementada.")),
                          );
                        },
                        child: Text(
                          "¿Olvidaste tu contraseña?",
                          style: TextStyle(
                              color: TColor.gray,
                              fontSize: 14,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  RoundButton(
                      title: "Login",
                      onPressed: _performLogin
                  ),                
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
