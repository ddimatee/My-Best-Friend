import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _i = NotificationService._internal();
  factory NotificationService() => _i;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    // Las notificaciones locales no están soportadas en web
    if (kIsWeb) { _initialized = true; return; }
    tzdata.initializeTimeZones();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (resp) {
      // Manejar taps futuros (deep link) si se quiere
    });

    final androidImplementation = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
    _initialized = true;
  }

  int _idFromString(String input) {
    // Hash simple estable dentro de rango int positivo
    return input.hashCode & 0x7fffffff;
  }

  Future<void> scheduleEventReminder({
    required String eventoId,
    required DateTime fechaEvento,
    required String titulo,
    String? body,
    required int minutosAntes,
  }) async {
    await init();
    final scheduled = fechaEvento.subtract(Duration(minutes: minutosAntes));
    if (scheduled.isBefore(DateTime.now())) return; // No programar si ya pasó

    final id = _idFromString(eventoId);
    final androidDetails = const AndroidNotificationDetails(
      'eventos_recordatorios',
      'Recordatorios de eventos',
      channelDescription: 'Notificaciones antes de eventos de mascotas',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );
    final notifDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      titulo,
      body ?? 'Tienes un evento próximo',
      tz.TZDateTime.from(scheduled, tz.local),
      notifDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelEventReminder(String eventoId) async {
    final id = _idFromString(eventoId);
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
}
