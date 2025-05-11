import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ogma_trainer/view/paso_a_paso/entrenamiento_flow_view.dart';

class LeerCodigoQRView extends StatefulWidget {
  final String expectedMachineId;
  const LeerCodigoQRView({super.key, required this.expectedMachineId});

  @override
  State<LeerCodigoQRView> createState() => _LeerCodigoQRViewState();
}

class _LeerCodigoQRViewState extends State<LeerCodigoQRView> {
  bool _isScanning = true;
  MobileScannerController controller = MobileScannerController();

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || capture.barcodes.isEmpty) return;

    final qrText = capture.barcodes.first.rawValue;
    if (qrText == null) {
      debugPrint("QR text is null");
      return;
    }

    debugPrint("QR Dectectado: $qrText");

    Map<String, dynamic> jsonData;

    try {
      jsonData = jsonDecode(qrText);
    } catch (e) {
      debugPrint("Error al decodificar JSON del QR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Formato de QR inválido.")),
        );
      }
      return; // Detener si el JSON no es válido
    }

    final String? qrId = jsonData['QrId'] as String?;
    final String? machineNameFromQR = jsonData['Name'] as String?; // Este es el que compararemos con expectedMachineId
    final String? qrDescription = jsonData['Description'] as String?; // Este es el que esperamos sea 'free'

    debugPrint("Datos JSON parseados: QrId=$qrId, Name=$machineNameFromQR, Description=$qrDescription");
    debugPrint("Máquina esperada (expectedMachineId): ${widget.expectedMachineId}");

    if (machineNameFromQR  == widget.expectedMachineId) {
      setState(() => _isScanning = false);
      controller.stop();
      debugPrint("QR Válido y máquina libre. Navegando...");
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const EntrenamientoFlowView(),
          ),
        );
      }
    } else {
      if (_isScanning && mounted) {
        String errorMessage = "Código QR no válido.";
         if (machineNameFromQR == null) {
          errorMessage = "QR no contiene un nombre de máquina.";
        } else if (machineNameFromQR != widget.expectedMachineId) {
          errorMessage = "Este QR no pertenece a la máquina esperada.";
        } else if (qrDescription?.toLowerCase() != 'free') {
          errorMessage = "La máquina está ocupada o el QR no indica disponibilidad (Descripción: ${qrDescription ?? 'N/A'}).";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );       
        Future.delayed(const Duration(seconds: 2), () {
           if (mounted && _isScanning) { // Verifica de nuevo por si acaso
              controller.start(); // Si lo detuviste antes
           }
         });
      }
    }
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // Añadido para poder volver si es necesario
        title: const Text("Escanear QR"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true, // Para que el AppBar no oculte el scanner
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Cámara abierta
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // Capa de guía de UI
          SafeArea(            
            child: Column(
              children: [                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    "Escanea el Qr sobre la máquina",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                //const SizedBox(height: 32),
                // Recuadro de escaneo con bordes entrecortados
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.white,
                      style: BorderStyle.solid,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: DashedBorderPainter(),
                  ),
                ),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    "Alinea el código QR dentro del recuadro para escanearlo.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 10.0;
    const dashSpace = 5.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
