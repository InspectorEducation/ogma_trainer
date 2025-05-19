import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/models/clase_info_model.dart';
import 'package:ogma_trainer/services/booking_service.dart'; // Asumiremos que aquí está el servicio de inscripción
import 'package:ogma_trainer/services/storage_service.dart';

class DetalleClaseView extends StatefulWidget {
  final ClaseInfo claseInfo; // Recibe el objeto ClaseInfo

  const DetalleClaseView({super.key, required this.claseInfo});

  @override
  State<DetalleClaseView> createState() => _DetalleClaseViewState();
}

class _DetalleClaseViewState extends State<DetalleClaseView> {
  final BookingService _bookingService = BookingService(); // O un ClassBookingService dedicado
  final StorageService _storageService = StorageService();

  bool _isRegistering = false;
  String? _statusMessage;
  String? _currentUserId;
  bool _lastBookingWasSuccessful = false; 

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _currentUserId = await _storageService.getUserId();
     if (!mounted) return;
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Usuario no identificado."), backgroundColor: Colors.red));
    }
  }

  Future<void> _registerForClass() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inicia sesión para inscribirte."), backgroundColor: Colors.orange));
      return;
    }
    if (!widget.claseInfo.activa) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Esta clase ya no está activa."), backgroundColor: Colors.orange));
      return;
    }

    setState(() {
      _isRegistering = true;
      _statusMessage = "Inscribiendo...";
    });

    try {     
      final result = await _bookingService.registerForClass(
        classId: widget.claseInfo.idClase,
        userId: int.parse(_currentUserId!),
      );

       if (mounted) {
        if (result["success"] == true) {
          setState(() {
            _statusMessage = result["message"] ?? "¡Inscripción exitosa!";
          });
          _lastBookingWasSuccessful = true;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_statusMessage!), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
          setState(() {
            _statusMessage = result["message"] ?? "Error al inscribirse a la clase.";
          });
          _lastBookingWasSuccessful = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_statusMessage!), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = "Error de conexión: ${e.toString()}";
        });
        _lastBookingWasSuccessful = false;
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_statusMessage!), backgroundColor: Colors.red),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _isRegistering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    ClaseInfo clase = widget.claseInfo;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: TColor.secondaryColor1.withOpacity(0.8),
              expandedHeight: media.height * 0.35,
              pinned: true,
              floating: false,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: TColor.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                title: Text(
                  clase.nombreClase,
                  style: TextStyle(color: TColor.white, fontSize: 16, fontWeight: FontWeight.w700, shadows: [Shadow(blurRadius: 2, color: Colors.black38)]),
                  textAlign: TextAlign.center,
                ),
                background: clase.urlImagen != null && clase.urlImagen!.isNotEmpty
                    ? Stack( // Stack para imagen y overlay
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            clase.urlImagen!,
                            fit: BoxFit.cover,
                            errorBuilder: (c,e,s) => _buildFallbackClassImage(),
                            loadingBuilder: (c, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white,)),
                          ),
                          Container( // Overlay oscuro para legibilidad del título
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                                begin: Alignment.topCenter,
                                end: Alignment.center,
                              )
                            ),
                          )
                        ],
                      )
                    : _buildFallbackClassImage(),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Descripción de la Clase",
                  style: TextStyle(color: TColor.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  clase.descripcion.isNotEmpty ? clase.descripcion : "No hay descripción disponible.",
                  style: TextStyle(color: TColor.gray, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.category, "Tipo:", clase.tipo),
                _buildInfoRow(Icons.person_pin_circle_outlined, "Espacio:", "ID Espacio: ${clase.idEspacio}"), // O cargar nombre del espacio
                _buildInfoRow(Icons.schedule, "Inicio:", DateFormat('EEEE dd MMM, HH:mm', 'es_ES').format(clase.fechaHoraInicio.toLocal())),
                _buildInfoRow(Icons.timer_outlined, "Duración:", "${clase.duracionMinutos} minutos"),
                _buildInfoRow(Icons.group, "Capacidad:", "${clase.capacidadMaxima} personas"),
                if (clase.urlClase != null && clase.urlClase!.isNotEmpty)
                  _buildInfoRow(Icons.videocam, "Link Clase:", clase.urlClase!, isLink: true),

                const SizedBox(height: 30),
                if (_statusMessage != null) ...[
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isRegistering
                        ? TColor.gray
                        : _lastBookingWasSuccessful
                            ? Colors.green[700]
                            : Colors.red[700],
                  ),
                ),
                const SizedBox(height: 15)
                ],
                // Solo mostrar si la clase está activa
                if (clase.activa && clase.fechaHoraInicio.isAfter(DateTime.now()))
                  RoundButton(
                    title: _isRegistering ? "Inscribiendo..." : "Inscribirme a la Clase",
                    onPressed: (_isRegistering || _currentUserId == null) ? null : _registerForClass,
                  )
                else if (!clase.activa)
                  Text("Esta clase ya no está activa.", style: TextStyle(color: TColor.gray, fontStyle: FontStyle.italic))
                else if (clase.fechaHoraInicio.isBefore(DateTime.now()))
                   Text("Esta clase ya ha comenzado o finalizado.", style: TextStyle(color: TColor.gray, fontStyle: FontStyle.italic)),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackClassImage(){
    return Container(
      color: TColor.secondaryColor2.withOpacity(0.3), // Un color diferente para clases
      alignment: Alignment.center,
      child: Icon(Icons.groups_2_outlined, size: 100, color: TColor.secondaryColor2.withOpacity(0.5)),
    );
  }

   Widget _buildInfoRow(IconData icon, String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: TColor.primaryColor1),
          const SizedBox(width: 10),
          Text("$label ", style: TextStyle(color: TColor.black, fontSize: 15, fontWeight: FontWeight.w500)),
          Expanded(
            child: isLink
                ? InkWell(
                    child: Text(value, style: TextStyle(color: Colors.blue, fontSize: 15, decoration: TextDecoration.underline)),
                    onTap: () { /* TODO: Abrir link */ },
                  )
                : Text(value, style: TextStyle(color: TColor.gray, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}