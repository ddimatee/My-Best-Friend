# My Best Friend - Colecciones MongoDB Atlas

Este directorio contiene los scripts para crear las colecciones de la base de datos en MongoDB Atlas.

## 📋 Colecciones

1. **usuarios** - Información de usuarios (dueños y cuidadores)
2. **mascotas** - Datos de las mascotas
3. **vacunas** - Registro de vacunas aplicadas
4. **registros_peso** - Historial de peso de las mascotas
5. **eventos** - Eventos importantes de las mascotas
6. **recordatorios_calendario** - Recordatorios con programación recurrente
7. **fotos_album** - Fotos del álbum organizadas por mes

## 🚀 Cómo ejecutar los scripts

### Opción 1: MongoDB Atlas UI (Web)

1. Accede a tu cluster en [MongoDB Atlas](https://cloud.mongodb.com)
2. Haz clic en "Browse Collections"
3. Ve a la pestaña "mongosh" (consola)
4. Copia y pega el contenido de cada archivo `.js` uno por uno
5. Presiona Enter para ejecutar cada script

### Opción 2: MongoDB Compass (Aplicación de escritorio)

1. Abre MongoDB Compass
2. Conéctate a tu cluster de Atlas
3. Selecciona tu base de datos
4. Ve a la pestaña "MongoSH" en la parte inferior
5. Copia y pega el contenido de cada archivo `.js`
6. Presiona Enter para ejecutar

### Opción 3: mongosh (CLI)

```bash
# Conéctate a tu cluster
mongosh "mongodb+srv://<tu-cluster>.mongodb.net/<tu-database>" --username <tu-usuario>

# En la consola mongosh, ejecuta cada script:
load('collections/usuarios.js')
load('collections/mascotas.js')
load('collections/vacunas.js')
load('collections/registros_peso.js')
load('collections/eventos.js')
load('collections/recordatorios_calendario.js')
load('collections/fotos_album.js')
```

### Opción 4: Desde Node.js

```bash
# Instala el driver de MongoDB si no lo tienes
npm install mongodb

# Ejecuta el script principal
node setup-database.js
```

## 📝 Orden de ejecución recomendado

1. `usuarios.js` - Debe ser la primera (otras colecciones dependen de userId)
2. `mascotas.js` - Segunda (eventos y registros dependen de mascotaId)
3. Los demás scripts pueden ejecutarse en cualquier orden

## ⚠️ Importante

- Asegúrate de estar conectado a la base de datos correcta antes de ejecutar los scripts
- Los scripts incluyen validación de esquema para mantener la integridad de datos
- Los índices optimizan las consultas más frecuentes de la aplicación
- Ejecuta cada script solo una vez; si necesitas recrear una colección, elimínala primero:
  ```javascript
  db.nombre_coleccion.drop()
  ```

## 🔍 Verificar las colecciones creadas

```javascript
// Ver todas las colecciones
show collections

// Ver información de validación de una colección
db.getCollectionInfos({name: "usuarios"})

// Ver índices de una colección
db.usuarios.getIndexes()
```

## 📊 Características de las colecciones

Todas las colecciones incluyen:
- ✅ Validación de esquema JSON
- 🔍 Índices optimizados para consultas frecuentes
- 📝 Documentación inline de cada campo
- 🛡️ Restricciones de tipos y valores permitidos

## 🔗 Relaciones entre colecciones

```
usuarios (1) ──── (N) mascotas
    │                  │
    │                  ├──── (N) vacunas
    │                  ├──── (N) registros_peso
    │                  ├──── (N) fotos_album
    │                  └──── (N) recordatorios_calendario
    │
    └──────────────── (N) eventos
                      └──── (N) recordatorios_calendario
```

## 💡 Notas adicionales

- Todos los campos `userId` y `mascotaId` son de tipo `ObjectId` para referencias
- Los campos de fecha usan el tipo `date` de MongoDB
- Los enums están definidos para garantizar valores válidos
- Los índices compuestos mejoran las consultas filtradas por usuario y mascota
