import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/config/app_config.dart';
import 'package:ogma_trainer/models/routine_model.dart';
import 'package:ogma_trainer/models/user_profile_data.dart';
import 'package:ogma_trainer/services/AIRoutineService.dart';
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:ogma_trainer/view/main_tab/main_tab_view.dart';

class GenerandoRutinaView extends StatefulWidget {
  final UserProfileData userProfileData;

  const GenerandoRutinaView({super.key, required this.userProfileData});

  @override
  State<GenerandoRutinaView> createState() => _GenerandoRutinaViewState();
}

class _GenerandoRutinaViewState extends State<GenerandoRutinaView>
    with TickerProviderStateMixin {
  final AIRoutineService _aiRoutineService = AIRoutineService();
  final StorageService _storageService = StorageService();

  final List<String> _loadingMessages = [
    "Estamos generando la rutina personalizada perfecta para ti...",
    "Consultando nuestro modelo de inteligencia artificial...",
    "Analizando tus objetivos y preferencias...",
    "Creando ejercicios adaptados a tu nivel...",
    "Ajustando los últimos detalles...",
    "Asignando la rutina..."
  ];
  int _currentMessageIndex = 0;
  String _displayMessage = "";
  Timer? _messageTimer;
  AnimationController? _fadeController;
  Animation<double>? _fadeAnimation;

  String? _apiError;
  bool _isProcessing = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _displayMessage = _loadingMessages[0];

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController!, curve: Curves.easeInOut);

    _startMessageAnimation();
    _initiateRoutineGenerationAndAssignment();
  }

  void _startMessageAnimation() {
    _fadeController?.forward(from: 0.0);
    _messageTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isProcessing) {
        timer.cancel();
        return;
      }
      if (mounted) {
        _fadeController?.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentMessageIndex =
                  (_currentMessageIndex + 1) % _loadingMessages.length;
              _displayMessage = _loadingMessages[_currentMessageIndex];
            });
            _fadeController?.forward(from: 0.0);
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _initiateRoutineGenerationAndAssignment() async {
    _currentUserId = await _storageService.getUserId(); // Obtener userId
    if (!mounted) return;

    if (_currentUserId == null) {
      setState(() {
        _isProcessing = false;
        _apiError =
            "Error: No se pudo identificar al usuario para asignar la rutina.";
      });
      _messageTimer?.cancel();
      _fadeController?.reverse();
      return;
    }

    
    Map<String, dynamic> generationResult;
    try {
      generationResult = await _aiRoutineService.generatePersonalizedRoutine(
        userProfileData: widget.userProfileData,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _apiError = "Error de conexión al generar rutina: ${e.toString()}";
      });
      _messageTimer?.cancel();
      _fadeController?.reverse();
      return;
    }

    if (!mounted) return;

    if (generationResult["success"] == true &&
        generationResult["data"] != null) {
      if (generationResult["data"] is Routine) {
        final Routine generatedRoutine = generationResult["data"] as Routine;
        final int? generatedRoutineId = generatedRoutine.idRutina;

        debugPrint("ID de rutina parseado: $generatedRoutineId");
        
        if (generatedRoutineId == null) {
          setState(() {
            _isProcessing = false;
            _apiError =
                "La generación de rutina fue exitosa pero no se recibió un ID de rutina válido.";
          });
          _messageTimer?.cancel();
          _fadeController?.reverse();
          return;
        }

       
        if (mounted) {
          _fadeController?.reverse().then((_) {
            if (mounted) {
              setState(() {
                _displayMessage = "Asignando la rutina a tu perfil...";
              });
              _fadeController?.forward(from: 0.0);
            }
          });
        }

       
        Map<String, dynamic> assignmentResult;
        try {
          assignmentResult = await _aiRoutineService.assignRoutineToUser(
            idUsuario: AppConfig.idEntrenadorAsignadorIa,
            idRutina: generatedRoutineId,            
          );
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _isProcessing = false;
            _apiError = "Error de conexión al asignar rutina: ${e.toString()}";
          });
          _messageTimer?.cancel();
          _fadeController?.reverse();
          return;
        }

        if (!mounted) return;
        setState(() => _isProcessing = false);
        _messageTimer?.cancel();

        if (assignmentResult["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(assignmentResult["message"] ??
                    "¡Rutina generada y asignada!"),
                backgroundColor: Colors.green),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainTabView()),
            (route) => false,
          );
        } else {
          setState(() {
            _apiError =
                assignmentResult["message"] ?? "No se pudo asignar la rutina.";
          });
          _fadeController?.reverse();
        }
      } else {        
        setState(() {
          _isProcessing = false;
          _apiError =
              "La respuesta de generación de rutina no tiene el formato esperado (campo 'data' no es un Routine).";
        });
        _messageTimer?.cancel();
        _fadeController?.reverse();
        return;
      }
    } else {
      setState(() {
        _isProcessing = false;
        _apiError =
            generationResult["message"] ?? "No se pudo generar la rutina.";
      });
      _messageTimer?.cancel();
      _fadeController?.reverse();
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: TColor.primaryG,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: media.width * 0.35,
                  height: media.width * 0.35,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8)),
                    backgroundColor: Colors.white.withOpacity(0.2),
                  ),
                ),
                const SizedBox(height: 40),
                if (_isProcessing) // Solo mostrar mensajes mientras se genera
                  FadeTransition(
                    opacity: _fadeAnimation!,
                    child: Text(
                      _displayMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TColor.white.withOpacity(0.9),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                  ),
                if (_apiError != null && !_isProcessing) ...[
                  const SizedBox(height: 20),
                  Text(
                    _apiError!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.orange[200], fontSize: 16),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reintentar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.white.withOpacity(0.2),
                      foregroundColor: TColor.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _apiError = null;
                        _isProcessing = true;
                        _currentMessageIndex = 0;
                        _displayMessage = _loadingMessages[0];
                      });
                      _startMessageAnimation();
                      _initiateRoutineGenerationAndAssignment();
                    },
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
