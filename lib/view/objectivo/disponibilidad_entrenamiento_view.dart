import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/models/user_profile_data.dart';
import 'package:ogma_trainer/services/auth_service.dart'; // Para la llamada API
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:ogma_trainer/view/main_tab/main_tab_view.dart'; // Para obtener userId



class DisponibilidadEntrenamientoView extends StatefulWidget {
  final UserProfileData profileData;
  const DisponibilidadEntrenamientoView({super.key, required this.profileData});

  @override
  State<DisponibilidadEntrenamientoView> createState() => _DisponibilidadEntrenamientoViewState();
}

class _DisponibilidadEntrenamientoViewState extends State<DisponibilidadEntrenamientoView> {
  final AuthService _authService = AuthService(); // Asumiendo que tendrás un método para esto
  final StorageService _storageService = StorageService(); // Para obtener el userId

  // Estado para esta vista
  final List<String> _diasSemana = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"];
  final List<String> _diasSeleccionados = [];
  TimeOfDay? _horaInicioSeleccionada;
  TimeOfDay? _horaFinSeleccionada;
  String? _lugarSeleccionado; // "Gimnasio", "Casa", "Ambos"
  final List<String> _lugaresEntrenamiento = ["Gimnasio", "Casa", "Ambos"];

  bool _isLoading = false;

  Future<void> _seleccionarHora(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _horaInicioSeleccionada = picked;
        } else {
          _horaFinSeleccionada = picked;
        }
      });
    }
  }

  Future<void> _submitPersonalInformation() async {
    // Validaciones básicas
    if (_diasSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecciona al menos un día.")));
      return;
    }
    if (_horaInicioSeleccionada == null || _horaFinSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecciona un rango de horas.")));
      return;
    }
    if (_horaInicioSeleccionada!.hour > _horaFinSeleccionada!.hour ||
        (_horaInicioSeleccionada!.hour == _horaFinSeleccionada!.hour && _horaInicioSeleccionada!.minute >= _horaFinSeleccionada!.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("La hora de fin debe ser posterior a la hora de inicio.")));
      return;
    }
    if (_lugarSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Selecciona un lugar de entrenamiento.")));
      return;
    }

    setState(() { _isLoading = true; });

    // Actualizar profileData
    widget.profileData.diasDisponibles = _diasSeleccionados;
    widget.profileData.horaInicioDisponible = _horaInicioSeleccionada!.format(context); // Formato HH:mm
    widget.profileData.horaFinDisponible = _horaFinSeleccionada!.format(context);
    widget.profileData.preferenciaLugarEntrenamiento = _lugarSeleccionado;

    String? userId = await _storageService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: ID de usuario no encontrado.")));
      setState(() { _isLoading = false; });
      return;
    }
    
    final result = await _authService.updateUserPersonalInformation(
        userId: userId,
        data: widget.profileData,
    );

    setState(() { _isLoading = false; });

    if (mounted) {
      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Información de perfil guardada exitosamente!"), backgroundColor: Colors.green),
        );        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainTabView()), // O tu pantalla de bienvenida/dashboard
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result["message"] ?? "Error al guardar la información."), backgroundColor: Colors.red),
        );
      }
    }
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
        title: const Text('Disponibilidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
             ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 1.0, // Último paso
                  minHeight: 8,
                  backgroundColor: TColor.lightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(TColor.secondaryColor1),
                ),
              ),
            const SizedBox(height: 30),
            Text('¿Cuándo y dónde prefieres entrenar?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TColor.black), textAlign: TextAlign.center),
            const SizedBox(height: 30),

            // Selección de Días
            Text('Días disponibles:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: TColor.black)),
            Wrap(
              spacing: 8.0,
              children: _diasSemana.map((dia) {
                bool isSelected = _diasSeleccionados.contains(dia);
                return ChoiceChip(
                  label: Text(dia),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _diasSeleccionados.add(dia);
                      } else {
                        _diasSeleccionados.remove(dia);
                      }
                    });
                  },
                  selectedColor: TColor.primaryColor1.withOpacity(0.7),
                  backgroundColor: TColor.lightGray,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : TColor.gray),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Selección de Horas
            Text('Rango de horas:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: TColor.black)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () => _seleccionarHora(context, true),
                  style: ElevatedButton.styleFrom(backgroundColor: TColor.secondaryColor1),
                  child: Text(_horaInicioSeleccionada == null ? 'Hora Inicio' : _horaInicioSeleccionada!.format(context), style: const TextStyle(color: Colors.white)),
                ),
                const Text("a"),
                ElevatedButton(
                   onPressed: () => _seleccionarHora(context, false),
                   style: ElevatedButton.styleFrom(backgroundColor: TColor.secondaryColor1),
                   child: Text(_horaFinSeleccionada == null ? 'Hora Fin' : _horaFinSeleccionada!.format(context), style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Lugar de Entrenamiento
            Text('Lugar preferido:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: TColor.black)),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: TColor.lightGray,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              ),
              value: _lugarSeleccionado,
              hint: Text('Selecciona un lugar', style: TextStyle(color: TColor.gray)),
              isExpanded: true,
              items: _lugaresEntrenamiento.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _lugarSeleccionado = newValue;
                });
              },
              validator: (value) => value == null ? 'Selecciona un lugar.' : null,
            ),
            SizedBox(height: media.height * 0.1),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              RoundButton(
                title: 'Finalizar y Guardar Perfil',
                onPressed: _submitPersonalInformation,
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}