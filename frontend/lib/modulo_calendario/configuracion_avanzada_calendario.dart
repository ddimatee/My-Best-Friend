import 'package:flutter/material.dart';
import 'confirmacion_final_calendario.dart';
import 'modelos/evento_calendario.dart';

class ConfiguracionAvanzadaCalendario extends StatefulWidget {
  final String descripcion;
  final String categoria;
  final String frecuencia;
  final DateTime fecha;
  final TimeOfDay hora;
  final bool notificacionActivada;
  final String tipoNotificacion;
  final int minutosAntes;
  final EventoCalendario? recordatorioParaEditar; // Recordatorio a editar (opcional)
  final Map<String, dynamic>? mascota; // Información de la mascota seleccionada
  
  const ConfiguracionAvanzadaCalendario({
    Key? key,
    required this.descripcion,
    required this.categoria,
    required this.frecuencia,
    required this.fecha,
    required this.hora,
    required this.notificacionActivada,
    required this.tipoNotificacion,
    required this.minutosAntes,
    this.recordatorioParaEditar,
    this.mascota,
  }) : super(key: key);

  @override
  State<ConfiguracionAvanzadaCalendario> createState() => _ConfiguracionAvanzadaCalendarioState();
}

class _ConfiguracionAvanzadaCalendarioState extends State<ConfiguracionAvanzadaCalendario> {
  final Color _greenColor = const Color(0xFF4CAF50); // Verde consistente con la app
  final Color _grayColor = const Color(0xFFE5E5E5);
  
  bool _sonidoActivado = true;
  bool _vibracionActivada = true;
  String _prioridadNotificacion = 'alta';
  bool _mostrarEnPantallaBloqueada = true;
  String _categoriaNotificacion = 'recordatorios';
  bool _repetirSiNoSeVe = false;
  int _intervalosRepeticion = 5;

  @override
  void initState() {
    super.initState();
    // Si estamos editando, podríamos precargar configuraciones avanzadas
    // Por ahora dejamos los valores por defecto, ya que el modelo EventoCalendario
    // no incluye estas propiedades avanzadas
  }

  void _continuar() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmacionFinalCalendario(
          descripcion: widget.descripcion,
          categoria: widget.categoria,
          frecuencia: widget.frecuencia,
          fecha: widget.fecha,
          hora: widget.hora,
          notificacionActivada: widget.notificacionActivada,
          tipoNotificacion: widget.tipoNotificacion,
          minutosAntes: widget.minutosAntes,
          sonidoActivado: _sonidoActivado,
          vibracionActivada: _vibracionActivada,
          prioridadNotificacion: _prioridadNotificacion,
          mostrarEnPantallaBloqueada: _mostrarEnPantallaBloqueada,
          categoriaNotificacion: _categoriaNotificacion,
          repetirSiNoSeVe: _repetirSiNoSeVe,
          intervalosRepeticion: _intervalosRepeticion,
          recordatorioParaEditar: widget.recordatorioParaEditar,
          mascota: widget.mascota,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _greenColor,
      appBar: AppBar(
        backgroundColor: _grayColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header gris
          Container(
            width: double.infinity,
            color: _grayColor,
            padding: const EdgeInsets.only(bottom: 20),
            child: const Center(
              child: Text(
                'Configuración avanzada',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          
          // Cuerpo verde con configuraciones avanzadas
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Personaliza tu experiencia de notificación:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Sonido y vibración
                  _ConfiguracionCard(
                    titulo: 'Sonido y vibración',
                    icono: Icons.volume_up,
                    children: [
                      _SwitchItem(
                        titulo: 'Sonido de notificación',
                        valor: _sonidoActivado,
                        onChanged: (value) => setState(() => _sonidoActivado = value),
                      ),
                      _SwitchItem(
                        titulo: 'Vibración',
                        valor: _vibracionActivada,
                        onChanged: (value) => setState(() => _vibracionActivada = value),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Prioridad
                  _ConfiguracionCard(
                    titulo: 'Prioridad de notificación',
                    icono: Icons.priority_high,
                    children: [
                      _DropdownItem<String>(
                        titulo: 'Nivel de prioridad',
                        valor: _prioridadNotificacion,
                        items: const [
                          ('baja', 'Baja'),
                          ('normal', 'Normal'),
                          ('alta', 'Alta'),
                          ('urgente', 'Urgente'),
                        ],
                        onChanged: (value) => setState(() => _prioridadNotificacion = value!),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Visibilidad
                  _ConfiguracionCard(
                    titulo: 'Visibilidad',
                    icono: Icons.visibility,
                    children: [
                      _SwitchItem(
                        titulo: 'Mostrar en pantalla bloqueada',
                        valor: _mostrarEnPantallaBloqueada,
                        onChanged: (value) => setState(() => _mostrarEnPantallaBloqueada = value),
                      ),
                      _DropdownItem<String>(
                        titulo: 'Categoría de notificación',
                        valor: _categoriaNotificacion,
                        items: const [
                          ('recordatorios', 'Recordatorios'),
                          ('salud', 'Salud de mascotas'),
                          ('general', 'General'),
                          ('urgente', 'Urgente'),
                        ],
                        onChanged: (value) => setState(() => _categoriaNotificacion = value!),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Repetición
                  _ConfiguracionCard(
                    titulo: 'Opciones de repetición',
                    icono: Icons.repeat,
                    children: [
                      _SwitchItem(
                        titulo: 'Repetir si no se ve la notificación',
                        valor: _repetirSiNoSeVe,
                        onChanged: (value) => setState(() => _repetirSiNoSeVe = value),
                      ),
                      if (_repetirSiNoSeVe)
                        _DropdownItem<int>(
                          titulo: 'Intervalo de repetición (minutos)',
                          valor: _intervalosRepeticion,
                          items: const [
                            (1, '1 minuto'),
                            (2, '2 minutos'),
                            (5, '5 minutos'),
                            (10, '10 minutos'),
                            (15, '15 minutos'),
                          ],
                          onChanged: (value) => setState(() => _intervalosRepeticion = value!),
                        ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Botón Continuar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _continuar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Finalizar configuración',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        height: 64,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _BottomItem(
              icon: Icons.pets,
              selected: true,
              onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
            ),
            _BottomItem(
              icon: Icons.calendar_month,
              selected: false,
              onTap: () {},
            ),
            _BottomItem(
              icon: Icons.settings,
              selected: false,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfiguracionCard extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final List<Widget> children;

  const _ConfiguracionCard({
    required this.titulo,
    required this.icono,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, size: 24, color: const Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final String titulo;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _SwitchItem({
    required this.titulo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }
}

class _DropdownItem<T> extends StatelessWidget {
  final String titulo;
  final T valor;
  final List<(T, String)> items;
  final ValueChanged<T?> onChanged;

  const _DropdownItem({
    required this.titulo,
    required this.valor,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          DropdownButton<T>(
            value: valor,
            items: items.map((item) => DropdownMenuItem<T>(
              value: item.$1,
              child: Text(item.$2),
            )).toList(),
            onChanged: onChanged,
            underline: const SizedBox(),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  
  const _BottomItem({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: selected
              ? const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))]
              : null,
        ),
        child: Icon(icon, size: 28, color: Colors.black),
      ),
    );
  }
}