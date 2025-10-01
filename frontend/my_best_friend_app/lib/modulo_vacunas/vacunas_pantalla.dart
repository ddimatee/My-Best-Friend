import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/vacunas_provider.dart';
import '../../providers/mascotas_provider.dart';
import 'detalle_vacuna.dart';
import 'formulario_vacuna.dart';
import '../modulo_general/widgets/bottom_nav_global.dart';

class VacunasPantalla extends StatefulWidget {
  const VacunasPantalla({Key? key}) : super(key: key);

  @override
  State<VacunasPantalla> createState() => _VacunasPantallaState();
}

class _VacunasPantallaState extends State<VacunasPantalla> {
  final Color _greenColor = const Color(0xFF4CAF50);
  String? _mascotaSeleccionada; // filtro opcional

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vacProv = context.read<VacunasProvider>();
      // Cargar todas (o podrías decidir esperar a que el usuario seleccione una mascota)
      vacProv.cargarVacunas();
    });
  }

  void _navegarAFormulario() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FormularioVacuna(),
      ),
    );
    if (resultado == true) {
      context.read<VacunasProvider>().cargarVacunas(mascotaId: _mascotaSeleccionada, forzar: true);
    }
  }

  void _navegarADetalle(Map<String, dynamic> vacuna) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetalleVacuna(vacuna: vacuna),
      ),
    );
    if (resultado == true) {
      context.read<VacunasProvider>().cargarVacunas(mascotaId: _mascotaSeleccionada, forzar: true);
    }
  }

  Widget _buildVacunaCard(Map<String, dynamic> vacuna) {
    final nombre = vacuna['nombre'] ?? 'Vacuna';
    final fechaAplicacion = DateTime.tryParse(vacuna['fechaAplicacion']?.toString() ?? '') ?? DateTime.now();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navegarADetalle(vacuna),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: _greenColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.medical_services,
                color: _greenColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'De: ${DateFormat('d MMM, yyyy').format(fechaAplicacion)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  if (vacuna['recordatorio']?['activo'] == true && vacuna['recordatorio']?['fechaRecordatorio'] != null)
                    Builder(
                      builder: (context) {
                        try {
                          final fechaRecordatorioUTC = DateTime.parse(vacuna['recordatorio']['fechaRecordatorio'].toString());
                          final fechaRecordatorioLocal = fechaRecordatorioUTC.toLocal();
                          final hora = DateFormat('h:mm a').format(fechaRecordatorioLocal);
                          return Text(
                            hora,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          );
                        } catch (e) {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.edit,
              color: Colors.black54,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Imagen de la veterinaria
          Image.asset(
            'assets/images/perro_vacuna_2.png',
            width: 200,
            height: 200,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: _greenColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Icon(
                  Icons.pets,
                  size: 80,
                  color: _greenColor,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'No se han encontrado Vacunas\nregistradas :(',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _navegarAFormulario,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
            child: const Text(
              'Crear',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vacProv = context.watch<VacunasProvider>();
    final mascotasProv = context.watch<MascotasProvider>();
    final listaMascotas = mascotasProv.mascotas;
    
    // Si no hay mascota seleccionada ("Todas"), obtener todas las vacunas
    final vacunas = (_mascotaSeleccionada == null)
        ? vacProv.todasLasVacunas() // Obtener todas las vacunas
        : vacProv.vacunasDe(_mascotaSeleccionada!);

    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        backgroundColor: _greenColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Vacunas', style: TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _navegarAFormulario,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Selector de mascota (simple dropdown)
            if (listaMascotas.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: DropdownButtonFormField<String>(
                  value: _mascotaSeleccionada,
                  decoration: const InputDecoration(
                    labelText: 'Filtrar por mascota',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
                  ),
                  items: [
                    const DropdownMenuItem<String>(value: null, child: Text('Todas', overflow: TextOverflow.ellipsis)),
                    ...listaMascotas.map((m) => DropdownMenuItem<String>(
                          value: m['_id'] ?? m['id'],
                          child: Text(m['nombre'] ?? 'Mascota', overflow: TextOverflow.ellipsis),
                        ))
                  ].cast<DropdownMenuItem<String>>(),
                  onChanged: (val) {
                    setState(() => _mascotaSeleccionada = val);
                    context.read<VacunasProvider>().cargarVacunas(mascotaId: val, forzar: true);
                  },
                ),
              ),
          Expanded(
            child: vacProv.cargando
                ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : (vacunas.isEmpty)
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 16),
                        itemCount: vacunas.length,
                        itemBuilder: (context, index) => _buildVacunaCard(vacunas[index]),
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavGlobal(selectedIndex: 0),
    );
  }
}

// _BottomItem eliminado en favor de BottomNavGlobal