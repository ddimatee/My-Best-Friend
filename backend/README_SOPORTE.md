# Módulo de Soporte

Colección: `soportes` (Mongo la crea al primer insert).

## Modelo
```
usuario: ObjectId (ref Usuario, opcional)
tipo: String ['Soporte técnico','Sugerencia','Reporte de error','Solicitud de función','Otro']
mensaje: String
estado: String ['nuevo','en_progreso','resuelto','cerrado'] (default: nuevo)
origen: String (default: 'app')
metadata: Object
respuesta: String
leido: Boolean
createdAt / updatedAt (timestamps)
```

## Endpoints
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | /api/soporte | Crear ticket (requiere token) |
| GET | /api/soporte | Listar tickets del usuario |
| GET | /api/soporte/:id | Ver ticket específico |

## Razón por la que no ves la colección
MongoDB solo crea la colección cuando se inserta el primer documento y la operación se confirma. Si recibes `Token no proporcionado`, nunca se insertó nada -> por eso no aparece `soportes` aún.

## Verificación rápida (con usuario logueado)
1. Haz login en la app.
2. Envía un comentario.
3. Ver en consola backend: debería salir `[REQ] POST /api/soporte` y respuesta 201.
4. Refresca en el explorador de Mongo -> aparece colección `soportes`.

## Consultar vía curl (ejemplo)
```
curl -H "Authorization: Bearer <TOKEN>" -H "Content-Type: application/json" \
 -d '{"tipo":"Sugerencia","mensaje":"Prueba desde curl"}' \
 http://localhost:3000/api/soporte
```

## Próximas mejoras sugeridas
- Paginación en GET /api/soporte.
- Filtro por estado.
- Campo prioridad.
- Notificación por email al crear ticket.
