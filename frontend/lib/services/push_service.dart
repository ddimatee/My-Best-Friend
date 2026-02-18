import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'api_service.dart';

/// Gestiona inicialización de Firebase Messaging, permisos y envío del token al backend.
class PushService {
  PushService._internal();
  static final PushService _i = PushService._internal();
  factory PushService() => _i;

  bool _initialized = false;
  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  Future<void> init({bool solicitarPermisos = true}) async {
    if (_initialized) return;
    // En web, Firebase necesita opciones explícitas (google-services no aplica).
    // Saltamos completamente en web para no bloquear el arranque.
    if (kIsWeb) { _initialized = true; return; }
    await Firebase.initializeApp();

    // En Web evitamos inicializar flutter_local_notifications (no tiene soporte completo / service worker maneja push).
    if (!kIsWeb) {
      // Config canal local para mostrar mensajes foreground (Android)
      const androidChannel = AndroidNotificationChannel(
        'push_general',
        'Notificaciones generales',
        description: 'Mensajes push y promociones',
        importance: Importance.high,
      );
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _fln.initialize(const InitializationSettings(android: androidInit));
      await _fln
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }

    if (solicitarPermisos) {
      await _pedirPermisos();
    }

    // Handlers
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    if (!kIsWeb) {
      // onBackgroundMessage no aplica para Web (usa service worker separado)
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    }

    _initialized = true;
  }

  Future<void> _pedirPermisos() async {
    try {
      NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
        alert: true, badge: true, sound: true, announcement: false, carPlay: false, criticalAlert: false, provisional: true,
      );
      debugPrint('FirebaseMessaging permission: ${settings.authorizationStatus}');
      // Nota: Evitamos usar dart:io (Platform.isAndroid) para compatibilidad Web.
      // En Android 13+, POST_NOTIFICATIONS se maneja dentro de requestPermission().
    } catch (e) {
      debugPrint('Error solicitando permisos push: $e');
    }
  }

  Future<String?> obtenerYRegistrarTokenBackend() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final api = ApiService();
        // Se ignora la respuesta; best-effort (requiere usuario autenticado con header)
        await api.registrarDeviceToken(token);
      }
      return token;
    } catch (e) {
      debugPrint('Error obteniendo token FCM: $e');
      return null;
    }
  }

  Future<void> suscribirseConsejos(bool on) async {
    if (on) {
      await FirebaseMessaging.instance.subscribeToTopic('consejos');
    } else {
      await FirebaseMessaging.instance.unsubscribeFromTopic('consejos');
    }
  }

  void _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (!kIsWeb && notification != null && notification.android != null) {
      await _fln.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'push_general',
            'Notificaciones generales',
            channelDescription: 'Mensajes push y promociones',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: message.data['tipo'] ?? 'general',
      );
    }
  }
}

/// Handler de mensajes en background (top-level function requerida).
/// La anotación asegura que el entry-point no sea eliminado por tree-shaking en release.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  // Asegurar inicialización mínima
  await Firebase.initializeApp();
  // Podrías guardar el mensaje localmente o generar una notificación manual.
}
