import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/round_textfield.dart';
import 'package:ogma_trainer/services/auth_service.dart';
import 'package:ogma_trainer/view/login/cual_es_tu_objectivo_view.dart';
import 'package:ogma_trainer/view/login/login_view.dart';

class RegistrarseView extends StatefulWidget {
  const RegistrarseView({super.key});

  @override
  State<RegistrarseView> createState() => _RegistrarseViewState();
}

class _RegistrarseViewState extends State<RegistrarseView> {
  final AuthService _authService = AuthService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  String? _selectedGender;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _aceptaTerminos = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: TColor.primaryColor1),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _performRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text("Debes aceptar los términos y políticas para continuar.")),
      );
      return;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, selecciona tu género.")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _authService.registerUser(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fechaNacimiento: _fechaNacimientoController.text,
      genero: _selectedGender!,
      telefono: _telefonoController.text.trim(),
    );

    final resultLogin = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result["success"] == true && resultLogin["success"]) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                result["message"] ?? "Error al registrar. Intenta de nuevo."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¡Registro Exitoso!"),
          content: const Text(
              "Tu usuario ha sido creado, ahora dinos cuál es tu objetivo."),
          actions: <Widget>[
            TextButton(
              child: const Text("Continuar"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CualEsTuObjectivoView()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                      height: media.width *
                          0.07), // Reducir un poco el espacio superior
                  Text(
                    "HOLA 👋",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: media.width * 0.02),
                  TextButton(
                      onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginView())),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("🙋 ¿Ya tienes una cuenta?",
                              style:
                                  TextStyle(color: TColor.black, fontSize: 16)),
                          Text(" Iniciar Sesión",
                              style: TextStyle(
                                  color: TColor.primaryColor1,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w700)), // Usar color primario
                        ],
                      )),
                  SizedBox(height: media.width * 0.04), // Espacio al final
                  Row(
                    children: [
                      Expanded(
                          child: Container(
                              height: 1, color: TColor.gray.withOpacity(0.5))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text("O",
                            style: TextStyle(color: TColor.gray, fontSize: 16)),
                      ),
                      Expanded(
                          child: Container(
                              height: 1, color: TColor.gray.withOpacity(0.5))),
                    ],
                  ),
                  SizedBox(height: media.width * 0.05),
                  Text(
                    "Crea una cuenta",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: media.width * 0.05),

                  // Campos de Registro
                  RoundTextfield(
                    controller: _nombreController,
                    hitText: "Nombre",
                    icon: "assets/img/user_text.png",
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingresa tu nombre.'
                        : null,
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextfield(
                    controller: _apellidoController,
                    hitText: "Apellido",
                    icon: "assets/img/user_text.png",
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingresa tu apellido.'
                        : null,
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextfield(
                    controller: _emailController,
                    hitText: "Correo electrónico",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Ingresa tu correo.';
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))
                        return 'Correo inválido.';
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextfield(
                    controller: _passwordController,
                    hitText: "Contraseña",
                    icon: "assets/img/lock.png",
                    obscureText: !_isPasswordVisible,
                    rightIcon: IconButton(
                      icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: TColor.gray),
                      onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Ingresa tu contraseña.';
                      if (value.length < 6) return 'Mínimo 6 caracteres.';
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),

                  // Género
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
                            child: Image.asset("assets/img/gender.png",
                                width: 20,
                                height: 20,
                                fit: BoxFit.contain,
                                color: TColor.gray)),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10)),
                              value: _selectedGender,
                              items: [
                                "Hombre",
                                "Mujer",
                                "Prefiero no especificar"
                              ]
                                  .map((name) => DropdownMenuItem(
                                      value: name,
                                      child: Text(name,
                                          style: TextStyle(
                                              color: TColor.gray,
                                              fontSize: 16))))
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _selectedGender = value),
                              isExpanded: true,
                              hint: Text("Selecciona tu género",
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 16)),
                              validator: (value) => value == null
                                  ? 'Selecciona tu género.'
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                  SizedBox(height: media.width * 0.04),

                  // Fecha de Nacimiento
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: RoundTextfield(
                        controller: _fechaNacimientoController,
                        hitText: "Fecha de nacimiento",
                        icon: "assets/img/date.png",
                        validator: (value) => value == null || value.isEmpty
                            ? 'Selecciona tu fecha de nacimiento.'
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: media.width * 0.04),

                  // Teléfono
                  RoundTextfield(
                    controller: _telefonoController,
                    hitText: "Teléfono (Opcional)",
                    icon:
                        "assets/img/phone.png", // Asegúrate que este asset exista
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(height: media.width * 0.04),

                  // Términos y Condiciones
                  Row(
                    children: [
                      IconButton(
                        onPressed: () =>
                            setState(() => _aceptaTerminos = !_aceptaTerminos),
                        icon: Icon(
                          _aceptaTerminos
                              ? Icons.check_box_outlined
                              : Icons.check_box_outline_blank_outlined,
                          color: _aceptaTerminos
                              ? TColor.primaryColor1
                              : TColor.gray,
                          size: 25,
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      "Mostrar Términos y Políticas aquí.")),
                            );
                          },
                          child: Text(
                            "Para continuar acepta nuestra Política de Privacidad y Términos de Uso",
                            style: TextStyle(
                                color: TColor.gray,
                                fontSize:
                                    14), // Tamaño de fuente un poco más pequeño
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                      height: media.width * 0.07), // Espacio antes del botón

                  // Botón de Registrarse
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    RoundButton(
                        title: "Registrarse", onPressed: _performRegistration),

                  SizedBox(height: media.width * 0.05), // Espacio al final
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
