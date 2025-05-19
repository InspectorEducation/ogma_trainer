import 'package:calendar_agenda/calendar_agenda.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common/common.dart';
import 'package:ogma_trainer/models/booking_model.dart';
import 'package:ogma_trainer/services/booking_service.dart';
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:ogma_trainer/view/paso_a_paso/estoy_listo_qr_view.dart';
import 'package:ogma_trainer/view/seguimiento_entrenamiento/agregar_reserva_view.dart';

class CalendarioEntrenamientoView extends StatefulWidget {
  const CalendarioEntrenamientoView({super.key});

  @override
  State<CalendarioEntrenamientoView> createState() => _CalendarioEntrenamientoViewState();
}

class _CalendarioEntrenamientoViewState extends State<CalendarioEntrenamientoView> {
  final CalendarAgendaController _calendarAgendaControllerAppBar = CalendarAgendaController();
  final BookingService _bookingService = BookingService();
  final StorageService _storageService = StorageService();
  final CalendarAgendaController _calendarAgendaController = CalendarAgendaController();
    
  late DateTime _selectedDate;
  String? _currentUserId;

  bool _isLoadingBookings = true;
  String? _errorLoadingBookings;
  List<Booking> _loadedBookings = [];
  List<Booking> _bookingsForSelectedDay = [];

  // Lista de horas para el timeline (0 a 23)
  final List<int> _hoursOfDay = List.generate(24, (index) => index);

  List selectDayEventArr = [];

  bool _isCancellingBooking = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _getCurrentUserId();
    if (_currentUserId != null) {
      _fetchBookingsForDate(_selectedDate);
    } else {
      if (mounted) {
        setState(() {
          _isLoadingBookings = false;
          _errorLoadingBookings = "No se pudo obtener el ID de usuario.";
        });
      }
    }
  }

  Future<void> _getCurrentUserId() async {
    _currentUserId = await _storageService.getUserId();
  }

  Future<void> _fetchBookingsForDate(DateTime date) async {
    if (_currentUserId == null) return;
    if (!mounted) return;

    setState(() {
      _isLoadingBookings = true;
      _errorLoadingBookings = null;
      _bookingsForSelectedDay = []; // Limpiar antes de cargar nuevas
    });

    try {
      _loadedBookings = await _bookingService.getUserBookingsForDay(_currentUserId!, date);
      _filterBookingsForSelectedDateAndTime(); // Filtrar y agrupar
    } catch (e) {
      _errorLoadingBookings = "Error al cargar reservas: ${e.toString()}";
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBookings = false;
        });
      }
    }
  }

  void _filterBookingsForSelectedDateAndTime() {
    // Esta función ya no es necesaria si el ListView.builder filtra por hora directamente
    // Pero si quieres pre-filtrar por día completo y luego por hora:
    final selectedDayStart = dateToStartDate(_selectedDate); // Tu función helper
     _bookingsForSelectedDay = _loadedBookings.where((booking) {
       return dateToStartDate(booking.startTime) == selectedDayStart;
     }).toList();
     // No necesitas setState aquí si _fetchBookingsForDate lo hace al final
  }

  Widget _getReservationTypeIndicator(String type) {
    IconData iconData;
    Color color;
    switch (type) {
      case "Machine":
        iconData = Icons.fitness_center; // Icono para máquina
        color = Colors.blue;
        break;
      case "Trainer":
        iconData = Icons.person; // Icono para entrenador
        color = Colors.green;
        break;
      case "Class":
        iconData = Icons.groups; // Icono para clase
        color = Colors.orange;
        break;
      default:
        iconData = Icons.event;
        color = Colors.grey;
    }
    return Icon(iconData, color: color, size: 16);
  }
      
  Future<void> _handleCancelBooking(BuildContext dialogContext, Booking booking) async {
    // Mostrar diálogo de confirmación
    final bool? confirmCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext confirmCtx) {
        return AlertDialog(
          title: const Text("Confirmar Cancelación"),
          content: Text("¿Estás seguro de que quieres cancelar la reserva para '${booking.itemName}'?"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.of(confirmCtx).pop(false),
            ),
            TextButton(
              child: Text("Sí, Cancelar", style: TextStyle(color: Colors.red[700])),
              onPressed: () => Navigator.of(confirmCtx).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmCancel != true) {
      return;
    }

    // Si se confirmó, cerrar el diálogo de detalles primero
    Navigator.of(dialogContext).pop(); // Cierra el _showBookingDetailsDialog

    setState(() {
      _isCancellingBooking = true;     
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cancelando reserva...")),
    );


    Map<String, dynamic> result;
    try {
      switch (booking.reservationType) {
        case "Machine":
          result = await _bookingService.cancelMachineBooking(booking.reservationId);
          break;
        case "Trainer":
          result = await _bookingService.cancelTrainerBooking(booking.reservationId);
          break;
        case "Class":         
          result = await _bookingService.cancelClassBookingRegistration(booking.reservationId);
          break;
        default:
          result = {"success": false, "message": "Tipo de reserva desconocido: ${booking.reservationType}"};
      }

      if (mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        if (result["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Reserva cancelada."), backgroundColor: Colors.green),
          );          
          _fetchBookingsForDate(_selectedDate);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Error al cancelar."), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
       if (mounted) {
         ScaffoldMessenger.of(context).removeCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Ocurrió un error: ${e.toString()}"), backgroundColor: Colors.red),
          );
       }
    } finally {
      if (mounted) {
        setState(() {
          _isCancellingBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            height: 40,
            width: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: TColor.lightGray,
                borderRadius: BorderRadius.circular(10)),
            child: Image.asset(
              "assets/img/black_btn.png",
              width: 15,
              height: 15,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          "Cronograma",
          style: TextStyle(
              color: TColor.black, fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(8),
              height: 40,
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: TColor.lightGray,
                  borderRadius: BorderRadius.circular(10)),
              child: Image.asset(
                "assets/img/more_btn.png",
                width: 15,
                height: 15,
                fit: BoxFit.contain,
              ),
            ),
          )
        ],
      ),
      backgroundColor: TColor.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CalendarAgenda(
            controller: _calendarAgendaControllerAppBar,
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
            weekDay: WeekDay.short,
            locale: 'es_ES',
            dayNameFontSize: 12,
            dayNumberFontSize: 16,
            dayBGColor: Colors.grey.withOpacity(0.15),
            titleSpaceBetween: 15,
            backgroundColor: Colors.transparent,
            // fullCalendar: false,
            fullCalendarScroll: FullCalendarScroll.horizontal,
            fullCalendarDay: WeekDay.short,
            selectedDateColor: Colors.white,
            dateColor: Colors.black,            

            initialDate: _selectedDate,
            calendarEventColor: TColor.primaryColor2,
            firstDate: DateTime.now().subtract(const Duration(days: 140)),
            lastDate: DateTime.now().add(const Duration(days: 60)),

            onDateSelected: (date) {
              _selectedDate = date;
              _fetchBookingsForDate(date);              
            },
            selectedDayLogo: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: TColor.primaryG,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
          Expanded(
            child: _isLoadingBookings
                ? const Center(child: CircularProgressIndicator())
                : _errorLoadingBookings != null
                    ? Center(child: Text(_errorLoadingBookings!, style: const TextStyle(color: Colors.red)))
                    : _bookingsForSelectedDay.isEmpty && !_isLoadingBookings
                        ? Center(child: Text("No tienes reservas para este día.", style: TextStyle(color: TColor.gray, fontSize: 16)))
                        : SingleChildScrollView(
                          child: SingleChildScrollView( // Scroll horizontal para el timeline
                              scrollDirection: Axis.horizontal,
                              child: SizedBox( // Ancho mayor que la pantalla para el timeline
                                width: media.width * 1.9, // Ajusta según necesidad
                                child: ListView.separated(
                                    shrinkWrap: true, // Importante para ListView dentro de otro scrollable
                                    physics: const NeverScrollableScrollPhysics(), // Deshabilitar scroll del ListView
                                    itemBuilder: (context, hourIndex) { 
                                      
                                      List<Booking> bookingsInThisHour = _bookingsForSelectedDay
                                          .where((booking) {                                            
                                            return booking.startTime.toLocal().hour == hourIndex;
                                          })
                                          .toList();
                                      bookingsInThisHour.sort((a, b) => a.startMinute.compareTo(b.startMinute));
                          
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        height: 60, // Aumentar altura para mejor visualización
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 80,
                                              child: Text(
                                                getTime(hourIndex * 60), // Tu función helper
                                                style: TextStyle(color: TColor.black, fontSize: 12),
                                              ),
                                            ),
                                            Expanded(
                                                child: Stack( // Usar Stack para superponer reservas si se solapan (simple)
                                              children: bookingsInThisHour.map((booking) {
                                                
                                                double availableWidth = (media.width * 1.5) - (80 + 40); // Ancho total - (hora + padding)
                                                double slotWidth = availableWidth / 2.5; // Ancho para cada slot, ajusta el divisor
                                                double startOffsetFraction = booking.startMinute / 60.0;                    

                                                bool isCancelled = booking.status.toLowerCase() == "cancelada";
                                                LinearGradient pillGradient;
                                                Color pillTextColor = TColor.white;

                                                if (isCancelled) {
                                                  pillGradient = LinearGradient(                                                   
                                                    colors: [Colors.red[600]!, Colors.red[400]!],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  );                                                  
                                                } else {                                                  
                                                  pillGradient = LinearGradient(colors: TColor.primaryG);
                                                }
      
                                                return Positioned(
                                                  
                                                  left: (availableWidth * startOffsetFraction * 0.8), // 0.8 para no ir al borde
                                                  top: 5,
                                                  bottom: 5,
                                                  child: InkWell(
                                                    onTap: () {
                                                      // Mostrar diálogo con detalles de la reserva
                                                      _showBookingDetailsDialog(context, booking);
                                                    },
                                                    child: Container(
                                                      width: slotWidth,
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        gradient: pillGradient,
                                                        borderRadius: BorderRadius.circular(8),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.15),
                                                            blurRadius: 3,
                                                            offset: const Offset(0, 1),
                                                          )
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          _getReservationTypeIndicator(booking.reservationType),
                                                          const SizedBox(width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              "${booking.itemName} (${DateFormat('HH:mm', 'es_ES').format(booking.startTime.toLocal())})",
                                                              maxLines: 2, // Permitir dos líneas
                                                              overflow: TextOverflow.ellipsis,
                                                              style: TextStyle(color: TColor.white, fontSize: 11),
                                                            ),
                                                          ),
                                                          if (isCancelled)
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 3.0),
                                                            child: Icon(Icons.cancel_outlined, color: TColor.white.withOpacity(0.7), size: 13),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ))
                                          ],
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return Divider(color: TColor.gray.withOpacity(0.2), height: 1);
                                    },
                                    itemCount: _hoursOfDay.length), // Itera 24 veces (por cada hora)
                              ),
                            ),
                        ),
          ),
        ],
      ),
      floatingActionButton: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AgregarReservaView(
                        date: _selectedDate,
                      )));
        },
        child: Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.secondaryG),
              borderRadius: BorderRadius.circular(27.5),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 5, offset: Offset(0, 2))
              ]),
          alignment: Alignment.center,
          child: Icon(
            Icons.add,
            size: 20,
            color: TColor.white,
          ),
        ),
      ),
    );
  }

  void _showBookingDetailsDialog(BuildContext context, Booking booking) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: TColor.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              _getReservationTypeIndicator(booking.reservationType),
              const SizedBox(width: 10),
              Expanded(child: Text(booking.reservationType, style: TextStyle(color: TColor.black, fontWeight: FontWeight.bold))),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context))
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                booking.itemName,
                style: TextStyle(color: TColor.black, fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              _buildDetailRow(Icons.calendar_today, "Fecha:", DateFormat('dd/MM/yyyy', 'es_ES').format(booking.startTime.toLocal())),
              _buildDetailRow(Icons.access_time, "Inicio:", DateFormat('HH:mm', 'es_ES').format(booking.startTime.toLocal())),
              _buildDetailRow(Icons.access_time_filled, "Fin:", DateFormat('HH:mm', 'es_ES').format(booking.endTime.toLocal())),
              _buildDetailRow(Icons.info_outline, "Estado:", booking.status),
              if (booking.attended != null)
                 _buildDetailRow(booking.attended! ? Icons.check_circle : Icons.cancel, "Asistió:", booking.attended! ? "Sí" : "No"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => EstoyListoQRView(booking: booking,))),
              child: Text("Iniciar Ahora", style: TextStyle(color: TColor.primaryColor1)),
            ),
            // Botón para cancelar la reserva
            // Solo mostrar si el estado de la reserva lo permite (ej. "Confirmada")
            if (booking.status.toLowerCase() == "confirmada") // O la lógica que determine si se puede cancelar
              TextButton(
                onPressed: _isCancellingBooking ? null : () => _handleCancelBooking(dialogContext, booking),
                child: _isCancellingBooking
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2,))
                    : Text("Cancelar Reserva", style: TextStyle(color: Colors.red[700])),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: TColor.gray),
          const SizedBox(width: 8),
          Text("$label ", style: TextStyle(color: TColor.gray, fontSize: 14, fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: TextStyle(color: TColor.black, fontSize: 14))),
        ],
      ),
    );
  }
}