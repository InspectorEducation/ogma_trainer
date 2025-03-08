import 'package:flutter/material.dart';
import 'package:ogma_trainer/common_widget/goal_option.dart';

class DefineTuMetaPage extends StatefulWidget {
  const DefineTuMetaPage({super.key});

  @override
  State<DefineTuMetaPage> createState() => _DefineTuMetaPageState();
}

class _DefineTuMetaPageState extends State<DefineTuMetaPage> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    String? selectedGoal;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: 0.2,
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
            SizedBox(height: 20),
            Text(
              "¿Cuál es tu objetivo?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GoalOption(
              title: "Hipertrofia",
              subtitle: "Ganar masa muscular y músculos voluminosos",
              isSelected: selectedGoal == "Hipertrofia",
              onTap: () {
                setState(() {
                  selectedGoal = "Hipertrofia";
                });
              },
            ),
            GoalOption(
              title: "Definición muscular",
              subtitle: "Músculos más fuertes, más rígidos y más visibles",
              isSelected: selectedGoal == "Definición muscular",
              onTap: () {
                setState(() {
                  selectedGoal = "Definición muscular";
                });
              },
            ),
            GoalOption(
              title: "Perder peso",
              subtitle: "Perder grasa corporal",
              isSelected: selectedGoal == "Perder peso",
              onTap: () {
                setState(() {
                  selectedGoal = "Perder peso";
                });
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: selectedGoal != null ? () {} : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                disabledBackgroundColor: Colors.grey[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text("Continuar", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
