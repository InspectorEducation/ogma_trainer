import 'package:flutter/material.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/services/auth_service.dart';
import 'package:ogma_trainer/services/storage_service.dart';
import 'package:ogma_trainer/services/user_service.dart';
import 'package:ogma_trainer/view/perfil/editar_perfil_view.dart';

import '../../common_widget/round_button.dart';
import '../../common_widget/setting_row.dart';
import '../../common_widget/title_subtitle_cell.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final UserService _userService = UserService();
  final StorageService _storageService = StorageService();

  // Estado para los datos del perfil
  bool _isLoading = true;
  String? _errorMessage;

  // Datos del perfil básico
  String _nombre = "Cargando...";
  String _apellido = "";
  String? _fotoUrl;
  String _programaActual = "Programa...";
  String? _emailDelUsuario;
  String? _fechaNacimientoOriginal;
  String? _generoOriginal;
  String? _telefonoOriginal;

  // Datos de información personal/física
  String _alturaDisplay = "- cm";
  String _pesoDisplay = "- kg";
  String _edadDisplay = "- años";

  bool positive = false;

  String membershipType = "Gold"; // Puede ser Gold, Platinum o Diamante
  String membershipStatus =
      "A punto de vencer"; // Puede ser Activa, En mora o A punto de vencer
  int daysToExpire = 7; // Días restantes si está a punto de vencer

  List accountArr = [
    {
      "image": "assets/img/p_personal.png",
      "name": "Información personal",
      "tag": "1"
    },
    {"image": "assets/img/p_achi.png", "name": "Logros", "tag": "2"},
    {
      "image": "assets/img/p_activity.png",
      "name": "Historial de actividad",
      "tag": "3"
    },
    {
      "image": "assets/img/p_workout.png",
      "name": "Progreso del entrenamiento",
      "tag": "4"
    }
  ];

  List otherArr = [
    {"image": "assets/img/p_contact.png", "name": "Contactanos", "tag": "5"},
    {
      "image": "assets/img/p_privacy.png",
      "name": "Politica de privacidad",
      "tag": "6"
    },
    {"image": "assets/img/p_setting.png", "name": "Configuración", "tag": "7"},
  ];

  @override
  void initState() {
    super.initState();
    _loadUserProfileData();
  }

  Future<void> _loadUserProfileData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? userId = await _storageService.getUserId();
    if (userId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            "No se pudo obtener el ID de usuario. Por favor, inicia sesión de nuevo.";
      });
      return;
    }

    try {
      // Cargar perfil básico
      final profileResult = await _userService.getUserProfile(userId);
      if (profileResult["success"] == true && profileResult["data"] != null) {
        final data = profileResult["data"];
        _nombre = data['nombre'] ?? "Usuario";
        _apellido = data['apellido'] ?? "";
        _fotoUrl = data['fotoUrl'];
        _emailDelUsuario = data['email'];
        _fechaNacimientoOriginal = data['fechaNacimiento'];
        _generoOriginal = data['genero'];
        _telefonoOriginal = data['telefono'];

        if (data['fechaNacimiento'] != null) {
          try {
            DateTime fechaNac = DateTime.parse(data['fechaNacimiento']);
            _edadDisplay = "${_calculateAge(fechaNac)} años";
          } catch (e) {
            debugPrint("Error parseando fechaNacimiento: $e");
            _edadDisplay = "- años";
          }
        }
      } else {
        throw Exception(
            profileResult["message"] ?? "Error al cargar perfil básico.");
      }

      // Cargar información personal/física
      final personalInfoResult =
          await _userService.getUserPersonalInformation(userId);
      if (personalInfoResult["success"] == true &&
          personalInfoResult["data"] != null) {
        final data = personalInfoResult["data"];
        _alturaDisplay =
            data['alturaCm'] != null ? "${data['alturaCm']}cm" : "- cm";
        _pesoDisplay =
            data['pesoActualKg'] != null ? "${data['pesoActualKg']}kg" : "- kg";
        _programaActual = data['objetivoPrincipal'] ?? "Programa...";
      } else {
        debugPrint(
            "Advertencia al cargar info personal: ${personalInfoResult["message"]}");
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      debugPrint("Error cargando datos del perfil: $e");
    }
  }

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return age < 0 ? 0 : age;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        title: Text(
          "Perfil",
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Error: $_errorMessage",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.red[700])),
                        const SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: _loadUserProfileData,
                            child: const Text("Reintentar"))
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(35), // Más redondeado
                              child: _fotoUrl != null && _fotoUrl!.isNotEmpty
                                  ? Image.network(
                                      // Cargar imagen desde URL
                                      _fotoUrl!,
                                      width: 70, // Más grande
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          // Fallback si la URL falla
                                          "assets/img/u1.png", // Tu imagen por defecto
                                          width: 70,
                                          height: 70,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          width: 70,
                                          height: 70,
                                          alignment: Alignment.center,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      // Imagen por defecto si no hay URL
                                      "assets/img/u1.png",
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$_nombre $_apellido", // Nombre y apellido combinados
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 18, // Más grande
                                      fontWeight:
                                          FontWeight.bold, // Más énfasis
                                    ),
                                  ),
                                  Text(
                                    _programaActual, // Usar la variable de estado
                                    style: TextStyle(
                                      color: TColor.gray,
                                      fontSize: 14, // Más grande
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 80, // Ancho ajustado
                              height: 30, // Altura ajustada
                              child: RoundButton(
                                title: "Editar",
                                type: RoundButtonType
                                    .bgSGradient, // Diferente tipo para destacar
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                onPressed: () async {
                                  final Map<String, dynamic> currentUserData = {
                                    'nombre': _nombre,
                                    'apellido': _apellido,
                                    'email': _emailDelUsuario,
                                    'fechaNacimiento': _fechaNacimientoOriginal,
                                    'genero': _generoOriginal,
                                    'telefono': _telefonoOriginal,
                                  };
                                  final result = await Navigator.push<bool>(
                                    // Esperar el resultado booleano
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditarPerfilView(
                                        initialUserData: currentUserData,
                                      ),
                                    ),
                                  );

                                  if (result == true && mounted) {
                                    _loadUserProfileData();
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 25), // Más espacio
                        Row(
                          children: [
                            Expanded(
                              child: TitleSubtitleCell(
                                title:
                                    _alturaDisplay, // Usar la variable de estado
                                subtitle: "Altura",
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TitleSubtitleCell(
                                title:
                                    _pesoDisplay, // Usar la variable de estado
                                subtitle: "Peso",
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: TitleSubtitleCell(
                                title:
                                    _edadDisplay, // Usar la variable de estado
                                subtitle: "Edad",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        // Información de la membresía
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                            color: TColor.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 2)
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Membresía",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Tipo: $membershipType",
                                    style: TextStyle(
                                      color: TColor.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "Estado: $membershipStatus",
                                    style: TextStyle(
                                      color: membershipStatus == "En mora"
                                          ? Colors.red
                                          : TColor.black,
                                    ),
                                  ),
                                  if (membershipStatus == "A punto de vencer")
                                    Text(
                                      "Días restantes: $daysToExpire",
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              Image.asset(
                                "assets/img/m_gold.png",
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ],
                          ),
                        ), //finaliza menbresia
                        const SizedBox(
                          height: 25,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                              color: TColor.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Cuenta",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: accountArr.length,
                                itemBuilder: (context, index) {
                                  var iObj = accountArr[index] as Map? ?? {};
                                  return SettingRow(
                                    icon: iObj["image"].toString(),
                                    title: iObj["name"].toString(),
                                    onPressed: () {},
                                  );
                                },
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                              color: TColor.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Notificaciones",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              SizedBox(
                                height: 30,
                                child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                          "assets/img/p_notification.png",
                                          height: 15,
                                          width: 15,
                                          fit: BoxFit.contain),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Recibir notificaciones",
                                          style: TextStyle(
                                            color: TColor.black,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      CustomAnimatedToggleSwitch<bool>(
                                        current: positive,
                                        values: [false, true],
                                        dif: 0.0,
                                        indicatorSize: Size.square(30.0),
                                        animationDuration:
                                            const Duration(milliseconds: 200),
                                        animationCurve: Curves.linear,
                                        onChanged: (b) =>
                                            setState(() => positive = b),
                                        iconBuilder: (context, local, global) {
                                          return const SizedBox();
                                        },
                                        defaultCursor: SystemMouseCursors.click,
                                        onTap: () => setState(
                                            () => positive = !positive),
                                        iconsTappable: false,
                                        wrapperBuilder:
                                            (context, global, child) {
                                          return Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                  left: 10.0,
                                                  right: 10.0,
                                                  height: 30.0,
                                                  child: DecoratedBox(
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          colors: TColor
                                                              .secondaryG),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  50.0)),
                                                    ),
                                                  )),
                                              child,
                                            ],
                                          );
                                        },
                                        foregroundIndicatorBuilder:
                                            (context, global) {
                                          return SizedBox.fromSize(
                                            size: const Size(10, 10),
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: TColor.white,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(50.0)),
                                                boxShadow: const [
                                                  BoxShadow(
                                                      color: Colors.black38,
                                                      spreadRadius: 0.05,
                                                      blurRadius: 1.1,
                                                      offset: Offset(0.0, 0.8))
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ]),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          decoration: BoxDecoration(
                              color: TColor.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 2)
                              ]),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Preferencias",
                                style: TextStyle(
                                  color: TColor.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: otherArr.length,
                                itemBuilder: (context, index) {
                                  var iObj = otherArr[index] as Map? ?? {};
                                  return SettingRow(
                                    icon: iObj["image"].toString(),
                                    title: iObj["name"].toString(),
                                    onPressed: () {},
                                  );
                                },
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
