# My Best Friend - Backend

API REST para la aplicación My Best Friend.

## Requisitos
- Node.js >= 16
- Cuenta y cluster en MongoDB Atlas (o instancia local)

## Variables de entorno (.env)
Crea un archivo `.env` en `backend/` con:
```
MONGO_URI=mongodb+srv://usuario:password@cluster/mi_db
JWT_SECRET=tu_secreto_seguro
PORT=3000
CORS_ORIGINS=http://localhost:3000,http://10.0.2.2:3000
```

## Instalación
Dentro de la carpeta `backend/`:
```
npm install
```

## Ejecutar
Desarrollo con reinicio automático:
```
npm run dev
```
Producción / simple:
```
npm start
```

## Endpoints principales
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/api/usuarios/registro` | Registrar nuevo usuario |
| POST | `/api/usuarios/login` | Iniciar sesión (devuelve token JWT) |
| GET | `/api/utils/info` | Información básica de la API |

Las demás rutas (mascotas, eventos, vacunas, peso, álbum) están organizadas en `/routes/`.

## Registro de usuario (Ejemplo)
Request:
```json
{
  "nombre": "Juan",
  "apellido": "Pérez",
  "correo": "juan@example.com",
  "celular": "1234567890",
  "contraseña": "Password123"
}
```

Respuesta (201):
```json
{
  "mensaje": "Usuario registrado correctamente",
  "usuario": { "_id": "...", "correo": "juan@example.com", "nombre": "Juan", "apellido": "Pérez" }
}
```

## Login (Ejemplo)
Request:
```json
{
  "correo": "juan@example.com",
  "contraseña": "Password123"
}
```
Response (200):
```json
{
  "mensaje": "Login exitoso",
  "token": "<JWT>",
  "usuario": { "_id": "...", "correo": "juan@example.com" }
}
```

## CORS
En desarrollo se permiten orígenes definidos en `CORS_ORIGINS`. Para emulador Android usa `10.0.2.2`.

## Autenticación
- En login se genera un JWT firmado con `JWT_SECRET`.
- Incluye el token en el header: `Authorization: Bearer <token>` para rutas protegidas.

## Notas
- La clave del JSON para contraseña es `contraseña` (con ñ). Asegúrate de enviarla así desde el frontend.
- Ajusta la expresión regular de contraseña en `middlewares/validaciones.js` si cambias requisitos.

## Próximos pasos sugeridos
- Implementar refresh tokens.
- Subir imágenes a un servicio (S3, Cloudinary) en lugar de almacenar localmente.
- Tests automatizados.

---
Made with ❤ for pets.
