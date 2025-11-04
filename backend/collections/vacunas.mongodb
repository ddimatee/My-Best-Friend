use ("My-Best-Friend");

db.createCollection("vacunas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "mascotaId", "nombre", "fechaAplicacion"],
      properties: {
        userId: {
          bsonType: "objectId",
          description: "ID del usuario dueño - requerido"
        },
        mascotaId: {
          bsonType: "objectId",
          description: "ID de la mascota - requerido"
        },
        nombre: {
          bsonType: "string",
          description: "Nombre de la vacuna - requerido"
        },
        fechaAplicacion: {
          bsonType: "date",
          description: "Fecha en que se aplicó la vacuna - requerido"
        },
        descripcion: {
          bsonType: "string",
          description: "Descripción o notas sobre la vacuna - opcional"
        },
        ubicacion: {
          bsonType: "string",
          description: "Lugar donde se aplicó la vacuna - opcional"
        },
        tieneRecordatorio: {
          bsonType: "bool",
          description: "Indica si tiene recordatorio configurado - por defecto false"
        },
        fechaCreacion: {
          bsonType: "date",
          description: "Fecha de creación del registro - opcional"
        }
      }
    }
  }
});