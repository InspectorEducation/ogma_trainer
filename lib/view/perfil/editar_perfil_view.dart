import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/round_textfield.dart';
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:ogma_trainer/services/user_service.dart';

class EditarPerfilView extends StatefulWidget {
  final Map<String, dynamic>? initialUserData;

  const EditarPerfilView({super.key, this.initialUserData});

  @override
  State<EditarPerfilView> createState() => _EditarPerfilViewState();
}

class _EditarPerfilViewState extends State<EditarPerfilView> {
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();

  // Controladores
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(); // Para nueva contraseña
  final _fechaNacimientoController = TextEditingController();
  final _telefonoController = TextEditingController();
  String? _selectedGender;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _userId;

  final List<String> _genders = [
    "Masculino",
    "Femenino",
    "Otro",
    "Prefiero no especificar"
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    _userId = await _storageService.getUserId();
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Error: Usuario no identificado."),
          backgroundColor: Colors.red));
      Navigator.pop(context);
      return;
    }

    // Cargar datos del perfil para pre-llenar
    if (widget.initialUserData != null) {
      _populateFields(widget.initialUserData!);
    } else {
      final profileResult = await _userService.getUserProfile(_userId!);
      if (profileResult["success"] == true && profileResult["data"] != null) {
        _populateFields(profileResult["data"]);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(profileResult["message"] ??
                "Error al cargar datos del perfil."),
            backgroundColor: Colors.red));        
      }
    }
    setState(() => _isLoading = false);
  }

  void _populateFields(Map<String, dynamic> data) {
    _nombreController.text = data['nombre'] ?? '';
    _apellidoController.text = data['apellido'] ?? '';
    _emailController.text = data['email'] ?? '';
    // La contraseña no se pre-llena por seguridad
    if (data['fechaNacimiento'] != null) {
      try {        
        DateTime parsedDate = DateTime.parse(data['fechaNacimiento']);
        _fechaNacimientoController.text =
            DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        _fechaNacimientoController.text = '';
        debugPrint(
            "Error parseando fecha de nacimiento para prellenar: ${data['fechaNacimiento']}");
      }
    }
    _selectedGender = data['genero'];    
    if (_selectedGender != null && !_genders.contains(_selectedGender)) {
      _selectedGender =
          "Otro";
    }
    _telefonoController.text = data['telefono'] ?? '';
  }

  Future<void> _selectDate() async {
    DateTime? initialDateValue;
    if (_fechaNacimientoController.text.isNotEmpty) {
      try {
        initialDateValue =
            DateFormat('yyyy-MM-dd').parse(_fechaNacimientoController.text);
      } catch (_) {}
    }

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDateValue ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // ... (builder para tema si lo tienes) ...
    );
    if (picked != null) {
      setState(() {
        _fechaNacimientoController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Por favor, selecciona tu género."),
          backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isSaving = true);
    
    final result = await _userService.updateUserProfile(
      userId: _userId!,
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.isNotEmpty
          ? _passwordController.text
          : null,
      fechaNacimiento: _fechaNacimientoController.text,
      genero: _selectedGender!,
      telefono: _telefonoController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (mounted) {
      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result["message"] ?? "Perfil actualizado."),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context,
            true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result["message"] ?? "Error al guardar."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Perfil",style: TextStyle(color: TColor.black, fontSize: 20, fontWeight: FontWeight.w700),),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: TColor.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      hitText: "Nueva Contraseña (dejar vacío si no cambia)",
                      icon: "assets/img/lock.png",
                      obscureText:
                          true,                       
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'La nueva contraseña debe tener al menos 6 caracteres.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: media.width * 0.04),
                    GestureDetector(
                      onTap: _selectDate,
                      child: AbsorbPointer(
                        child: RoundTextfield(
                          controller: _fechaNacimientoController,
                          hitText: "Fecha de nacimiento",
                          icon: "assets/img/date.png",
                          validator: (value) => value == null || value.isEmpty
                              ? 'Selecciona tu fecha.'
                              : null,
                        ),
                      ),
                    ),
                    SizedBox(height: media.width * 0.04),
                    // Género
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 10),
                          child: Image.asset("assets/img/gender.png",
                              width: 20, height: 20, color: TColor.gray),
                        ),
                        hintText: "Selecciona tu género",
                        hintStyle: TextStyle(color: TColor.gray, fontSize: 14),
                        filled: true,
                        fillColor: TColor.lightGray,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 0),
                      ),
                      value: _selectedGender,
                      items: _genders
                          .map((String gender) => DropdownMenuItem(
                              value: gender, child: Text(gender)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedGender = value),
                      validator: (value) =>
                          value == null ? 'Selecciona tu género.' : null,
                    ),
                    SizedBox(height: media.width * 0.04),
                    RoundTextfield(
                      controller: _telefonoController,
                      hitText: "Teléfono",
                      icon: "assets/img/phone.png",
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Ingresa tu teléfono.'
                          : null,
                    ),
                    SizedBox(height: media.width * 0.08),
                    if (_isSaving)
                      const Center(child: CircularProgressIndicator())
                    else
                      RoundButton(
                        title: "Guardar Cambios",
                        onPressed: _saveProfile,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
