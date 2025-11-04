use ("My-Best-Friend");

db.createCollection("fotos_album", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "mascotaId", "mes", "ano", "fechaSubida"],
      properties: {
        userId: {
          bsonType: "objectId",
          description: "ID del usuario dueño - requerido"
        },
        mascotaId: {
          bsonType: "objectId",
          description: "ID de la mascota - requerido"
        },
        mes: {
          bsonType: "string",
          description: "Mes de la foto (nombre del mes) - requerido"
        },
        ano: {
          bsonType: "string",
          description: "Año de la foto - requerido"
        },
        rutasImagenes: {
          bsonType: "array",
          items: {
            bsonType: "string"
          },
          maxItems: 4,
          description: "Array de URLs o paths de las imágenes (máximo 4) - opcional"
        },
        descripcion: {
          bsonType: "string",
          description: "Descripción o notas sobre las fotos - opcional"
        },
        fechaSubida: {
          bsonType: "date",
          description: "Fecha de subida de las fotos - requerido"
        }
      }
    }
  }
});