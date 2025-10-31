use ("My-Best-Friend");

db.createCollection("registros_peso", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "mascotaId", "peso", "fecha"],
      properties: {
        userId: {
          bsonType: "objectId",
          description: "ID del usuario dueño - requerido"
        },
        mascotaId: {
          bsonType: "objectId",
          description: "ID de la mascota - requerido"
        },
        peso: {
          bsonType: "double",
          minimum: 0,
          description: "Peso de la mascota en kilogramos - requerido"
        },
        fecha: {
          bsonType: "date",
          description: "Fecha del registro de peso - requerido"
        },
        notas: {
          bsonType: "string",
          description: "Notas adicionales sobre el registro - opcional"
        },
        fechaCreacion: {
          bsonType: "date",
          description: "Fecha de creación del registro - opcional"
        }
      }
    }
  }
});