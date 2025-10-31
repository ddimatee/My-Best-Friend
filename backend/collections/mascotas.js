use ("My-Best-Friend");

db.createCollection("mascotas", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["userId", "nombre", "fechaCreacion"],
      properties: {
        userId: {
          bsonType: "objectId",
          description: "ID del usuario dueño de la mascota - requerido"
        },
        nombre: {
          bsonType: "string",
          description: "Nombre de la mascota - requerido"
        },
        imagenPath: {
          bsonType: "string",
          description: "URL o path de la imagen de la mascota - opcional"
        },
        cumpleanos: {
          bsonType: "date",
          description: "Fecha de cumpleaños de la mascota - opcional"
        },
        situacion: {
          bsonType: "string",
          enum: ["Acabo de tener un perro", "Ya conozco bien a mi perro"],
          description: "Situación actual con la mascota - opcional"
        },
        sexo: {
          bsonType: "string",
          enum: ["Macho", "Hembra"],
          description: "Sexo de la mascota - opcional"
        },
        raza: {
          bsonType: "string",
          description: "Raza de la mascota - opcional"
        },
        seguimiento: {
          bsonType: "bool",
          description: "Indica si se realiza seguimiento de comidas/vacunas - opcional"
        },
        estiloVida: {
          bsonType: "array",
          items: {
            bsonType: "string"
          },
          description: "Estilos de vida seleccionados para la mascota - opcional"
        },
        coCuidado: {
          bsonType: "bool",
          description: "Indica si la mascota es cuidada por más de una persona - opcional"
        },
        rol: {
          bsonType: "string",
          enum: ["Dueño", "Cuidador"],
          description: "Rol del usuario respecto a esta mascota - opcional"
        },
        oculto: {
          bsonType: "bool",
          description: "Indica si la mascota está oculta - por defecto false"
        },
        fechaCreacion: {
          bsonType: "date",
          description: "Fecha de creación del registro - requerido"
        },
        fechaActualizacion: {
          bsonType: "date",
          description: "Fecha de última actualización - opcional"
        }
      }
    }
  }
});