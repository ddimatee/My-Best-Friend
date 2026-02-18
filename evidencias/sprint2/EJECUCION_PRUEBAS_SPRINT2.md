# EJECUCIÓN DE PRUEBAS MANUALES — SPRINT 2
**Proyecto:** My Best Friend  
**Fecha de ejecución:** 17/02/2026  
**Tester:** Brayan (QA)  
**Ambiente:** Desarrollo — Flutter Web (Chrome) + Node.js 22 + MongoDB Atlas  
**Versión backend:** server.js (Node.js Express)  
**Versión frontend:** Flutter 3.35.5 — Web (Chrome debug mode)

---

## MÓDULO 1 — ONBOARDING

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-ONBOARDING-V1 | Primer slide al abrir la app | — | Pantalla "MY BEST FRIEND" con ilustración de perro con laptop | Pantalla "MY BEST FRIEND" con perro con laptop en fondo verde ✓ | ✅ PASS | EP_ONBOARDING_01_PantallaInicio_17022026.png |
| E-ONBOARDING-V2 | Navegación entre slides con botón → | Clic en → desde slide 1 hasta slide 4 | Avanza al siguiente slide en cada clic | Avanzó correctamente por los 5 slides ✓ | ✅ PASS | EP_ONBOARDING_02-04_Slides_17022026.png |
| E-ONBOARDING-V3 | Último slide muestra botón "Empezar" | Navegar hasta slide 5 | Botón "Empezar" visible | Aparece "Bienvenido a ¡My Best Friend!" con botón "Empezar" ✓ | ✅ PASS | EP_ONBOARDING_05_UltimaSlide_17022026.png |
| E-ONBOARDING-V4 | Botón "Empezar" navega al Login | Clic en "Empezar" | Pantalla de Login | Navegó correctamente a "Inicia sesión" ✓ | ✅ PASS | EP_LOGIN_00_PantallaLogin_17022026.png |

---

## MÓDULO 2 — LOGIN / AUTENTICACIÓN

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-LOGIN-V1 | Login exitoso con usuario dueño | correo: admin_qa@lab.test / contraseña: Lab1234! | Acceso a pantalla principal de la app | Ingresó correctamente a la app ✓ | ✅ PASS | EP_LOGIN_V1_LoginExitoso_17022026.png |
| E-LOGIN-F1 | Correo no registrado | correo: noexiste@correo.com / contraseña: Lab1234! | Mensaje de error "correo no registrado" | Mostró mensaje de error genérico (mismo que contraseña incorrecta) | ⚠️ PASS* | EP_LOGIN_F1_CorreoNoExiste_17022026.png |
| E-LOGIN-F2 | Contraseña incorrecta con correo válido | correo: admin_qa@lab.test / contraseña: Incorrecta123 | Mensaje de error "contraseña incorrecta" | Mostró el mismo mensaje de error que F1 — no diferencia los casos | ⚠️ DEFECTO | EP_LOGIN_F2_ContrasenaIncorrecta_17022026.png |
| E-LOGIN-F3 | Campos vacíos | Ambos campos en blanco | Validación de campos requeridos | — | ⏳ PENDIENTE | — |

> \* **Nota INC-005:** El sistema muestra el mismo mensaje de error tanto para correo inexistente como para contraseña incorrecta. Ver reporte de incidente INC-005.

---

## MÓDULO 3 — NAVEGACIÓN PRINCIPAL Y FILTROS

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-NAVEGACION-V1 | Barra navegación inferior funciona | Clic en 📅 Calendario, ⚙️ Configuración, 🐾 Mascotas | Navega entre módulos sin errores | Navegó correctamente entre los 3 módulos ✓ | ✅ PASS | EP_CALENDARIO_V1_FechaActual_17022026.png |
| E-FILTRO-V1 | Toggle Visible/Oculto — tab Oculto | Clic en "Oculto" | Muestra solo mascotas con oculto:true | Mostró únicamente QA_Oculta ✓ | ✅ PASS | EP_MASCOTAS_F1_ToggleOculto_17022026.png |
| E-FILTRO-V2 | Toggle Visible/Oculto — tab Visible | Clic en "Visible" | Muestra mascotas activas | Mostró QA_Labrador, QA_Siamesa y demás visibles ✓ | ✅ PASS | EP_MASCOTAS_V1_ListaPrincipal_17022026.png |

---

## MÓDULO 4 — CALENDARIO

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-CALENDARIO-V1 | Calendario muestra mes actual | Navegar a sección Calendario | Muestra mes y año correctos con día actual marcado | Muestra febrero 2026, día 17 marcado en verde ✓ | ✅ PASS | EP_CALENDARIO_V1_FechaActual_17022026.png |
| E-CALENDARIO-V2 | Fecha sin actividades | Clic en día 17 (hoy) | Mensaje informativo de sin actividades | "No se han encontrado actividades para esta fecha" + botón Crear ✓ | ✅ PASS | EP_CALENDARIO_V1_FechaActual_17022026.png |

---

## MÓDULO 5 — PESO (Registro de peso por mascota)

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-PESO-V1 | Pantalla de peso carga correctamente | Clic en "Peso" de QA_Labrador | Pantalla de peso con filtros de fecha | Cargó pantalla con filtros Hoy/1sem/1mes/1año/Personalizado ✓ | ✅ PASS | EP_PESO_V1_PantallaPeso_17022026.png |
| E-PESO-V2 | Registrar nuevo peso | Mascota: QA_Labrador / Peso: 28.5 kg / Fecha: hoy / Notas: prueba QA | Registro guardado y visible en el historial | Registro creado correctamente, aparece en historial con peso y fecha ✓ | ✅ PASS | EP_PESO_V2_AgregarPeso_17022026.png |
| E-PESO-V3 | Historial muestra valores de peso correctos | Entrar a historial de QA_Labrador | Valores numéricos de kg visibles (no "- kg") | Todos los registros muestran el peso en kg correctamente ✓ | ✅ PASS | EP_PESO_V3_HistorialKg_17022026.png |
| E-PESO-V4 | Fechas y horas correctas en el historial | Ver lista de registros con fechas conocidas | Fecha y hora local correcta en cada registro | Fechas y horas locales mostradas correctamente ✓ | ✅ PASS | EP_PESO_V4_FechasCorrectas_17022026.png |
| E-PESO-V5 | Editar registro de peso existente | Seleccionar registro / cambiar peso a 29.0 kg | Registro actualizado con nuevo valor | Edición guardada correctamente, historial refleja el cambio ✓ | ✅ PASS | EP_PESO_V5_EditarPeso_17022026.png |
| E-PESO-V6 | Eliminar registro de peso | Seleccionar registro / confirmar eliminación | Registro removido del historial | Registro eliminado, ya no aparece en el historial ✓ | ✅ PASS | EP_PESO_V6_EliminarPeso_17022026.png |
| E-PESO-V7 | Filtro "Hoy" muestra solo registros del día | Seleccionar chip "Hoy" | Solo registros creados en el día de hoy | Filtró correctamente mostrando únicamente los de hoy ✓ | ✅ PASS | EP_PESO_V7_FiltroHoy_17022026.png |
| E-PESO-V8 | Filtro "1 sem." — registros de última semana | Seleccionar chip "1 sem." | Registros de los últimos 7 días | Clasificó correctamente los registros de la semana ✓ | ✅ PASS | EP_PESO_V8_Filtro1Sem_17022026.png |
| E-PESO-V9 | Filtro "1 mes" — registros del último mes | Seleccionar chip "1 mes" | Registros de los últimos 30 días | Clasificó correctamente los registros del mes ✓ | ✅ PASS | EP_PESO_V9_Filtro1Mes_17022026.png |
| E-PESO-V10 | Filtro "1 año" — registros del último año | Seleccionar chip "1 año" | Registros de los últimos 365 días | Clasificó correctamente los registros del año ✓ | ✅ PASS | EP_PESO_V10_Filtro1Anio_17022026.png |
| E-PESO-V11 | Filtro "Personalizado" — rango de fechas | Seleccionar "Personalizado" / definir rango específico | Solo registros dentro del rango indicado | — | ⏳ PENDIENTE | — |
| E-PESO-F1 | Overflow visual en dropdown de mascota | Pantalla de peso con dropdown visible | Dropdown dentro de sus límites | Corregido con `isExpanded: true` — ya no hay desbordamiento ✓ | ✅ PASS* | EP_PESO_F1_OverflowDropdown_17022026.png |

> \* **Nota INC-006 (Resuelto):** El overflow de 63px en el dropdown de mascota fue corregido durante la sesión de desarrollo (isExpanded + TextOverflow.ellipsis).

---

## MÓDULO 6 — VACUNAS

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-VACUNAS-V1 | Pantalla de vacunas carga sin registros | Clic en "Vacunas" desde lista mascotas | Pantalla vacunas con filtro y estado vacío | Cargó con mensaje "No se han encontrado Vacunas registradas :(" ✓ | ✅ PASS | EP_VACUNAS_F1_OverflowDropdown_17022026.png |
| E-VACUNAS-F1 | Overflow visual en dropdown "Filtrar por mascota" | Dropdown "Todas" visible | Dropdown dentro de sus límites | **DESBORDAMIENTO: "RIGHT OVERFLOWED BY 79px"** — franja debug visible | ❌ FAIL | EP_VACUNAS_F1_OverflowDropdown_17022026.png |

---

## MÓDULO 7 — CONFIGURACIÓN / PERFIL USUARIO

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-CONFIG-V1 | Pantalla configuración carga correctamente | Clic en ⚙️ Configuración | Nombre y correo del usuario autenticado | Muestra **"Usuario"** y **"correo no disponible"** — datos no cargados | ❌ FAIL | EP_CONFIG_F1_PerfilSinDatos_17022026.png |
| E-CONFIG-V2 | Opciones de configuración visibles | — | Perfil, Contraseña, Notificaciones, Cuenta y Sesión | Todas las opciones visibles ✓ | ✅ PASS | EP_CONFIG_F1_PerfilSinDatos_17022026.png |

---

## MÓDULO 8 — RECORDAR SESIÓN

| ID Caso | Descripción | Datos de entrada | Resultado esperado | Resultado obtenido | Estado | Evidencia |
|---|---|---|---|---|---|---|
| E-RECORDAR-V1 | Login con checkbox "Recordar" activado | correo: admin_qa@lab.test / contraseña: Lab1234! / Recordar: ✓ | Token persistente generado, sesión recordada | — | ⏳ PENDIENTE | — |
| E-RECORDAR-F1 | Login sin checkbox "Recordar" | correo: admin_qa@lab.test / contraseña: Lab1234! / Recordar: ☐ | Sesión normal sin persistencia | — | ⏳ PENDIENTE | — |

---

## MÓDULOS PENDIENTES DE EJECUCIÓN

| Módulo | Casos totales | Ejecutados | PASS | FAIL | Pendientes |
|---|---|---|---|---|---|
| Onboarding | 4 | 4 | 4 | 0 | 0 |
| Login | 4 | 3 | 2 | 1 | 1 |
| Recordar sesión | 2 | 0 | 0 | 0 | 2 |
| Cerrar sesión | 2 | 0 | 0 | 0 | 2 |
| Recuperar contraseña | 2 | 0 | 0 | 0 | 2 |
| Código verificación | 3 | 0 | 0 | 0 | 3 |
| Nueva contraseña | 5 | 0 | 0 | 0 | 5 |
| Perfil mascota | 2 | 0 | 0 | 0 | 2 |
| Accesos mascota | 6 | 0 | 0 | 0 | 6 |
| Navegación | 1 | 0 | 0 | 0 | 1 |
| Fecha/Peso/Notas | 16 | 9 | 9 | 0 | 7 |
| Vacunas | 12 | 0 | 0 | 0 | 12 |
| Álbum | 8 | 0 | 0 | 0 | 8 |
| Eventos calendario | 12 | 0 | 0 | 0 | 12 |
| Recordatorios | 12 | 0 | 0 | 0 | 12 |
| Dueño | 4 | 0 | 0 | 0 | 4 |
| Configuración | 8 | 0 | 0 | 0 | 8 |
| Perfil usuario | 11 | 0 | 0 | 0 | 11 |
| Preferencias | 4 | 0 | 0 | 0 | 4 |
| Cambiar contraseña | 9 | 0 | 0 | 0 | 9 |
| Notificaciones | 7 | 0 | 0 | 0 | 7 |
| Cuenta/sesión | 5 | 0 | 0 | 0 | 5 |
| **TOTAL** | **133** | **29** | **25** | **3** | **104** |

---

## RESUMEN PARCIAL AL 17/02/2026

- **Total ejecutados:** 29 / 133 (22%)
- **PASS:** 25 ✅
- **FAIL / Defecto:** 3 ❌
- **Pendientes:** 104

---

## INCIDENTES DETECTADOS

| ID | Módulo | Descripción | Severidad |
|---|---|---|---|
| INC-001 | Backend | No hay validación de authToken en endpoints protegidos | Crítica |
| INC-002 | Backend | DELETE físico — no usa campo `oculto` para borrado lógico | Mayor |
| INC-003 | Backend | No existía POST /api/usuarios/login (corregido en sesión) | Mayor |
| INC-004 | Backend | GET /api/mascotas devuelve mascotas con oculto:true en vista Visible | Menor |
| INC-005 | Login | Mismo mensaje de error para correo inexistente y contraseña incorrecta | Media |
| INC-006 | Peso / Vacunas | Overflow visual en dropdown de filtro por mascota ("RIGHT OVERFLOWED BY 79px") — **Resuelto en módulo Peso** (`isExpanded: true` + `TextOverflow.ellipsis`); pendiente aplicar en Vacunas | Media |
| INC-007 | Configuración | Perfil de usuario autenticado no carga — muestra "Usuario / correo no disponible" | Alta |
