import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
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

// Punto de entrada de la aplicación My Best Friend.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializar múltiples localizaciones
  await initializeDateFormatting('es', null);
  await initializeDateFormatting('es_ES', null);
  await initializeDateFormatting('es_MX', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        Locale('es', 'ES'), // Español España
      ],
      locale: const Locale('es', 'ES'), // Idioma por defecto
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
      },
    );
  }
}
