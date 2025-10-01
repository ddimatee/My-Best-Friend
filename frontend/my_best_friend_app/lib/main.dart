import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'providers/mascotas_provider.dart';
import 'providers/vacunas_provider.dart';
import 'providers/peso_provider.dart';
import 'providers/album_provider.dart';
import 'providers/eventos_provider.dart';
import 'modulo_general/introduccion.dart';
import 'modulo_general/menu_principal.dart';
import 'modulo_general/buscar.dart';
import 'modulo_configuracion/pantallas/perfil_pantalla.dart';
import 'modulo_configuracion/pantallas/preferencias_pantalla.dart';
import 'modulo_configuracion/pantallas/notificaciones_pantalla.dart';
import 'modulo_configuracion/pantallas/cuenta_sesion_pantalla.dart';
import 'modulo_configuracion/pantallas/comentarios_soporte_pantalla.dart';
import 'modulo_calendario/calendario_modulo_pantalla.dart';
import 'modulo_eventos/eventos_pantalla.dart';
import 'modulo_album/album_modulo_pantalla.dart';
import 'modulo_dueno/dueno_modulo_pantalla.dart';
import 'utils/test_conexion_screen.dart';
import 'providers/auth_provider.dart';

// Punto de entrada de la aplicación My Best Friend.

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicialización protegida para evitar que la app no arranque silenciosamente
  await _inicializarServiciosSeguros();
  runApp(const MyApp());
}

Future<void> _inicializarServiciosSeguros() async {
  try {
    await NotificationService().init();
    // Inicializar múltiples localizaciones en paralelo
    await Future.wait([
      initializeDateFormatting('es', null),
      initializeDateFormatting('es_ES', null),
      initializeDateFormatting('es_MX', null),
    ]);
  } catch (e, st) {
    // Mostrar en consola para diagnóstico, pero no impedir que la UI cargue
    // (por ejemplo, si el plugin de notificaciones no está disponible en la plataforma actual)
    debugPrint('Error al inicializar servicios: $e');
    debugPrint(st.toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MascotasProvider()),
        ChangeNotifierProvider(create: (_) => VacunasProvider()),
        ChangeNotifierProvider(create: (_) => PesoProvider()),
        ChangeNotifierProvider(create: (_) => AlbumProvider()),
        ChangeNotifierProvider(create: (_) => EventosProvider()),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'My Best Friend',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        ),
        // Configuración de localizaciones (nuestro delegate personalizado va después
        // para sobreescribir las abreviaturas del calendario)
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', ''), // Español genérico
        ],
        locale: const Locale('es'), // Idioma por defecto
        home: OnboardingScreens(),
        routes: {
          '/menu': (_) => const MenuPrincipal(),
          '/buscar': (_) => const BuscarPantalla(),
          '/calendario': (_) => const CalendarioModuloPantalla(),
          '/eventos': (_) => const EventosPantalla(),
          '/album': (_) => const AlbumModuloPantalla(),
          '/dueno': (_) => const DuenoModuloPantalla(),
          '/config/perfil': (_) => const PerfilPantalla(),
          '/config/preferencias': (_) => const PreferenciasPantalla(),
          '/config/notificaciones': (_) => const NotificacionesPantalla(),
          '/config/cuenta': (_) => const CuentaSesionPantalla(),
          '/config/soporte': (_) => const ComentariosSoportePantalla(),
          '/test-conexion': (_) => const TestConexionScreen(),
        },
      ),
    );
  }
}
