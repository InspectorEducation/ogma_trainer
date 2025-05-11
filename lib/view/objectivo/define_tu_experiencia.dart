import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/goal_option.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/models/user_profile_data.dart';
import 'package:ogma_trainer/view/objectivo/define_tu_estado_fisico.dart';

class DefineTuExperiencia extends StatefulWidget {
  final UserProfileData profileData;
  const DefineTuExperiencia({super.key, required this.profileData});

  @override
  State<DefineTuExperiencia> createState() => _DefineTuExperienciaPageState();
}

class _DefineTuExperienciaPageState extends State<DefineTuExperiencia> {
  int? _selectedExperienceIndex;

  final List<String> _experienceValues = [
    "Principiante", 
    "Intermedio",   
    "Avanzado"     
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mi perfil',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            //barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.50, 
                minHeight: 8,
                backgroundColor: TColor.gray,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff55c1ff)),
              ),
            ),
            const SizedBox(height: 40),
            Text(
                  "¿Cual es tu experiencia?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
            Text(
                  "Es importante para nosotros conocer el timpo que llevas entrenando ",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TColor.gray, fontSize: 12),
                ),
            const SizedBox(height: 20),
            
            // Experience options
            GoalOption(
              title: 'Principiante',
              description: 'Menos de 6 meses de experiencia',
              isSelected: _selectedExperienceIndex == 0,
              onTap: () => setState(() => _selectedExperienceIndex = 0),
            ),
            const SizedBox(height: 15),
            
            GoalOption(
              title: 'Intermediario',
              description: 'Más de 6 meses y menos de 2 años.',
              isSelected: _selectedExperienceIndex == 1,
              onTap: () => setState(() => _selectedExperienceIndex = 1),
            ),
            const SizedBox(height: 15),
            
            GoalOption(
              title: 'Avanzado',
              description: 'Más de 2 años',
              isSelected: _selectedExperienceIndex == 2,
              onTap: () => setState(() => _selectedExperienceIndex = 2),
            ),
            
            const Spacer(),
            
            RoundButton(
              title: "Continuar",
              onPressed: () {
                if (_selectedExperienceIndex != null) {                  
                  widget.profileData.experienciaEntrenamiento = _experienceValues[_selectedExperienceIndex!];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DefineTuEstadoFisico(profileData: widget.profileData),
                    ),
                  );
                } else {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, selecciona tu experiencia.")),
                  );
                }
              }
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}