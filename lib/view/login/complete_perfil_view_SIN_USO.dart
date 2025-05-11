import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/round_textfield.dart';
import 'package:ogma_trainer/services/auth_service.dart';
import 'package:ogma_trainer/view/login/cual_es_tu_objectivo_view.dart';

class CompletePerfilView extends StatefulWidget {
  const CompletePerfilView({super.key});

  @override
  State<CompletePerfilView> createState() => _CompletePerfilViewState();
}

class _CompletePerfilViewState extends State<CompletePerfilView> {
  final AuthService _authService = AuthService(); // Instancia del servicio
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Para validación

  // Controladores para los campos
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fechaNacimientoController =
      TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  // Los controladores de peso y altura no se envían a este servicio,
  // pero los mantenemos si se usan en otra parte o para un perfil más completo después.
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _alturaController = TextEditingController();

  String? _selectedGender;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fechaNacimientoController.dispose();
    _telefonoController.dispose();
    _pesoController.dispose();
    _alturaController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now()
          .subtract(const Duration(days: 365 * 18)), // Default a 18 años
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

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) {
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

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (result["success"] == true) {
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
      barrierDismissible: false, // El usuario no puede cerrar tocando fuera
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _isLoading ? null : Navigator.pop(context),
        ),
        title: const Text(
          'Completar Perfil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Aumentar padding general
            child: Form( // Envolver en un widget Form
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    "assets/img/complete_profile.png",
                    width: media.width * 0.5, // Imagen más pequeña
                    height: media.width * 0.5, // Asegurar que sea proporcional
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: media.width * 0.03),
                  Text(
                    "Vamos a completar tu perfil",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: TColor.black, // Color más oscuro para mejor contraste
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    "¡Nos ayudará a conocer más sobre ti! 😉",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),

                  // Nuevos campos
                  RoundTextfield(
                    controller: _nombreController,
                    hitText: "Nombre",
                    icon: "assets/img/gender.png", // Reemplaza con un icono adecuado
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu nombre.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextfield(
                    controller: _apellidoController,
                    hitText: "Apellido",
                    icon: "assets/img/gender.png", // Reemplaza con un icono adecuado
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu apellido.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                  RoundTextfield(
                    controller: _emailController,
                    hitText: "Correo Electrónico",
                    icon: "assets/img/email.png",
                    keyboardType: TextInputType.emailAddress,
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu correo.';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor, ingresa un correo válido.';
                      }
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
                        _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                        color: TColor.gray,
                      ),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                     validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña.';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: media.width * 0.04),
                   RoundTextfield(
                    controller: _telefonoController,
                    hitText: "Teléfono (Opcional)",
                    icon: "assets/img/gender.png", 
                    keyboardType: TextInputType.phone,                    
                  ),
                  SizedBox(height: media.width * 0.04),

                  // Campos existentes
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
                            child: DropdownButtonFormField<String>( // Usar DropdownButtonFormField para validación
                              decoration: const InputDecoration(
                                border: InputBorder.none, // Quitar borde interno
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0)
                              ),
                              value: _selectedGender,
                              items: [
                                "Hombre", // Usado en UI
                                "Mujer",  // Usado en UI
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
                                  _selectedGender = value;
                                });
                              },
                              isExpanded: true,
                              hint: Text(
                                "Selecciona tu género",
                                style: TextStyle(
                                    color: TColor.gray, fontSize: 16),
                              ),
                              validator: (value) => value == null ? 'Por favor, selecciona tu género.' : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                  SizedBox(height: media.width * 0.04),
                  GestureDetector(
                    onTap: _selectDate,
                    child: AbsorbPointer(
                      child: RoundTextfield(
                        controller: _fechaNacimientoController,
                        hitText: "Fecha de nacimiento",
                        icon: "assets/img/date.png",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, selecciona tu fecha de nacimiento.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: media.width * 0.04),
                  // Campos de peso y altura (opcionales para este servicio de registro)
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: RoundTextfield(
                  //         controller: _pesoController,
                  //         hitText: "Tu peso (Opcional)",
                  //         icon: "assets/img/weight.png",
                  //         keyboardType: TextInputType.number,
                  //       ),
                  //     ),
                  //     // ... KG
                  //   ],
                  // ),
                  // SizedBox(height: media.width * 0.04),
                  // Row(
                  //   children: [
                  //     Expanded(
                  //       child: RoundTextfield(
                  //         controller: _alturaController,
                  //         hitText: "Tu altura (Opcional)",
                  //         icon: "assets/img/hight.png",
                  //         keyboardType: TextInputType.number,
                  //       ),
                  //     ),
                  //     // ... CM
                  //   ],
                  // ),
                  SizedBox(height: media.width * 0.05), // Más espacio antes del botón
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    RoundButton(
                        title: "Continuar",
                        onPressed: _submitProfile
                    ),
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
