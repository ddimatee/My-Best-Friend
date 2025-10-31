use ("My-Best-Friend");

db.createCollection("usuarios", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["nombre", "apellido", "correo", "password", "celular", "fechaCreacion"],
      properties: {
        nombre: {
          bsonType: "string",
          description: "Nombre del usuario - requerido"
        },
        apellido: {
          bsonType: "string",
          description: "Apellido del usuario - requerido"
        },
        correo: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$",
          description: "Correo electrónico único del usuario - requerido"
        },
        password: {
          bsonType: "string",
          description: "Contraseña hasheada del usuario - requerido"
        },
        celular: {
          bsonType: "string",
          description: "Número de teléfono celular - requerido"
        },
        fotoPerfil: {
          bsonType: "string",
          description: "URL o path de la foto de perfil - opcional"
        },
        direccion: {
          bsonType: "string",
          description: "Dirección del usuario - opcional"
        },
        rol: {
          bsonType: "string",
          enum: ["dueno", "cuidador"],
          description: "Rol del usuario en el sistema - por defecto 'dueno'"
        },
        fcmToken: {
          bsonType: "string",
          description: "Token de Firebase Cloud Messaging para notificaciones push - opcional"
        },
        fechaCreacion: {
          bsonType: "date",
          description: "Fecha de creación de la cuenta - requerido"
        },
        ultimoAcceso: {
          bsonType: "date",
          description: "Fecha del último acceso - opcional"
        }
      }
    }
  }
});