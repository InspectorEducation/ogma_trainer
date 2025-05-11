import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/goal_option.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/models/user_profile_data.dart';
import 'package:ogma_trainer/view/objectivo/define_tu_experiencia.dart';

class DefineTuMetaPage extends StatefulWidget {
  final UserProfileData profileData;
  const DefineTuMetaPage({super.key, required this.profileData});

  @override
  State<DefineTuMetaPage> createState() => _DefineTuMetaPageState();
}

class _DefineTuMetaPageState extends State<DefineTuMetaPage> {
  int? _selectedGoalIndex;

   final List<String> _goalValues = [
    "Definición muscular",
    "Hipertrofia",
    "Perder peso",
    "Mejorar la flexibilidad"
  ];

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mi perfil',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.25,
                minHeight: 8,
                backgroundColor: TColor.gray,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff55c1ff)),               
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              '¿Cuál es tu objetivo?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Goal options
            GoalOption(
              title: 'Definición muscular',
              description: 'Define tu cuerpo',
              isSelected: _selectedGoalIndex == 0,
              onTap: () => setState(() => _selectedGoalIndex = 0),
            ),
            const SizedBox(height: 15),
            
            GoalOption(
              title: 'Hipertrofia',
              description: 'Gana mas musculo',
              isSelected: _selectedGoalIndex == 1,
              onTap: () => setState(() => _selectedGoalIndex = 1),
            ),
            const SizedBox(height: 15),
            
            GoalOption(
              title: 'Perder peso',
              description: 'Perder grasa corporal',
              isSelected: _selectedGoalIndex == 2,
              onTap: () => setState(() => _selectedGoalIndex = 2),
            ),
            const SizedBox(height: 15),

             GoalOption(
              title: 'Mejorar la flexibilidad',
              description: 'Perder grasa corporal',
              isSelected: _selectedGoalIndex == 3,
              onTap: () => setState(() => _selectedGoalIndex = 3),
            ),
            
            const Spacer(),                   
            RoundButton(title: "Continuar", onPressed: () {
               if (_selectedGoalIndex != null) {                  
                  widget.profileData.objetivoPrincipal = _goalValues[_selectedGoalIndex!];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DefineTuExperiencia(profileData: widget.profileData), // Pasa los datos actualizados
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Por favor, selecciona un objetivo.")),
                  );
                }
              }),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
