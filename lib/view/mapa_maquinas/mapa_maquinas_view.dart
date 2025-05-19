import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ogma_trainer/common/color_extension.dart';
import 'package:ogma_trainer/models/clase_info_model.dart';
import 'package:ogma_trainer/models/machine_model.dart';
import 'package:ogma_trainer/services/equipment_service.dart';
import 'package:ogma_trainer/view/mapa_maquinas/detalle_clase_view.dart';
import 'package:ogma_trainer/view/mapa_maquinas/detalle_maquina_view.dart';

class MapaMaquinasView extends StatefulWidget {
  const MapaMaquinasView({super.key});

  @override
  State<MapaMaquinasView> createState() => _MapaMaquinasViewState();
}

class _MapaMaquinasViewState extends State<MapaMaquinasView> {
  final EquipmentService _equipmentService = EquipmentService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String? _errorMessage;

  List<Machine> _allMachines = [];
  Map<String, List<Machine>> _groupedAndFilteredMachines = {};
  String _searchTerm = "";

  List<ClaseInfo> _availableClasses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {   
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchTerm != _searchController.text) {
    debugPrint("CAMBIO DETECTADO EN EL BUSCADOR: ${_searchController.text}");
    setState(() {
      _searchTerm = _searchController.text;
      _filterAndGroupMachines();
    });
  }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _allMachines = []; // Limpiar antes de cargar
      _groupedAndFilteredMachines = {};
      _availableClasses = [];
    });
    try {
      // Cargar todas las máquinas
      _allMachines = await _equipmentService.getAllMachines();
      _filterAndGroupMachines(); // Aplicar filtro inicial (sin término de búsqueda)

      // Cargar clases (sin cambios en su lógica de carga)
      final classes = await _equipmentService.getAllClasses();
      _availableClasses = classes.where((clase) => clase.activa && clase.fechaHoraInicio.isAfter(DateTime.now())).toList();
      _availableClasses.sort((a, b) => a.fechaHoraInicio.compareTo(b.fechaHoraInicio));

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterAndGroupMachines() {
    Map<String, List<Machine>> tempGroupedMachines = {};
    List<Machine> filteredMachines;

    if (_searchTerm.isEmpty) {
      filteredMachines = _allMachines;
    } else {
      filteredMachines = _allMachines.where((machine) {
        return machine.nombre.toLowerCase().contains(_searchTerm.toLowerCase());
      }).toList();
      debugPrint("BUSCANDO: $_searchTerm ");
    }

    // Agrupar las máquinas filtradas
    for (var machine in filteredMachines) {
      if (machine.reservable && machine.estado.toLowerCase() == "disponible") {
        tempGroupedMachines.putIfAbsent(machine.tipoMaquina, () => []).add(machine);
      }
    }

      _groupedAndFilteredMachines = tempGroupedMachines;
      debugPrint("MAQUINAS FILTRADAS $_groupedAndFilteredMachines");
    
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: TColor.primaryG)),
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              // pinned: true,
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
                "Reserva tu Maquina",
                style: TextStyle(
                    color: TColor.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700),
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
            SliverAppBar(
              backgroundColor: Colors.transparent,
              centerTitle: true,
              elevation: 0,
              leadingWidth: 0,
              leading: Container(),
              expandedHeight: media.width * 0.5,
              flexibleSpace: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  "assets/img/strong_man.png",
                  width: media.width * 0.75,
                  height: media.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ];
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
              color: TColor.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25), topRight: Radius.circular(25))),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Buscar máquina por nombre...",
                      hintStyle: TextStyle(color: TColor.gray.withOpacity(0.7)),
                      prefixIcon: Icon(Icons.search, color: TColor.gray),
                      suffixIcon: _searchTerm.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: TColor.gray),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged(); // El listener ya lo hace
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: TColor.lightGray.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    ),
                  ),
                ),
                Expanded(
                  child: _isLoading
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
                                        onPressed: _loadData,
                                        child: const Text("Reintentar"))
                                  ],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  Container(/* ... La barrita gris ... */),
                                  SizedBox(height: media.width * 0.05),
                  
                                  // --- SECCIÓN DE MÁQUINAS AGRUPADAS ---
                                  if (_groupedAndFilteredMachines.isNotEmpty)
                                    ..._groupedAndFilteredMachines.entries.map((entry) {
                                      String tipoMaquina = entry.key;
                                      List<Machine> machinesInType = entry.value;
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 10.0),
                                            child: Text(
                                              tipoMaquina, // Nombre del grupo (ej. "Cardio", "Fuerza Piernas")
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: TColor.black),
                                            ),
                                          ),                                          
                                          SizedBox(
                                            height:
                                                180, // Altura para la fila de máquinas
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: machinesInType.length,
                                              itemBuilder: (context, index) {
                                                Machine machine =
                                                    machinesInType[index];
                                                return MachineCard(
                                                    machine: machine); // Nuevo widget
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                      );
                                    }).toList()
                                  else if (_searchTerm.isNotEmpty && !_isLoading) // Si hay búsqueda y no hay resultados
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                                      child: Center(child: Text("No se encontraron máquinas para '$_searchTerm'.", style: TextStyle(color: TColor.gray, fontSize: 16), textAlign: TextAlign.center,)),
                                    )
                                  else if (_allMachines.isEmpty && !_isLoading) // Si no hay máquinas cargadas en absoluto
                                     Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                                      child: Center(child: Text("No hay máquinas disponibles en este momento.", style: TextStyle(color: TColor.gray, fontSize: 16), textAlign: TextAlign.center,)),
                                    ),
                  
                                  // --- SECCIÓN DE CLASES DISPONIBLES ---
                                  if (_availableClasses.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20.0, bottom: 10.0),
                                      child: Text(
                                        "Clases Disponibles",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: TColor.black),
                                      ),
                                    ),
                                  if (_availableClasses.isNotEmpty)
                                    ListView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: _availableClasses.length,
                                      itemBuilder: (context, index) {
                                        ClaseInfo clase = _availableClasses[index];
                                        return ClaseCard(
                                            claseInfo: clase); // Nuevo widget
                                      },
                                    ),
                                  SizedBox(
                                      height: media.width * 0.1), // Espacio al final
                                ],
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
}

class MachineCard extends StatelessWidget {
  final Machine machine;
  const MachineCard({super.key, required this.machine});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleMaquinaView(machine: machine,                                
              ),
            ),
          );
      },
      child: Container(
        width: media.width * 0.45, // Un poco más de ancho para la imagen
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: TColor.white, // Fondo blanco para la tarjeta
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: TColor.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded( 
              flex: 3, 
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15), bottom: Radius.circular(15)),
                child: machine.urlImagen != null && machine.urlImagen!.isNotEmpty
                    ? Image.network(
                        machine.urlImagen!,
                        fit: BoxFit.cover, // Cubrir el área
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(child: CircularProgressIndicator(
                             value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                              strokeWidth: 2,
                          ));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container( // Placeholder si la imagen falla
                            color: TColor.lightGray,
                            alignment: Alignment.center,
                            child: Icon(Icons.fitness_center, size: 40, color: TColor.gray.withOpacity(0.5)),
                          );
                        },
                      )
                    : Container( // Placeholder si no hay URL de imagen
                        color: TColor.lightGray,
                        alignment: Alignment.center,
                        child: Icon(Icons.fitness_center, size: 40, color: TColor.gray.withOpacity(0.5)),
                      ),
              ),
            ),
            Expanded( // Para el texto
              flex: 2, // Dar menos espacio al texto que a la imagen
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, // Centrar texto verticalmente
                  children: [
                    Text(
                      machine.nombre,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: TColor.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      machine.tipoMaquina,
                      style: TextStyle(fontSize: 12, color: TColor.gray),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class ClaseCard extends StatelessWidget {
  final ClaseInfo claseInfo;
  const ClaseCard({super.key, required this.claseInfo});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias, 
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetalleClaseView(claseInfo: claseInfo,                                
              ),
            ),
          );
        },
        child: Stack(
          alignment: Alignment.bottomLeft, // Alinear el contenido de texto abajo a la izquierda
          children: [
            // --- IMAGEN DE FONDO ---
            if (claseInfo.urlImagen != null && claseInfo.urlImagen!.isNotEmpty)
              Positioned.fill( // Para que la imagen ocupe todo el espacio de la tarjeta
                child: Image.network(
                  claseInfo.urlImagen!,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                  },
                  errorBuilder: (context, error, stackTrace) {
                    // Podrías tener un color de fondo si la imagen falla
                    return Container(color: TColor.primaryColor1.withOpacity(0.1));
                  },
                ),
              ),
            // --- SUPERPOSICIÓN DE COLOR (OVERLAY) ---
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.7), // Más oscuro abajo
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.2),
                      Colors.transparent, // Transparente arriba
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.0, 0.3, 0.6, 1.0] // Controlar la transición del gradiente
                  ),
                ),
              ),
            ),
            // --- CONTENIDO DE TEXTO ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Para que la columna no ocupe más de lo necesario
                children: [
                  Text(
                    claseInfo.nombreClase,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Texto blanco para contraste
                        fontSize: 18,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black54)] // Sombra para legibilidad
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${claseInfo.tipo} - ${claseInfo.duracionMinutos} min",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        shadows: [Shadow(blurRadius: 1, color: Colors.black45)]
                        ),
                  ),
                  Text(
                    "Inicio: ${DateFormat('dd/MM HH:mm').format(claseInfo.fechaHoraInicio)}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        shadows: [Shadow(blurRadius: 1, color: Colors.black45)]
                        ),
                  ),
                ],
              ),
            ),
             // --- TRAILING ICON (OPCIONAL, puede interferir con el texto si el fondo es complejo) ---
            Positioned(
              top: 10,
              right: 10,
              child: Icon(Icons.arrow_forward_ios, size: 18, color: Colors.white.withOpacity(0.8)),
            )
          ],
        ),
      ),
    );
  }
}