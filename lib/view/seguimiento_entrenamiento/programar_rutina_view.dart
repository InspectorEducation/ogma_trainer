import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/icon_title_next_row.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/models/routine_model.dart';
import 'package:ogma_trainer/services/booking_service.dart';
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:ogma_trainer/models/availability_check_response_model.dart';
// Importa la vista a la que navegarás después de programar (ej. Calendario o Home)
import 'package:ogma_trainer/view/seguimiento_entrenamiento/calendario_entrenamiento_view.dart';


class ProgramarRutinaView extends StatefulWidget {
  final Routine routine;
  const ProgramarRutinaView({super.key, required this.routine});

  @override
  State<ProgramarRutinaView> createState() => _ProgramarRutinaViewState();
}

class _ProgramarRutinaViewState extends State<ProgramarRutinaView> {
  final BookingService _bookingService = BookingService();
  final StorageService _storageService = StorageService();
  final CalendarAgendaController _calendarAgendaController = CalendarAgendaController();

  DateTime _selectedDateForRoutineStart = DateTime.now(); // Fecha para el Día 1
  TimeOfDay _selectedTimeForSessionStart = const TimeOfDay(hour: 8, minute: 0);
  int _selectedRoutineDayNumber = 1; // Día de la rutina a programar (1, 2, etc.)

  bool _isCheckingAvailability = false;
  bool _isBookingDay = false;
  AvailabilityCheckResponse? _availabilityResponse;
  String? _statusMessage;
  String? _currentUserId;
  List<int> _diasDeRutina = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateForRoutineStart = (now.hour > 18 && now.day == DateTime.now().day)
                                ? now.add(const Duration(days: 1))
                                : DateTime(now.year, now.month, now.day);
   
    _diasDeRutina = List.generate(widget.routine.numeroDias, (i) => i + 1);
    if (_diasDeRutina.isNotEmpty && !_diasDeRutina.contains(_selectedRoutineDayNumber)) {
        _selectedRoutineDayNumber = _diasDeRutina.first;
    }
    _loadUserId();
  }

   Future<void> _loadUserId() async {
    _currentUserId = await _storageService.getUserId();
    if (_currentUserId == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Usuario no identificado."), backgroundColor: Colors.red));
      Navigator.pop(context);
    }
  }


  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateForRoutineStart.toUtc(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDateForRoutineStart) {
      setState(() {
        _selectedDateForRoutineStart = picked;
        _availabilityResponse = null; // Resetear al cambiar fecha
        _statusMessage = null;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTimeForSessionStart,
    );
    if (picked != null && picked != _selectedTimeForSessionStart) {
      setState(() {
        _selectedTimeForSessionStart = picked;
        _availabilityResponse = null; // Resetear al cambiar hora
        _statusMessage = null;
      });
    }
  }

  DateTime get _desiredStartDateTimeForSelectedDay {    
    DateTime actualDateForRoutineDay = _selectedDateForRoutineStart.add(Duration(days: _selectedRoutineDayNumber - 1));
    DateTime localDateTime = DateTime(
      actualDateForRoutineDay.year,
      actualDateForRoutineDay.month,
      actualDateForRoutineDay.day,
      _selectedTimeForSessionStart.hour,
      _selectedTimeForSessionStart.minute,
    );
    return localDateTime.toUtc();
  }

  Future<void> _validateAvailability() async {
    if (_currentUserId == null) {
      setState(() => _statusMessage = "Error: ID de usuario no disponible.");
      return;
    }
    setState(() {
      _isCheckingAvailability = true;
      _statusMessage = "Verificando disponibilidad para el Día $_selectedRoutineDayNumber...";
      _availabilityResponse = null;
    });
    
    try {
      final response = await _bookingService.validateRoutineDayAvailability(
        routineId: widget.routine.idRutina,
        diaNumero: _selectedRoutineDayNumber,
        desiredStartDateTime: _desiredStartDateTimeForSelectedDay,
      );
      setState(() {
        _availabilityResponse = response;
        _statusMessage = response.message;
        if (response.isOverallAvailable) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message), backgroundColor: Colors.green),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message), backgroundColor: Colors.orange, duration: const Duration(seconds: 5)),
          );
        }
      });
    } catch (e) {
      setState(() {
        _statusMessage = "Error: ${e.toString()}";
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_statusMessage!), backgroundColor: Colors.red),
          );
      });
    } finally {
      setState(() => _isCheckingAvailability = false);
    }
  }

  Future<void> _bookDay() async {
    if (_currentUserId == null) {
      setState(() => _statusMessage = "Error: ID de usuario no disponible.");
      return;
    }
    if (_availabilityResponse == null || !_availabilityResponse!.isOverallAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verifica la disponibilidad primero o la disponibilidad no fue confirmada."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() {
      _isBookingDay = true;
      _statusMessage = "Programando Día $_selectedRoutineDayNumber...";
    });

    try {
      DateTime startTimeForBooking = _availabilityResponse!.actualPossibleStartTime ?? _desiredStartDateTimeForSelectedDay;
      String fechaEnviada = startTimeForBooking.toIso8601String();
      debugPrint("FECHA ENVIADA LA API: $fechaEnviada");

      final bookingResponse = await _bookingService.bookRoutineDay(
        userId: int.parse(_currentUserId!),
        routineId: widget.routine.idRutina,
        diaNumero: _selectedRoutineDayNumber,
        startDateTime: startTimeForBooking,
      );

      setState(() {
        _statusMessage = bookingResponse.message;
        // Podrías mostrar detalles de bookedMachines si quieres
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(bookingResponse.message), backgroundColor: Colors.green, duration: const Duration(seconds: 4)),
      );
      // Opcional: Preguntar si quiere programar el siguiente día o ir al calendario      
      Navigator.pop(context, true); // true para que la vista anterior pueda refrescar
    } catch (e) {
      setState(() {
        _statusMessage = "Error al programar: ${e.toString()}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_statusMessage!), backgroundColor: Colors.red, duration: const Duration(seconds: 5)),
      );
    } finally {
      setState(() => _isBookingDay = false);
    }
  }

  Future<void> _showDaySelectionDialog(BuildContext context) async {
    if (_diasDeRutina.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Esta rutina no tiene días definidos.")),
      );
      return;
    }

    final int? chosenDay = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.only(top:20, bottom: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Text(
                  "Selecciona el Día de la Rutina",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TColor.black),
                ),
              ),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _diasDeRutina.length,
                  itemBuilder: (BuildContext context, int index) {
                    int dayNumber = _diasDeRutina[index];
                    return ListTile(
                      title: Center(child: Text('Día $dayNumber', style: TextStyle(fontSize: 16, color: TColor.primaryColor1))),
                      onTap: () {
                        Navigator.pop(context, dayNumber); 
                      },
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (chosenDay != null) {
      setState(() {
        _selectedRoutineDayNumber = chosenDay;
        _availabilityResponse = null;
        _statusMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {        
    return Scaffold(
      appBar: AppBar(
        title: Text("Programar Rutina", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.routine.nombreRutina, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: TColor.black)),
            const SizedBox(height: 10),
            Text("¡Ingresa el día y la hora que te gustaria iniciar tu entrenamiento!", style: TextStyle(fontSize: 16, color: TColor.gray)),
            const SizedBox(height: 5),
            Text("Total días de la rutina: ${widget.routine.numeroDias}", style: TextStyle(fontSize: 16, color: TColor.gray)),
            const SizedBox(height: 20),
            Text("1. Selecciona el Día de la Rutina a programar y la fecha:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: TColor.gray)),
            IconTitleNextRow(
              icon: "assets/img/date.png",
              title: "Día de Rutina a Programar",
              time: "Día $_selectedRoutineDayNumber",
              color: TColor.lightGray,
              onPressed: () {
                _showDaySelectionDialog(context);
              }
            ),

            Text("2. Fecha de inicio para el Día $_selectedRoutineDayNumber:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: TColor.gray)),
            const SizedBox(height: 10),
            CalendarAgenda(
              controller: _calendarAgendaController,
              appbar: false,
              selectedDayPosition: SelectedDayPosition.center,              
              leading: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowLeft.png",
                  width: 15,
                  height: 15,
                )),
              training: IconButton(
                onPressed: () {},
                icon: Image.asset(
                  "assets/img/ArrowRight.png",
                  width: 15,
                  height: 15,
                )),
              weekDay: WeekDay.short, // lun, mar, mié
              locale: 'es',
              dayNameFontSize: 12,
              dayNumberFontSize: 16,
              dayBGColor: TColor.lightGray.withOpacity(0.7), // Fondo para días no seleccionados
              titleSpaceBetween: 15,
              backgroundColor: Colors.transparent, // El fondo del CalendarAgenda en sí
              fullCalendarScroll: FullCalendarScroll.horizontal,
              fullCalendarDay: WeekDay.short,
              selectedDateColor: Colors.white, // Color del texto del número y día en el slot seleccionado
              dateColor: TColor.black, // Color del texto del número y día en slots no seleccionados
              initialDate: _selectedDateForRoutineStart,
              // calendarEventColor: TColor.primaryColor2, // Color para puntos de eventos (no lo usamos aquí)
              firstDate: DateTime.now().subtract(const Duration(days: 1)), // Permitir seleccionar desde ayer (o hoy)
              lastDate: DateTime.now().add(const Duration(days: 90)), // Rango futuro

              onDateSelected: (date) {
                // La 'date' devuelta por CalendarAgenda puede tener hora, minuto, segundo.
                // Nos interesa solo la parte de la fecha para _selectedDateForRoutineStart.
                DateTime dateOnly = DateTime(date.year, date.month, date.day);
                if (_selectedDateForRoutineStart != dateOnly) {
                   setState(() {
                    _selectedDateForRoutineStart = dateOnly;
                    _availabilityResponse = null; // Resetear al cambiar fecha
                    _statusMessage = null;
                  });
                }
              },
              selectedDayLogo: Container( // Diseño para el slot del día seleccionado
                width: double.maxFinite,
                height: double.maxFinite,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: TColor.primaryG, // Usa tu gradiente primario
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),              
            ),
            const SizedBox(height: 20),

            Text("3. Hora de inicio deseada para la sesión:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: TColor.gray)),
            Row(
              children: [
                Expanded(child: Text(_selectedTimeForSessionStart.format(context), style: const TextStyle(fontSize: 18))),
                IconButton(icon: const Icon(Icons.access_time), onPressed: _pickTime, tooltip: "Cambiar Hora"),
              ],
            ),
            const SizedBox(height: 30),

            Center(
              child: RoundButton(
                title: _isCheckingAvailability ? "Verificando..." : "Verificar Disponibilidad (Día $_selectedRoutineDayNumber)",
                onPressed: _isCheckingAvailability || _isBookingDay || widget.routine.numeroDias == 0 ? null : _validateAvailability,
                type: (_availabilityResponse?.isOverallAvailable ?? false) ? RoundButtonType.bgSGradient : RoundButtonType.bgGradient,
              ),
            ),

            if (_statusMessage != null) ...[
              const SizedBox(height: 15),
              Text(
                _statusMessage!,
                style: TextStyle(color: (_availabilityResponse?.isOverallAvailable ?? false) && !_isCheckingAvailability ? Colors.green[700] : Colors.orange[700]),
                textAlign: TextAlign.center,
              ),
            ],

            // Mostrar detalles de disponibilidad si existen
            if (_availabilityResponse != null && !_isCheckingAvailability) ...[
              const SizedBox(height: 15),
              Text("Hora de inicio solicitada: ${DateFormat('HH:mm', 'es_ES').format(_availabilityResponse!.originalRequestedStartTime.toLocal())}", style: const TextStyle(fontSize: 13)),
              if (_availabilityResponse!.actualPossibleStartTime != null &&
                  _availabilityResponse!.actualPossibleStartTime != _availabilityResponse!.originalRequestedStartTime)
                Text("Hora posible de inicio sugerida: ${DateFormat('HH:mm', 'es_ES').format(_availabilityResponse!.actualPossibleStartTime!.toLocal())}", 
                style: TextStyle(fontSize: 13, color: TColor.secondaryColor1)),
              const SizedBox(height: 10),
              Text("Disponibilidad de ejercicios para Día $_selectedRoutineDayNumber:", style: TextStyle(fontWeight: FontWeight.bold)),
              for (var exAvail in _availabilityResponse!.exerciseAvailabilities)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "${exAvail.exerciseName}: ${exAvail.isAvailable ? 'Disponible' : 'NO Disponible'}"
                    "${exAvail.isAvailable && exAvail.availableMachineName != null ? ' (Máq: ${exAvail.availableMachineName})' : ''}"
                    "${!exAvail.isAvailable && exAvail.reasonIfNotAvailable != null ? ' - Razón: ${exAvail.reasonIfNotAvailable}' : ''}",
                    style: TextStyle(fontSize: 12, color: exAvail.isAvailable ? Colors.black87 : Colors.red),
                  ),
                ),
            ],

            const SizedBox(height: 30),
            if (_availabilityResponse?.isOverallAvailable ?? false)
              Center(
                child: RoundButton(
                  title: _isBookingDay ? "Programando..." : "Programar Día $_selectedRoutineDayNumber",
                  onPressed: _isBookingDay || _isCheckingAvailability ? null : _bookDay,
                ),
              ),
            const SizedBox(height: 20),
             if (_isBookingDay || _isCheckingAvailability)
              const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())),
          ],
        ),
      ),
    );
  }
}