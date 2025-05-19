import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/models/machine_model.dart';
import 'package:ogma_trainer/services/booking_service.dart';
import 'package:ogma_trainer/services/storage_service.dart';  

class DetalleMaquinaView extends StatefulWidget {
  final Machine machine;
  const DetalleMaquinaView({super.key, required this.machine});

  @override
  State<DetalleMaquinaView> createState() => _DetalleMaquinaViewState();
}

class _DetalleMaquinaViewState extends State<DetalleMaquinaView> {
  final BookingService _bookingService = BookingService();
  final StorageService _storageService = StorageService();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedStartTime = TimeOfDay.now();
  
  final int _bookingDurationMinutes = 30;

  bool _isBooking = false;
  String? _statusMessage;
  String? _currentUserId;
  bool _lastBookingWasSuccessful = false; 

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = (now.hour >= 22) ? DateTime(now.year, now.month, now.day).add(const Duration(days: 1)) : DateTime(now.year, now.month, now.day);
    _selectedStartTime = TimeOfDay(hour: now.hour < 22 ? now.hour + 1 : 8, minute: 0); // Siguiente hora en punto
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _currentUserId = await _storageService.getUserId();
    if (!mounted) return;
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Usuario no identificado."), backgroundColor: Colors.red));      
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days:1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _statusMessage = null;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime,
    );
    if (picked != null && picked != _selectedStartTime) {
      setState(() {
        _selectedStartTime = picked;
        _statusMessage = null;
      });
    }
  }

  Future<void> _performBooking() async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Inicia sesión para reservar."), backgroundColor: Colors.orange));
      return;
    }
    if (!widget.machine.reservable || widget.machine.estado.toLowerCase() != "disponible") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Esta máquina no está disponible para reservar en este momento."), backgroundColor: Colors.orange));
      return;
    }


    setState(() {
      _isBooking = true;
      _statusMessage = "Reservando...";
    });

    DateTime bookingStartTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedStartTime.hour,
      _selectedStartTime.minute,
    );
    DateTime bookingEndTime = bookingStartTime.add(Duration(minutes: _bookingDurationMinutes));
    debugPrint("DIA Y HORA A RESERVAR: $bookingEndTime");
    try {
      final result = await _bookingService.bookMachine(
        userId: int.parse(_currentUserId!),
        machineId: widget.machine.idMaquina,
        startTime: bookingStartTime.toUtc(), 
        endTime: bookingEndTime.toUtc(),    
      );

      if (mounted) {
        if (result["success"] == true) {
          setState(() {
            _statusMessage = result["message"] ?? "¡Máquina reservada exitosamente!";
            _lastBookingWasSuccessful = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_statusMessage!), backgroundColor: Colors.green),
          );
          // Opcional: Navegar a la vista de calendario o mis reservas
          Navigator.pop(context, true);
        } else {
          setState(() {
            _statusMessage = result["message"] ?? "Error al reservar la máquina.";
            _lastBookingWasSuccessful = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_statusMessage!), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = "Error de conexión: ${e.toString()}";
          _lastBookingWasSuccessful = false;
        });
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_statusMessage!), backgroundColor: Colors.red),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _isBooking = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: NestedScrollView( // Similar a DetalleEjercicioView
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: TColor.primaryColor1.withOpacity(0.8), // Un color para el fondo del AppBar
              expandedHeight: media.height * 0.35, // Altura para la imagen
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
                  widget.machine.nombre,
                  style: TextStyle(color: TColor.white, fontSize: 16, fontWeight: FontWeight.w700, shadows: [Shadow(blurRadius: 2, color: Colors.black38)]),
                  textAlign: TextAlign.center,
                ),
                background: widget.machine.urlImagen != null && widget.machine.urlImagen!.isNotEmpty
                    ? Image.network(
                        widget.machine.urlImagen!,
                        fit: BoxFit.cover,
                        errorBuilder: (c,e,s) => _buildFallbackMachineImage(),
                        loadingBuilder: (c, child, progress) => progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white,)),
                      )
                    : _buildFallbackMachineImage(),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          decoration: BoxDecoration(
            color: TColor.white,
            // No necesitamos bordes redondeados aquí si el SliverAppBar cubre la parte superior
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Descripción",
                  style: TextStyle(color: TColor.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.machine.descripcion.isNotEmpty ? widget.machine.descripcion : "No hay descripción disponible.",
                  style: TextStyle(color: TColor.gray, fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(child: _buildInfoChip("Tipo:", widget.machine.tipoMaquina)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildInfoChip("Estado:", widget.machine.estado,
                      statusColor: widget.machine.estado.toLowerCase() == "disponible" ? Colors.green.shade700 : Colors.orange.shade700
                    )),
                  ],
                ),
                const SizedBox(height: 25),

                Text(
                  "Reservar Máquina",
                  style: TextStyle(color: TColor.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                // Selector de Fecha
                Text("Fecha:", style: TextStyle(color: TColor.black, fontSize: 16)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    decoration: BoxDecoration(color: TColor.lightGray, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate), style: TextStyle(fontSize: 16, color: TColor.gray)),
                        Icon(Icons.calendar_today, color: TColor.gray),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Selector de Hora
                Text("Hora de Inicio:", style: TextStyle(color: TColor.black, fontSize: 16)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                    decoration: BoxDecoration(color: TColor.lightGray, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedStartTime.format(context), style: TextStyle(fontSize: 16, color: TColor.gray)),
                        Icon(Icons.access_time, color: TColor.gray),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                    "Duración estimada: $_bookingDurationMinutes minutos.",
                    style: TextStyle(color: TColor.gray, fontSize: 13)),

                const SizedBox(height: 30),
                if (_statusMessage != null) ...[
                Text(
                  _statusMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isBooking
                        ? TColor.gray
                        : _lastBookingWasSuccessful
                            ? Colors.green[700]
                            : Colors.red[700],
                  ),
                ),
                const SizedBox(height: 15)
                ],
                RoundButton(
                  title: _isBooking ? "Reservando..." : "Confirmar Reserva",
                  onPressed: (_isBooking || _currentUserId == null || !widget.machine.reservable || widget.machine.estado.toLowerCase() != "disponible")
                            ? null
                            : _performBooking,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackMachineImage(){
    return Container(
      color: TColor.gray.withOpacity(0.1),
      alignment: Alignment.center,
      child: Icon(Icons.fitness_center, size: 100, color: TColor.gray.withOpacity(0.3)),
    );
  }

  Widget _buildInfoChip(String label, String value, {Color? statusColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: TColor.gray, fontSize: 13)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: TColor.lightGray.withOpacity(0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(value, style: TextStyle(color: statusColor ?? TColor.gray, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}