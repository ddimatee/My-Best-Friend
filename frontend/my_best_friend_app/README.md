# My Best Friend (Flutter)

Aplicación Flutter orientada solo a Android (se retiró soporte iOS/macOS/Linux para simplificar el proyecto).

## Plataformas soportadas
- ✅ Android
- ❌ iOS (no necesario actualmente)
- ❌ macOS / Linux / Web (no en esta fase; web aún puede permanecer pero no se mantiene)

Si en el futuro quieres volver a generar alguna plataforma eliminada:
```
flutter create --platforms=android,ios,linux,macos,web .
```
(añade sólo las que necesites)

## Ícono de la app
Generado con `flutter_launcher_icons` a partir de `assets/icon/app_icon.png`.
Para regenerar:
```
flutter pub run flutter_launcher_icons
```

## Comandos básicos
```
flutter pub get
flutter run
```

## Estructura breve
```
lib/
	main.dart
	modulo_autenticacion/
	...
assets/
	images/
	icon/app_icon.png
```

## Próximos pasos sugeridos
- Añadir splash screen: `flutter_native_splash`
- Configurar flavors (dev / prod) si se requiere.

---
Este README fue ajustado tras la limpieza para reflejar el alcance real del proyecto.
