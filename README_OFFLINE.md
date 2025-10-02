# Modo Offline (Rama `frontend_funcional`)

Esta rama contiene únicamente el frontend Flutter funcionando SIN backend ni base de datos.
Todas las operaciones se simulan en memoria mediante un `ApiService` mock.
Al cerrar la app, los datos se pierden (no hay persistencia más allá de `SharedPreferences` para el token y alguna preferencia menor).

## Características simuladas
- Registro / Login: Se genera un usuario inicial (Ana Offline) y se guarda un token falso automáticamente.
- Mascotas: Incluye una mascota inicial (Fido). Puedes crear, editar, eliminar.
- Eventos: Se crean 3 eventos de ejemplo próximos.
- Vacunas: 1 vacuna de ejemplo.
- Peso: 1 registro de peso inicial.
- Álbum / Fotos: Puedes agregar fotos (la URL que introduzcas se guarda tal cual). No hay subida real.
- Recordatorios: Se almacenan en memoria.

## Archivo principal del mock
`frontend/my_best_friend_app/lib/services/api_service.dart`

## Limitaciones
- No hay validaciones profundas de negocio.
- No existe persistencia entre sesiones (excepto token de sesión si no cierras la app por completo).
- Códigos de recuperación de contraseña: se generan y guardan internamente, sin envío de correo.

## Cómo volver al modo con backend
Cambia a la rama original (por ejemplo `developer`) donde aún existe la carpeta `backend/` y la antigua implementación de `ApiService`.

## Posibles mejoras futuras
- Añadir persistencia ligera usando Hive/Isar opcional.
- Flag runtime para alternar online/offline con `--dart-define`.
- Generador de más datos de ejemplo desde un comando interno.

---
Si necesitas que añada datos adicionales de seed o un switch online/offline, dímelo y lo implemento.
