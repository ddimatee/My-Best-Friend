import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'modelos/evento_calendario.dart';
import 'servicios/calendario_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../modulo_eventos/modelos/evento.dart';
import '../providers/eventos_provider.dart';
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
  
  // Listas para almacenar recordatorios
  List<EventoCalendario> _recordatorios = [];
  List<Map<String, dynamic>> _recordatoriosVacunas = [];
  // Caché local de eventos del provider para evitar problemas con context
  Map<String, List<Map<String, dynamic>>> _eventosCache = {};
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
      // Cargar todo en paralelo para mejor rendimiento
      final auth = mounted ? context.read<AuthProvider>() : null;
      final currentUserId = auth?.user?['_id']?.toString();
      // Purga inicial (descarta eventos de otros usuarios si existían en SharedPreferences)
      if (currentUserId != null) {
        await CalendarioService.purgarEventosDeOtrosUsuarios(currentUserId);
      }
      final recordatorios = await CalendarioService.obtenerEventos(currentUserId: currentUserId);
      final recordatoriosVacunas = await CalendarioService.obtenerRecordatoriosVacunas();
      
      setState(() {
  _recordatorios = recordatorios;
        _recordatoriosVacunas = recordatoriosVacunas;
      });
      
      // Cargar eventos del mes usando el provider si el context está disponible
      if (mounted) {
        await _cargarEventosDelMes();
      }
      
      setState(() {
        _isLoading = false;
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    } catch (e) {
      print('Error al cargar datos del calendario: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _cargarEventosDelMes() async {
    if (!mounted) return;
    
    try {
      final eventosProvider = context.read<EventosProvider>();
      
      // Cargar solo el día actual inicialmente para mostrar rápido
      await eventosProvider.cargarDia(_selectedDay ?? DateTime.now(), forzar: true);
      
      // Actualizar caché con los eventos cargados
      final keyActual = _key(_selectedDay ?? DateTime.now());
      final eventosActuales = eventosProvider.eventosDeDia(keyActual);
      if (eventosActuales.isNotEmpty) {
        _eventosCache[keyActual] = List.from(eventosActuales);
      }
      
      // Cargar el resto del mes en segundo plano
      final primerDiaMes = DateTime(_focusedDay.year, _focusedDay.month, 1);
      final ultimoDiaMes = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);
      _cargarRestoDeMesEnSegundoPlano(eventosProvider, primerDiaMes, ultimoDiaMes);
    } catch (e) {
      print('Error al cargar eventos del mes: $e');
    }
  }

  void _cargarRestoDeMesEnSegundoPlano(
    EventosProvider provider,
    DateTime inicio,
    DateTime fin,
  ) {
    // Cargar días del mes en lotes pequeños
    Future.microtask(() async {
      final diasACargar = <DateTime>[];
      for (int dia = inicio.day; dia <= fin.day; dia++) {
        final fecha = DateTime(inicio.year, inicio.month, dia);
        // No recargar el día ya cargado
        if (!isSameDay(fecha, _selectedDay)) {
          diasACargar.add(fecha);
        }
      }
      
      // Cargar en lotes de 5 días para no saturar
      for (int i = 0; i < diasACargar.length; i += 5) {
        final lote = diasACargar.skip(i).take(5);
        await Future.wait(
          lote.map((fecha) => provider.cargarDia(fecha, forzar: false)),
        );
        
        // Actualizar caché después de cada lote
        if (mounted) {
          setState(() {
            for (final fecha in lote) {
              final key = _key(fecha);
              final eventos = provider.eventosDeDia(key);
              if (eventos.isNotEmpty) {
                _eventosCache[key] = List.from(eventos);
              }
            }
          });
        }
        
        // Pequeña pausa entre lotes para no bloquear
        await Future.delayed(const Duration(milliseconds: 100));
      }
      
      // Actualizar UI después de cargar todo
      if (mounted) {
        setState(() {
          _selectedEvents.value = _getEventsForDay(_selectedDay!);
        });
      }
    });
  }

  void _cargarEventosDelNuevoMes(DateTime nuevoMes) {
    if (!mounted) return;
    
    final eventosProvider = context.read<EventosProvider>();
    final primerDia = DateTime(nuevoMes.year, nuevoMes.month, 1);
    final ultimoDia = DateTime(nuevoMes.year, nuevoMes.month + 1, 0);
    
    // Cargar en segundo plano
    _cargarRestoDeMesEnSegundoPlano(eventosProvider, primerDia, ultimoDia);
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    List<dynamic> eventos = [];
    
    // Agregar recordatorios del día
    for (final recordatorio in _recordatorios) {
      if (_isEventForDay(recordatorio.fechaHora, day)) {
        eventos.add(recordatorio);
      }
    }
    
    // Agregar eventos del día desde la caché local (más seguro que usar context aquí)
    final keyDia = _key(day);
    final eventosDelDia = _eventosCache[keyDia] ?? [];
    eventos.addAll(eventosDelDia);
    
    // Agregar recordatorios de vacunas del día
    for (final recordatorioVacuna in _recordatoriosVacunas) {
      try {
        final fechaUTC = DateTime.parse(recordatorioVacuna['fechaHora']);
        final fechaLocal = fechaUTC.toLocal(); // Convertir de UTC a hora local
        if (_isEventForDay(fechaLocal, day)) {
          eventos.add(recordatorioVacuna);
        }
      } catch (e) {
        // Si hay error al parsear la fecha, continuar
        print('Error al parsear fecha de recordatorio de vacuna: $e');
      }
    }
    
    return eventos;
  }

  String _key(DateTime d) => '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

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

      // Cargar eventos del día seleccionado si no están cargados y actualizar caché
      if (mounted) {
        final eventosProvider = context.read<EventosProvider>();
        eventosProvider.cargarDia(selectedDay, forzar: false).then((_) {
          if (mounted) {
            setState(() {
              final key = _key(selectedDay);
              final eventos = eventosProvider.eventosDeDia(key);
              if (eventos.isNotEmpty) {
                _eventosCache[key] = List.from(eventos);
              }
            });
          }
        });
      }

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
    Color _colorTipo(String? tipo) {
      switch (tipo) {
        case 'veterinario': return Colors.redAccent;
        case 'alimentacion': return Colors.orangeAccent;
        case 'ejercicio': return Colors.blueAccent;
        case 'medicamento': return Colors.purpleAccent;
        case 'baño': return Colors.teal;
        case 'vacuna': return Colors.indigo;
        default: return _greenColor;
      }
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(.25), width: 1),
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
        locale: 'es_ES',
        headerVisible: true,
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: true,
          formatButtonShowsNext: false,
          formatButtonDecoration: BoxDecoration(
            color: _greenColor.withOpacity(.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _greenColor.withOpacity(.4)),
          ),
          formatButtonTextStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _greenColor.withOpacity(.9)),
          titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _greenColor.withOpacity(.9)),
          leftChevronIcon: Icon(Icons.chevron_left, color: _greenColor.withOpacity(.9)),
          rightChevronIcon: Icon(Icons.chevron_right, color: _greenColor.withOpacity(.9)),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(fontWeight: FontWeight.w600, color: _greenColor.withOpacity(.9)),
          weekendStyle: const TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent),
          dowTextFormatter: (date, locale) {
            // Reemplazar 'X' por 'M' para miércoles (petición del usuario)
            // Representación de 1 letra personalizada: L M M J V S D
            final int weekday = date.weekday; // 1 Lunes ... 7 Domingo
            const letras = ['L','M','M','J','V','S','D'];
            return letras[weekday - 1];
          },
        ),
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          isTodayHighlighted: true,
          todayDecoration: BoxDecoration(
            color: _greenColor.withOpacity(.15),
            shape: BoxShape.circle,
            border: Border.all(color: _greenColor, width: 1.5),
          ),
          selectedDecoration: BoxDecoration(
            color: _greenColor,
            shape: BoxShape.circle,
          ),
          defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
          weekendDecoration: const BoxDecoration(shape: BoxShape.circle),
          todayTextStyle: TextStyle(fontWeight: FontWeight.bold, color: _greenColor.withOpacity(.95)),
          selectedTextStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
          defaultTextStyle: TextStyle(color: Colors.grey.shade800),
          weekendTextStyle: TextStyle(color: Colors.grey.shade800),
          markersAlignment: Alignment.bottomCenter,
          markersMaxCount: 5,
        ),
        calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, day, focusedDay) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: _greenColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text('${day.day}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            );
          },
          todayBuilder: (context, day, focusedDay) {
            return Container(
              decoration: BoxDecoration(
                color: _greenColor.withOpacity(.15),
                shape: BoxShape.circle,
                border: Border.all(color: _greenColor, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text('${day.day}', style: TextStyle(color: _greenColor.withOpacity(.9), fontWeight: FontWeight.w700)),
            );
          },
          markerBuilder: (context, day, events) {
            if (events.isEmpty) return const SizedBox.shrink();
            // Pequeñas píldoras de colores por tipo de evento
            final max = events.length > 5 ? 5 : events.length;
            return Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 2,
                runSpacing: 2,
                children: List.generate(max, (i) {
                  final ev = events[i];
                  String? tipo;
                  if (ev is Map) {
                    tipo = (ev['tipo'] ?? ev['categoria'])?.toString();
                  } else {
                    try {
                      final dynamic dyn = ev;
                      final t = dyn.tipo;
                      if (t != null) tipo = t.toString();
                    } catch (_) {}
                  }
                  return Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _colorTipo(tipo),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 0.8),
                    ),
                  );
                }),
              ),
            );
          },
        ),
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() => _calendarFormat = format);
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
          _cargarEventosDelNuevoMes(focusedDay);
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
      subtitulo = '${event.categoria} • ${event.hora ?? DateFormat('HH:mm').format(event.fecha)}';
      icono = Icons.event;
      color = _greenColor;
    } else if (event is Map<String, dynamic>) {
      // Puede ser un evento del backend o un recordatorio de vacuna
      titulo = event['titulo'] ?? 'Recordatorio';
      
      // Verificar si es un recordatorio de vacuna (tiene 'fechaHora')
      if (event.containsKey('fechaHora')) {
        final fechaUTC = DateTime.parse(event['fechaHora']);
        final fechaLocal = fechaUTC.toLocal();
        final mascotaNombre = event['mascota']?['nombre'] ?? 'mascota';
        subtitulo = 'Vacuna • ${DateFormat('HH:mm').format(fechaLocal)} • $mascotaNombre';
        icono = Icons.vaccines;
        color = Colors.purple;
      } else {
        // Es un evento del backend
        final tipo = (event['tipo'] ?? event['categoria'] ?? 'evento').toString();
        final hora = event['hora'] ?? '';
        final mascotaNombre = event['mascota']?['nombre'] ?? '';
        subtitulo = '$tipo • $hora${mascotaNombre.isNotEmpty ? ' • $mascotaNombre' : ''}';
        icono = _getIconoCategoria(tipo);
        color = _greenColor;
      }
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

  IconData _getIconoCategoria(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'veterinario':
        return Icons.local_hospital;
      case 'alimentacion':
      case 'comida':
        return Icons.restaurant;
      case 'ejercicio':
      case 'paseo':
        return Icons.directions_walk;
      case 'medicamento':
        return Icons.medical_services;
      case 'baño':
        return Icons.bathtub;
      default:
        return Icons.event;
    }
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
