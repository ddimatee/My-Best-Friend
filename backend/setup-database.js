
require('dotenv').config();
const { MongoClient } = require('mongodb');
const fs = require('fs');
const path = require('path');


const MONGODB_URI = process.env.MONGODB_URI || 'mongodb+srv://ddimatee:1069729798@cluster0.9gantq5.mongodb.net/';
const DATABASE_NAME = process.env.DATABASE_NAME || 'My_Best_Friend';


const collections = [
  'usuarios',
  'mascotas',
  'vacunas',
  'registros_peso',
  'eventos',
  'recordatorios_calendario',
  'fotos_album'
];

async function createCollections() {
  const client = new MongoClient(MONGODB_URI);

  try {
    // Conectar a MongoDB
    console.log('Conectando a MongoDB Atlas...\n');
    await client.connect();
    console.log('Conexión exitosa!\n');

    const db = client.db(DATABASE_NAME);

    // Obtener colecciones existentes
    const existingCollections = await db.listCollections().toArray();
    const existingNames = existingCollections.map(col => col.name);

    // Crear cada colección
    for (const collectionName of collections) {
      console.log(`Procesando colección: ${collectionName}`);

      // Verificar si ya existe
      if (existingNames.includes(collectionName)) {
        console.log(` La colección '${collectionName}' ya existe. Omitiendo...\n`);
        continue;
      }

      // Leer el archivo de configuración
      const scriptPath = path.join(__dirname, 'collections', `${collectionName}.js`);
      
      if (!fs.existsSync(scriptPath)) {
        console.log(`No se encontró el archivo: ${scriptPath}\n`);
        continue;
      }

      // Cargar definiciones desde el archivo
      const definitions = getCollectionDefinition(collectionName);
      
      if (!definitions) {
        console.log(`No se pudo cargar la definición de ${collectionName}\n`);
        continue;
      }

      try {
        // Crear colección con validación
        await db.createCollection(collectionName, definitions.validator);
        console.log(`Colección creada`);

        // Crear índices
        if (definitions.indexes && definitions.indexes.length > 0) {
          for (const index of definitions.indexes) {
            await db.collection(collectionName).createIndex(index.key, index.options || {});
          }
          console.log(`${definitions.indexes.length} índice(s) creado(s)`);
        }

        console.log(`'${collectionName}' configurada exitosamente!\n`);
      } catch (err) {
        console.log(`Error al crear '${collectionName}': ${err.message}\n`);
      }
    }

    // Mostrar resumen
    console.log('\nRESUMEN');
    console.log('═'.repeat(50));
    const finalCollections = await db.listCollections().toArray();
    console.log(`Total de colecciones en la base de datos: ${finalCollections.length}`);
    console.log('\nColecciones disponibles:');
    finalCollections.forEach(col => {
      console.log(`  • ${col.name}`);
    });

  } catch (error) {
    console.error('Error:', error.message);
    process.exit(1);
  } finally {
    await client.close();
    console.log('\nConexión cerrada.');
  }
}

// Definiciones de colecciones (traducidas desde los archivos .js)
function getCollectionDefinition(collectionName) {
  const definitions = {
    usuarios: {
      validator: {
        validator: {
          $jsonSchema: {
            bsonType: "object",
            required: ["nombre", "apellido", "correo", "password", "celular", "fechaCreacion"],
            properties: {
              nombre: { bsonType: "string", description: "Nombre del usuario - requerido" },
              apellido: { bsonType: "string", description: "Apellido del usuario - requerido" },
              correo: { bsonType: "string", pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", description: "Correo electrónico único del usuario - requerido" },
              password: { bsonType: "string", description: "Contraseña hasheada del usuario - requerido" },
              celular: { bsonType: "string", description: "Número de teléfono celular - requerido" },
              fotoPerfil: { bsonType: "string", description: "URL o path de la foto de perfil - opcional" },
              direccion: { bsonType: "string", description: "Dirección del usuario - opcional" },
              rol: { bsonType: "string", enum: ["dueno", "cuidador"], description: "Rol del usuario en el sistema - por defecto 'dueno'" },
              fcmToken: { bsonType: "string", description: "Token de Firebase Cloud Messaging para notificaciones push - opcional" },
              fechaCreacion: { bsonType: "date", description: "Fecha de creación de la cuenta - requerido" },
              ultimoAcceso: { bsonType: "date", description: "Fecha del último acceso - opcional" }
            }
          }
        }
      },
      indexes: [
        { key: { correo: 1 }, options: { unique: true } },
        { key: { fechaCreacion: -1 } },
        { key: { fcmToken: 1 }, options: { sparse: true } }
      ]
    },
    mascotas: {
      validator: {
        validator: {
          $jsonSchema: {
            bsonType: "object",
            required: ["userId", "nombre", "fechaCreacion"],
            properties: {
              userId: { bsonType: "objectId", description: "ID del usuario dueño de la mascota - requerido" },
              nombre: { bsonType: "string", description: "Nombre de la mascota - requerido" },
              imagenPath: { bsonType: "string", description: "URL o path de la imagen de la mascota - opcional" },
              cumpleanos: { bsonType: "date", description: "Fecha de cumpleaños de la mascota - opcional" },
              situacion: { bsonType: "string", enum: ["Acabo de tener un perro", "Ya conozco bien a mi perro"], description: "Situación actual con la mascota - opcional" },
              sexo: { bsonType: "string", enum: ["Macho", "Hembra"], description: "Sexo de la mascota - opcional" },
              raza: { bsonType: "string", description: "Raza de la mascota - opcional" },
              seguimiento: { bsonType: "bool", description: "Indica si se realiza seguimiento de comidas/vacunas - opcional" },
              estiloVida: { bsonType: "array", items: { bsonType: "string" }, description: "Estilos de vida seleccionados para la mascota - opcional" },
              coCuidado: { bsonType: "bool", description: "Indica si la mascota es cuidada por más de una persona - opcional" },
              rol: { bsonType: "string", enum: ["Dueño", "Cuidador"], description: "Rol del usuario respecto a esta mascota - opcional" },
              oculto: { bsonType: "bool", description: "Indica si la mascota está oculta - por defecto false" },
              fechaCreacion: { bsonType: "date", description: "Fecha de creación del registro - requerido" },
              fechaActualizacion: { bsonType: "date", description: "Fecha de última actualización - opcional" }
            }
          }
        }
      },
      indexes: [
        { key: { userId: 1 } },
        { key: { userId: 1, oculto: 1 } },
        { key: { fechaCreacion: -1 } }
      ]
    },
    vacunas: {
      validator: {
        validator: {
          $jsonSchema: {
            bsonType: "object",
            required: ["userId", "mascotaId", "nombre", "fechaAplicacion"],
            properties: {
              userId: { bsonType: "objectId", description: "ID del usuario dueño - requerido" },
              mascotaId: { bsonType: "objectId", description: "ID de la mascota - requerido" },
              nombre: { bsonType: "string", description: "Nombre de la vacuna - requerido" },
              fechaAplicacion: { bsonType: "date", description: "Fecha en que se aplicó la vacuna - requerido" },
              descripcion: { bsonType: "string", description: "Descripción o notas sobre la vacuna - opcional" },
              ubicacion: { bsonType: "string", description: "Lugar donde se aplicó la vacuna - opcional" },
              tieneRecordatorio: { bsonType: "bool", description: "Indica si tiene recordatorio configurado - por defecto false" },
              fechaCreacion: { bsonType: "date", description: "Fecha de creación del registro - opcional" }
            }
          }
        }
      },
      indexes: [
        { key: { userId: 1 } },
        { key: { mascotaId: 1 } },
        { key: { userId: 1, mascotaId: 1 } },
        { key: { fechaAplicacion: -1 } }
      ]
    },
    registros_peso: {
      validator: {
        validator: {
          $jsonSchema: {
            bsonType: "object",
            required: ["userId", "mascotaId", "peso", "fecha"],
            properties: {
              userId: { bsonType: "objectId", description: "ID del usuario dueño - requerido" },
              mascotaId: { bsonType: "objectId", description: "ID de la mascota - requerido" },
              peso: { bsonType: "double", minimum: 0, description: "Peso de la mascota en kilogramos - requerido" },
              fecha: { bsonType: "date", description: "Fecha del registro de peso - requerido" },
              notas: { bsonType: "string", description: "Notas adicionales sobre el registro - opcional" },
              fechaCreacion: { bsonType: "date", description: "Fecha de creación del registro - opcional" }
            }
          }
        }
      },
      indexes: [
        { key: { userId: 1 } },
        { key: { mascotaId: 1 } },
        { key: { userId: 1, mascotaId: 1 } },
        { key: { fecha: -1 } }
      ]
    },
    eventos: {
      validator: {
        validator: {
          $jsonSchema: {
            bsonType: "object",
            required: ["userId", "titulo", "tipo", "fecha"],
            properties: {
              userId: { bsonType: "objectId", description: "ID del usuario dueño - requerido" },
              mascotaId: { bsonType: "objectId", description: "ID de la mascota asociada - opcional" },
              titulo: { bsonType: "string", description: "Título del evento - requerido" },
              tipo: { bsonType: "string", enum: ["vacunas", "medicamentos", "alimentacion", "ejercicio", "citas_veterinario", "aseo", "juegos", "otro"], description: "Tipo/categoría del evento - requerido" },
              fecha: { bsonType: "date", description: "Fecha del evento - requerido" },
              hora: { bsonType: "string", description: "Hora del evento en formato HH:mm - opcional" },
              descripcion: { bsonType: "string", description: "Descripción detallada del evento - opcional" },
              completado: { bsonType: "bool", description: "Indica si el evento fue completado - por defecto false" },
              prioridad: { bsonType: "string", enum: ["baja", "media", "alta"], description: "Prioridad del evento - opcional" },
              recordatorio: { bsonType: "object", description: "Configuración de recordatorio - opcional" },
              mascota: { bsonType: "object", description: "Información de la mascota asociada - opcional" },
              fechaCreacion: { bsonType: "date", description: "Fecha de creación del registro - opcional" },
              fechaActualizacion: { bsonType: "date", description: "Fecha de última actualización - opcional" }
            }
          }
        }
      },
      indexes: [
        { key: { userId: 1 } },
        { key: { mascotaId: 1 } },
        { key: { userId: 1, fecha: -1 } },
        { key: { tipo: 1 } },
        { key: { completado: 1 } }
      ]
    },
    recordatorios_calendario: {
      validator: {
        validator: {
          $jsonSchema: {
            bsonType: "object",
            required: ["userId", "titulo", "descripcion", "categoria", "fechaHora", "tipoRecordatorio", "frecuencia"],
            properties: {
              userId: { bsonType: "objectId", description: "ID del usuario dueño - requerido" },
              mascotaId: { bsonType: "objectId", description: "ID de la mascota asociada - opcional" },
              mascotaNombre: { bsonType: "string", description: "Nombre de la mascota para mostrar - opcional" },
              mascotaFoto: { bsonType: "string", description: "URL o path de la foto de la mascota - opcional" },
              titulo: { bsonType: "string", description: "Título del recordatorio - requerido" },
              descripcion: { bsonType: "string", description: "Descripción del recordatorio - requerido" },
              categoria: { bsonType: "string", enum: ["vacunas", "medicamentos", "alimentacion", "ejercicio", "citas_veterinario", "aseo", "juegos", "otro"], description: "Categoría del recordatorio - requerido" },
              fechaHora: { bsonType: "date", description: "Fecha y hora del recordatorio - requerido" },
              tipoRecordatorio: { bsonType: "string", enum: ["una_vez", "repetir"], description: "Tipo de recordatorio (una vez o repetir) - requerido" },
              frecuencia: { bsonType: "string", enum: ["una_vez", "diario", "semanal", "mensual", "anual"], description: "Frecuencia del recordatorio - requerido" },
              avisos: { bsonType: "array", items: { bsonType: "object" }, description: "Lista de avisos configurados" },
              activo: { bsonType: "bool", description: "Indica si el recordatorio está activo - por defecto true" },
              fechaCreacion: { bsonType: "date", description: "Fecha de creación del registro - opcional" },
              fechaActualizacion: { bsonType: "date", description: "Fecha de última actualización - opcional" }
            }
          }
        }
      },
      indexes: [
        { key: { userId: 1 } },
        { key: { mascotaId: 1 } },
        { key: { userId: 1, fechaHora: 1 } },
        { key: { categoria: 1 } },
        { key: { activo: 1 } },
        { key: { frecuencia: 1 } }
      ]
    },
    fotos_album: {
      validator: {
        validator: {
          $jsonSchema: {
            bsonType: "object",
            required: ["userId", "mascotaId", "mes", "ano", "fechaSubida"],
            properties: {
              userId: { bsonType: "objectId", description: "ID del usuario dueño - requerido" },
              mascotaId: { bsonType: "objectId", description: "ID de la mascota - requerido" },
              mes: { bsonType: "string", description: "Mes de la foto (nombre del mes) - requerido" },
              ano: { bsonType: "string", description: "Año de la foto - requerido" },
              rutasImagenes: { bsonType: "array", items: { bsonType: "string" }, maxItems: 4, description: "Array de URLs o paths de las imágenes (máximo 4) - opcional" },
              descripcion: { bsonType: "string", description: "Descripción o notas sobre las fotos - opcional" },
              fechaSubida: { bsonType: "date", description: "Fecha de subida de las fotos - requerido" }
            }
          }
        }
      },
      indexes: [
        { key: { userId: 1 } },
        { key: { mascotaId: 1 } },
        { key: { userId: 1, mascotaId: 1 } },
        { key: { ano: 1, mes: 1 } },
        { key: { fechaSubida: -1 } }
      ]
    }
  };

  return definitions[collectionName];
}

// Ejecutar el script
if (require.main === module) {
  console.log('\n🐕 My Best Friend - Setup Database\n');
  console.log('═'.repeat(50));
  createCollections()
    .then(() => {
      console.log('\n¡Configuración completada exitosamente!');
      process.exit(0);
    })
    .catch(err => {
      console.error('\nError fatal:', err);
      process.exit(1);
    });
}

module.exports = { createCollections };
