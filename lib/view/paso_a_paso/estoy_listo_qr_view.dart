import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/gradient_icon_button.dart';
import 'package:ogma_trainer/view/paso_a_paso/leer_codigo_qr_view.dart';

class EstoyListoQRView extends StatelessWidget {
  final String machineName;
  final String machineImageAsset;

  const EstoyListoQRView({
    super.key,
    required this.machineName,
    required this.machineImageAsset,
  });

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
                    "Ubícate en la máquina y/o equipo y escanea el código QR",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    machineName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipOval(
                    child: Image.asset(
                      machineImageAsset,
                      height: 200,
                      width: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                  SizedBox(height: media.width * 0.3),
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
                    label: "Escanear QR",
                    icon: Icons.qr_code_scanner,
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LeerCodigoQRView(expectedMachineId: '1',),
                          ));
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
}
