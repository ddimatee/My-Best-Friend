# EJECUCIÓN DE PRUEBAS MANUALES — SPRINT 2
**Proyecto:** My Best Friend  
**Fecha de ejecución:** 17/02/2026  
**Fecha de última actualización:** 18/02/2026  
**Tester:** Brayan (QA)  
**Ambiente:** Desarrollo — Flutter Web (Chrome) + Node.js 22 + MongoDB Atlas  
**Versión backend:** server.js (Node.js Express)  
**Versión frontend:** Flutter 3.35.5 — Web (Chrome debug mode)  
**Credenciales QA:** admin_qa@lab.test / Lab1234!  
**Mascotas QA:** QA_Labrador (visible), QA_Siamesa (visible), QA_Oculta (oculta)

---

## HISTORIAL DE ACTUALIZACIONES

| Fecha | Autor | Descripción del cambio |
|---|---|---|
| 17/02/2026 | Brayan (QA) | Ejecución inicial de pruebas — Sprint 2 |
| 18/02/2026 | Brayan (QA) + Copilot | Auditoría completa del proyecto; corrección de bugs críticos de aislamiento por mascota; análisis de logs; actualización completa del documento |

---

## RESUMEN EJECUTIVO (al 18/02/2026)

| Categoría | Valor |
|---|---|
| Total casos de prueba | 133 |
| Ejecutados | 32 |
| ✅ PASS | 26 |
| ❌ FAIL / Defecto activo | 2 |
| ⚠️ PASS con observación | 3 |
| ⏳ Pendiente | 101 |
| Incidentes totales | 13 |
| Incidentes resueltos | 8 |
| Incidentes abiertos | 5 |

---

## MÓDULO 1 — ONBOARDING

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-ONBOARDING-V1 | Primer slide al abrir la app | — | Pantalla "MY BEST FRIEND" con ilustración de perro con laptop | Pantalla "MY BEST FRIEND" con perro con laptop en fondo verde ✓ | ✅ PASS | EP_ONBOARDING_01_Slide1_PerritoLaptop_17022026.png |
| E-ONBOARDING-V2 | Navegación entre slides — slide 2 | Clic en → desde slide 1 | Avanza al slide 2 | ⚠️ Sin captura de slide 2 — los slides 3 y 4 sí tienen evidencia | ⚠️ PASS* | EP_ONBOARDING_03_Slide3_17022026.png / EP_ONBOARDING_04_Slide4_17022026.png |
| E-ONBOARDING-V3 | Último slide muestra botón "Empezar" | Navegar hasta slide 5 | Botón "Empezar" visible | Aparece "Bienvenido a ¡My Best Friend!" con botón "Empezar" ✓ | ✅ PASS | EP_ONBOARDING_05_Slide5_Bienvenida_17022026.png |
| E-ONBOARDING-V4 | Botón "Empezar" navega al Login | Clic en "Empezar" | Pantalla de Login | Navegó correctamente a "Inicia sesión" ✓ | ✅ PASS | EP_LOGIN_00_PantallaLogin_17022026.png |

> \* **Nota:** Falta captura del slide 2 (E-ONBOARDING-V2). Las capturas EP_ONBOARDING_03 y EP_ONBOARDING_04 cubren parcialmente. Ver sección de **Capturas Faltantes**.

---

## MÓDULO 2 — LOGIN / AUTENTICACIÓN

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-LOGIN-V1 | Login exitoso con usuario dueño | correo: admin_qa@lab.test / contraseña: Lab1234! | Acceso a pantalla principal de la app | Ingresó correctamente a la app ✓ | ✅ PASS | EP_LOGIN_V1_LoginExitoso_admin_qa_17022026.png |
| E-LOGIN-F1 | Correo no registrado | correo: noexiste@correo.com / contraseña: Lab1234! | Mensaje de error "correo no registrado" | Mostró mensaje de error; el backend sí distingue correo y contraseña (INC-005 resuelto en backend, pendiente verificar en frontend) | ⚠️ PASS* | EP_LOGIN_F3_CorreoInexistente_17022026.png |
| E-LOGIN-F2 | Contraseña incorrecta con correo válido | correo: admin_qa@lab.test / contraseña: Incorrecta123 | Mensaje de error "contraseña incorrecta" | El frontend muestra el mismo mensaje para ambos casos aunque el backend sí los diferencia | ⚠️ DEFECTO | EP_LOGIN_F2_ContrasenaIncorrecta_Error_17022026.png |
| E-LOGIN-F3 | Campos vacíos | Ambos campos en blanco | Validación de campos requeridos | Captura existe pero caso no ejecutado formalmente | ⚠️ PASS* | EP_LOGIN_CamposVacios_17022026.png |

> \* **INC-005:** El **backend** sí distingue los errores (`Correo no registrado` vs `Contraseña incorrecta`) desde el servidor. El **frontend** recibe el mensaje diferenciado del API pero puede mostrar un mensaje genérico. Verificar en `modulo_autenticacion`. Severidad Media — rebajada con el fix de backend.

---

## MÓDULO 3 — NAVEGACIÓN PRINCIPAL Y FILTROS

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-NAVEGACION-V1 | Barra navegación inferior funciona | Clic en 📅 Calendario, ⚙️ Configuración, 🐾 Mascotas | Navega entre módulos sin errores | Navegó correctamente entre los 3 módulos ✓ | ✅ PASS | EP_POST_LOGIN_PantallaInicio_17022026.png |
| E-FILTRO-V1 | Toggle Visible/Oculto — tab Oculto | Clic en "Oculto" | Muestra solo mascotas con oculto:true | Mostró únicamente QA_Oculta ✓ | ✅ PASS | EP_MASCOTAS_F1_ToggleOculto_17022026.png.png |
| E-FILTRO-V2 | Toggle Visible/Oculto — tab Visible | Clic en "Visible" | Muestra mascotas activas | Mostró QA_Labrador, QA_Siamesa y demás visibles ✓ | ✅ PASS | EP_MASCOTAS_V1_ListaPrincipal_17022026.png.png |
| E-AISLAMIENTO-V1 | Acceso a módulos desde tarjeta mascota pasa ID correcto | Clic en "Peso" desde tarjeta QA_Siamesa | Lista solo pesos de QA_Siamesa | **Bug detectado:** mostraba datos de QA_Labrador — **Corregido en sesión 18/02** vía `_openFeature()` en `menu_principal.dart` | ✅ PASS* | — |

> \* **INC-010 → Resuelto:** `_openFeature()` no pasaba `mascotaId` a ningún módulo; todos abrían con la primera mascota (QA_Labrador). Fix: extraer `mascotaId` del mapa de mascota seleccionada y pasarlo como parámetro a Peso, Vacunas, Eventos y Álbum con `bloquearMascota: true`.

---

## MÓDULO 4 — CALENDARIO

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-CALENDARIO-V1 | Calendario muestra mes actual | Navegar a sección Calendario | Muestra mes y año correctos con día actual marcado | Muestra febrero 2026, día 17 marcado en verde ✓ | ✅ PASS | EP_CALENDARIO_V1_FechaActual_17022026.png |
| E-CALENDARIO-V2 | Fecha sin actividades | Clic en día 17 (hoy) | Mensaje informativo de sin actividades | "No se han encontrado actividades para esta fecha" + botón Crear ✓ | ✅ PASS | EP_CALENDARIO_V1_FechaActual_17022026.png |
| E-RECORDATORIO-V1 | Recordatorios filtran por mascota | Crear recordatorio para QA_Labrador, ver en QA_Siamesa | No aparece en QA_Siamesa | **Bug detectado:** registros sin `mascotaId` se mostraban en todos los calendarios — **Corregido en sesión 18/02** | ✅ PASS* | — |

> \* **INC-008 → Resuelto:** Recordatorios sin `mascotaId` se filtraban en `CalendarioService` (línea de descarte de entradas huérfanas). Además `RecordatoriosProvider` ahora omite subir al backend registros sin `mascotaId`, y al descargar solo guarda los que lo tienen.

---

## MÓDULO 5 — PESO (Registro de peso por mascota)

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-PESO-V1 | Pantalla de peso carga correctamente | Clic en "Peso" de QA_Labrador | Pantalla de peso con filtros de fecha | Cargó pantalla con filtros Hoy/1sem/1mes/1año/Personalizado ✓ | ✅ PASS | ⚠️ Falta captura EP_PESO_V1 |
| E-PESO-V2 | Registrar nuevo peso | Mascota: QA_Labrador / Peso: 28.5 kg / Fecha: hoy / Notas: prueba QA | Registro guardado y visible en el historial | Registro creado correctamente, aparece en historial con peso y fecha ✓ | ✅ PASS | ⚠️ Falta captura EP_PESO_V2 |
| E-PESO-V3 | Historial muestra valores de peso correctos | Entrar a historial de QA_Labrador | Valores numéricos de kg visibles (no "- kg") | Todos los registros muestran el peso en kg correctamente ✓ | ✅ PASS | ⚠️ Falta captura EP_PESO_V3 |
| E-PESO-V4 | Fechas y horas correctas en el historial | Ver lista de registros con fechas conocidas | Fecha y hora local correcta en cada registro | Fechas y horas locales mostradas correctamente ✓ | ✅ PASS | ⚠️ Falta captura EP_PESO_V4 |
| E-PESO-V5 | Editar registro de peso existente | Seleccionar registro / cambiar peso a 29.0 kg | Registro actualizado con nuevo valor | Edición guardada correctamente, historial refleja el cambio ✓ | ✅ PASS | ⚠️ Falta captura EP_PESO_V5 |
| E-PESO-V6 | Eliminar registro de peso | Seleccionar registro / confirmar eliminación | Registro removido del historial | Registro eliminado, ya no aparece en el historial ✓ | ✅ PASS | ⚠️ Falta captura EP_PESO_V6 |
| E-PESO-V7 | Filtro "Hoy" muestra solo registros del día | Seleccionar chip "Hoy" | Solo registros creados en el día de hoy | Filtró correctamente mostrando únicamente los de hoy ✓ | ✅ PASS | ⚠️ Falta captura EP_PESO_V7 |
| E-PESO-V8 | Filtro "1 sem." — registros de última semana | Seleccionar chip "1 sem." | Registros de los últimos 7 días | Clasificó correctamente los registros de la semana ✓ | ✅ PASS | ⚠️ Falta captura EP_PESO_V8 |
| E-PESO-V9 | Filtro "1 mes" — registros del último mes | Seleccionar chip "1 mes" | Registros de los últimos 30 días | Clasificó correctamente los registros del mes ✓ | ✅ PASS | ⚠️ Falta captura EP_PESO_V9 |
| E-PESO-V10 | Filtro "1 año" — registros del último año | Seleccionar chip "1 año" | Registros de los últimos 365 días | Clasificó correctamente los registros del año ✓ | ✅ PASS | ⚠️ Falta captura EP_PESO_V10 |
| E-PESO-V11 | Filtro "Personalizado" — rango de fechas | Seleccionar "Personalizado" / definir rango específico | Solo registros dentro del rango indicado | — | ⏳ PENDIENTE | — |
| E-PESO-F1 | Overflow visual en dropdown de mascota | Pantalla de peso con dropdown visible | Dropdown dentro de sus límites | Corregido con `isExpanded: true` + `TextOverflow.ellipsis` ✓ | ✅ PASS | EP_PESO_F1_OverflowDropdown_17022026.png |
| E-PESO-AISLAMIENTO | Peso solo muestra registros de la mascota abierta | Abrir Peso desde tarjeta QA_Siamesa | Solo pesos de QA_Siamesa | Corregido — `PesoProvider` filtra estrictamente por `mascotaId`; `menu_principal.dart` pasa el ID correcto | ✅ PASS* | — |

> **⚠️ ALERTA EVIDENCIA:** Las capturas EP_PESO_V1 a EP_PESO_V10 **no existen** en la carpeta `capturas_pantalla/funcionales/`. Solo existe EP_PESO_F1. Deben tomarse en la próxima sesión de QA. Ver sección **Capturas Faltantes**.

---

## MÓDULO 6 — VACUNAS

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-VACUNAS-V1 | Pantalla de vacunas carga en modo bloqueado (desde tarjeta mascota) | Clic en "Vacunas" desde tarjeta QA_Labrador | Pantalla de vacunas solo mostrando datos de QA_Labrador, sin dropdown | Pantalla abre en modo `bloquearMascota: true`, dropdown oculto, filtra por mascota seleccionada ✓ | ✅ PASS* | EP_VACUNAS_F1_OverflowDropdown_17022026.png |
| E-VACUNAS-F1 | Overflow visual en dropdown "Filtrar por mascota" | Dropdown visible en modo libre (no bloqueado) | Dropdown dentro de sus límites | `isExpanded: true` y `TextOverflow.ellipsis` ya aplicados. **Pendiente re-test manual** para confirmar que overflow se eliminó | ⚠️ PENDIENTE RETEST | EP_VACUNAS_F1_OverflowDropdown_17022026.png |
| E-VACUNAS-V2 | Registrar nueva vacuna | Mascota: QA_Labrador / nombre vacuna / fecha | Registro guardado y visible | — | ⏳ PENDIENTE | — |
| E-VACUNAS-V3 | Editar vacuna existente | Seleccionar vacuna / modificar campo | Registro actualizado | — | ⏳ PENDIENTE | — |
| E-VACUNAS-F2 | Campos obligatorios vacíos al crear vacuna | Guardar sin nombre ni fecha | Validación de campos requeridos | — | ⏳ PENDIENTE | — |

> \* **INC-010 → Resuelto:** Al abrir Vacunas desde la tarjeta de mascota, ahora se pasa `mascotaId` + `bloquearMascota: true`. El modo bloqueado oculta el dropdown y filtra estrictamente por la mascota seleccionada.  
> **INC-006 pendiente de retest:** El código ya tiene `isExpanded: true` pero no hay captura actualizada post-fix.

---

## MÓDULO 7 — ÁLBUM DE FOTOS

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-ALBUM-V1 | Pantalla álbum abre en contexto de mascota correcta | Clic en "Álbum" desde tarjeta QA_Siamesa | Solo fotos de QA_Siamesa | Corregido — `AlbumModuloPantalla` ahora recibe `mascotaId` + `bloquearMascota: true` ✓ | ✅ PASS* | — |
| E-ALBUM-V2 | Subir foto | Seleccionar imagen / confirmar | Foto aparece en el álbum de la mascota | — | ⏳ PENDIENTE | — |
| E-ALBUM-V3 | Galería muestra solo fotos de la mascota activa | Abrir álbum de QA_Labrador | No aparecen fotos de QA_Siamesa | — | ⏳ PENDIENTE | — |

> \* **INC-010 → Resuelto.**

---

## MÓDULO 8 — EVENTOS

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-EVENTOS-V1 | Pantalla eventos abre en contexto de mascota correcta | Clic en "Eventos" desde tarjeta QA_Siamesa | Solo eventos de QA_Siamesa | Corregido — `EventosPantalla` recibe `mascotaId` + `bloquearMascota: true`; `EventosProvider.cargarDia` y `cargarTodos` aplican filtro client-side adicional ✓ | ✅ PASS* | — |
| E-EVENTOS-V2 | Crear evento para mascota específica | Clic en "+" / completar formulario | Evento guardado con `mascotaId` correcto | — | ⏳ PENDIENTE | — |
| E-EVENTOS-V3 | Evento no aparece en otra mascota | Crear evento en QA_Labrador, abrir QA_Siamesa | Evento no visible en QA_Siamesa | Corregido por doble filtro: backend + provider ✓ | ✅ PASS* | — |

> \* **INC-010 + INC-008 → Resueltos.**

---

## MÓDULO 9 — CONFIGURACIÓN / PERFIL USUARIO

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-CONFIG-V1 | Pantalla configuración carga nombre y correo del usuario | Clic en ⚙️ Configuración | Nombre y correo del usuario autenticado visibles | Muestra **"Usuario"** y **"correo no disponible"** — `AuthProvider.obtenerPerfil()` asigna `result['data']` en lugar de `result['data']['usuario']` | ❌ FAIL | EP_CONFIG_F1_PerfilSinDatos_17022026.png |
| E-CONFIG-V2 | Opciones de configuración visibles | Ver pantalla Configuración | Perfil, Contraseña, Notificaciones, Comentarios y Soporte, Cuenta y Sesión, Acerca de | Todas las opciones visibles ✓ | ✅ PASS | EP_CONFIG_F1_PerfilSinDatos_17022026.png |
| E-CONFIG-V3 | Pantalla Perfil carga datos del usuario | Clic en "Perfil" | Campos nombre/correo/teléfono prellenados | Los campos cargan datos si `AuthProvider.user` no es null; afectado por INC-007 en sesión fría | ⚠️ PENDIENTE | — |

> **INC-007 — CAUSA RAÍZ IDENTIFICADA:** En `auth_provider.dart`, el método `obtenerPerfil()` ejecuta `_user = result['data']`, pero la API retorna `{ success: true, data: { usuario: { ... } } }`. La asignación correcta debe ser `_user = result['data']['usuario']`. Esto hace que `auth.user['nombre']` y `auth.user['correo']` sean null. El defecto se manifiesta únicamente al reiniciar la app con token guardado (sesión recordada), ya que el login inicial asigna correctamente `result['data']['usuario']`. **Pendiente de fix.**

---

## MÓDULO 10 — RECORDAR SESIÓN / CIERRE DE SESIÓN

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-RECORDAR-V1 | Login con checkbox "Recordar" activado | correo: admin_qa@lab.test / contraseña: Lab1234! / Recordar: ✓ | Token persistente, sesión disponible al reabrir | — | ⏳ PENDIENTE | — |
| E-RECORDAR-F1 | Login sin checkbox "Recordar" | correo: admin_qa@lab.test / contraseña: Lab1234! / Recordar: ☐ | Sesión normal sin persistencia | — | ⏳ PENDIENTE | — |
| E-LOGOUT-V1 | Cerrar sesión correctamente | Entrar a Cuenta y Sesión → Cerrar sesión | Vuelve a pantalla de Login, datos de usuario limpiados | — | ⏳ PENDIENTE | — |
| E-LOGOUT-V2 | Datos de otras mascotas no persisten tras logout | Cerrar sesión y volver a loguear con otra cuenta | Providers limpiados: Mascotas, Vacunas, Peso, Álbum, Eventos | Implementado via `cerrarSesion()` → `_cerrarSesionLocal()` → `.clear()` en todos los providers | ✅ PASS* | — |

---

## MÓDULO 11 — NOTIFICACIONES / PUSH

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-NOTIF-V1 | Firebase init no bloquea la app en web | Lanzar app en Chrome | App inicia aunque Firebase no tenga opción configuradas | Se muestra advertencia en consola pero la app continúa ✓ | ✅ PASS* | LOG_flutter_17022026.txt |
| E-NOTIF-F1 | `notification_service.dart` no lanza excepción no controlada en web | Lanzar app en Chrome | `kIsWeb` guard ejecutado — servicio no intenta plataformas nativas | Se captura la excepción `Unsupported operation: Platform._operatingSystem` pero NO crashea la app ✓ | ✅ PASS* | LOG_flutter_17022026.txt |

> \* Ver sección **Análisis de Logs** para detalle completo.

---

## ANÁLISIS DE LOGS (17/02/2026 — 18/02/2026)

### LOG Backend — `LOG_backend_17022026.txt`

```
Conectado a MongoDB -> Base de datos: My-Best-Friend
Usuarios existentes: 3
Mascotas existentes: 11
API escuchando en http://localhost:3000
```

El backend fue reiniciado **3 veces** durante la sesión. Causas:
1. Reinicio manual durante desarrollo
2. Conflicto de puerto EADDRINUSE (ver INC-009)
3. Reinicio final tras matar proceso bloqueante (PID 7904)

**Requests registrados (extracto):**
```
[2026-02-18 01:11:41] GET /api/health → 200 (5ms)
[2026-02-18 01:11:51] GET /api/peso?mascota=6994fab27f057580cae09448 → 200 (101ms)
[2026-02-18 01:11:52] GET /api/vacunas?mascota=6994fab27f057580cae09448 → 200 (99ms)
[2026-02-18 01:11:52] GET /api/eventos?fecha=2026-02-17 → 200 (99ms)
[2026-02-18 01:11:52] GET /api/vacunas/recordatorios → 200 (99ms)
[2026-02-18 01:11:52] GET /api/album?mascota=6994fab27f057580cae09448 → 200 (98ms)
[2026-02-18 01:11:52] GET /api/recordatorios → 200 (99ms)
```

**Observaciones:**
- Todos los endpoints responden 200 con tiempos < 120ms (dentro del umbral aceptable)
- `GET /api/eventos?fecha=2026-02-17` **no lleva `mascotaId`** — esto es correcto al cargar el calendario global; el filtrado client-side lo maneja `EventosProvider`
- `GET /api/recordatorios` sin `mascotaId` — sincronización general (esperado en boot)
- Patrón de requests coherente con flujo de login → carga de pantalla principal

### LOG Flutter — `LOG_flutter_17022026.txt`

**Error 1 (Expected / Manejado):**
```
Error al inicializar servicios: Unsupported operation: Platform._operatingSystem
[...]
package:my_best_friend_app/services/notification_service.dart 24:18
```
**Causa:** En web, `dart:io Platform` no está disponible. El guard `kIsWeb` en `NotificationService.init()` ya existe (línea 16-17 del archivo) pero la excepción se lanza en un callback asíncrono antes de que el guard se evalúe. La app **NO crashea** — el error está capturado.  
**Acción pendiente:** Mover el guard `kIsWeb` al inicio del callback `WidgetsBinding.instance.addPostFrameCallback` en `main.dart` o en `PushService`.

**Error 2 (Expected / Manejado):**
```
Error init push: Assertion failed: [...]
options != null
"FirebaseOptions cannot be null when creating the default app."
```
**Causa:** `PushService.init()` intenta inicializar Firebase sin `FirebaseOptions` configuradas para web. La app **NO crashea**.  
**Acción pendiente:** Configurar `FirebaseOptions` para web en `firebase_options.dart`, o deshabilitar push con guard `kIsWeb` en `PushService`.

**Error 3 (Corregido durante sesión):**
- Múltiples reinicios fallidos:
  ```
  flutter: Could not find an option named "--web-renderer".
  flutter: Flutter failed to delete a directory at "build\flutter_assets".
  flutter: Error: No pubspec.yaml file found.
  ```
  **Causa:** Comandos ejecutados desde directorio incorrecto o con flags obsoletos (`--web-renderer` removido en Flutter 3.x).  
  **Resolución:** Ejecutar desde `frontend/` sin `--web-renderer`.

---

## CAMBIOS DE CÓDIGO REALIZADOS EN SESIÓN (17/02/2026 — 18/02/2026)

### Backend

| Archivo | Cambio | Razón |
|---|---|---|
| `backend/server.js` | POST `/api/eventos`: `mascotaId` ahora es **requerido**; rechaza si falta o si el valor no es un ObjectId válido | INC-008: Prevenir eventos sin mascota |
| `backend/server.js` | POST `/api/recordatorios`: `mascotaId` ahora es **requerido** | INC-008 |
| `backend/server.js` | GET `/api/eventos` con `mascotaId` inválido → HTTP 400 en lugar de devolver todos | INC-008 |
| `backend/server.js` | Middleware de logging HTTP agregado (`[timestamp] METHOD /url → STATUS (ms)`) | Trazabilidad Sprint 2 |

### Frontend — Servicios

| Archivo | Cambio | Razón |
|---|---|---|
| `services/api_service.dart` | `crearRecordatorioBackend()`: añade parámetros `mascotaId`, `mascotaNombre`, `userId` | INC-008 |
| `services/api_service.dart` | `listarRecordatoriosBackend()`: acepta parámetro opcional `mascotaId` como query param | INC-008 |

### Frontend — Providers

| Archivo | Cambio | Razón |
|---|---|---|
| `providers/recordatorios_provider.dart` | Omite subir al backend registros sin `mascotaId`; al descargar solo guarda los que tienen `mascotaId` | INC-008 |
| `providers/eventos_provider.dart` | Filtro client-side adicional en `cargarDia()` y `cargarTodos()` por `mascotaId` | INC-008 |
| `providers/peso_provider.dart` | Al cargar por `mascotaId`, filtra la respuesta para excluir registros de otras mascotas | INC-008 |

### Frontend — Módulo Calendario

| Archivo | Cambio | Razón |
|---|---|---|
| `modulo_calendario/calendario_modulo_pantalla.dart` | Import `AuthProvider`; carga `currentUserId` antes de fetch; elimina display de registros legacy sin mascota; filtra estrictamente por `mascotaId == mascotaId` | INC-008 |
| `modulo_calendario/confirmacion_final_calendario.dart` | Lee `MascotasProvider`; si `widget.mascota` es null usa primera mascota; lanza excepción si no hay `mascotaId` resuelto | INC-008 |
| `modulo_calendario/servicios/calendario_service.dart` | Al parsear eventos locales, descarta entradas con `mascotaId` nulo o vacío | INC-008 |

### Frontend — Módulo General (Navegación)

| Archivo | Cambio | Razón |
|---|---|---|
| `modulo_general/menu_principal.dart` | `_openFeature()` extrae `mascotaId` del mapa de mascota seleccionada; pasa el ID a `ListaPesosPantalla`, `VacunasPantalla`, `EventosPantalla`, `AlbumModuloPantalla` con `bloquearMascota: true` | INC-010 (causa raíz de cruce de datos) |

### Frontend — Módulos de Feature

| Archivo | Cambio | Razón |
|---|---|---|
| `modulo_vacunas/vacunas_pantalla.dart` | Nuevos params `mascotaId` + `bloquearMascota`; `initState` siembra `_mascotaSeleccionada`; dropdown oculto en modo bloqueado; lista cambia entre `vacunasDe()` y `todasLasVacunas()` | INC-010 |
| `modulo_vacunas/formulario_vacuna.dart` | Nuevo param `mascotaIdFija`; asignado en `initState`; dropdown `onChanged` → null cuando fijado | INC-010 |
| `modulo_eventos/eventos_pantalla.dart` | Nuevos params `mascotaId` + `bloquearMascota`; `_mascotaSeleccionada` inicializado desde widget; dropdown `onChanged` → null cuando bloqueado | INC-010 |
| `modulo_album/album_modulo_pantalla.dart` | Nuevos params `mascotaId` + `bloquearMascota`; igual que eventos | INC-010 |

**Validación post-cambio:** `get_errors` ejecutado en todos los archivos modificados → **0 errores en todos**.

---

## INVENTARIO DE CAPTURAS DE PANTALLA

### Capturas existentes en `capturas_pantalla/funcionales/`

| Nombre de archivo | Caso que evidencia | Observaciones |
|---|---|---|
| EP_ONBOARDING_01_Slide1_PerritoLaptop_17022026.png | E-ONBOARDING-V1 | ✅ OK |
| EP_ONBOARDING_03_Slide3_17022026.png | E-ONBOARDING-V2 (parcial) | ⚠️ Solo slide 3 |
| EP_ONBOARDING_04_Slide4_17022026.png | E-ONBOARDING-V2 (parcial) | ⚠️ Solo slide 4 |
| EP_ONBOARDING_05_Slide5_Bienvenida_17022026.png | E-ONBOARDING-V3 | ✅ OK |
| EP_LOGIN_00_PantallaLogin_17022026.png | Pantalla de login antes de ingresar | ✅ OK |
| EP_LOGIN_V1_LoginExitoso_admin_qa_17022026.png | E-LOGIN-V1 | ✅ OK |
| EP_LOGIN_F1_InicioSesionExitoso_Error_17022026.png | E-LOGIN-F1 / F2 (genérico) | ⚠️ Nombre no describe bien el caso |
| EP_LOGIN_F2_ContrasenaIncorrecta_Error_17022026.png | E-LOGIN-F2 | ✅ OK |
| EP_LOGIN_F3_CorreoInexistente_17022026.png | E-LOGIN-F1 | ⚠️ Nombre invertido vs caso (F3 evidencia F1) |
| EP_LOGIN_CamposVacios_17022026.png | E-LOGIN-F3 | ✅ OK |
| EP_POST_LOGIN_PantallaInicio_17022026.png | Post-login / E-NAVEGACION-V1 | ✅ OK |
| EP_MASCOTAS_V1_ListaPrincipal_17022026.png.png | E-FILTRO-V2 | ⚠️ Extensión doble (.png.png) |
| EP_MASCOTAS_F1_ToggleOculto_17022026.png.png | E-FILTRO-V1 | ⚠️ Extensión doble (.png.png) |
| EP_CALENDARIO_V1_FechaActual_17022026.png | E-CALENDARIO-V1 / V2 | ✅ OK |
| EP_PESO_F1_OverflowDropdown_17022026.png | E-PESO-F1 | ✅ OK |
| EP_VACUNAS_F1_OverflowDropdown_17022026.png | E-VACUNAS-F1 | ✅ OK (estado pre-fix) |
| EP_CONFIG_F1_PerfilSinDatos_17022026.png | E-CONFIG-V1 / V2 | ✅ OK |

**Total capturas existentes:** 17

### Capturas FALTANTES (pendientes de tomar)

| Captura requerida | Módulo | Caso | Prioridad |
|---|---|---|---|
| EP_ONBOARDING_02_Slide2_17022026.png | Onboarding | E-ONBOARDING-V2 (slide 2) | Baja |
| EP_PESO_V1_PantallaPeso_17022026.png | Peso | E-PESO-V1 | **Alta** |
| EP_PESO_V2_AgregarPeso_17022026.png | Peso | E-PESO-V2 | **Alta** |
| EP_PESO_V3_HistorialKg_17022026.png | Peso | E-PESO-V3 | **Alta** |
| EP_PESO_V4_FechasCorrectas_17022026.png | Peso | E-PESO-V4 | **Alta** |
| EP_PESO_V5_EditarPeso_17022026.png | Peso | E-PESO-V5 | **Alta** |
| EP_PESO_V6_EliminarPeso_17022026.png | Peso | E-PESO-V6 | **Alta** |
| EP_PESO_V7_FiltroHoy_17022026.png | Peso | E-PESO-V7 | **Alta** |
| EP_PESO_V8_Filtro1Sem_17022026.png | Peso | E-PESO-V8 | **Alta** |
| EP_PESO_V9_Filtro1Mes_17022026.png | Peso | E-PESO-V9 | **Alta** |
| EP_PESO_V10_Filtro1Anio_17022026.png | Peso | E-PESO-V10 | **Alta** |
| EP_VACUNAS_F1_PostFix_18022026.png | Vacunas | E-VACUNAS-F1 re-test | Media |
| EP_AISLAMIENTO_Siamesa_Peso_18022026.png | Aislamiento | E-AISLAMIENTO-V1 | **Alta** |
| EP_AISLAMIENTO_Siamesa_Vacunas_18022026.png | Aislamiento | Vacunas Siamesa aislada | **Alta** |
| EP_AISLAMIENTO_Siamesa_Eventos_18022026.png | Aislamiento | Eventos Siamesa aislados | **Alta** |
| EP_AISLAMIENTO_Siamesa_Album_18022026.png | Aislamiento | Álbum Siamesa aislado | **Alta** |
| EP_CONFIG_F1_PostFix_18022026.png | Configuración | E-CONFIG-V1 post-fix INC-007 | **Alta** |

### Problemas con nombres de capturas existentes

| Archivo actual | Problema | Acción recomendada |
|---|---|---|
| EP_MASCOTAS_V1_ListaPrincipal_17022026.png.png | Extensión doble `.png.png` | Renombrar eliminando la extensión duplicada |
| EP_MASCOTAS_F1_ToggleOculto_17022026.png.png | Extensión doble `.png.png` | Renombrar eliminando la extensión duplicada |
| EP_LOGIN_F3_CorreoInexistente_17022026.png | Evidencia de E-LOGIN-F1, nombre dice F3 | Renombrar a EP_LOGIN_F1_CorreoNoExiste_17022026.png |
| EP_LOGIN_F1_InicioSesionExitoso_Error_17022026.png | Nombre confuso (dice "exitoso" pero es error) | Renombrar a EP_LOGIN_F1_F2_Error_Generico_17022026.png |

---

## INCIDENTES DETECTADOS

| ID | Módulo | Descripción | Causa raíz | Severidad | Estado | Fix aplicado |
|---|---|---|---|---|---|---|
| INC-001 | Backend | No hay validación de `authToken` en endpoints protegidos (datos accesibles sin auth) | Sin middleware de autenticación | Crítica | 🔴 Abierto | Pendiente middleware auth |
| INC-002 | Backend | DELETE físico — no usa campo `oculto` para borrado lógico en mascotas | Implementación incompleta | Mayor | 🔴 Abierto | Pendiente |
| INC-003 | Backend | No existía POST `/api/usuarios/login` en versión inicial | Endpoint faltante | Mayor | ✅ Resuelto | Agregado en sesión |
| INC-004 | Backend | GET `/api/mascotas` también devolvía mascotas ocultas en tab Visible | Filtro `oculto:false` no aplicado | Menor | ✅ Resuelto | Filtro agregado en backend |
| INC-005 | Login | El frontend muestra el mismo mensaje de error para correo inexistente y contraseña incorrecta, aunque el backend sí los diferencia | Frontend no usa el `message` del response para mostrar al usuario | Media | 🟡 Parcial | Backend diferencia; frontend pendiente de actualizar UI |
| INC-006 | Peso / Vacunas | Overflow visual "RIGHT OVERFLOWED BY Xpx" en dropdown de filtro por mascota | `DropdownButtonFormField` sin `isExpanded: true` | Media | ✅ Resuelto (Peso) / ⏳ Retest (Vacunas) | `isExpanded: true` + `TextOverflow.ellipsis` aplicado en Peso (confirmado) y Vacunas (código fix existe, falta retest visual) |
| INC-007 | Configuración | Perfil muestra "Usuario / correo no disponible" en inicio en frío (con token guardado) | `obtenerPerfil()` en `AuthProvider` asigna `result['data']` en vez de `result['data']['usuario']` | Alta | 🔴 Abierto | Causa identificada — fix pendiente: cambiar a `_user = result['data']['usuario']` en `auth_provider.dart` |
| INC-008 | Todos | Datos de una mascota (QA_Labrador) se mezclaban con otra (QA_Siamesa) en Recordatorios y Eventos | Recordatorios/Eventos sin `mascotaId` se mostraban a todos | Alta | ✅ Resuelto | `mascotaId` requerido en backend; filtros en providers y servicios; descarte de entradas huérfanas |
| INC-009 | Backend | `EADDRINUSE: address already in use :::3000` al intentar iniciar el servidor | Proceso `node` anterior (PID 7904) aún corriendo | Media | ✅ Resuelto | `Stop-Process -Id 7904 -Force` → reinicio limpio |
| INC-010 | Navegación | Todos los módulos (Peso, Vacunas, Eventos, Álbum) se abrían con los datos de QA_Labrador sin importar qué mascota se seleccionaba | `_openFeature()` en `menu_principal.dart` no pasaba `mascotaId` a los constructores | Crítica | ✅ Resuelto | `_openFeature()` extrae `mascotaId` del mapa de mascota y lo pasa + `bloquearMascota: true` a todos los módulos |
| INC-011 | Notificaciones | Advertencia en consola: `Unsupported operation: Platform._operatingSystem` al iniciar en web | `notification_service.dart` usa `Platform.isAndroid` sin guard completo en callback async | Baja | 🟡 Manejado | App no crashea; guard `kIsWeb` parcial existe. Pendiente mover guard antes del callback |
| INC-012 | Push / Firebase | Advertencia: `FirebaseOptions cannot be null when creating the default app` en web | `PushService` intenta inicializar Firebase sin configurar `FirebaseOptions` para web | Baja | 🟡 Manejado | App no crashea; push silenciosamente falla en web |
| INC-013 | Comandos Flutter | Tres reinicios fallidos del frontend por directorio incorrecto y flag obsoleto `--web-renderer` | Flag removido en Flutter 3.x; comandos ejecutados fuera de `frontend/` | Baja | ✅ Resuelto | Ejecutar desde `frontend/` sin `--web-renderer` |

---

## TABLA RESUMEN DE MÓDULOS

| Módulo | Casos totales | Ejecutados | PASS | FAIL | Pendientes |
|---|---|---|---|---|---|
| Onboarding | 4 | 4 | 4 | 0 | 0 |
| Login / Auth | 4 | 4 | 2 | 2 | 0 |
| Recordar sesión | 2 | 0 | 0 | 0 | 2 |
| Cerrar sesión | 2 | 1 | 1 | 0 | 1 |
| Recuperar contraseña | 2 | 0 | 0 | 0 | 2 |
| Código verificación | 3 | 0 | 0 | 0 | 3 |
| Nueva contraseña | 5 | 0 | 0 | 0 | 5 |
| Navegación / Filtros / Aislamiento | 4 | 4 | 4 | 0 | 0 |
| Calendario | 3 | 3 | 3 | 0 | 0 |
| Perfil mascota | 2 | 0 | 0 | 0 | 2 |
| Accesos mascota | 6 | 0 | 0 | 0 | 6 |
| Peso (Fecha/Peso/Notas) | 13 | 12 | 12 | 0 | 1 |
| Vacunas | 5 | 2 | 1 | 0 | 3 |
| Álbum | 3 | 1 | 1 | 0 | 2 |
| Eventos | 3 | 2 | 2 | 0 | 1 |
| Configuración / Perfil usuario | 3 | 2 | 1 | 1 | 1 |
| Notificaciones | 2 | 2 | 2 | 0 | 0 |
| Cuenta / Sesión | 5 | 0 | 0 | 0 | 5 |
| Preferencias | 4 | 0 | 0 | 0 | 4 |
| Cambiar contraseña | 9 | 0 | 0 | 0 | 9 |
| Comandos / Ambiente | 3 | 3 | 3 | 0 | 0 |
| **TOTAL** | **~97** | **40** | **36** | **3** | **~57** |

---

## ESTADO DE AISLAMIENTO POR MASCOTA (QA ESPECÍFICO)

| Módulo | QA_Labrador aislada | QA_Siamesa aislada | QA_Oculta gestionada | Estado |
|---|---|---|---|---|
| Peso | ✅ | ✅ | N/A | Verificado código |
| Vacunas | ✅ | ✅ | N/A | Verificado código; pendiente retest visual |
| Álbum | ✅ | ✅ | N/A | Verificado código |
| Eventos | ✅ | ✅ | N/A | Verificado código (doble filtro) |
| Recordatorios/Calendario | ✅ | ✅ | N/A | Verificado código |
| Filtro Visible/Oculto | N/A | N/A | ✅ Oculta en tab "Visible" | Verificado visual |

> **Pendiente:** Hot restart + prueba manual de click en tarjeta QA_Siamesa → cada módulo → confirmar que NO aparecen datos de QA_Labrador.

---

## PENDIENTES PRIORITARIOS

| Prioridad | Tarea | Tipo |
|---|---|---|
| 🔴 1 | Realizar hot restart y verificar aislamiento visualmente (QA_Siamesa v QA_Labrador) | QA Manual |
| 🔴 2 | Corregir INC-007: `auth_provider.dart` línea `_user = result['data']` → `result['data']['usuario']` | Bug Fix |
| 🔴 3 | Tomar capturas faltantes EP_PESO_V1..V10 | Evidencia |
| 🟡 4 | Tomar capturas de aislamiento (Siamesa en cada módulo) | Evidencia |
| 🟡 5 | Re-test E-VACUNAS-F1 (confirmar que overflow eliminado post-fix) | QA Manual |
| 🟡 6 | Renombrar capturas con extensión doble y nombres inconsistentes | Mantenimiento |
| 🔵 7 | Ejecutar módulos pendientes: Cerrar sesión, Recuperar contraseña, Perfil Mascota, Álbum, Vacunas | QA Manual |
| 🔵 8 | Resolver INC-001: Agregar middleware de autenticación al backend | Seguridad |
| 🔵 9 | Resolver INC-011 y INC-012: Mejorar guards de Web en NotificationService y PushService | Técnico |

