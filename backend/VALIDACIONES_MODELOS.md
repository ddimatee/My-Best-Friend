# Validaciones de Modelos - Base de Datos

Este documento detalla todas las validaciones implementadas en cada colección de la base de datos de My Best Friend.

## 📋 Índice
1. [Usuario](#usuario)
2. [Mascota](#mascota)
3. [Evento](#evento)
4. [Foto](#foto)
5. [Recordatorio](#recordatorio)
6. [Registro de Peso](#registro-de-peso)
7. [Vacuna](#vacuna)
8. [Soporte](#soporte)

---

## 👤 Usuario

### Campos Validados:

#### **nombre**
- ✅ Obligatorio
- 📏 Longitud: 2-50 caracteres
- 🔤 Solo letras y espacios (incluyendo caracteres latinos)
- ✂️ Trim automático

#### **apellido**
- ✅ Obligatorio
- 📏 Longitud: 2-50 caracteres
- 🔤 Solo letras y espacios (incluyendo caracteres latinos)
- ✂️ Trim automático

#### **correo**
- ✅ Obligatorio
- ✅ Único en la base de datos
- 📏 Máximo 100 caracteres
- 📧 Formato de email válido
- 🔡 Convertido a minúsculas
- ✂️ Trim automático

#### **celular**
- ✅ Obligatorio
- 📱 Exactamente 10 dígitos numéricos
- ✂️ Trim automático

#### **contraseña**
- ✅ Obligatorio
- 📏 Longitud: 6-255 caracteres
- 🔐 Encriptada con bcrypt antes de guardar

#### **fotoPerfil**
- 📏 Máximo 500 caracteres
- 🔗 Validación de URL válida o ruta relativa
- 📌 Valor por defecto: string vacío

#### **preferencias.notificaciones**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: true

#### **preferencias.idioma**
- ✅ Obligatorio
- 🌐 Valores permitidos: 'es', 'en'
- 📌 Valor por defecto: 'es'

#### **preferencias.timezone**
- ✅ Obligatorio
- 📏 Máximo 100 caracteres
- 📌 Valor por defecto: 'America/Mexico_City'

#### **mascotas**
- 🔗 Array de ObjectIds válidos
- 📎 Referencia a colección Mascota

#### **deviceTokens**
- 🔗 Array de strings
- 📏 Cada token máximo 500 caracteres
- ✅ No pueden estar vacíos

#### **activo**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: true

#### **hasSeenOnboarding**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: false

---

## 🐕 Mascota

### Campos Validados:

#### **nombre**
- ✅ Obligatorio
- 📏 Longitud: 1-50 caracteres
- 🔤 Letras, números y espacios
- ✂️ Trim automático

#### **especie**
- 📏 Longitud: 2-50 caracteres
- 🔤 Solo letras y espacios
- 📌 Valor por defecto: 'perro'
- ✂️ Trim automático

#### **sexo**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'macho', 'hembra'

#### **raza**
- ✅ Obligatorio
- 📏 Longitud: 2-100 caracteres
- ✂️ Trim automático

#### **fecha_nac**
- 📅 Debe ser fecha pasada válida
- 📏 Rango: últimos 150 años
- ⚪ Campo opcional

#### **fotoPerfil**
- 📏 Máximo 500 caracteres
- 🔗 Validación de URL válida o ruta relativa
- 📌 Valor por defecto: string vacío

#### **oculto**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: false

#### **estiloVida**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'activo', 'tranquilo', 'mixto'
- 📌 Valor por defecto: 'mixto'

#### **cuidaConAlguien**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: false

#### **dueño**
- ✅ Obligatorio
- 🔗 ObjectId válido
- 📎 Referencia a colección Usuario

#### **cuidador**
- 🔗 ObjectId válido (cuando presente)
- 📎 Referencia a colección Usuario
- ⚪ Campo opcional

---

## 📅 Evento

### Campos Validados:

#### **titulo**
- ✅ Obligatorio
- 📏 Longitud: 1-100 caracteres
- ✂️ Trim automático

#### **descripcion**
- 📏 Máximo 500 caracteres
- ✂️ Trim automático
- ⚪ Campo opcional

#### **fecha**
- ✅ Obligatorio
- 📅 Rango válido: últimos 10 años a próximos 10 años

#### **hora**
- ✅ Obligatorio
- 🕐 Formato HH:MM (24 horas)

#### **tipo**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'veterinario', 'alimentacion', 'ejercicio', 'medicamento', 'baño', 'otro'

#### **prioridad**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'baja', 'media', 'alta'
- 📌 Valor por defecto: 'media'

#### **completado**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: false

#### **recordatorio.activo**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: true

#### **recordatorio.tiempoAntes**
- 🔢 Número entero
- 📏 Rango: 0-10080 minutos (7 días)
- 📌 Valor por defecto: 30

#### **mascota**
- ✅ Obligatorio
- 🔗 ObjectId válido
- 📎 Referencia a colección Mascota

#### **usuario**
- ✅ Obligatorio
- 🔗 ObjectId válido
- 📎 Referencia a colección Usuario

---

## 📸 Foto

### Campos Validados:

#### **url**
- ✅ Obligatorio
- 📏 Máximo 500 caracteres
- 🔗 Validación de URL válida o ruta relativa

#### **titulo**
- 📏 Máximo 100 caracteres
- ✂️ Trim automático
- 📌 Valor por defecto: string vacío

#### **descripcion**
- 📏 Máximo 500 caracteres
- ✂️ Trim automático
- 📌 Valor por defecto: string vacío

#### **fecha**
- ✅ Obligatorio
- 📅 Debe ser fecha pasada válida
- 📏 Rango: últimos 50 años

#### **ubicacion**
- 📏 Máximo 200 caracteres
- ✂️ Trim automático
- ⚪ Campo opcional

#### **etiquetas**
- 🏷️ Array de strings
- 📏 Cada etiqueta máximo 50 caracteres
- 🔤 Solo letras, números, guiones y espacios
- ✂️ Trim automático

#### **esPortada**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: false
- ⚠️ Solo una foto puede ser portada por mascota (validación en middleware)

#### **mascota**
- ✅ Obligatorio
- 🔗 ObjectId válido
- 📎 Referencia a colección Mascota

#### **usuario**
- ✅ Obligatorio
- 🔗 ObjectId válido
- 📎 Referencia a colección Usuario

---

## 🔔 Recordatorio

### Campos Validados:

#### **usuario**
- ✅ Obligatorio
- 🔗 ObjectId válido
- 📎 Referencia a colección Usuario

#### **titulo**
- ✅ Obligatorio
- 📏 Longitud: 1-100 caracteres
- ✂️ Trim automático

#### **descripcion**
- 📏 Máximo 500 caracteres
- ✂️ Trim automático
- ⚪ Campo opcional

#### **categoria**
- 📏 Longitud: 1-60 caracteres
- ✂️ Trim automático
- 📌 Valor por defecto: 'otro'

#### **fechaHora**
- ✅ Obligatorio
- 📅 Rango válido: últimos 10 años a próximos 10 años

#### **tipoRecordatorio**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'una_vez', 'repetir'
- 📌 Valor por defecto: 'una_vez'

#### **frecuencia**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'una_vez', 'diario', 'semanal', 'mensual', 'anual'
- 📌 Valor por defecto: 'una_vez'

#### **avisos**
- 📋 Array de avisos (máximo 10)
- 📌 Valor por defecto: array vacío

#### **avisos[].tipo**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'a_la_hora', 'antes_de'

#### **avisos[].minutos**
- 🔢 Número entero
- 📏 Rango: 0-10080 minutos (7 días)
- 📌 Valor por defecto: 0

#### **avisos[].descripcion**
- 📏 Máximo 200 caracteres
- ✂️ Trim automático
- ⚪ Campo opcional

#### **activo**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: true

---

## ⚖️ Registro de Peso

### Campos Validados:

#### **peso**
- ✅ Obligatorio
- 🔢 Número válido
- 📏 Rango: 0.1-200 kg

#### **fecha**
- ✅ Obligatorio
- 📅 Debe ser fecha pasada válida
- 📏 Rango: últimos 50 años
- 📌 Valor por defecto: fecha actual

#### **observaciones**
- 📏 Máximo 500 caracteres
- ✂️ Trim automático
- ⚪ Campo opcional

#### **tipoRegistro**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'rutina', 'veterinario', 'enfermedad', 'otro'
- 📌 Valor por defecto: 'rutina'

#### **mascota**
- ✅ Obligatorio
- 🔗 ObjectId válido
- 📎 Referencia a colección Mascota

#### **usuario**
- ✅ Obligatorio
- 🔗 ObjectId válido
- 📎 Referencia a colección Usuario

---

## 💉 Vacuna

### Campos Validados:

#### **nombre**
- ✅ Obligatorio
- 📏 Longitud: 2-100 caracteres
- ✂️ Trim automático

#### **fechaAplicacion**
- ✅ Obligatorio
- 📅 Debe ser fecha pasada válida
- 📏 Rango: últimos 50 años

#### **fechaVencimiento**
- 📅 Debe ser posterior a fechaAplicacion
- 📏 Rango: hasta 50 años en el futuro
- ⚪ Campo opcional

#### **veterinario.nombre**
- 📏 Máximo 100 caracteres
- 🔤 Solo letras, espacios y puntos
- ✂️ Trim automático
- ⚪ Campo opcional

#### **veterinario.clinica**
- 📏 Máximo 150 caracteres
- ✂️ Trim automático
- ⚪ Campo opcional

#### **veterinario.telefono**
- 📏 Longitud: 7-20 caracteres
- 🔢 Solo números, guiones, paréntesis y espacios
- ✂️ Trim automático
- ⚪ Campo opcional

#### **lote**
- 📏 Máximo 50 caracteres
- ✂️ Trim automático
- ⚪ Campo opcional

#### **laboratorio**
- 📏 Máximo 100 caracteres
- ✂️ Trim automático
- ⚪ Campo opcional

#### **observaciones**
- 📏 Máximo 500 caracteres
- ✂️ Trim automático
- ⚪ Campo opcional

#### **ubicacion**
- 📏 Máximo 200 caracteres
- ✂️ Trim automático
- ⚪ Campo opcional

#### **recordatorio.activo**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: false

#### **recordatorio.fechaRecordatorio**
- 📅 Debe ser fecha futura válida
- 📏 Rango: hasta 50 años en el futuro
- ⚪ Campo opcional

#### **estado**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'vigente', 'vencida', 'proxima_vencer'
- 📌 Valor por defecto: 'vigente'
- ⚠️ Calculado automáticamente en middleware pre-save

#### **mascota**
- ✅ Obligatorio
- 🔗 ObjectId válido
- 📎 Referencia a colección Mascota

#### **usuario**
- ✅ Obligatorio
- 🔗 ObjectId válido
- 📎 Referencia a colección Usuario

---

## 🆘 Soporte

### Campos Validados:

#### **usuario**
- 🔗 ObjectId válido (cuando presente)
- 📎 Referencia a colección Usuario
- ⚪ Campo opcional (permite tickets anónimos)

#### **tipo**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'Soporte técnico', 'Sugerencia', 'Reporte de error', 'Solicitud de función', 'Otro'

#### **mensaje**
- ✅ Obligatorio
- 📏 Longitud: 10-2000 caracteres
- ✂️ Trim automático

#### **estado**
- ✅ Obligatorio
- 🔘 Valores permitidos: 'nuevo', 'en_progreso', 'resuelto', 'cerrado'
- 📌 Valor por defecto: 'nuevo'

#### **origen**
- 📏 Máximo 50 caracteres
- 🔤 Solo letras, números, guiones y guiones bajos
- 📌 Valor por defecto: 'app'

#### **metadata**
- 📦 Objeto JSON válido
- 📌 Valor por defecto: objeto vacío

#### **respuesta**
- 📏 Máximo 2000 caracteres
- 📌 Valor por defecto: string vacío

#### **leido**
- ✅ Obligatorio
- ✔️ Boolean
- 📌 Valor por defecto: false

---