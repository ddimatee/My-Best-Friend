use ("My-Best-Friend");

db.createCollection("recordatorios_calendario", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "titulo", "descripcion", "categoria", "fechaHora", "tipoRecordatorio", "frecuencia"],
      properties: {
        userId: {
          bsonType: "objectId",
          description: "ID del usuario dueño - requerido"
        },
        mascotaId: {
          bsonType: "objectId",
          description: "ID de la mascota asociada - opcional"
        },
        mascotaNombre: {
          bsonType: "string",
          description: "Nombre de la mascota para mostrar - opcional"
        },
        mascotaFoto: {
          bsonType: "string",
          description: "URL o path de la foto de la mascota - opcional"
        },
        titulo: {
          bsonType: "string",
          description: "Título del recordatorio - requerido"
        },
        descripcion: {
          bsonType: "string",
          description: "Descripción del recordatorio - requerido"
        },
        categoria: {
          bsonType: "string",
          enum: ["vacunas", "medicamentos", "alimentacion", "ejercicio", "citas_veterinario", "aseo", "juegos", "otro"],
          description: "Categoría del recordatorio - requerido"
        },
        fechaHora: {
          bsonType: "date",
          description: "Fecha y hora del recordatorio - requerido"
        },
        tipoRecordatorio: {
          bsonType: "string",
          enum: ["una_vez", "repetir"],
          description: "Tipo de recordatorio (una vez o repetir) - requerido"
        },
        frecuencia: {
          bsonType: "string",
          enum: ["una_vez", "diario", "semanal", "mensual", "anual"],
          description: "Frecuencia del recordatorio - requerido"
        },
        avisos: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["tipo", "minutos", "descripcion"],
            properties: {
              tipo: {
                bsonType: "string",
                enum: ["a_la_hora", "antes_de"],
                description: "Tipo de aviso"
              },
              minutos: {
                bsonType: "int",
                description: "Minutos antes del evento (0 para a la hora)"
              },
              descripcion: {
                bsonType: "string",
                description: "Descripción del aviso"
              }
            }
          },
          description: "Lista de avisos configurados"
        },
        activo: {
          bsonType: "bool",
          description: "Indica si el recordatorio está activo - por defecto true"
        },
        fechaCreacion: {
          bsonType: "date",
          description: "Fecha de creación del registro - opcional"
        },
        fechaActualizacion: {
          bsonType: "date",
          description: "Fecha de última actualización - opcional"
        }
      }
    }
  }
});