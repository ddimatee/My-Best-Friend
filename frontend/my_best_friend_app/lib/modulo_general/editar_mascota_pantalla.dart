import 'package:flutter/material.dart';
import 'datos/mascota_model.dart';

class EditarMascotaPantalla extends StatefulWidget {
  final String mascotaId;
  const EditarMascotaPantalla({super.key, required this.mascotaId});

  @override
  State<EditarMascotaPantalla> createState() => _EditarMascotaPantallaState();
}

class _EditarMascotaPantallaState extends State<EditarMascotaPantalla> {
  final MascotasRepo _repo = MascotasRepo();
  bool _cargando = true;
  
  // Controladores para los campos editables
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  
  // Variables para los campos de selección
  String? _sexoSeleccionado;
  String? _situacionSeleccionada;
  DateTime? _cumpleanos;
  bool? _seguimiento;
  Set<String> _estiloVida = {};
  bool? _coCuidado;
  String? _rolSeleccionado;
  
  // Opciones predefinidas
  final List<String> _opcionesSexo = ['Macho', 'Hembra'];
  final List<String> _opcionesSituacion = [
    'Acabo de tener un perro',
    'Ya conozco bien a mi perro'
  ];
  final List<String> _opcionesRol = ['Dueño', 'Cuidador'];
  final List<String> _opcionesEstiloVida = [
    'Soy una persona de ciudad',
    'Me gusta recibir gente',
    'Tengo hijos',
    'Me estreso mucho',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    _cargarMascota();
  }

  void _cargarMascota() {
    final mascota = _repo.obtener(widget.mascotaId);
    if (mascota == null) {
      Navigator.pop(context);
      return;
    }
    
    // Debug: Imprimir los datos de la mascota
    print('=== DATOS DE LA MASCOTA ===');
    print('Nombre: ${mascota.nombre}');
    print('Sexo: ${mascota.sexo}');
    print('Situación: ${mascota.situacion}');
    print('Raza: ${mascota.raza}');
    print('Cumpleaños: ${mascota.cumpleanos}');
    print('Seguimiento: ${mascota.seguimiento}');
    print('Estilo de vida: ${mascota.estiloVida}');
    print('Co-cuidado: ${mascota.coCuidado}');
    print('Rol: ${mascota.rol}');
    print('==========================');
    
    setState(() {
      _nombreController.text = mascota.nombre;
      _razaController.text = mascota.raza ?? '';
      _sexoSeleccionado = mascota.sexo; // Puede ser null para mascotas viejas
      _situacionSeleccionada = mascota.situacion; // Puede ser null para mascotas viejas
      _cumpleanos = mascota.cumpleanos;
      _seguimiento = mascota.seguimiento; // Puede ser null para mascotas viejas
      _estiloVida = Set.from(mascota.estiloVida); // El getter maneja null automáticamente
      _coCuidado = mascota.coCuidado; // Puede ser null para mascotas viejas
      _rolSeleccionado = mascota.rol; // Puede ser null para mascotas viejas
      _cargando = false;
    });
  }

  void _guardarCambios() {
    _repo.actualizar(
      widget.mascotaId,
      nombre: _nombreController.text.trim().isNotEmpty 
          ? _nombreController.text.trim() 
          : null,
      cumpleanos: _cumpleanos,
      situacion: _situacionSeleccionada,
      sexo: _sexoSeleccionado,
      raza: _razaController.text.trim().isNotEmpty 
          ? _razaController.text.trim() 
          : null,
      seguimiento: _seguimiento,
      estiloVida: _estiloVida,
      coCuidado: _coCuidado,
      rol: _rolSeleccionado,
    );
    
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Información actualizada correctamente')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Editar información',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _guardarCambios,
            child: const Text(
              'Guardar',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSeccionNombre(),
            const SizedBox(height: 24),
            _buildSeccionSexo(),
            const SizedBox(height: 24),
            _buildSeccionCumpleanos(),
            const SizedBox(height: 24),
            _buildSeccionRaza(),
            const SizedBox(height: 24),
            _buildSeccionSituacion(),
            const SizedBox(height: 24),
            _buildSeccionSeguimiento(),
            const SizedBox(height: 24),
            _buildSeccionEstiloVida(),
            const SizedBox(height: 24),
            _buildSeccionCoCuidado(),
            const SizedBox(height: 24),
            _buildSeccionRol(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionNombre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nombre',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _nombreController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: 'Nombre de tu mascota',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionSexo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sexo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _opcionesSexo.map((opcion) {
            final seleccionado = _sexoSeleccionado == opcion;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => setState(() => _sexoSeleccionado = opcion),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: seleccionado ? const Color(0xFF4CAF50) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: seleccionado ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                      ),
                    ),
                    child: Text(
                      opcion,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: seleccionado ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeccionCumpleanos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de nacimiento',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final fechaSeleccionada = await showDatePicker(
              context: context,
              initialDate: _cumpleanos ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 30)), // 30 años atrás
              lastDate: DateTime.now(),
              locale: const Locale('es', 'ES'),
            );
            if (fechaSeleccionada != null) {
              setState(() => _cumpleanos = fechaSeleccionada);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 12),
                Text(
                  _cumpleanos != null
                      ? '${_cumpleanos!.day}/${_cumpleanos!.month}/${_cumpleanos!.year}'
                      : 'Seleccionar fecha',
                  style: TextStyle(
                    color: _cumpleanos != null ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionRaza() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Raza',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _razaController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              hintText: 'Ej: Labrador, Mestizo, etc.',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionSituacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Situación',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: _opcionesSituacion.map((opcion) {
            final seleccionado = _situacionSeleccionada == opcion;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GestureDetector(
                onTap: () => setState(() => _situacionSeleccionada = opcion),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: seleccionado ? const Color(0xFF4CAF50) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: seleccionado ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        seleccionado ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                        color: seleccionado ? Colors.white : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opcion,
                          style: TextStyle(
                            color: seleccionado ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeccionSeguimiento() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seguimiento de comidas y vacunas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _seguimiento = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _seguimiento == true ? const Color(0xFF4CAF50) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _seguimiento == true ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                    ),
                  ),
                  child: Text(
                    'Sí',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _seguimiento == true ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _seguimiento = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _seguimiento == false ? const Color(0xFF4CAF50) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _seguimiento == false ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                    ),
                  ),
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _seguimiento == false ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeccionEstiloVida() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estilo de vida',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Selecciona todas las que correspondan',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _opcionesEstiloVida.map((opcion) {
            final seleccionado = _estiloVida.contains(opcion);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (seleccionado) {
                    _estiloVida.remove(opcion);
                  } else {
                    _estiloVida.add(opcion);
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: seleccionado ? const Color(0xFF4CAF50) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: seleccionado ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                  ),
                ),
                child: Text(
                  opcion,
                  style: TextStyle(
                    color: seleccionado ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSeccionCoCuidado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '¿Cuidas con alguien más?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _coCuidado = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _coCuidado == true ? const Color(0xFF4CAF50) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _coCuidado == true ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                    ),
                  ),
                  child: Text(
                    'Sí',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _coCuidado == true ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _coCuidado = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _coCuidado == false ? const Color(0xFF4CAF50) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _coCuidado == false ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                    ),
                  ),
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _coCuidado == false ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSeccionRol() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu rol',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _opcionesRol.map((opcion) {
            final seleccionado = _rolSeleccionado == opcion;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: GestureDetector(
                  onTap: () => setState(() => _rolSeleccionado = opcion),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: seleccionado ? const Color(0xFF4CAF50) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: seleccionado ? const Color(0xFF4CAF50) : Colors.grey.shade400,
                      ),
                    ),
                    child: Text(
                      opcion,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: seleccionado ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    super.dispose();
  }
}