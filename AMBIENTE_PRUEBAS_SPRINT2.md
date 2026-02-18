# SENA — Servicio Nacional de Aprendizaje
## SISTEMA DE GESTIÓN DE CALIDAD
### Programa de Formación en Análisis y Desarrollo de Software
**Versión:** 1.0 | **Fecha:** 17/02/2026

---

# DOCUMENTO TÉCNICO DE CONFIGURACIÓN Y EJECUCIÓN — AMBIENTE DE PRUEBAS
## Proyecto: MY BEST FRIEND — Aplicación de Gestión de Mascotas

| Campo               | Valor                                          |
|---------------------|------------------------------------------------|
| Elaborado por       | Aprendiz — Programa ADSO                       |
| Instructor          | Pedro Meléndez Rivera                          |
| Centro de Formación | Centro Agroecológico y Empresarial             |
| Ficha               | 2996315                                        |
| Ciudad / Fecha      | Fusagasugá, 17 de febrero de 2026              |

---

## TABLA DE CONTENIDO

1. Introducción
2. Versiones y Dependencias
3. Variables de Entorno Requeridas
4. Checklist Operativo
5. Configuración de la Base de Datos
6. Datos Semilla (Seed Data)
7. Cuentas de Prueba
8. Observabilidad y Logs
9. Convención de Evidencias
10. Checklist Final de Verificación
- Anexo A: Comandos Rápidos de Referencia
- Anexo B: Plantilla de Reporte de Pruebas

---

## 1. Introducción

El presente documento ha sido elaborado en el marco de la formación tecnológica en Análisis y Desarrollo de Software (ADSO) del Servicio Nacional de Aprendizaje (SENA). Su propósito es describir de manera detallada la configuración y ejecución del ambiente de pruebas del proyecto **My Best Friend**, una aplicación móvil multiplataforma orientada a la gestión integral de mascotas.

A lo largo de este documento se abordan los aspectos técnicos relacionados con las versiones de software requeridas, la configuración de variables de entorno, el levantamiento del backend y frontend, la gestión de la base de datos MongoDB Atlas, la generación de datos semilla y las convenciones para el registro de evidencias de calidad (QA).

Este documento está dirigido a los integrantes del equipo de desarrollo y al equipo de aseguramiento de calidad (QA) que participan en la etapa de pruebas del proyecto, dentro del ambiente controlado de laboratorio del SENA.

---

## 2. Versiones y Dependencias

### 2.1 Backend (Node.js)

El servidor de la aplicación está desarrollado con **Node.js + Express** y utiliza **MongoDB Atlas** como sistema de gestión de base de datos.

| Componente       | Versión Instalada  | Notas                           |
|------------------|--------------------|---------------------------------|
| Node.js          | **v22.19.0**       | Verificado con `node --version` |
| npm              | **10.9.3**         | Verificado con `npm --version`  |
| MongoDB Atlas    | Cluster compartido | cloud.mongodb.com               |
| Driver MongoDB   | ^6.3.0             | `package.json`                  |
| Express          | ^4.19.2            | `package.json`                  |
| dotenv           | ^16.3.1            | `package.json`                  |
| cors             | ^2.8.5             | `package.json`                  |
| SO (Pruebas)     | Windows 11         | —                               |

```json
{
  "express": "^4.19.2",
  "mongodb": "^6.3.0",
  "dotenv":  "^16.3.1",
  "cors":    "^2.8.5"
}
```

### 2.2 Frontend (Flutter / Dart)

La interfaz de usuario está construida con el framework **Flutter**, lo que permite su despliegue en dispositivos Android, iOS y entornos web.

| Componente          | Versión Instalada     | Notas                              |
|---------------------|-----------------------|------------------------------------|
| Flutter SDK         | **3.35.5** (stable)   | Verificado con `flutter --version` |
| Dart SDK            | **3.9.2**             | Incluido con Flutter               |
| Android Studio      | Última versión estable | Compilación móvil                 |

Dependencias principales declaradas en `frontend/pubspec.yaml`:

```yaml
dependencies:
  flutter: sdk: flutter
  http: ^0.13.6
  provider: ^6.0.5
  table_calendar: ^3.0.9
  intl: 0.20.2
  shared_preferences: ^2.2.2
  image_picker: ^1.2.0
  flutter_local_notifications: ^17.2.1
  firebase_core: ^3.5.0
  firebase_messaging: ^15.1.0
  permission_handler: ^11.3.1
```

---

## 3. Variables de Entorno Requeridas

### 3.1 Configuración del Backend

Archivo: `backend/.env` *(NO subir a git — ya incluido en `.gitignore`)*

```env
# CONFIGURACIÓN MONGODB ATLAS
MONGODB_URI=mongodb+srv://<usuario>:<password>@<cluster>.mongodb.net/
DATABASE_NAME=My-Best-Friend

# CONFIGURACIÓN DEL SERVIDOR
PORT=3000
NODE_ENV=development

# LOGS DETALLADOS (opcional, para mayor detalle en pruebas)
DEBUG=true
LOG_LEVEL=verbose
```

> 📌 **NOTA:** Las credenciales reales están en el archivo `.env` local del entorno de laboratorio. Nunca deben ser utilizadas en ambientes de producción.

### 3.2 Configuración del Frontend

El frontend no utiliza un archivo de configuración externo. Los parámetros se pasan en tiempo de compilación:

| Plataforma        | URL por Defecto              |
|-------------------|------------------------------|
| Android Emulator  | `http://10.0.2.2:3000/api`   |
| iOS Simulator     | `http://localhost:3000/api`  |
| Web / Desktop     | `http://localhost:3000/api`  |

```powershell
# Opción recomendada para pruebas con IP personalizada
flutter run --dart-define=API_BASE=http://192.168.1.100:3000
```

---

## 4. Checklist Operativo

A continuación se presenta el procedimiento paso a paso para la puesta en marcha del ambiente de pruebas. Es fundamental seguir el orden establecido para evitar errores de configuración.

### Paso 1: Clonar y Configurar el Repositorio

```powershell
# Clonar el repositorio
git clone https://github.com/ddimatee/My-Best-Friend.git
cd My-Best-Friend

# Verificar estructura del proyecto
dir
# Debe mostrar: backend/, frontend/, README.md
```

### Paso 2: Levantar el Backend

```powershell
# Navegar al directorio backend
cd backend

# Instalar dependencias
npm install

# Crear archivo .env (completar con credenciales reales — ver sección 3.1)

# Iniciar servidor en modo desarrollo
npm run dev
# o directamente:
node server.js
```

**Salida esperada en consola:**
```
Conectado a MongoDB -> Base de datos: My-Best-Friend
Usuarios existentes: X
Mascotas existentes: X
API escuchando en http://localhost:3000
```

**Verificación de salud del API:**
```
GET http://localhost:3000/api/health
→ {"ok":true,"service":"My-Best-Friend API","db":true,"database":"My-Best-Friend"}
```

### Paso 3: Levantar el Frontend

```powershell
# Navegar al directorio frontend
cd ..\frontend

# Instalar dependencias Flutter
flutter pub get

# Verificar dispositivos disponibles
flutter devices

# Ejecutar en emulador Android
flutter run

# Ejecutar con IP del backend en red local
flutter run --dart-define=API_BASE=http://192.168.1.100:3000

# Ejecutar en navegador web
flutter run -d chrome
```

### Paso 4: Configurar la Base de Datos

El script `setup-database.js` realiza automáticamente la creación de las 7 colecciones con validaciones de esquema y los índices para optimización de consultas.

```powershell
cd ..\backend
npm run setup
```

### Paso 5: Poblar con Datos Semilla

Ejecutar el script de seed de pruebas (idempotente — se puede re-ejecutar sin duplicados):

```powershell
node seed-pruebas.js
```

Los scripts de inserción individuales también están disponibles en `backend/collections/insert_collections/`. Deben ejecutarse en este orden:

| Orden | Archivo                      | Descripción                    |
|-------|------------------------------|--------------------------------|
| 1     | insert-usuarios.mongodb      | Crear usuarios primero         |
| 2     | insert-mascotas.mongodb      | Asociar mascotas a usuarios    |
| 3     | insert-vacunas.mongodb       | Datos de vacunas               |
| 4     | insert-peso.mongodb          | Registros de peso              |
| 5     | insert-eventos.mongodb       | Eventos del calendario         |
| 6     | insert-recordatorios.mongodb | Recordatorios programados      |
| 7     | insert-fotos.mongodb         | Álbum de fotos                 |

---

## 5. Configuración de la Base de Datos

La base de datos del proyecto se llama **`My-Best-Friend`** y se ejecuta en **MongoDB Atlas** (nube).

### 5.1 Arquitectura del Sistema

```
┌─────────────────────┐       HTTP/REST        ┌──────────────────────┐
│  Frontend (Flutter) │ ──────────────────────►│ Backend (Express.js) │
│  App móvil Android  │       port 3000         │  Node.js v22.19.0    │
└─────────────────────┘                         └──────────┬───────────┘
                                                           │ MongoDB Driver v6.3
                                                           ▼
                                                ┌──────────────────────┐
                                                │  MongoDB Atlas       │
                                                │  DB: My-Best-Friend  │
                                                └──────────────────────┘
```

### 5.2 Colecciones y Estructuras

| Colección                  | Propósito                           | Validaciones clave                   |
|----------------------------|-------------------------------------|--------------------------------------|
| `usuarios`                 | Gestión de usuarios y autenticación | correo único, password requerido     |
| `mascotas`                 | Perfil de mascotas                  | userId requerido, nombre obligatorio |
| `vacunas`                  | Historial de vacunación             | mascotaId, fecha de aplicación       |
| `registros_peso`           | Seguimiento de peso                 | mascotaId, peso en kg, fecha         |
| `eventos`                  | Eventos generales                   | userId, mascotaId, tipo, fecha       |
| `recordatorios_calendario` | Recordatorios programados           | userId, mascotaId, fecha/hora        |
| `fotos_album`              | Álbum fotográfico                   | mascotaId, ruta imagen               |

### 5.3 Roles de Usuario

| Rol        | Descripción              | Nivel de Acceso                             |
|------------|--------------------------|---------------------------------------------|
| `dueno`    | Propietario de mascotas  | Gestión completa de sus mascotas y datos    |
| `cuidador` | Cuidador asignado        | Acceso restringido — consulta y seguimiento |

> **Nota:** El esquema de la BD define los roles `dueno` y `cuidador`. Para el Sprint 2, el rol `dueno` cumple la función de usuario privilegiado y `cuidador` la de usuario restringido.

---

## 6. Datos Semilla (Seed Data)

Los datos semilla son un conjunto de registros predefinidos que simulan condiciones reales y casos borde durante la ejecución de las pruebas. Se generan mediante `seed-pruebas.js`.

### 6.1 Estrategia de Datos de Prueba

#### A) Usuarios — 2 cuentas QA creadas por el seed

```javascript
// Usuario privilegiado (rol dueño)
{ nombre: "Admin", apellido: "QA", correo: "admin_qa@lab.test",
  rol: "dueno", password: "Lab1234!" }

// Usuario restringido (rol cuidador)
{ nombre: "Viewer", apellido: "QA", correo: "viewer_qa@lab.test",
  rol: "cuidador", password: "Lab1234!" }
```

#### B) Mascotas — 10 registros con variedad de casos y casos borde

```javascript
// Caso normal — dueño
{ nombre: "QA_Labrador", raza: "Labrador Retriever", sexo: "Macho",
  situacion: "Ya conozco bien a mi perro", oculto: false }

// Caso normal — cuidador
{ nombre: "QA_Bulldog", raza: "Bulldog Francés", coCuidado: true, rol: "Cuidador" }

// Mascota oculta → simula borrado lógico
{ nombre: "QA_Oculta", oculto: true }

// Caso borde — nombre de 1 carácter
{ nombre: "Q", raza: "Mestizo" }

// Caso borde — nombre de 100 caracteres
{ nombre: "Q".repeat(100), raza: "Mestizo" }

// Con cumpleaños explícito
{ nombre: "QA_ConCumple", cumpleanos: new Date("2021-03-10") }

// Sin estiloVida
{ nombre: "QA_SinEstilo", estiloVida: [] }
```

#### C) Registros de Peso — casos borde

```javascript
// Peso mínimo (cachorro muy pequeño)
{ mascotaId: ObjectId(), peso: 0.1, fecha: new Date() }

// Peso máximo (raza gigante)
{ mascotaId: ObjectId(), peso: 105.5, fecha: new Date() }

// Variación drástica de peso (alerta de salud)
{ mascotaId: ObjectId(), peso: 30, fecha: new Date("2025-01-01") }
{ mascotaId: ObjectId(), peso: 20, fecha: new Date("2025-02-01") }
```

#### D) Vacunas — casos borde

```javascript
// Vacuna vencida sin aplicar
{ nombre: "Rabia", fechaVencimiento: new Date("2024-01-01") }

// Vacuna para aplicar hoy
{ nombre: "Parvovirus", fechaAplicacion: new Date() }

// Vacuna con refuerzo muy lejano
{ nombre: "Refuerzo", fechaAplicacion: new Date("2030-12-31") }
```

#### E) Eventos y Recordatorios — casos borde

```javascript
// Evento pasado sin completar
{ titulo: "Cita veterinario", fecha: new Date("2024-01-01"), completado: false }

// Evento para hoy
{ titulo: "Baño", fecha: new Date(), hora: "10:00" }

// Diferentes prioridades
{ titulo: "Urgente",      prioridad: "alta"  }
{ titulo: "Importante",   prioridad: "media" }
{ titulo: "Recordatorio", prioridad: "baja"  }
```

---

## 7. Cuentas de Prueba

> 📌 **NOTA:** Las credenciales indicadas en esta sección son exclusivas del entorno de **LABORATORIO / QA**. Están estrictamente **PROHIBIDAS** en entornos de producción.

### 7.1 Usuarios Preconfigurados

| Rol en sistema | Nombre    | Correo Electrónico  | Contraseña | Descripción                          |
|----------------|-----------|---------------------|------------|--------------------------------------|
| `dueno`        | Admin QA  | admin_qa@lab.test   | Lab1234!   | Rol privilegiado — gestión completa  |
| `cuidador`     | Viewer QA | viewer_qa@lab.test  | Lab1234!   | Rol restringido — acceso limitado    |

### 7.2 Datos Asociados por Usuario

| Usuario              | Mascotas Asignadas                                                                 | Rol Mascota |
|----------------------|------------------------------------------------------------------------------------|-------------|
| admin_qa@lab.test    | QA_Labrador, QA_Siamesa, QA_ConCumple, QA_Oculta, Q, QQQ…(×100), QA_SinEstilo    | Dueño       |
| viewer_qa@lab.test   | QA_Bulldog, QA_Persa, QA_CoCuidado                                                 | Cuidador    |

### 7.3 Obtener Token de Autenticación vía API

El sistema genera tokens mediante el siguiente endpoint:

```
POST http://localhost:3000/api/usuarios/:id/token
```

Respuesta esperada (HTTP 200 OK):
```json
{
  "token": "cfe0a6231f2f519d6c847320f6de88a7...",
  "usuario": {
    "_id": "6994fab27f057580cae09446",
    "nombre": "Admin",
    "correo": "admin_qa@lab.test",
    "rol": "dueno"
  }
}
```

> ⚠️ **Hallazgo crítico detectado (INC-001):** Ningún endpoint verifica el `authToken` en los headers. Cualquier petición se ejecuta sin autenticación.

---

## 8. Observabilidad y Logs

### 8.1 Logs del Backend

El servidor Express genera logs automáticos en consola para:

- Inicio del servidor y puerto de escucha
- Estado de la conexión a MongoDB (exitosa o fallida)
- Conteo de documentos al iniciar
- Errores de validación del esquema MongoDB

**Formato de log generado:**
```
[2026-02-17 10:30:45] Conectado a MongoDB -> Base de datos: My-Best-Friend
[2026-02-17 10:30:45] Usuarios existentes: 3
[2026-02-17 10:30:45] Mascotas existentes: 11
[2026-02-17 10:30:45] API escuchando en http://localhost:3000
[2026-02-17 10:31:12] GET /api/mascotas - 200 OK - 45ms
[2026-02-17 10:31:20] GET /api/mascotas/123456 - 404 Not Found - 12ms
[2026-02-17 10:31:25] ERROR: ValidationError en /api/mascotas - Campo requerido
```

### 8.2 Activar Logs Detallados

Agregar al archivo `backend/.env` y reiniciar el servidor:

```env
NODE_ENV=development
DEBUG=true
LOG_LEVEL=verbose
```

### 8.3 Logs del Frontend

La aplicación Flutter genera logs en la consola de desarrollo. Para activar el modo verboso:

```powershell
flutter run --verbose
```

Los logs incluyen: peticiones HTTP (URL, headers, body), respuestas de API, errores de red, navegación entre pantallas y cambios de estado en providers.

### 8.4 Ubicación de Archivos de Log

| Plataforma | Archivo                     | Contenido                       |
|------------|-----------------------------|---------------------------------|
| Backend    | `backend/logs/error.log`    | Solo errores y excepciones      |
| Backend    | `backend/logs/combined.log` | Todos los eventos registrados   |
| Backend    | `backend/logs/access.log`   | Logs de acceso HTTP             |

---

## 9. Convención de Evidencias

### 9.1 Estructura de Carpetas

```
evidencias/
└── sprint2/
    ├── capturas_pantalla/
    │   ├── funcionales/
    │   │   └── EP001_ListarMascotas_20260217_103045.png
    │   ├── errores/
    │   │   └── ERR001_TokenNoValidado_20260217_104015.png
    │   └── casos_frontera/
    │       └── CF001_NombreMascota_100chars_20260217.png
    ├── videos/
    │   └── VID001_FlujoCrearMascota_20260217.mp4
    ├── logs/
    │   ├── LOG_backend_20260217.txt
    │   └── LOG_frontend_20260217.txt
    ├── api/
    │   └── API_Test_Mascotas_20260217.json
    └── reportes/
        └── REP_Sprint02_20260217.pdf
```

### 9.2 Nomenclatura de Archivos

Patrón general: `<TIPO>_<DESCRIPCION>_<YYYYMMDD>_<HHMMSS>.<ext>`

| Prefijo | Descripción                      | Ejemplo                                    |
|---------|----------------------------------|--------------------------------------------|
| EP      | Evidencia Positiva (PASS)        | `EP001_ListarMascotas_20260217_103045.png` |
| ERR     | Evidencia de Error o Bug         | `ERR001_TokenSinValidar_20260217.png`      |
| CF      | Caso Frontera (edge case)        | `CF001_NombreMinimo_20260217.png`          |
| VID     | Video de ejecución               | `VID001_FlujoCompleto_20260217.mp4`        |
| LOG     | Archivo de log                   | `LOG_Backend_20260217_103000.txt`          |
| API     | Prueba de API (Postman/Insomnia) | `API_Test_Mascotas_20260217.json`          |
| REP     | Reporte formal                   | `REP_Sprint02_20260217.pdf`                |
| INC     | Evidencia de incidente           | `INC001_TokenNoValidado_20260217.png`      |

### 9.3 Contenido Requerido en Capturas

Toda captura de pantalla debe incluir:
- Fecha y hora del sistema al momento de la captura
- Nombre de la pantalla o módulo bajo prueba
- Datos de entrada utilizados
- Resultado obtenido (mensaje de éxito o error visible)
- URL o endpoint probado (si aplica)

### 9.4 Logs a Capturar por Caso de Prueba

```
=== CASO DE PRUEBA: EP001 - Listar Mascotas ===
Fecha: 2026-02-17 10:30:45
Tester: <nombre del aprendiz>

[API REQUEST]
GET http://localhost:3000/api/mascotas

[BACKEND LOG]
[10:30:45] GET /api/mascotas - 200 OK - 45ms
[10:30:45] Documentos retornados: 11

[API RESPONSE]
Status: 200 OK — Tiempo: 45ms

[RESULTADO]
✅ PASS - Mascotas listadas correctamente
```

---

## 10. Checklist Final de Verificación

| N° | Elemento a Verificar                                          | Estado        |
|----|---------------------------------------------------------------|---------------|
| 1  | Backend instalado y corriendo en puerto 3000                  | ✅ Completado  |
| 2  | Frontend instalado (`flutter pub get` ejecutado)              | ☐ Pendiente   |
| 3  | Base de datos MongoDB Atlas conectada (`My-Best-Friend`)      | ✅ Completado  |
| 4  | 7 colecciones creadas con validaciones aplicadas              | ✅ Completado  |
| 5  | Datos semilla insertados (`node seed-pruebas.js` ejecutado)   | ✅ Completado  |
| 6  | Casos frontera incluidos en los datos semilla                 | ✅ Completado  |
| 7  | Cuentas de prueba creadas (`dueno` y `cuidador`)              | ✅ Completado  |
| 8  | Token generado vía `POST /api/usuarios/:id/token`             | ☐ Pendiente   |
| 9  | Logs visibles en backend al recibir peticiones                | ✅ Completado  |
| 10 | Logs visibles en frontend (consola Flutter)                   | ☐ Pendiente   |
| 11 | Carpeta `evidencias/sprint2/` creada con estructura definida  | ✅ Completado  |
| 12 | Convención de nomenclatura documentada y comprendida          | ✅ Completado  |
| 13 | Variables de entorno configuradas en `backend/.env`           | ✅ Completado  |
| 14 | Documentación leída y comprendida por todo el equipo QA       | ☐ Pendiente   |

---

## Anexo A: Comandos Rápidos de Referencia

### Backend (Node.js / npm)

```powershell
# Instalar dependencias
npm install

# Crear estructura de BD
npm run setup

# Iniciar servidor en modo desarrollo
npm run dev

# Ejecutar seed de datos de prueba
node seed-pruebas.js
```

### Frontend (Flutter / Dart)

```powershell
# Instalar dependencias
flutter pub get

# Limpiar caché
flutter clean

# Ejecutar en emulador
flutter run

# Ejecutar con API personalizada
flutter run --dart-define=API_BASE=http://192.168.1.100:3000

# Ver logs detallados
flutter run --verbose

# Generar APK de prueba
flutter build apk --debug
```

### MongoDB (mongosh / Atlas)

```javascript
// Seleccionar base de datos
use("My-Best-Friend")

// Listar colecciones
show collections

// Ver documentos de una colección
db.usuarios.find().pretty()
db.mascotas.find({ oculto: true }).pretty()

// Contar documentos
db.mascotas.countDocuments()

// Verificar cuentas QA insertadas por el seed
db.usuarios.find({ correo: /lab\.test/ }).pretty()

// ⚠️ CUIDADO: Eliminar todos los datos
db.dropDatabase()
```

---

## Anexo B: Plantilla de Reporte de Pruebas

```markdown
# REPORTE DE PRUEBAS — MY BEST FRIEND
Fecha: 2026-02-17
Tester: <nombre del aprendiz>
Sprint / Versión: Sprint 2 / v1.0
Ambiente: QA / Development — MongoDB Atlas

## RESUMEN EJECUTIVO
- Total casos planificados:  X
- Total casos ejecutados:    X
- Casos PASS:                X (XX%)
- Casos FAIL:                X (XX%)
- Casos BLOCKED:             X (XX%)

## INCIDENTES ABIERTOS
- INC-001: Ningún endpoint valida authToken — Severidad: Critical
- INC-002: DELETE físico en mascotas (no lógico) — Severidad: Major
- INC-003: No existe endpoint POST /api/login — Severidad: Major

## CASOS EJECUTADOS

### EP001 - Listar mascotas (GET /api/mascotas)
- Estado: ✅ PASS / ❌ FAIL / ⛔ BLOCKED
- Evidencia: capturas_pantalla/funcionales/EP001_...

### ERR001 - Token no validado en endpoint
- Estado: ❌ FAIL
- Bug ID: INC-001
- Descripción: Se accede a /api/mascotas sin token y retorna 200 OK

## RECOMENDACIONES
- Implementar middleware de validación de authToken en todos los endpoints
- Cambiar DELETE de mascotas a borrado lógico usando el campo `oculto`
- Agregar endpoint POST /api/usuarios/login con credenciales
```

---

*Documento elaborado en el marco de la formación ADSO — SENA, Fusagasugá | 2026*
