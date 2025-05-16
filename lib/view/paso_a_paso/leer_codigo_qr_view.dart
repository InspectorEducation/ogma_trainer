import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
// Quita la importación directa de EntrenamientoFlowView si ya no es la única acción
// import 'package:ogma_trainer/view/paso_a_paso/entrenamiento_flow_view.dart';

// Define un typedef para la función de callback de QR válido
typedef OnValidQRCallback = Future<void> Function(BuildContext context, Map<String, dynamic> qrData);
// Define un typedef para la lógica de validación personalizada
typedef QRValidationLogic = bool Function(Map<String, dynamic> qrData, String? expectedContent);


class LeerCodigoQRView extends StatefulWidget {
  final String? expectedContent; // El contenido esperado (ej. machineId, gymId_nombreGym)
  final String successMessage; // Mensaje a mostrar en SnackBar si la acción del callback es exitosa (opcional)
  final String processingMessage; // Mensaje mientras se procesa la acción del callback
  final OnValidQRCallback onValidQR; // Callback para ejecutar en QR válido
  final QRValidationLogic? customValidationLogic; // Lógica de validación personalizada opcional

  const LeerCodigoQRView({
    super.key,
    this.expectedContent,
    required this.onValidQR,
    this.customValidationLogic,
    this.successMessage = "Acción completada exitosamente.",
    this.processingMessage = "Procesando...",
  });

  @override
  State<LeerCodigoQRView> createState() => _LeerCodigoQRViewState();
}

class _LeerCodigoQRViewState extends State<LeerCodigoQRView> {
  bool _isScanning = true;
  bool _isProcessingAction = false; // Para mostrar un indicador mientras el callback se ejecuta
  MobileScannerController controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async { // Marcar como async
    if (!_isScanning || _isProcessingAction || capture.barcodes.isEmpty) return;

    final String? qrText = capture.barcodes.first.rawValue;
    if (qrText == null || qrText.isEmpty) {
      debugPrint("QR text is null or empty");
      return;
    }

    debugPrint("QR Detectado: $qrText");

    Map<String, dynamic> jsonData;
    try {
      jsonData = jsonDecode(qrText);
    } catch (e) {
      debugPrint("Error al decodificar JSON del QR: $e");
      _showErrorSnackBar("Formato de QR inválido.");
      return;
    }

    // Acceder a los campos del JSON. Asegúrate que las claves sean consistentes.
    // En tu ejemplo original, el QR de máquina usaba "name" y "description".
    // El QR del GYM podría usar "gymId", "Name", etc.
    // Haremos el parseo más genérico y dejaremos que el callback o la lógica de validación se encarguen.
    // String? nameFromQr = jsonData['Name'] as String? ?? jsonData['name'] as String?; // Intenta con ambas capitalizaciones
    // String? descriptionFromQr = jsonData['Description'] as String? ?? jsonData['description'] as String?;

    bool isValid;
    if (widget.customValidationLogic != null) {
      isValid = widget.customValidationLogic!(jsonData, widget.expectedContent);
    } else if (widget.expectedContent != null) {
      // Lógica de validación por defecto si no hay customValidationLogic pero sí expectedContent
      // Asumimos que el campo 'Name' (o 'name') del QR debe coincidir con expectedContent
      String? nameFieldFromQR = jsonData['Name'] as String? ?? jsonData['name'] as String?;
      isValid = (nameFieldFromQR == widget.expectedContent);
    } else {
      // Si no hay expectedContent ni customValidationLogic, asumimos que cualquier QR bien formado es "válido"
      // y el callback `onValidQR` se encargará de la lógica específica.
      isValid = true;
    }


    if (isValid) {
      setState(() {
        _isScanning = false; // Detener lógicamente el escaneo para procesar la acción
        _isProcessingAction = true; // Indicar que estamos procesando
      });
      controller.stop(); // Detener físicamente el scanner

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.processingMessage)),
        );
      }

      // Ejecutar la acción definida por el llamador
      try {
        await widget.onValidQR(context, jsonData);
        // Si onValidQR maneja su propia navegación, no necesitamos hacer nada más aquí.
        // Si onValidQR es exitoso y no navega, podemos mostrar un mensaje de éxito y reanudar o cerrar.
        // Por ahora, asumimos que onValidQR se encarga de la navegación o de cerrar esta vista.
        // Si la vista sigue montada después del callback, es que no hubo navegación de reemplazo.
        if (mounted && _isProcessingAction) { // Si _isProcessingAction es false, el callback ya manejó el estado
           ScaffoldMessenger.of(context).removeCurrentSnackBar(); // Quitar el de "Procesando"
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.successMessage), backgroundColor: Colors.green),
          );          
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _isScanning = true;
                _isProcessingAction = false;
              });
              controller.start();
            }
          });
        }
      } catch (e) {
         debugPrint("Error durante onValidQR callback: $e");
         if (mounted) {
          _showErrorSnackBar("Ocurrió un error al procesar el QR: ${e.toString()}");
          _resumeScanningAfterError();
         }
      } finally {
        // Asegurarse de que _isProcessingAction se resetee si la vista sigue activa y no se navegó.
        if (mounted && _isProcessingAction) {
           setState(() { _isProcessingAction = false; });
        }
      }

    } else {
      String errorMessage = "Código QR no válido para este contexto.";
      // Podrías intentar obtener un campo 'Name' para dar un mensaje más específico
      String? nameFieldFromQR = jsonData['Name'] as String? ?? jsonData['name'] as String?;
      if (nameFieldFromQR == null && widget.expectedContent != null) {
        errorMessage = "El QR no contiene la información esperada.";
      } else if (nameFieldFromQR != null && widget.expectedContent != null && nameFieldFromQR != widget.expectedContent) {
        errorMessage = "Este QR ('$nameFieldFromQR') no es el esperado ('${widget.expectedContent}').";
      }
      _showErrorSnackBar(errorMessage);
      _resumeScanningAfterError();
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _resumeScanningAfterError() {
    // Reanudar el escaneo después de un breve retraso si no estamos ya procesando otra acción
    if (mounted && _isScanning && !_isProcessingAction) {
      // Detener explícitamente por si acaso antes de reanudar con delay
      controller.stop();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isScanning && !_isProcessingAction) { // Volver a verificar estado
          controller.start();
          debugPrint("Scanner reanudado después de error.");
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Escanear Código QR"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 1),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    "Escanea el Código QR", // Título más genérico
                    style: TextStyle(
                      color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  width: 250, height: 250,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: CustomPaint(painter: DashedBorderPainter(cornerRadius: 12.0)),
                ),
                const SizedBox(height: 32),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    "Alinea el código QR dentro del recuadro para escanearlo.",
                    style: TextStyle(
                      color: Colors.white70, fontSize: 16,
                      shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_isProcessingAction) // Mostrar indicador de carga si se está procesando
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// DashedBorderPainter permanece igual (asegúrate que esté definido o importado)
class DashedBorderPainter extends CustomPainter {
  final double cornerRadius;
  final double strokeWidth;
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    this.cornerRadius = 12.0,
    this.strokeWidth = 2.5,
    this.color = Colors.white,
    this.dashWidth = 20.0,
    this.dashSpace = 10.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final Rect rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2, size.width - strokeWidth, size.height - strokeWidth);
    final RRect rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: Radius.circular(cornerRadius - strokeWidth / 2 > 0 ? cornerRadius - strokeWidth / 2 : 0),
      topRight: Radius.circular(cornerRadius - strokeWidth / 2 > 0 ? cornerRadius - strokeWidth / 2 : 0),
      bottomLeft: Radius.circular(cornerRadius - strokeWidth / 2 > 0 ? cornerRadius - strokeWidth / 2 : 0),
      bottomRight: Radius.circular(cornerRadius - strokeWidth / 2 > 0 ? cornerRadius - strokeWidth / 2 : 0),
    );
    final Path path = Path()..addRRect(rrect);
    final ui.PathMetrics pathMetrics = path.computeMetrics();
    for (final ui.PathMetric metric in pathMetrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, math.min(distance + dashWidth, metric.length)), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }
  @override
  bool shouldRepaint(covariant DashedBorderPainter oldDelegate) => oldDelegate.cornerRadius != cornerRadius || oldDelegate.strokeWidth != strokeWidth || oldDelegate.color != color || oldDelegate.dashWidth != dashWidth || oldDelegate.dashSpace != dashSpace;
}