import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/rest_timer_buttons.dart';
import 'package:ogma_trainer/common_widget/start_exercise_control.dart';
import 'package:ogma_trainer/models/exercise_detail_model.dart';
import 'package:ogma_trainer/models/routine_model.dart';
import 'package:ogma_trainer/services/booking_service.dart';
import 'package:ogma_trainer/services/exercise_service.dart';
import 'package:ogma_trainer/view/seguimiento_entrenamiento/calendario_entrenamiento_view.dart'; 
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';


class EntrenamientoFlowView extends StatefulWidget {
  final int idReservaMaquina;
  final String? ejercicioImagenUrl;

  const EntrenamientoFlowView({
    super.key,
    required this.idReservaMaquina,
    this.ejercicioImagenUrl,
  });

  @override
  State<EntrenamientoFlowView> createState() => _EntrenamientoFlowViewState();
}

class _EntrenamientoFlowViewState extends State<EntrenamientoFlowView> with TickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  final ExerciseService _exerciseService = ExerciseService();
  
  RoutineExerciseDetail? _bookedExerciseData; 
  ExerciseDetail? _fullExerciseDetails;
  
  bool _isLoading = true;
  String? _errorMessage;

  int _currentSerie = 1;
  bool _isResting = false;
  bool _isPaused = false;
  Timer? _restTimer;
  Duration _remainingRestTime = Duration.zero;

  // Temporizador para la duración total de la reserva
  static const int _totalReservationMinutes = 20;
  Timer? _workoutSessionTimer;
  Duration _elapsedWorkoutTime = Duration.zero;
  late AnimationController _progressController;


  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: _totalReservationMinutes),
    )..addListener(() {        
        if (mounted) setState(() {});
      });

    _loadAllExerciseData();
    _startWorkoutSessionTimer();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: _totalReservationMinutes),
    )..addListener(() {
        if (mounted) setState(() {});
      });
  }

   Future<void> _loadAllExerciseData() async {
    setState(() => _isLoading = true);
    try {
     
      final bookedData = await _bookingService.getBookedExerciseDetails(widget.idReservaMaquina);
      if (!mounted) return;
      setState(() {
        _bookedExerciseData = bookedData;
        // Preparar tiempo de descanso si ya tenemos los datos
        if (_bookedExerciseData != null) {
           _remainingRestTime = Duration(seconds: _bookedExerciseData!.descansoSegundos);
        }
      });

      
      if (_bookedExerciseData != null && _bookedExerciseData!.idEjercicio > 0) {
        final fullDetails = await _exerciseService.getExerciseDetails(_bookedExerciseData!.idEjercicio);
        if (mounted) {
          setState(() {
            _fullExerciseDetails = fullDetails;
          });
        }
      } else if (_bookedExerciseData == null) {
        throw Exception("No se pudieron obtener los datos básicos del ejercicio de la reserva.");
      }      

    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Error al cargar datos: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _startWorkoutSessionTimer() {
    _progressController.forward();
    _workoutSessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        _progressController.stop();
        return;
      }
      setState(() {
        _elapsedWorkoutTime += const Duration(seconds: 1);
      });
      if (_elapsedWorkoutTime.inMinutes >= _totalReservationMinutes) {
        timer.cancel();
        _progressController.stop();
        //Mostrar un mensaje de que el tiempo de reserva ha terminado
        _showTimeUpDialog();
      }
    });
  }

  int get _totalSeries {
    if (_bookedExerciseData  == null) return 1;
    return int.tryParse(_bookedExerciseData !.series) ?? 1;
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    if (_bookedExerciseData == null) return;
    _remainingRestTime = Duration(seconds: _bookedExerciseData!.descansoSegundos);
    _isPaused = false;

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isPaused) return;

      if (_remainingRestTime.inSeconds > 0) {
        setState(() {
          _remainingRestTime -= const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        _finishRest();
      }
    });
  }

  void _completeSerie() {
    if (_currentSerie < _totalSeries) {
      setState(() {
        _isResting = true;
      });
      _startRestTimer();
    } else {      
      _showCompletionDialog();
    }
  }

  void _finishRest() {
    _restTimer?.cancel();
    setState(() {
      _isResting = false;
      _currentSerie++;      
    });
  }

  void _addRestTime() {
    if (!_isResting) return;
    setState(() {
      _remainingRestTime += const Duration(seconds: 20);
    });
  }

  void _togglePauseRestTimer() {
    if (!_isResting) return;
    setState(() {
      _isPaused = !_isPaused;
    });
  }

  void _showCompletionDialog() {
    _workoutSessionTimer?.cancel();
    _progressController.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¡Felicidades! 🎉"),
          content: Text("Has completado todas las series de ${_bookedExerciseData?.ejercicioNombre ?? 'este ejercicio'}.\n¡Buen trabajo! Revisa tu calendario para tu próxima reserva."),
          actions: <Widget>[
            TextButton(
              child: const Text("Ver Calendario"),
              onPressed: () {
                Navigator.of(context).pop(); 
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const CalendarioEntrenamientoView()),
                );
              },
            ),
          ],
        );
      },
    );
  }

   void _showTimeUpDialog() {    
    if (!(_currentSerie > _totalSeries)) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
                return AlertDialog(
                title: const Text("¡Tiempo Terminado!"),
                content: const Text("El tiempo asignado para tu reserva de máquina ha finalizado."),
                actions: <Widget>[
                    TextButton(
                    child: const Text("Entendido"),
                    onPressed: () {
                        Navigator.of(context).pop();                         
                        Navigator.of(context).pushReplacement(
                           MaterialPageRoute(builder: (context) => const CalendarioEntrenamientoView()),
                        );
                    },
                    ),
                ],
                );
            },
        );
    }
  }


  @override
  void dispose() {
    _restTimer?.cancel();
    _workoutSessionTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: const Text("Cargando Ejercicio...")), body: const Center(child: CircularProgressIndicator()));
    }
    if (_errorMessage != null) {
      return Scaffold(appBar: AppBar(title: const Text("Error")), body: Center(child: Text(_errorMessage!)));
    }
    if (_bookedExerciseData == null) {
      return Scaffold(appBar: AppBar(title: const Text("Ejercicio no Encontrado")), body: const Center(child: Text("No se pudo cargar la información del ejercicio.")));
    }

    // --- Barra de Progreso para la Sesión Completa ---
    double progressRatio = _elapsedWorkoutTime.inSeconds / (_totalReservationMinutes * 60);
    if (progressRatio > 1.0) progressRatio = 1.0;
    if (progressRatio < 0.0) progressRatio = 0.0;

    if (_isLoading) {
      return Scaffold(appBar: AppBar(title: const Text("Cargando Entrenamiento...")), body: const Center(child: CircularProgressIndicator()));
    }
    if (_errorMessage != null) {
      return Scaffold(appBar: AppBar(title: const Text("Error")), body: Center(child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
      )));
    }
    
    if (_bookedExerciseData == null) {
      return Scaffold(appBar: AppBar(title: const Text("Entrenamiento no Disponible")), body: const Center(child: Text("No se pudo cargar la información del ejercicio de esta reserva.")));
    }

    final String ejercicioNombreDisplay = _fullExerciseDetails?.nombre ?? _bookedExerciseData!.ejercicioNombre;
    final String? gifUrl = _fullExerciseDetails?.urlVideoDemostracion;

    return Scaffold(
      backgroundColor: _isResting ? TColor.primaryColor1.withOpacity(0.9) : TColor.white,
      body: SafeArea(
        child: Column(
          children: [            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text("Tiempo de Reserva", style: TextStyle(color: _isResting ? TColor.white : TColor.gray, fontSize: 12)),
                       Text(
                        "${(_totalReservationMinutes - _elapsedWorkoutTime.inMinutes).toString().padLeft(2,'0')}:${(60 - _elapsedWorkoutTime.inSeconds % 60).toString().padLeft(2,'0')} restantes",
                        style: TextStyle(color: _isResting ? TColor.white : TColor.gray, fontSize: 12, fontWeight: FontWeight.bold)
                       ),
                     ],
                   ),
                   const SizedBox(height: 5),
                   SimpleAnimationProgressBar(
                    height: 12,
                    width: media.width - 40,
                    backgroundColor: Colors.grey.shade300,
                    foregrondColor: Colors.lightBlue,
                    ratio: progressRatio,
                    direction: Axis.horizontal,
                    curve: Curves.linear,
                    duration: const Duration(seconds: 1),
                    borderRadius: BorderRadius.circular(6),
                    gradientColor: LinearGradient(colors: TColor.primaryG),
                  ),
                ],
              ),
            ),
            // --- CONTENIDO (EJERCICIO O DESCANSO) ---
            Expanded(
              child: _isResting
                  ? _buildRestView(media, ejercicioNombreDisplay) // Pasar nombre para "Siguiente:"
                  : _buildExerciseView(media, ejercicioNombreDisplay, gifUrl),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseView(Size media, String ejercicioNombre, String? gifUrl) { // Recibe gifUrl
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex:1),
          Text(
            ejercicioNombre, // Usar el nombre que ya tenemos
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: TColor.black),
          ),
          const SizedBox(height: 10),
          Text(
            "Serie $_currentSerie de $_totalSeries",
            style: TextStyle(fontSize: 18, color: TColor.gray, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text("Indicaciones: ${_bookedExerciseData!.notasEjercicio}", style: TextStyle(color: TColor.black, )),
          const Spacer(flex:1),
          // --- IMAGEN/GIF DEL EJERCICIO ---
          Container(
            height: media.height * 0.35,
            width: media.width * 0.8,
            decoration: BoxDecoration(
              color: TColor.lightGray,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: (gifUrl != null && gifUrl.isNotEmpty) // Usar el gifUrl cargado
                  ? Image.network(
                      gifUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                        ));
                      },
                      errorBuilder: (c,e,s) => Icon(Icons.broken_image_outlined, size: 60, color: TColor.gray.withOpacity(0.7)),
                    )
                  : Center(child: Icon(Icons.fitness_center, size: 80, color: TColor.gray.withOpacity(0.5))), // Fallback
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "x${_bookedExerciseData!.repeticiones}", // De _bookedExerciseData
            style: TextStyle(fontSize: 30, color: TColor.secondaryColor1, fontWeight: FontWeight.w700),
          ),
          Text("REPETICIONES"),
          const Spacer(flex:2),
          RoundButton(
            title: "Serie Completada ($_currentSerie/$_totalSeries)",
            onPressed: _completeSerie,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildRestView(Size media, String proximoEjercicioNombre) {
    return Container( 
        decoration: BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG, begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Text(
              "¡Descanso!",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: TColor.white),
            ),
            const SizedBox(height: 10),
            Text(
              _formatDuration(_remainingRestTime),
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold, color: TColor.white),
            ),
            const SizedBox(height: 5),
            if (_isPaused)
                Text("PAUSADO", style: TextStyle(fontSize: 14, color: Colors.yellow[300], fontWeight: FontWeight.bold)),

            const Spacer(flex: 1),
            // --- Iconos de control de descanso ---
             Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    IconButton(
                        icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause, color: TColor.white, size: 40),
                        onPressed: _togglePauseRestTimer,
                    ),
                    TextButton(
                        onPressed: _addRestTime,
                        child: Text("+20s", style: TextStyle(color: TColor.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    TextButton(
                        onPressed: _finishRest, // Saltar Descanso
                        child: Text("Saltar", style: TextStyle(color: TColor.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    )
                ],
            ),

            const Spacer(flex: 2),
             if (_currentSerie < _totalSeries)
                Text(
                "Siguiente: $proximoEjercicioNombre - Serie ${_currentSerie + 1}", // Usar el nombre pasado
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: TColor.white.withOpacity(0.8)),
                )
             else
                Text(
                "¡Última serie completada!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: TColor.white.withOpacity(0.8)),
                ),
            const SizedBox(height: 30),
          ],
        ),
    );
  }


  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}