use ("My-Best-Friend");

db.createCollection("eventos", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "titulo", "tipo", "fecha"],
      properties: {
        userId: {
          bsonType: "objectId",
          description: "ID del usuario dueño - requerido"
        },
        mascotaId: {
          bsonType: "objectId",
          description: "ID de la mascota asociada - opcional"
        },
        titulo: {
          bsonType: "string",
          description: "Título del evento - requerido"
        },
        tipo: {
          bsonType: "string",
          enum: ["vacunas", "medicamentos", "alimentacion", "ejercicio", "citas_veterinario", "aseo", "juegos", "otro"],
          description: "Tipo/categoría del evento - requerido"
        },
        fecha: {
          bsonType: "date",
          description: "Fecha del evento - requerido"
        },
        hora: {
          bsonType: "string",
          description: "Hora del evento en formato HH:mm - opcional"
        },
        descripcion: {
          bsonType: "string",
          description: "Descripción detallada del evento - opcional"
        },
        completado: {
          bsonType: "bool",
          description: "Indica si el evento fue completado - por defecto false"
        },
        prioridad: {
          bsonType: "string",
          enum: ["baja", "media", "alta"],
          description: "Prioridad del evento - opcional"
        },
        recordatorio: {
          bsonType: "object",
          properties: {
            activo: {
              bsonType: "bool",
              description: "Indica si el recordatorio está activo"
            },
            minutosAntes: {
              bsonType: "int",
              description: "Minutos antes del evento para recordar"
            }
          },
          description: "Configuración de recordatorio - opcional"
        },
        mascota: {
          bsonType: "object",
          properties: {
            id: {
              bsonType: "string",
              description: "ID de la mascota"
            },
            nombre: {
              bsonType: "string",
              description: "Nombre de la mascota"
            },
            foto: {
              bsonType: "string",
              description: "URL de la foto de la mascota"
            }
          },
          description: "Información de la mascota asociada - opcional"
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