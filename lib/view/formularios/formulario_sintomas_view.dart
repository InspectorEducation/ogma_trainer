// lib/view/formularios/formulario_sintomas_view.dart (o donde la ubiques)
import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart'; // Ajusta la ruta
import 'package:ogma_trainer/common_widget/round_button.dart'; // Ajusta la ruta
import 'package:ogma_trainer/services/auth_service.dart';
import 'package:ogma_trainer/services/capacity_service.dart';
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:ogma_trainer/view/login/login_view.dart';
import 'package:ogma_trainer/view/main_tab/main_tab_view.dart'; // Vista final

class FormularioSintomasView extends StatefulWidget {
  final int checkInId;
  final int userId;
  final List<Map<String, String>> questions;

  const FormularioSintomasView(
      {super.key,
      required this.checkInId,
      required this.userId,
      required this.questions});

  @override
  State<FormularioSintomasView> createState() => _FormularioSintomasViewState();
}

class _FormularioSintomasViewState extends State<FormularioSintomasView> {
  final CapacityService _capacityService = CapacityService();
  late Map<int, bool?> _answers;
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  bool _isProcessingLogout = false;

  @override
  void initState() {
    super.initState();
    // Inicializar el mapa de respuestas con null para cada pregunta
    _answers = Map.fromIterable(
      List.generate(widget.questions.length, (index) => index),
      key: (index) => index,
      value: (index) => null,
    );
  }

  void _submitForm() async {
    if (_answers.containsValue(null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, responde todas las preguntas."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }    
    
    final result = await _capacityService.submitFormSymptoms(
      checkInId: widget.checkInId,
      userId: widget.userId,
      hasSymptoms: _answers[3] ?? false,
      hasRecentContact: _answers[4] ?? false,
    );

    if (result["succes"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Formulario completado. ¡Disfruta tu entrenamiento!"),
            backgroundColor: Colors.green),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainTabView()),
        (Route<dynamic> route) => false,
      );
    } else if (result["succes"] == false &&
        result["message"] == "El usuario presenta síntomas") {
      _showSymptomAlertDialog();
    } else {
      debugPrint("Fallo enviando el formulario, resultado: $result");
      String message = result["message"] ?? "";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
      throw Exception(result["message"] ?? "Error durante el envio");
    }
  }

  void _showSymptomAlertDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 10),
              Text('Alerta de Síntomas', textAlign: TextAlign.center),
            ],
          ),
          content: const SingleChildScrollView(
            // Para evitar overflow si el texto es largo
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "🛑 ¡Gracias por tu honestidad!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  "Detectamos que presentas algunos síntomas o has estado en contacto reciente con alguien que podría estar enfermo.\nPor tu bienestar y el de todos, te pedimos que no ingreses al establecimiento por ahora.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Text(
                  "Te recomendamos consultar a un profesional de salud y seguir las indicaciones médicas.\n¡Esperamos verte pronto y en mejores condiciones! 💪🙂",
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            ElevatedButton(
              // Usar ElevatedButton para más énfasis
              style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primaryColor1,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              // Deshabilitar botón mientras se procesa el logout
              onPressed: _isProcessingLogout ? null : _logoutAndNotify,
              child: _isProcessingLogout
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ))
                  : const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logoutAndNotify() async {
    if (_isProcessingLogout) return;

    setState(() {
      _isProcessingLogout = true;
    });

    // Cerrar sesión
    await _authService.logout();

    // Navegar a Login y limpiar stack
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Formulario de Síntomas 👩‍⚕️",
          style: TextStyle(
              fontSize: 20, color: TColor.black, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              "Por favor, responde honestamente a las siguientes preguntas antes de continuar.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: TColor.gray),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.questions[index]['question']!,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: TColor.black),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text('Sí'),
                                  value: true,
                                  groupValue: _answers[index],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _answers[index] = value;
                                    });
                                  },
                                  activeColor: TColor.primaryColor1,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                              Expanded(
                                child: RadioListTile<bool>(
                                  title: const Text('No'),
                                  value: false,
                                  groupValue: _answers[index],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _answers[index] = value;
                                    });
                                  },
                                  activeColor: TColor.primaryColor1,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            RoundButton(
              title: "Enviar y Continuar",
              onPressed: _submitForm,
            ),
          ],
        ),
      ),
    );
  }
}
