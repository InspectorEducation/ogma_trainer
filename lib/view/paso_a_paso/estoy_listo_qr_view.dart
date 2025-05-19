import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/gradient_icon_button.dart';
import 'package:ogma_trainer/models/booking_model.dart';
import 'package:ogma_trainer/models/machine_model.dart';
import 'package:ogma_trainer/services/equipment_service.dart';
import 'package:ogma_trainer/view/paso_a_paso/entrenamiento_flow_view.dart';
import 'package:ogma_trainer/view/paso_a_paso/leer_codigo_qr_view.dart';

class EstoyListoQRView extends StatefulWidget {
  final Booking booking;
  

  const EstoyListoQRView({
    super.key,
    required this.booking,    
  });

  @override
  State<EstoyListoQRView> createState() => _EstoyListoQRViewState();
}

class _EstoyListoQRViewState extends State<EstoyListoQRView> {

  final EquipmentService _equipmentService = EquipmentService();
  Machine? _machineDetails;
  bool _isLoadingMachine = true;
  String? _machineLoadError;

  Timer? _countdownTimer;
  Duration _timeRemaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _loadMachineDetails();
    _startCountdown();
  }

  Future<void> _loadMachineDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoadingMachine = true;
      _machineLoadError = null;
    });
    try {    
      final details = await _equipmentService.getMachineDetails(widget.booking.itemId);
      if (mounted) {
        setState(() {
          _machineDetails = details;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _machineLoadError = "No se pudo cargar la imagen de la máquina.";
        });
      }
      debugPrint("Error cargando detalles de máquina: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMachine = false;
        });
      }
    }
  }

  void _startCountdown() {
    final now = DateTime.now();    
    final reservaStartTimeLocal = widget.booking.startTime.toLocal();

    if (reservaStartTimeLocal.isAfter(now)) {
      _timeRemaining = reservaStartTimeLocal.difference(now);
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        final currentNow = DateTime.now();
        if (reservaStartTimeLocal.isAfter(currentNow)) {
          setState(() {
            _timeRemaining = reservaStartTimeLocal.difference(currentNow);
          });
        } else {
          setState(() {
            _timeRemaining = Duration.zero;
          });
          timer.cancel();
          //Habilitar el botón de escanear automáticamente o mostrar un mensaje
        }
      });
    } else {      
      _timeRemaining = Duration.zero;
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative || duration.inSeconds == 0) {
      return "¡Ahora!";
    }
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
    } else if (duration.inMinutes > 0) {
      return "${twoDigitMinutes}m ${twoDigitSeconds}s";
    } else {
      return "${twoDigitSeconds}s";
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("¿Dónde encontrar la máquina?"),
        content: const Text(
          "Busca la máquina en la zona asignada.\n"
          "Cada máquina tiene un código QR visible en la parte frontal o lateral. "
          "Consulta con un entrenador si necesitas ayuda.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    final String displayName = _machineDetails?.nombre ?? widget.booking.itemName;
    final String? displayImageUrl = _machineDetails?.urlImagen;
    final DateTime reservaStartTimeLocal = widget.booking.startTime.toLocal();
    bool canScan = _timeRemaining.inSeconds <= 0;
    int idReserva = widget.booking.reservationId;

    return Scaffold(
      backgroundColor: TColor.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/img/background_qr.png",
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Ubícate en la máquina y escanea el código QR para comenzar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    displayName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 1, color: Colors.black54)]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Fecha y Hora de la Reserva
                  Text(
                    "Reservado para: ${DateFormat('dd MMM, HH:mm').format(reservaStartTimeLocal)}",
                    style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9), shadows: const [Shadow(blurRadius: 1, color: Colors.black38)]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  // Imagen de la Máquina
                  Container(
                    height: 180, // Tamaño ajustado
                    width: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: TColor.lightGray.withOpacity(0.3), // Fondo si la imagen tarda o no hay
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 2)
                    ),
                    child: ClipOval(
                      child: _isLoadingMachine
                          ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,))
                          : displayImageUrl != null && displayImageUrl.isNotEmpty
                              ? Image.network(
                                  displayImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c,e,s) => _buildMachineFallbackIcon(),
                                  loadingBuilder: (c, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)),
                                )
                              : _machineLoadError != null
                                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, color: Colors.orange[200], size: 40), SizedBox(height:5), Text("Error imagen", style: TextStyle(color: Colors.orange[100], fontSize: 10))]))
                                  : _buildMachineFallbackIcon(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Contador Regresivo
                  Text(
                    "Comienza en:",
                    style: TextStyle(fontSize: 14, color: TColor.black.withOpacity(0.8), shadows: const [Shadow(blurRadius: 1, color: Colors.black38)]),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _formatDuration(_timeRemaining),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, shadows: [Shadow(blurRadius: 2, color: Colors.black54)]),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _showHelpDialog(context),
                    child: const Text(
                      "¿No encuentras la máquina?",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: media.width * 0.1),
                  const Text(
                    "¡Ya estoy listo!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GradientIconButton(
                    label: canScan ? "Escanear QR para Iniciar" : "Espera el Inicio",
                    icon: Icons.qr_code_scanner,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LeerCodigoQRView(
                            expectedContent: _machineDetails?.idMaquina.toString() ?? widget.booking.itemId.toString(),
                            processingMessage: "Validando máquina...",
                            successMessage:
                                "Máquina validada. Iniciando entrenamiento.",
                            onValidQR: (ctx, qrData) async {                             
                              Navigator.pushReplacement(
                                ctx,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EntrenamientoFlowView(idReservaMaquina: idReserva,),
                                ),
                              );                              
                            },                            
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineFallbackIcon(){
    return Icon(Icons.fitness_center, size: 80, color: Colors.white.withOpacity(0.6));
  }
}
