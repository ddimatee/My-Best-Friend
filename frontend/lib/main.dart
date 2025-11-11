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
import 'providers/recordatorios_provider.dart';
import 'modulo_general/introduccion.dart';
import 'modulo_general/menu_principal.dart';
import 'modulo_general/buscar.dart';
import 'modulo_autenticacion/inicio_sesion.dart';
import 'modulo_configuracion/pantallas/perfil_pantalla.dart';
import 'modulo_configuracion/pantallas/notificaciones_pantalla.dart';
import 'modulo_configuracion/pantallas/cuenta_sesion_pantalla.dart';
import 'modulo_configuracion/pantallas/comentarios_soporte_pantalla.dart';
import 'modulo_calendario/calendario_modulo_pantalla.dart';
import 'modulo_eventos/eventos_pantalla.dart';
import 'modulo_album/album_modulo_pantalla.dart';
import 'modulo_dueno/dueno_modulo_pantalla.dart';
import 'providers/auth_provider.dart';
import 'services/push_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Punto de entrada de la aplicación My Best Friend.

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _inicializarServiciosSeguros();
  runApp(const MyApp());
}

Future<void> _inicializarServiciosSeguros() async {
  try {
    await NotificationService().init();
    try { await PushService().init(); } catch (e) { debugPrint('Error init push: $e'); }
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _loadingPref = true;
  bool _showOnboarding = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferenciaOnboarding();
  }

  Future<void> _cargarPreferenciaOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final seen = prefs.getBool('has_seen_onboarding') ?? false;
      setState(() {
        _showOnboarding = !seen; // Mostrar onboarding si NO lo ha visto
        _loadingPref = false;
      });
    } catch (e) {
      setState(() { _loadingPref = false; _showOnboarding = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingPref) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MascotasProvider()),
        ChangeNotifierProvider(create: (_) => VacunasProvider()),
        ChangeNotifierProvider(create: (_) => PesoProvider()),
        ChangeNotifierProvider(create: (_) => AlbumProvider()),
        ChangeNotifierProvider(create: (_) => EventosProvider()),
        ChangeNotifierProvider(create: (_) => RecordatoriosProvider()),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'My Best Friend',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF50)),
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', ''),
        ],
        locale: const Locale('es'),
  home: _showOnboarding ? OnboardingScreens(onFinish: _marcarOnboardingVisto) : LoginScreen(),
        routes: {
          '/menu': (_) => const MenuPrincipal(),
          '/buscar': (_) => const BuscarPantalla(),
          '/calendario': (_) => const CalendarioModuloPantalla(),
          '/eventos': (_) => const EventosPantalla(),
          '/album': (_) => const AlbumModuloPantalla(),
          '/dueno': (_) => const DuenoModuloPantalla(),
          '/config/perfil': (_) => const PerfilPantalla(),
          '/config/notificaciones': (_) => const NotificacionesPantalla(),
          '/config/cuenta': (_) => const CuentaSesionPantalla(),
          '/config/soporte': (_) => const ComentariosSoportePantalla(),
        },
      ),
    );
  }

  Future<void> _marcarOnboardingVisto() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      setState(() { _showOnboarding = false; });
    }
  }
}
