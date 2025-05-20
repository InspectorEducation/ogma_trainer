import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/common_widget/live_class_row.dart';
import 'package:ogma_trainer/common_widget/round_button.dart';
import 'package:ogma_trainer/common_widget/siguiente_entrenamiento_row.dart';
import 'package:ogma_trainer/common_widget/what_train_row.dart';
import 'package:ogma_trainer/models/routine_model.dart';
import 'package:ogma_trainer/services/capacity_service.dart';
import 'package:ogma_trainer/services/equipment_service.dart';
import 'package:ogma_trainer/services/routine_service.dart';
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:ogma_trainer/view/formularios/formulario_sintomas_view.dart';
import 'package:ogma_trainer/view/login/login_view.dart';
import 'package:ogma_trainer/view/paso_a_paso/leer_codigo_qr_view.dart';
import 'package:ogma_trainer/view/seguimiento_entrenamiento/detalle_entranamiento_view.dart';
import 'package:ogma_trainer/view/tele_entrenamiento/call_page.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:ogma_trainer/services/auth_service.dart';
import 'package:ogma_trainer/models/clase_info_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final AuthService _authService = AuthService();
  final CapacityService _capacityService = CapacityService();
  final StorageService _storageService = StorageService();
  final EquipmentService _equipmentService = EquipmentService();
  final RoutineService _routineService = RoutineService();

  Routine? _assignedRoutine;
  bool _isLoadingAssignedRoutine = true;
  String? _errorLoadingAssignedRoutine;

  bool _isLoadingCheckInStatus = true;
  String? _currentCheckInId;
  String? _checkedInGymId;
  int? _currentUserId;

  List<ClaseInfo> _liveClasses = [];
  bool _isLoadingLiveClasses = true;
  String? _errorLoadingLiveClasses;

  List ids_availables_gyms_for_user = [1, 2, 3];

  List latestArr = [
    {
      "image": "assets/img/Workout1.png",
      "title": "Entrenamiento Personalizado DIA 1",
      "time": "Hoy, 02:00 pm"
    }
  ];

  List whatArr = [
    {
      "image": "assets/img/what_1.png",
      "title": "Entranamiento Cuerpo Completo",
      "exercises": "11 Ejercicios",
      "time": "32 minutos"
    },
    {
      "image": "assets/img/what_2.png",
      "title": "Entramiento Tren Inferior",
      "exercises": "12 Ejercicios",
      "time": "40 minutos"
    },
    {
      "image": "assets/img/what_3.png",
      "title": "Entranamiento Abdominales",
      "exercises": "14 Ejercicios",
      "time": "20 minutos"
    }
  ];

  final List<Map<String, String>> questionsSym = [
    {
      "question":
          "¿Tienes fiebre (mayor a 38°C), tos seca o dificultad para respirar?"
    },
    {
      "question":
          "¿Has perdido recientemente el sentido del olfato o del gusto?"
    },
    {
      "question":
          "¿Tienes dolor de garganta, congestión nasal o fatiga inusual?"
    },
    {
      "question":
          "¿Has estado en contacto con alguien diagnosticado con COVID-19 en los últimos 14 días?"
    },
    {
      "question":
          "¿Has estado en lugares con brotes recientes de COVID-19 en los últimos 14 días?"
    }
  ];

  bool workoutNow = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingCheckInStatus = true; 
      _isLoadingLiveClasses = true;   
      _isLoadingAssignedRoutine = true; 
      _errorLoadingAssignedRoutine = null; 
      _errorLoadingLiveClasses = null; 
    });

    await _getCurrentUserId();
    if (!mounted) return;

    if (_currentUserId == null) {
      setState(() {
        _isLoadingCheckInStatus = false;
        _isLoadingLiveClasses = false;
        _isLoadingAssignedRoutine = false;
        _errorLoadingAssignedRoutine = "No se pudo obtener la información del usuario para cargar los datos.";        
      });
      return;
    }

    Future<void> checkInFuture = _loadCheckInStatus();    
    Future<void> liveClassesFuture = _loadLiveClasses();
    Future<void> assignedRoutineFuture = _loadAssignedRoutine();

    await Future.wait([
      checkInFuture,
      liveClassesFuture,
      assignedRoutineFuture,
    ]);
    if (!mounted) return;

    if (workoutNow && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showWorkoutAlert(context);
      });
    }
    if (mounted) {
      setState(() {
        _isLoadingCheckInStatus = false;
      });
    }
  }

  Future<void> _getCurrentUserId() async {
    final userIdStr = await _storageService.getUserId();
    if (userIdStr != null) {
      _currentUserId = int.tryParse(userIdStr);
    }
  }

  Future<void> _loadCheckInStatus() async {
    _currentCheckInId = await _storageService.getCheckInId();
    _checkedInGymId = await _storageService.getCheckedInGymId();
    debugPrint("CheckInId EN SISTEMA: $_currentCheckInId");
  }

  Future<void> _loadLiveClasses() async {
    if (!mounted) return;
    setState(() {
      _isLoadingLiveClasses = true;
      _errorLoadingLiveClasses = null;
    });

    try {
      final allClasses = await _equipmentService.getAllClasses();
      final now = DateTime.now();
      // Filtrar clases activas y futuras (o de hoy)
      _liveClasses = allClasses.where((clase) {
        // Comparar solo la parte de la fecha para "hoy"
        DateTime claseStartDate = DateTime(clase.fechaHoraInicio.year,
            clase.fechaHoraInicio.month, clase.fechaHoraInicio.day);
        DateTime todayDate = DateTime(now.year, now.month, now.day);
        return clase.activa &&
            (claseStartDate.isAtSameMomentAs(todayDate) ||
                clase.fechaHoraInicio.isAfter(now));
      }).toList();

      //Ordenar por fecha de inicio más próxima
      _liveClasses
          .sort((a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio));
    } catch (e) {
      if (mounted) {
        _errorLoadingLiveClasses =
            "Error al cargar clases: ${e.toString().substring(0, (e.toString().length > 100 ? 100 : e.toString().length))}"; // Acortar mensaje
      }
      debugPrint("Error en _loadLiveClasses: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingLiveClasses = false;
        });
      }
    }
  }

  void _showWorkoutAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("¡Entrenamiento Próximo!"),
          content: const Text(
              "Tienes un entrenamiento programado, empieza en 15 minutos"),
          actions: <Widget>[
            RoundButton(
                title: "¡Entendido!",
                type: RoundButtonType.bgSGradient,
                fontSize: 12,
                fontWeight: FontWeight.w400,
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Cerrar Sesión'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmLogout != true) {
      return;
    }

    await _authService.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _performCheckIn(
      BuildContext context, Map<String, dynamic> qrData) async {
    if (_currentUserId == null) throw Exception("ID de usuario no disponible.");

    dynamic rawGymId = qrData['Name'];
    int? gymIdFromQR;
    if (rawGymId is int)
      gymIdFromQR = rawGymId;
    else if (rawGymId is String) gymIdFromQR = int.tryParse(rawGymId);

    if (gymIdFromQR == null)
      throw Exception("QR no contiene un ID de gimnasio válido.");

    final result = await _capacityService.checkInToGym(
      userId: _currentUserId!,
      gymId: gymIdFromQR,
    );

    if (result["success"] == true) {
      final Map<String, dynamic>? data =
          result["data"] as Map<String, dynamic>?;
      final int? checkInIdFromData = data?["checkInId"] as int?;
      final bool requiresSymptomForm =
          data?["requiresSymptomForm"] as bool? ?? false;

      if (checkInIdFromData != null) {
        final String checkInIdStr = checkInIdFromData.toString();
        final String gymIdStr =
            (data?["gymId"] as int? ?? gymIdFromQR).toString();

        await _storageService.saveCheckInData(
            checkInId: checkInIdStr, gymId: gymIdStr);

        if (mounted) {
          setState(() {
            _currentCheckInId = checkInIdStr;
            _checkedInGymId = gymIdStr;
          });
        }
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result["message"] ?? "Ingreso exitoso!"),
              backgroundColor: Colors.green),
        );

        //si validacion de sintomas esta prendido
        if (requiresSymptomForm) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FormularioSintomasView(
                    checkInId: checkInIdFromData,
                    userId: _currentUserId!,
                    questions: questionsSym),
              ),
            );
          }
        }
      } else {
        debugPrint(
            "Check-in reportado como exitoso, pero falta 'checkInId' en los datos devueltos: $result");
        throw Exception(result["message"] ??
            "Respuesta de check-in incompleta desde el servidor.");
      }
    } else {
      if (Navigator.canPop(context)) Navigator.pop(context);
      debugPrint("Fallo en checkInToGym, resultado: $result");
      throw Exception(result["message"] ?? "Error durante el check-in.");
    }
  }

  Future<void> _performCheckOut(
      BuildContext context, Map<String, dynamic> qrData) async {
    if (_currentUserId == null) throw Exception("ID de usuario no disponible.");
    if (_checkedInGymId == null)
      throw Exception("No hay check-in activo para realizar check-out.");

    // Validamos que el QR corresponda al gym donde estamos checked-in
    dynamic rawGymIdQR = qrData['Name'];
    int? gymIdFromQR;
    if (rawGymIdQR is int)
      gymIdFromQR = rawGymIdQR;
    else if (rawGymIdQR is String) gymIdFromQR = int.tryParse(rawGymIdQR);

    int? checkedInGymIdInt = int.tryParse(_checkedInGymId!); // El ID guardado

    if (gymIdFromQR == null ||
        checkedInGymIdInt == null ||
        gymIdFromQR != checkedInGymIdInt) {
      throw Exception(
          "Este QR no corresponde al gimnasio donde hiciste check-in.");
    }

    final result = await _capacityService.checkOutFromGym(
      userId: _currentUserId!,
      gymId: checkedInGymIdInt,
    );

    if (result["success"] == true) {
      await _storageService.clearCheckInData();
      if (mounted) {
        setState(() {
          _currentCheckInId = null;
          _checkedInGymId = null;
        });
        if (Navigator.canPop(context)) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result["message"] ?? "Check-out exitoso!"),
              backgroundColor: Colors.green),
        );
      }
    } else {
      if (Navigator.canPop(context)) Navigator.pop(context);
      throw Exception(result["message"] ?? "Error durante el check-out.");
    }
  }

  Future<void> _loadAssignedRoutine() async {
    if (!mounted) return;
    
    if (_currentUserId == null) {
      if (mounted) {
        setState(() {
          _errorLoadingAssignedRoutine =
              "ID de usuario no disponible para cargar rutina.";
          _isLoadingAssignedRoutine = false;
        });
      }
      return;
    }

    try {
      final assignment = await _routineService
          .getAssignedAIRoutine(_currentUserId!.toString());
      if (mounted) {
        setState(() {
          if (assignment != null) {
            _assignedRoutine = assignment.rutinaDetalles;
          } else {
            _assignedRoutine = null; // No hay rutina asignada
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorLoadingAssignedRoutine =
              "Error al cargar rutina personalizada.";
        });
      }
      debugPrint("Error en _loadAssignedRoutine: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingAssignedRoutine = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    if (_isLoadingCheckInStatus) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool isCheckedIn = _currentCheckInId != null;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bienvenido de nuevo,",
                        style: TextStyle(color: TColor.gray, fontSize: 20),
                      ),
                      Text(
                        "Ivan Pulido",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 25,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: Image.asset(
                            "assets/img/notification_active.png",
                            width: 25,
                            height: 25,
                            fit: BoxFit.fitHeight,
                          )),
                      IconButton(
                          onPressed: _handleLogout,
                          icon: Image.asset(
                            "assets/img/logout.png",
                            width: 25,
                            height: 25,
                            fit: BoxFit.fitHeight,
                          )),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: media.width * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tu entramiento personalizado",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(
                height: media.width * 0.02,
              ),
              _isLoadingAssignedRoutine
                  ? Container(
                      // Placeholder mientras carga
                      height: media.width * 0.4,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    )
                  : _errorLoadingAssignedRoutine != null
                      ? Container(
                          // Mensaje de error
                          height: media.width * 0.4,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius:
                                  BorderRadius.circular(media.width * 0.075)),
                          alignment: Alignment.center,
                          child: Text(_errorLoadingAssignedRoutine!,
                              style: TextStyle(color: Colors.red[700]),
                              textAlign: TextAlign.center),
                        )
                      : _assignedRoutine != null
                          ? Container(
                              // Contenedor de la rutina cargada
                              height: media.width * 0.4, // Mantener altura
                              decoration: BoxDecoration(
                                gradient:
                                    LinearGradient(colors: TColor.primaryG),
                                borderRadius:
                                    BorderRadius.circular(media.width * 0.075),
                              ),
                              child: Stack(clipBehavior: Clip.none, children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _assignedRoutine!
                                            .nombreRutina,
                                        style: const TextStyle(
                                            color: Colors
                                                .white,
                                            fontSize:
                                                18,
                                            fontWeight: FontWeight.w700),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: media.width * 0.01),
                                      Row(
                                        children: [
                                          Icon(Icons.timer,
                                              size: 16,
                                              color: TColor.white
                                                  .withOpacity(0.8)),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${_assignedRoutine!.numeroDias} Día(s)",
                                            style: TextStyle(
                                                color: TColor.white
                                                    .withOpacity(0.8),
                                                fontSize: 13),
                                          ),
                                          const SizedBox(width: 10),
                                          Icon(Icons.star,
                                              size: 16,
                                              color: TColor.white
                                                  .withOpacity(0.8)),
                                          const SizedBox(width: 4),
                                          Text(
                                            "2100 kcal",
                                            style: TextStyle(
                                                color: TColor.white
                                                    .withOpacity(0.8),
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                          height: media.width *
                                              0.02),
                                      Text(
                                        "0% completado",
                                        style: TextStyle(
                                            color:
                                                TColor.white.withOpacity(0.9),
                                            fontSize: 13),
                                      ),
                                      SizedBox(height: media.width * 0.01),
                                      SimpleAnimationProgressBar(
                                        height: 10,
                                        width: media.width * 0.5,
                                        backgroundColor: Colors.white
                                            .withOpacity(
                                                0.3),
                                        foregrondColor: Colors.purple,
                                        ratio: 0.0, 
                                        direction: Axis.horizontal,
                                        curve: Curves.fastLinearToSlowEaseIn,
                                        duration: const Duration(
                                            seconds:
                                                1),
                                        borderRadius:
                                            BorderRadius.circular(7.5),
                                        gradientColor: LinearGradient(
                                            colors: TColor
                                                .secondaryG,
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight),
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                          width: 120,
                                          height: 35,
                                          child: RoundButton(
                                              title:
                                                  "Ver Detalles", // Título cambiado
                                              type: RoundButtonType.bgSGradient,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              onPressed: () {
                                                if (_assignedRoutine != null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          DetalleEntranamientoView(
                                                              routine:
                                                                  _assignedRoutine!),
                                                    ),
                                                  );
                                                }
                                              }))
                                    ],
                                  ),
                                ),                                
                                  Positioned(
                                    right: -25,
                                    top: -8,
                                    child: Image.asset(
                                      "assets/img/man_1.png",
                                      height: media.width * 0.41,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                              ]),
                            )
                          : Container(
                              // Mensaje si no hay rutina asignada
                              height: media.width * 0.4,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                  color: TColor.lightGray.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(
                                      media.width * 0.075)),
                              alignment: Alignment.center,
                              child: Text(
                                  "Aún no tienes un entrenamiento personalizado asignado.",
                                  style: TextStyle(
                                      color: TColor.gray, fontSize: 15),
                                  textAlign: TextAlign.center),
                            ),
              SizedBox(
                height: media.width * 0.05,
              ),
              // --- INICIO NUEVA SECCIÓN: INGRESAR AL GYM ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCheckedIn ? "Salir del GYM" : "Ingresar al GYM",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              SizedBox(height: media.width * 0.03),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                    color: isCheckedIn
                        ? TColor.secondaryColor1.withOpacity(0.1)
                        : TColor.primaryColor1.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: (isCheckedIn
                                ? TColor.secondaryColor1
                                : TColor.primaryColor1)
                            .withOpacity(0.3))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      // Para que el texto no se desborde si es largo
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCheckedIn
                                ? "Registra tu salida"
                                : "Accede a tu gimnasio",
                            style: TextStyle(
                                color: TColor.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: media.width * 0.01),
                          Text(
                            isCheckedIn
                                ? "Escanea el código QR en la salida para finalizar."
                                : "Escanea el código QR en la entrada para continuar.",
                            style: TextStyle(color: TColor.gray, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    SizedBox(
                      width: media.width * 0.35,
                      height: 45,
                      child: RoundButton(
                        title: isCheckedIn ? "Escanear Salida" : "Leer QR",
                        icon: "assets/img/qr.png",
                        type: isCheckedIn
                            ? RoundButtonType.bgSGradient
                            : RoundButtonType.bgGradient,
                        fontSize: 14,
                        onPressed: () async {
                          if (_currentUserId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        "Error: ID de usuario no disponible.")));
                            return;
                          }
                          if (isCheckedIn) {
                            // --- CHECK-OUT ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeerCodigoQRView(
                                  processingMessage: "Registrando tu salida...",
                                  successMessage:
                                      "¡Hasta pronto! Salida registrada.",
                                  customValidationLogic: (qrData, expected) {
                                    // Validar que el QR sea del gym donde se hizo check-in
                                    dynamic rawGymIdQR = qrData['Name'];
                                    int? gymIdFromQR;
                                    if (rawGymIdQR is int)
                                      gymIdFromQR = rawGymIdQR;
                                    else if (rawGymIdQR is String)
                                      gymIdFromQR = int.tryParse(rawGymIdQR);
                                    int? checkedInGymIdInt =
                                        int.tryParse(_checkedInGymId ?? "");

                                    return gymIdFromQR != null &&
                                        checkedInGymIdInt != null &&
                                        gymIdFromQR == checkedInGymIdInt;
                                  },
                                  onValidQR: _performCheckOut,
                                ),
                              ),
                            );
                          } else {
                            // --- CHECK-IN ---
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LeerCodigoQRView(
                                  processingMessage:
                                      "Registrando tu ingreso...",
                                  successMessage:
                                      "¡Bienvenido! Ingreso registrado.",
                                  customValidationLogic: (qrData, expected) {
                                    dynamic rawGymId = qrData['Name'];
                                    int? gymIdFromQR;
                                    if (rawGymId is int)
                                      gymIdFromQR = rawGymId;
                                    else if (rawGymId is String)
                                      gymIdFromQR = int.tryParse(rawGymId);
                                    if (gymIdFromQR == null) return false;
                                    return ids_availables_gyms_for_user
                                        .contains(gymIdFromQR);
                                  },
                                  onValidQR: _performCheckIn,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                  height: media.width *
                      0.04), // Espacio después de la nueva sección
              // --- FIN NUEVA SECCIÓN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Próximas Clases en Vivo",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20, // Consistente con otros títulos
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {/* Navegar a vista de todas las clases */},
                    child: Text("Ver Todas",
                        style: TextStyle(
                            color: TColor.gray,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  )
                ],
              ),
              SizedBox(height: media.width * 0.01),
              _isLoadingLiveClasses
                  ? const Center(
                      child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator()))
                  : _errorLoadingLiveClasses != null
                      ? Center(
                          child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(_errorLoadingLiveClasses!,
                                  style: const TextStyle(color: Colors.red))))
                      : _liveClasses.isEmpty
                          ? Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                      "No hay clases en vivo programadas.",
                                      style: TextStyle(color: TColor.gray))))
                          : ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: _liveClasses.length > 3
                                  ? 3
                                  : _liveClasses
                                      .length, // Mostrar solo las primeras 3 o menos
                              itemBuilder: (context, index) {
                                final clase = _liveClasses[index];
                                return LiveClassRow(
                                  clase: clase,
                                  onJoinNow: () {
                                    // Lógica para unirse a la clase:
                                    // 1. Verificar si el usuario ya está inscrito.
                                    // 2. Si no, llamar al servicio de inscripción (POST /api/Bookings/classes/{classId}/register).
                                    // 3. Si la inscripción es exitosa (o ya estaba inscrito),
                                    //    navegar a la vista de la clase en vivo (usando clase.urlClaseVideo si es un link directo
                                    //    o a una pantalla intermedia que maneje la conexión a la plataforma de streaming).

                                    // Ejemplo simple de inscripción (necesitarás adaptar esto con tu servicio real)
                                    if (_currentUserId != null &&
                                        clase.urlClase != null) {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => CallPage(
                                                  callID: clase.urlClase!,
                                                  userId:
                                                      _currentUserId.toString(),
                                                  userName: "Anonimo")));
                                      // Ejemplo de llamada al servicio (debes tenerlo en BookingService o similar)
                                      /*
                                      _bookingService.registerForClass(classId: clase.idClase, userId: _currentUserId!).then((result) {
                                        if (result["success"] == true) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text("¡Inscrito! Abriendo clase..."), backgroundColor: Colors.green)
                                          );
                                          // TODO: Abrir clase.urlClaseVideo o navegar a la vista de streaming
                                          if (clase.urlClaseVideo != null && clase.urlClaseVideo!.isNotEmpty) {
                                            // launchUrl(Uri.parse(clase.urlClaseVideo!)); // Necesitas package url_launcher
                                          } else {
                                            // Navegar a una pantalla de clase sin video directo
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(result["message"] ?? "Error al unirse."), backgroundColor: Colors.red)
                                          );
                                        }
                                      });
                                      */
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text(
                                                  "Por favor, inicia sesión para unirte.")));
                                    }
                                  },
                                );
                              },
                            ),
              // --- FIN SECCIÓN PRÓXIMAS CLASES EN VIVO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Proximo entrenamiento",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "Ver Más",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                  color: TColor.primaryColor2.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_month, size: 24),
                        SizedBox(width: 8),
                        Text(
                          "Revisa tu calendario",
                          style: TextStyle(
                              color: TColor.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 70,
                      height: 25,
                      child: RoundButton(
                        title: "Revisar",
                        type: RoundButtonType.bgGradient,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        onPressed: () {},
                      ),
                    )
                  ],
                ),
              ),
              ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: latestArr.length,
                  itemBuilder: (context, index) {
                    var wObj = latestArr[index] as Map? ?? {};
                    return SiguienteEntrenamientoRow(wObj: wObj);
                  }),
              SizedBox(
                height: media.width * 0.05,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Escoge otro entrenamiento",
                    style: TextStyle(
                        color: TColor.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "ver más",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 14,
                          fontWeight: FontWeight.w700),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: media.width * 0.1,
              ),
            ],
          ),
        )),
      ),
    );
  }

  Widget _buildLiveClassesSection() {
    if (_isLoadingLiveClasses) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator()));
    }
    if (_errorLoadingLiveClasses != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_errorLoadingLiveClasses!,
                  style: const TextStyle(color: Colors.red))));
    }
    if (_liveClasses.isEmpty) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("No hay clases en vivo programadas.",
                  style: TextStyle(color: TColor.gray))));
    }
    final clasex = _liveClasses[0];
    String? id_clase = clasex.urlClase;
    debugPrint("URL DE CLASE: $id_clase");
    return ListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      // Mostrar un máximo de, por ejemplo, 3-5 clases en el home
      itemCount: _liveClasses.length > 3 ? 3 : _liveClasses.length,
      itemBuilder: (context, index) {
        final clase = _liveClasses[index];
        String? id_clase = clase.urlClase;
        debugPrint("URL DE CLASE: $id_clase");
        return LiveClassRow(
          clase: clase,
          onJoinNow: () {
            if (_currentUserId != null && clase.urlClase != null) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CallPage(
                          callID: clase.urlClase!,
                          userId: _currentUserId.toString(),
                          userName: "Anonimo")));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Por favor, inicia sesión para unirte.")));
            }
          },
        );
      },
    );
  }
  // --- FIN WIDGET HELPER ---
}
