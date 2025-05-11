import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/round_textfield.dart';
import 'package:ogma_trainer/models/user_profile_data.dart';
import 'package:ogma_trainer/view/objectivo/disponibilidad_entrenamiento_view.dart';


class DatosFisicosView extends StatefulWidget {
  final UserProfileData profileData;
  const DatosFisicosView({super.key, required this.profileData});

  @override
  State<DatosFisicosView> createState() => _DatosFisicosViewState();
}

class _DatosFisicosViewState extends State<DatosFisicosView> {
  final _formKey = GlobalKey<FormState>();
  final _alturaController = TextEditingController();
  final _pesoActualController = TextEditingController();
  final _pesoObjetivoController = TextEditingController();
  final _condicionesMedicasController = TextEditingController();

  @override
  void dispose() {
    _alturaController.dispose();
    _pesoActualController.dispose();
    _pesoObjetivoController.dispose();
    _condicionesMedicasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Información Física', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView( // Usar ListView para campos que podrían necesitar scroll
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.85, // Ajusta el progreso
                  minHeight: 8,
                  backgroundColor: TColor.lightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(TColor.secondaryColor1),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Cuéntanos sobre tu físico',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TColor.black),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Estos datos nos ayudarán a personalizar tu plan.',
                style: TextStyle(fontSize: 14, color: TColor.gray),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              RoundTextfield(
                controller: _alturaController,
                hitText: 'Altura (cm)',
                icon: 'assets/img/height.png', 
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa tu altura.';
                  if (double.tryParse(value) == null) return 'Ingresa un número válido.';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              RoundTextfield(
                controller: _pesoActualController,
                hitText: 'Peso Actual (kg)',
                icon: 'assets/img/peso-inicial.png',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa tu peso actual.';
                  if (double.tryParse(value) == null) return 'Ingresa un número válido.';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              RoundTextfield(
                controller: _pesoObjetivoController,
                hitText: 'Peso Objetivo (kg)',
                icon: 'assets/img/peso-obj.png', 
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa tu peso objetivo.';
                  if (double.tryParse(value) == null) return 'Ingresa un número válido.';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              RoundTextfield(
                controller: _condicionesMedicasController,
                hitText: 'Condiciones Médicas (Opcional)',
                icon: 'assets/img/patient.png', // Reemplaza con icono adecuado
                keyboardType: TextInputType.multiline,                
              ),
              SizedBox(height: media.height * 0.1), // Espacio para el botón
              RoundButton(
                title: 'Continuar',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.profileData.alturaCm = double.tryParse(_alturaController.text);                    
                    widget.profileData.pesoInicialKg = double.tryParse(_pesoActualController.text);
                    widget.profileData.pesoActualKg = double.tryParse(_pesoActualController.text);
                    widget.profileData.pesoObjetivoKg = double.tryParse(_pesoObjetivoController.text);
                    widget.profileData.condicionesMedicas = _condicionesMedicasController.text.trim();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DisponibilidadEntrenamientoView(profileData: widget.profileData),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}