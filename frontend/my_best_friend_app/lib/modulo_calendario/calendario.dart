import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'modelos/evento_calendario.dart';
import 'servicios/calendario_service.dart';
import '../modulo_eventos/modelos/evento.dart';
import '../modulo_eventos/servicios/evento_service.dart';
import 'calendario_modulo_pantalla.dart';
import '../modulo_eventos/eventos_pantalla.dart';

// Pantalla principal del calendario de la barra inferior
class CalendarioPantalla extends StatefulWidget {
  const CalendarioPantalla({Key? key}) : super(key: key);

  @override
  State<CalendarioPantalla> createState() => _CalendarioPantallaState();
}

class _CalendarioPantallaState extends State<CalendarioPantalla> {
  late final ValueNotifier<List<dynamic>> _selectedEvents;
  late final PageController _pageController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Color _greenColor = const Color(0xFF4CAF50);
  
  // Listas para almacenar recordatorios y eventos
  List<EventoCalendario> _recordatorios = [];
  List<Evento> _eventos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _pageController = PageController();
    _cargarDatos();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      // Cargar recordatorios y eventos en paralelo
      final recordatorios = await CalendarioService.obtenerEventos();
      final eventos = await EventoService.obtenerEventos();
      
      setState(() {
        _recordatorios = recordatorios;
        _eventos = eventos;
        _isLoading = false;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    List<dynamic> eventos = [];
    
    // Agregar recordatorios del día
    for (final recordatorio in _recordatorios) {
      if (_isEventForDay(recordatorio.fechaHora, day)) {
        eventos.add(recordatorio);
      }
    }
    
    // Agregar eventos del día
    for (final evento in _eventos) {
      if (_isEventForDay(evento.fecha, day)) {
        eventos.add(evento);
      }
    }
    
    return eventos;
  }

  bool _isEventForDay(DateTime eventDate, DateTime day) {
    return eventDate.year == day.year &&
           eventDate.month == day.month &&
           eventDate.day == day.day;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _mostrarDialogoCrear() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Quiero...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              _OpcionCrear(
                icono: Icons.check_circle_outline,
                titulo: 'Crear un recordatorio',
                onTap: () {
                  Navigator.pop(context);
                  _navegarARecordatorio();
                },
              ),
              const SizedBox(height: 15),
              _OpcionCrear(
                icono: Icons.event,
                titulo: 'Registrar un evento',
                onTap: () {
                  Navigator.pop(context);
                  _navegarAEvento();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _navegarARecordatorio() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CalendarioModuloPantalla(),
      ),
    );
    
    if (resultado == true) {
      _cargarDatos(); // Recargar datos si se creó algo
    }
  }

  void _navegarAEvento() async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EventosPantalla(),
      ),
    );
    
    if (resultado == true) {
      _cargarDatos(); // Recargar datos si se creó algo
    }
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar<dynamic>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.monday,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Mes',
          CalendarFormat.twoWeeks: '2 Semanas',
          CalendarFormat.week: 'Semana',
        },
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          markerDecoration: BoxDecoration(
            color: _greenColor,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: _greenColor,
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: _greenColor.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: Colors.transparent,
          ),
          formatButtonTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 12,
          ),
        ),
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekendStyle: TextStyle(color: Colors.red),
        ),
        locale: 'es_ES',
        selectedDayPredicate: (day) {
          return isSameDay(_selectedDay, day);
        },
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildEventsList() {
    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: _selectedEvents,
      builder: (context, events, _) {
        if (events.isEmpty) {
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'No se han encontrado\nactividades para esta fecha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _mostrarDialogoCrear,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: const BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  child: const Text(
                    'Crear',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Actividades del ${DateFormat('d MMMM', 'es_ES').format(_selectedDay!)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      onPressed: _mostrarDialogoCrear,
                      icon: const Icon(Icons.add_circle_outline),
                      color: _greenColor,
                    ),
                  ],
                ),
              ),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: events.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _buildEventItem(event);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventItem(dynamic event) {
    String titulo = '';
    String subtitulo = '';
    IconData icono = Icons.event;
    Color color = _greenColor;

    if (event is EventoCalendario) {
      titulo = event.titulo;
      subtitulo = '${event.categoria} • ${DateFormat('HH:mm').format(event.fechaHora)}';
      icono = Icons.check_circle_outline;
      color = Colors.orange;
    } else if (event is Evento) {
      titulo = event.titulo;
      subtitulo = '${event.categoria} • ${DateFormat('HH:mm').format(event.fecha)}';
      icono = Icons.event;
      color = _greenColor;
    }

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icono, color: color, size: 20),
      ),
      title: Text(
        titulo,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitulo,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      onTap: () {
        // Aquí puedes agregar navegación al detalle
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCalendar(),
          _buildEventsList(),
          const SizedBox(height: 100), // Espacio para la barra inferior
        ],
      ),
    );
  }
}

class _OpcionCrear extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final VoidCallback onTap;

  const _OpcionCrear({
    required this.icono,
    required this.titulo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icono,
                color: const Color(0xFF4CAF50),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
