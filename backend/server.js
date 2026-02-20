require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { MongoClient, ObjectId } = require('mongodb');
const crypto = require('crypto');

// Configuración
const PORT = process.env.PORT || 3000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017';

const DATABASE_NAME = process.env.DATABASE_NAME || 'My-Best-Friend';

// Inicialización
const app = express();
app.use(express.json());
app.use(cors({ origin: true }));

// ── Middleware de logging HTTP (evidencia para Sprint 2) ─────────────────────
app.use((req, res, next) => {
  const start = Date.now();
  const timestamp = new Date().toISOString().replace('T', ' ').substring(0, 19);
  // Capturar body para métodos que lo envían
  const body = ['POST', 'PUT', 'PATCH'].includes(req.method)
    ? JSON.stringify(req.body)
    : '';
  res.on('finish', () => {
    const ms = Date.now() - start;
    const bodyStr = body ? ` | BODY: ${body}` : '';
    console.log(`[${timestamp}] ${req.method} ${req.originalUrl} → ${res.statusCode} (${ms}ms)${bodyStr}`);
  });
  next();
});
// ─────────────────────────────────────────────────────────────────────────────

let db, client;

async function connectDB() {
  if (db) return db;
  client = new MongoClient(MONGODB_URI);
  await client.connect();
  db = client.db(DATABASE_NAME);
  return db;
}

// Utilidades
const toObjectId = (id) => {
  try { return new ObjectId(id); } catch { return null; }
};

const getAuthTokenFromRequest = (req) =>
  (req.headers.authorization || '').replace('Bearer ', '').trim();

const getAuthenticatedUser = async (req) => {
  const token = getAuthTokenFromRequest(req);
  if (!token) return null;
  const db = await connectDB();
  return db.collection('usuarios').findOne({ authToken: token });
};

const getOwnerCandidates = (user) => {
  if (!user || !user._id) return [];
  const idAsString = user._id.toString();
  return [user._id, idAsString];
};

// Serialización segura para enviar a la UI
const serialize = (doc) => {
  if (!doc) return doc;
  const out = { ...doc };
  if (out._id && typeof out._id === 'object' && out._id.toString) out._id = out._id.toString();
  if (out.userId && typeof out.userId === 'object' && out.userId.toString) out.userId = out.userId.toString();
  if (out.mascotaId && typeof out.mascotaId === 'object' && out.mascotaId.toString) out.mascotaId = out.mascotaId.toString();
  return out;
};

const coerceUsuario = (payload, { isCreate = false } = {}) => {
  const data = {};
  const fields = ['nombre', 'apellido', 'correo', 'password', 'celular', 'fotoPerfil', 'direccion', 'rol', 'fcmToken', 'authToken'];
  for (const f of fields) if (payload[f] !== undefined) data[f] = payload[f];
  if (payload.fechaCreacion) data.fechaCreacion = new Date(payload.fechaCreacion);
  if (payload.ultimoAcceso) data.ultimoAcceso = new Date(payload.ultimoAcceso);
  if (isCreate && !data.fechaCreacion) data.fechaCreacion = new Date();
  return data;
};

const coerceMascota = (payload, { isCreate = false } = {}) => {
  const data = {};
  // Sólo establecer userId si es un ObjectId válido
  if (payload.userId) {
    if (typeof payload.userId === 'string') {
      const trimmed = payload.userId.trim();
      const oid = toObjectId(trimmed);
      if (oid) data.userId = oid; // ignorar valores inválidos para no romper validador
    } else if (payload.userId instanceof ObjectId) {
      data.userId = payload.userId;
    }
  }
  const fields = ['nombre', 'imagenPath', 'situacion', 'sexo', 'raza', 'rol'];
  for (const f of fields) if (payload[f] !== undefined) data[f] = payload[f];
  if (!data.situacion && typeof payload.descripcion === 'string') {
    const desc = payload.descripcion.trim();
    if (desc === 'Acabo de tener un perro' || desc === 'Ya conozco bien a mi perro') {
      data.situacion = desc;
    }
  }
  if (!data.cumpleanos && payload.fechaNacimiento) data.cumpleanos = new Date(payload.fechaNacimiento);
  if (!data.cumpleanos && payload.fecha_nac) data.cumpleanos = new Date(payload.fecha_nac);
  if (payload.cumpleanos) data.cumpleanos = new Date(payload.cumpleanos);
  if (typeof data.sexo === 'string') {
    const s = data.sexo.trim().toLowerCase();
    if (s === 'macho') data.sexo = 'Macho';
    if (s === 'hembra') data.sexo = 'Hembra';
  }
  if (typeof data.rol === 'string') {
    const r = data.rol.trim().toLowerCase();
    if (r === 'dueno' || r === 'dueño') data.rol = 'Dueño';
    if (r === 'cuidador') data.rol = 'Cuidador';
  }
  if (payload.seguimiento !== undefined) data.seguimiento = Boolean(payload.seguimiento);
  if (payload.coCuidado !== undefined) data.coCuidado = Boolean(payload.coCuidado);
  if (payload.oculto !== undefined) data.oculto = Boolean(payload.oculto);
  if (Array.isArray(payload.estiloVida)) data.estiloVida = payload.estiloVida.map(String);
  if (payload.fechaActualizacion) data.fechaActualizacion = new Date(payload.fechaActualizacion);
  if (isCreate) {
    if (!data.fechaCreacion) data.fechaCreacion = new Date();
  }
  return data;
};

// Rutas de salud
app.get('/api/health', (_req, res) => res.json({ ok: true, service: 'My-Best-Friend API', db: Boolean(db), database: DATABASE_NAME }));
// Endpoint rápido para verificar cantidad de documentos
app.get('/api/usuarios/count', async (_req, res) => {
  try {
    const db = await connectDB();
    const count = await db.collection('usuarios').countDocuments();
    res.json({ count });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ── Auth endpoints ───────────────────────────────────────────────────────────

// POST /api/usuarios/login — autenticación por correo + contraseña
app.post('/api/usuarios/login', async (req, res) => {
  const payload = req.body || {};
  const correo = payload.correo;
  const contrasena = payload['contraseña'] ?? payload.password;
  const recordar = payload.recordar === true;
  if (!correo || !contrasena) {
    return res.status(400).json({ success: false, message: 'Correo y contraseña son requeridos' });
  }
  try {
    const db = await connectDB();
    const usuario = await db.collection('usuarios').findOne({ correo });
    if (!usuario) {
      return res.status(401).json({ success: false, message: 'Correo no registrado' });
    }
    // Comparación simple (el seed guardó en campo 'password' — en producción usar bcrypt)
    if (usuario.password !== contrasena) {
      return res.status(401).json({ success: false, message: 'Contraseña incorrecta' });
    }
    // Generar / reutilizar token de sesión
    let token = usuario.authToken;
    if (!token) {
      token = crypto.randomBytes(48).toString('hex');
      await db.collection('usuarios').updateOne(
        { _id: usuario._id },
        { $set: { authToken: token, ultimoAcceso: new Date() } }
      );
    } else {
      await db.collection('usuarios').updateOne(
        { _id: usuario._id },
        { $set: { ultimoAcceso: new Date() } }
      );
    }
    const rememberToken = recordar ? crypto.randomBytes(32).toString('hex') : null;
    if (rememberToken) {
      try {
        await db.collection('usuarios').updateOne(
          { _id: usuario._id },
          { $set: { rememberToken } }
        );
      } catch (errRemember) {
        console.warn('Aviso login: no se pudo persistir rememberToken (continuando):', errRemember?.message || errRemember);
      }
    }
    return res.json({
      success: true,
      message: 'Sesión iniciada correctamente',
      data: {
        token,
        rememberToken: rememberToken || '',
        usuario: serialize(usuario),
      },
    });
  } catch (err) {
    console.error('Error en POST /api/usuarios/login:', err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// POST /api/usuarios/registro — registro de nuevo usuario
app.post('/api/usuarios/registro', async (req, res) => {
  const { nombre, apellido, correo, celular, contraseña } = req.body || {};
  if (!nombre || !apellido || !correo || !contraseña) {
    return res.status(400).json({ success: false, message: 'Campos requeridos: nombre, apellido, correo, contraseña' });
  }
  try {
    const db = await connectDB();
    const existe = await db.collection('usuarios').findOne({ correo });
    if (existe) {
      return res.status(409).json({ success: false, message: 'El correo ya está registrado' });
    }
    const token = crypto.randomBytes(48).toString('hex');
    const nuevo = {
      nombre, apellido, correo,
      celular: celular || '',
      password: contraseña,
      rol: 'dueno',
      authToken: token,
      fotoPerfil: '',
      fechaCreacion: new Date(),
    };
    const result = await db.collection('usuarios').insertOne(nuevo);
    return res.status(201).json({
      success: true,
      message: 'Usuario registrado correctamente',
      data: {
        token,
        usuario: serialize({ _id: result.insertedId, ...nuevo }),
      },
    });
  } catch (err) {
    console.error('Error en POST /api/usuarios/registro:', err);
    res.status(500).json({ success: false, message: err.message });
  }
});

// GET /api/usuarios/perfil — perfil del usuario autenticado por token
app.get('/api/usuarios/perfil', async (req, res) => {
  const token = getAuthTokenFromRequest(req);
  if (!token) return res.status(401).json({ success: false, message: 'Token requerido' });
  try {
    const db = await connectDB();
    const usuario = await db.collection('usuarios').findOne({ authToken: token });
    if (!usuario) return res.status(401).json({ success: false, message: 'Token inválido o expirado' });
    return res.json({ success: true, data: { usuario: serialize(usuario) } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ─────────────────────────────────────────────────────────────────────────────

// CRUD Usuarios
app.get('/api/usuarios', async (req, res) => {
  try {
    const db = await connectDB();
    const items = await db.collection('usuarios').find({}).sort({ fechaCreacion: -1 }).toArray();
    res.json(items.map(serialize));
  } catch (err) {
    console.error('Error en GET /api/usuarios:', err);
    res.status(500).json({ error: err.message, stack: err.stack });
  }
});

app.get('/api/usuarios/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const item = await db.collection('usuarios').findOne({ _id });
    if (!item) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json(serialize(item));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/usuarios', async (req, res) => {
  try {
    const data = coerceUsuario(req.body, { isCreate: true });
    const required = ['nombre', 'apellido', 'correo', 'password', 'celular'];
    for (const r of required) if (!data[r]) return res.status(400).json({ error: `Campo requerido: ${r}` });
    const db = await connectDB();
    const result = await db.collection('usuarios').insertOne(data);
    res.status(201).json(serialize({ _id: result.insertedId, ...data }));
  } catch (err) {
    const msg = err?.code === 11000 ? 'Correo ya registrado' : err.message;
    res.status(500).json({ error: msg });
  }
});

// Generar / rotar token de autenticación simple para un usuario
// (No es JWT, es un token aleatorio largo; para producción se recomienda hashing y expiración)
app.post('/api/usuarios/:id/token', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    // Generar token seguro de 48 bytes -> 96 hex chars
    const token = crypto.randomBytes(48).toString('hex');
    const result = await db.collection('usuarios').findOneAndUpdate(
      { _id },
      { $set: { authToken: token, ultimoAcceso: new Date() } },
      { returnDocument: 'after' }
    );
    const updated = result && (result.value !== undefined ? result.value : result);
    if (!updated) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json({ token, usuario: serialize(updated) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/usuarios/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const data = coerceUsuario(req.body);
    const db = await connectDB();
    const result = await db.collection('usuarios').findOneAndUpdate({ _id }, { $set: data }, { returnDocument: 'after' });
    const updated = result && (result.value !== undefined ? result.value : result);
    if (!updated) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json(serialize(updated));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/usuarios/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const result = await db.collection('usuarios').deleteOne({ _id });
    if (result.deletedCount === 0) return res.status(404).json({ error: 'Usuario no encontrado' });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// CRUD Mascotas
app.get('/api/mascotas', async (req, res) => {
  try {
    const usuario = await getAuthenticatedUser(req);
    if (!usuario) return res.status(401).json({ error: 'No autenticado' });

    const db = await connectDB();
    const query = { userId: { $in: getOwnerCandidates(usuario) } };
    const items = await db.collection('mascotas').find(query).sort({ fechaCreacion: -1 }).toArray();
    res.json(items.map(serialize));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/mascotas/:id', async (req, res) => {
  const rawId = (req.params.id || '').trim();
  const _id = toObjectId(rawId);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const usuario = await getAuthenticatedUser(req);
    if (!usuario) return res.status(401).json({ error: 'No autenticado' });

    const db = await connectDB();
    const ownerCandidates = getOwnerCandidates(usuario);
    // Intento 1: buscar por ObjectId
    let item = await db.collection('mascotas').findOne({ _id, userId: { $in: ownerCandidates } });
    // Intento 2: en algunos entornos el _id pudo guardarse como string
    if (!item) item = await db.collection('mascotas').findOne({ _id: rawId, userId: { $in: ownerCandidates } });
    if (!item) {
      console.warn(`GET /api/mascotas/:id no encontrada -> id=${rawId}`);
      return res.status(404).json({ error: `Mascota no encontrada (id: ${rawId})` });
    }
    res.json(serialize(item));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/mascotas', async (req, res) => {
  try {
    const usuario = await getAuthenticatedUser(req);
    if (!usuario) return res.status(401).json({ error: 'No autenticado' });

    const data = coerceMascota(req.body, { isCreate: true });
    data.userId = usuario._id;
    if (!data.nombre) return res.status(400).json({ error: 'Campo requerido: nombre' });
    const db = await connectDB();
    const result = await db.collection('mascotas').insertOne(data);
    res.status(201).json(serialize({ _id: result.insertedId, ...data }));
  } catch (err) {
    console.error('Error en POST /api/mascotas:', err);
    const isValidation = /Document failed validation/i.test(err.message) || err?.name === 'MongoServerError';
    const payload = { error: isValidation ? 'El documento no cumple el esquema (verifique userId y tipos permitidos)' : err.message };
    if (process.env.NODE_ENV !== 'production') payload.details = err?.errInfo || err?.errmsg || err?.message;
    res.status(isValidation ? 400 : 500).json(payload);
  }
});

app.put('/api/mascotas/:id', async (req, res) => {
  const rawId = (req.params.id || '').trim();
  const _id = toObjectId(rawId);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const usuario = await getAuthenticatedUser(req);
    if (!usuario) return res.status(401).json({ error: 'No autenticado' });

    const data = coerceMascota(req.body);
    delete data.userId;
    data.fechaActualizacion = new Date();
    const db = await connectDB();
    const ownerCandidates = getOwnerCandidates(usuario);

    let result = await db.collection('mascotas').findOneAndUpdate({ _id, userId: { $in: ownerCandidates } }, { $set: data }, { returnDocument: 'after' });
    let updated = result && (result.value !== undefined ? result.value : result);

    if (!updated) {
      result = await db.collection('mascotas').findOneAndUpdate({ _id: rawId, userId: { $in: ownerCandidates } }, { $set: data }, { returnDocument: 'after' });
      updated = result && (result.value !== undefined ? result.value : result);
    }
    if (!updated) {
      console.warn(`PUT /api/mascotas/:id no encontrada -> id=${rawId}`);
      return res.status(404).json({ error: `Mascota no encontrada (id: ${rawId})` });
    }
    res.json(serialize(updated));
  } catch (err) {
    console.error('Error en PUT /api/mascotas/:id', err);
    // Si es error de validador, dar mensaje más claro
    const isValidation = /Document failed validation/i.test(err.message) || err?.name === 'MongoServerError';
    const msg = isValidation ? 'La actualización no cumple el esquema (verifique userId y tipos de campos)' : err.message;
    const payload = { error: msg };
    if (process.env.NODE_ENV !== 'production') payload.details = err?.errInfo || err?.errmsg || err?.message;
    res.status(isValidation ? 400 : 500).json(payload);
  }
});

app.delete('/api/mascotas/:id', async (req, res) => {
  const rawId = (req.params.id || '').trim();
  const _id = toObjectId(rawId);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const usuario = await getAuthenticatedUser(req);
    if (!usuario) return res.status(401).json({ error: 'No autenticado' });

    const db = await connectDB();
    const ownerCandidates = getOwnerCandidates(usuario);
    let result = await db.collection('mascotas').deleteOne({ _id, userId: { $in: ownerCandidates } });
    if (result.deletedCount === 0) {
      result = await db.collection('mascotas').deleteOne({ _id: rawId, userId: { $in: ownerCandidates } });
    }
    if (result.deletedCount === 0) return res.status(404).json({ error: 'Mascota no encontrada' });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Endpoint de diagnóstico para IDs problemáticos
app.get('/api/mascotas/debug/:id', async (req, res) => {
  const rawId = (req.params.id || '').trim();
  const _id = toObjectId(rawId);
  try {
    const db = await connectDB();
    const asObjectIdValid = Boolean(_id);
    let foundByObjectId = false;
    let foundByString = false;
    let item = null;
    if (_id) {
      item = await db.collection('mascotas').findOne({ _id });
      foundByObjectId = Boolean(item);
    }
    if (!item) {
      item = await db.collection('mascotas').findOne({ _id: rawId });
      foundByString = Boolean(item);
    }
    return res.json({ rawId, asObjectIdValid, foundByObjectId, foundByString, item: serialize(item) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ══════════════════════════════════════════════════════════════════════════════
// ALIAS /api/peso → mapea los campos que usa Flutter ('mascota' → mascotaId)
// ══════════════════════════════════════════════════════════════════════════════
app.get('/api/peso', async (req, res) => {
  try {
    const db = await connectDB();
    const query = {};
    const mascotaParam = req.query.mascota || req.query.mascotaId;
    if (mascotaParam) {
      const mid = toObjectId(mascotaParam);
      if (!mid) return res.status(400).json({ error: 'mascotaId inválido' });
      query.mascotaId = mid;
    }
    if (req.query.userId) {
      const uid = toObjectId(req.query.userId);
      if (uid) query.userId = uid;
    }
    // Filtro por rango de fechas
    if (req.query.fechaInicio || req.query.fechaFin) {
      query.fecha = {};
      if (req.query.fechaInicio) query.fecha.$gte = new Date(req.query.fechaInicio);
      if (req.query.fechaFin) query.fecha.$lte = new Date(req.query.fechaFin);
    }
    const limite = req.query.limite ? parseInt(req.query.limite) : 100;
    const items = await db.collection('registros_peso').find(query).sort({ fecha: -1 }).limit(limite).toArray();
    // Añadir campo 'id' como alias de '_id' para compatibilidad Flutter
    const data = items.map(doc => ({ ...serialize(doc), id: doc._id.toString() }));
    res.json({ success: true, data });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/peso', async (req, res) => {
  try {
    const db = await connectDB();
    const body = req.body;
    const mascotaParam = body.mascota || body.mascotaId;
    if (!mascotaParam || body.peso === undefined) return res.status(400).json({ error: 'Campos requeridos: mascota, peso' });
    const data = {
      userId: body.userId ? toObjectId(body.userId) : null,
      mascotaId: toObjectId(mascotaParam),
      peso: parseFloat(body.peso),
      fecha: body.fecha ? new Date(body.fecha) : new Date(),
      notas: body.observaciones || body.notas || '',
      tipoRegistro: body.tipoRegistro || 'rutina',
      fechaCreacion: new Date(),
    };
    if (!data.mascotaId) return res.status(400).json({ error: 'mascotaId inválido' });
    const result = await db.collection('registros_peso').insertOne(data, { bypassDocumentValidation: true });
    const saved = { _id: result.insertedId, ...data };
    res.status(201).json({ success: true, data: { ...serialize(saved), id: result.insertedId.toString() } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/peso/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const body = req.body;
    const data = {};
    if (body.peso !== undefined) data.peso = parseFloat(body.peso);
    if (body.fecha !== undefined) data.fecha = new Date(body.fecha);
    if (body.observaciones !== undefined) data.notas = body.observaciones;
    if (body.notas !== undefined) data.notas = body.notas;
    data.fechaActualizacion = new Date();
    const result = await db.collection('registros_peso').findOneAndUpdate(
      { _id },
      { $set: data },
      { returnDocument: 'after', bypassDocumentValidation: true }
    );
    const updated = result && (result.value !== undefined ? result.value : result);
    if (!updated) return res.status(404).json({ error: 'Registro no encontrado' });
    const serialized = serialize(updated);
    res.json({ success: true, data: { ...serialized, id: updated._id ? updated._id.toString() : (updated.id || '') } });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/peso/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const result = await db.collection('registros_peso').deleteOne({ _id });
    if (result.deletedCount === 0) return res.status(404).json({ error: 'Registro no encontrado' });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ══════════════════════════════════════════════════════════════════════════════
// ALIAS /api/album → mapea los campos que usa Flutter ('mascota' → mascotaId)
// ══════════════════════════════════════════════════════════════════════════════
app.get('/api/album', async (req, res) => {
  try {
    const db = await connectDB();
    const query = {};
    const mascotaParam = req.query.mascota || req.query.mascotaId;
    if (mascotaParam) {
      const mid = toObjectId(mascotaParam);
      if (!mid) return res.status(400).json({ error: 'mascotaId inválido' });
      query.mascotaId = mid;
    }
    if (req.query.userId) {
      const uid = toObjectId(req.query.userId);
      if (uid) query.userId = uid;
    }
    const items = await db.collection('fotos_album').find(query).sort({ fechaSubida: -1 }).toArray();
    res.json({ success: true, data: items.map(serialize) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/album', async (req, res) => {
  try {
    const db = await connectDB();
    const body = req.body;
    const mascotaParam = body.mascota || body.mascotaId;
    if (!mascotaParam) return res.status(400).json({ error: 'Campo requerido: mascota' });
    const data = {
      userId: body.userId ? toObjectId(body.userId) : null,
      mascotaId: toObjectId(mascotaParam),
      url: body.url || '',
      titulo: body.titulo || '',
      descripcion: body.descripcion || '',
      ubicacion: body.ubicacion || '',
      etiquetas: body.etiquetas || [],
      esPortada: body.esPortada === true,
      mes: body.mes || new Date().toLocaleString('es', { month: 'long' }),
      ano: body.ano || String(new Date().getFullYear()),
      rutasImagenes: body.url ? [body.url] : [],
      fechaSubida: body.fecha ? new Date(body.fecha) : new Date(),
      fechaCreacion: new Date(),
    };
    if (!data.mascotaId) return res.status(400).json({ error: 'mascotaId inválido' });
    const result = await db.collection('fotos_album').insertOne(data, { bypassDocumentValidation: true });
    res.status(201).json({ success: true, data: serialize({ _id: result.insertedId, ...data }) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/album/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const body = req.body;
    const data = {};
    if (body.titulo !== undefined) data.titulo = body.titulo;
    if (body.descripcion !== undefined) data.descripcion = body.descripcion;
    if (body.etiquetas !== undefined) data.etiquetas = body.etiquetas;
    if (body.esPortada !== undefined) data.esPortada = Boolean(body.esPortada);
    data.fechaActualizacion = new Date();
    const result = await db.collection('fotos_album').findOneAndUpdate({ _id }, { $set: data }, { returnDocument: 'after' });
    const updated = result && (result.value !== undefined ? result.value : result);
    if (!updated) return res.status(404).json({ error: 'Foto no encontrada' });
    res.json({ success: true, data: serialize(updated) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/album/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const result = await db.collection('fotos_album').deleteOne({ _id });
    if (result.deletedCount === 0) return res.status(404).json({ error: 'Foto no encontrada' });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ══════════════════════════════════════════════════════════════════════════════
// CRUD Registros de Peso
// ══════════════════════════════════════════════════════════════════════════════
app.get('/api/registros_peso', async (req, res) => {
  try {
    const db = await connectDB();
    const query = {};
    if (req.query.mascotaId) {
      const mid = toObjectId(req.query.mascotaId);
      if (!mid) return res.status(400).json({ error: 'mascotaId inválido' });
      query.mascotaId = mid;
    }
    if (req.query.userId) {
      const uid = toObjectId(req.query.userId);
      if (!uid) return res.status(400).json({ error: 'userId inválido' });
      query.userId = uid;
    }
    const items = await db.collection('registros_peso').find(query).sort({ fecha: -1 }).toArray();
    res.json(items.map(serialize));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/registros_peso', async (req, res) => {
  try {
    const db = await connectDB();
    const body = req.body;
    if (!body.mascotaId || !body.peso) return res.status(400).json({ error: 'Campos requeridos: mascotaId, peso' });
    const data = {
      userId: body.userId ? toObjectId(body.userId) : null,
      mascotaId: toObjectId(body.mascotaId),
      peso: parseFloat(body.peso),
      fecha: body.fecha ? new Date(body.fecha) : new Date(),
      notas: body.notas || '',
      fechaCreacion: new Date(),
    };
    if (!data.mascotaId) return res.status(400).json({ error: 'mascotaId inválido' });
    const result = await db.collection('registros_peso').insertOne(data, { bypassDocumentValidation: true });
    res.status(201).json(serialize({ _id: result.insertedId, ...data }));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/registros_peso/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const body = req.body;
    const data = {};
    if (body.peso !== undefined) data.peso = parseFloat(body.peso);
    if (body.fecha !== undefined) data.fecha = new Date(body.fecha);
    if (body.notas !== undefined) data.notas = body.notas;
    data.fechaActualizacion = new Date();
    const result = await db.collection('registros_peso').findOneAndUpdate({ _id }, { $set: data }, { returnDocument: 'after' });
    const updated = result && (result.value !== undefined ? result.value : result);
    if (!updated) return res.status(404).json({ error: 'Registro no encontrado' });
    res.json(serialize(updated));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/registros_peso/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const result = await db.collection('registros_peso').deleteOne({ _id });
    if (result.deletedCount === 0) return res.status(404).json({ error: 'Registro no encontrado' });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ══════════════════════════════════════════════════════════════════════════════
// CRUD Vacunas
// ══════════════════════════════════════════════════════════════════════════════

// IMPORTANTE: /api/vacunas/recordatorios debe ir ANTES de /api/vacunas/:id
app.get('/api/vacunas/recordatorios', async (req, res) => {
  try {
    const db = await connectDB();
    const query = { tieneRecordatorio: true };
    if (req.query.userId) {
      const uid = toObjectId(req.query.userId);
      if (uid) query.userId = uid;
    }
    const items = await db.collection('vacunas').find(query).sort({ fechaAplicacion: -1 }).toArray();
    res.json({ success: true, data: items.map(serialize) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/vacunas', async (req, res) => {
  try {
    const db = await connectDB();
    const query = {};
    const mascotaParam = req.query.mascota || req.query.mascotaId;
    if (mascotaParam) {
      const mid = toObjectId(mascotaParam);
      if (!mid) return res.status(400).json({ error: 'mascotaId inválido' });
      query.mascotaId = mid;
    }
    if (req.query.userId) {
      const uid = toObjectId(req.query.userId);
      if (uid) query.userId = uid;
    }
    const items = await db.collection('vacunas').find(query).sort({ fechaAplicacion: -1 }).toArray();
    res.json({ success: true, data: items.map(serialize) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/vacunas', async (req, res) => {
  try {
    const db = await connectDB();
    const body = req.body;
    const mascotaParam = body.mascota || body.mascotaId;
    if (!mascotaParam || !body.nombre) return res.status(400).json({ error: 'Campos requeridos: mascota, nombre' });
    const recordatorioActivo = body.recordatorio?.activo === true;
    const data = {
      userId: body.userId ? toObjectId(body.userId) : null,
      mascotaId: toObjectId(mascotaParam),
      nombre: body.nombre,
      fechaAplicacion: body.fechaAplicacion ? new Date(body.fechaAplicacion) : new Date(),
      descripcion: body.observaciones || body.descripcion || '',
      ubicacion: body.ubicacion || '',
      tieneRecordatorio: recordatorioActivo,
      recordatorio: body.recordatorio || null,
      veterinario: body.veterinario || null,
      lote: body.lote || '',
      laboratorio: body.laboratorio || '',
      fechaCreacion: new Date(),
    };
    if (!data.mascotaId) return res.status(400).json({ error: 'mascotaId inválido' });
    const result = await db.collection('vacunas').insertOne(data, { bypassDocumentValidation: true });
    res.status(201).json({ success: true, data: serialize({ _id: result.insertedId, ...data }) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/vacunas/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const body = req.body;
    const data = {};
    const mascotaParam = body.mascota || body.mascotaId;
    if (mascotaParam !== undefined) {
      const mid = toObjectId(mascotaParam);
      if (!mid) return res.status(400).json({ error: 'mascotaId inválido' });
      data.mascotaId = mid;
    }
    if (body.nombre !== undefined) data.nombre = body.nombre;
    if (body.fechaAplicacion !== undefined) data.fechaAplicacion = new Date(body.fechaAplicacion);
    if (body.observaciones !== undefined) data.descripcion = body.observaciones;
    if (body.descripcion !== undefined) data.descripcion = body.descripcion;
    if (body.ubicacion !== undefined) data.ubicacion = body.ubicacion;
    if (body.recordatorio !== undefined) {
      data.recordatorio = body.recordatorio;
      data.tieneRecordatorio = body.recordatorio?.activo === true;
    }
    if (body.veterinario !== undefined) data.veterinario = body.veterinario;
    data.fechaActualizacion = new Date();
    const result = await db.collection('vacunas').findOneAndUpdate(
      { _id },
      { $set: data },
      { returnDocument: 'after', bypassDocumentValidation: true }
    );
    const updated = result && (result.value !== undefined ? result.value : result);
    if (!updated) return res.status(404).json({ error: 'Vacuna no encontrada' });
    res.json({ success: true, data: serialize(updated) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/vacunas/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const result = await db.collection('vacunas').deleteOne({ _id });
    if (result.deletedCount === 0) return res.status(404).json({ error: 'Vacuna no encontrada' });
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });

  }
});

// ══════════════════════════════════════════════════════════════════════════════
// CRUD Eventos
// ══════════════════════════════════════════════════════════════════════════════
app.get('/api/eventos', async (req, res) => {
  try {
    const db = await connectDB();
    const query = {};
    if (req.query.userId) {
      const uid = toObjectId(req.query.userId);
      if (uid) query.userId = uid;
    }
    const mascotaParam = req.query.mascota || req.query.mascotaId;
    if (mascotaParam) {
      const mid = toObjectId(mascotaParam);
      if (!mid) return res.status(400).json({ error: 'mascotaId inválido' });
      query.mascotaId = mid;
    }
    // Filtro por fecha exacta (día): Flutter manda ?fecha=2026-02-17
    if (req.query.fecha) {
      const fechaInicio = new Date(req.query.fecha);
      const fechaFin = new Date(req.query.fecha);
      fechaFin.setDate(fechaFin.getDate() + 1);
      query.fecha = { $gte: fechaInicio, $lt: fechaFin };
    }
    const items = await db.collection('eventos').find(query).sort({ fecha: -1 }).toArray();
    res.json({ success: true, data: items.map(serialize) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/eventos', async (req, res) => {
  try {
    const db = await connectDB();
    const body = req.body;
    if (!body.titulo || !body.tipo || !body.fecha) return res.status(400).json({ error: 'Campos requeridos: titulo, tipo, fecha' });
    const tiposValidos = ['vacunas', 'medicamentos', 'alimentacion', 'ejercicio', 'citas_veterinario', 'aseo', 'juegos', 'otro'];
    const tipo = tiposValidos.includes(body.tipo) ? body.tipo : 'otro';
    const mascotaParam = body.mascota || body.mascotaId;
    if (!mascotaParam) return res.status(400).json({ error: 'Campo requerido: mascotaId' });
    const mascotaOid = toObjectId(mascotaParam);
    if (!mascotaOid) return res.status(400).json({ error: 'mascotaId inválido' });
    const data = {
      userId: body.userId ? toObjectId(body.userId) : null,
      mascotaId: mascotaOid,
      titulo: body.titulo,
      tipo,
      fecha: new Date(body.fecha),
      hora: body.hora || '',
      descripcion: body.descripcion || '',
      completado: false,
      prioridad: body.prioridad || 'media',
      mascota: body.mascota || null,
      recordatorio: body.recordatorio || null,
      fechaCreacion: new Date(),
      fechaActualizacion: new Date(),
    };
    const result = await db.collection('eventos').insertOne(data, { bypassDocumentValidation: true });
    res.status(201).json({ success: true, data: serialize({ _id: result.insertedId, ...data }) });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/eventos/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const body = req.body;
    const data = {};
    if (body.titulo !== undefined) data.titulo = body.titulo;
    if (body.tipo !== undefined) data.tipo = body.tipo;
    if (body.fecha !== undefined) data.fecha = new Date(body.fecha);
    if (body.hora !== undefined) data.hora = body.hora;
    if (body.descripcion !== undefined) data.descripcion = body.descripcion;
    if (body.completado !== undefined) data.completado = Boolean(body.completado);
    if (body.prioridad !== undefined) data.prioridad = body.prioridad;
    data.fechaActualizacion = new Date();
    const result = await db.collection('eventos').findOneAndUpdate({ _id }, { $set: data }, { returnDocument: 'after' });
    const updated = result && (result.value !== undefined ? result.value : result);
    if (!updated) return res.status(404).json({ error: 'Evento no encontrado' });
    res.json(serialize(updated));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/eventos/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const result = await db.collection('eventos').deleteOne({ _id });
    if (result.deletedCount === 0) return res.status(404).json({ error: 'Evento no encontrado' });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ══════════════════════════════════════════════════════════════════════════════
// CRUD Recordatorios del Calendario
// ══════════════════════════════════════════════════════════════════════════════
app.get('/api/recordatorios', async (req, res) => {
  try {
    const db = await connectDB();
    const query = {};
    if (req.query.userId) {
      const uid = toObjectId(req.query.userId);
      if (!uid) return res.status(400).json({ error: 'userId inválido' });
      query.userId = uid;
    }
    if (req.query.mascotaId) {
      const mid = toObjectId(req.query.mascotaId);
      if (!mid) return res.status(400).json({ error: 'mascotaId inválido' });
      query.mascotaId = mid;
    }
    const items = await db.collection('recordatorios_calendario').find(query).sort({ fechaHora: 1 }).toArray();
    res.json(items.map(serialize));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.post('/api/recordatorios', async (req, res) => {
  try {
    const db = await connectDB();
    const body = req.body;
    if (!body.mascotaId) return res.status(400).json({ error: 'Campo requerido: mascotaId' });
    const mascotaOid = toObjectId(body.mascotaId);
    if (!mascotaOid) return res.status(400).json({ error: 'mascotaId inválido' });
    const categoriasValidas = ['vacunas', 'medicamentos', 'alimentacion', 'ejercicio', 'citas_veterinario', 'aseo', 'juegos', 'otro'];
    const frecuenciasValidas = ['una_vez', 'diario', 'semanal', 'mensual', 'anual'];
    const categoria = categoriasValidas.includes(body.categoria) ? body.categoria : 'otro';
    const frecuencia = frecuenciasValidas.includes(body.frecuencia) ? body.frecuencia : 'una_vez';
    const tipoRecordatorio = ['una_vez', 'repetir'].includes(body.tipoRecordatorio) ? body.tipoRecordatorio : 'una_vez';
    const data = {
      userId: body.userId ? toObjectId(body.userId) : null,
      mascotaId: mascotaOid,
      mascotaNombre: body.mascotaNombre || '',
      titulo: body.titulo || body.descripcion || 'Recordatorio',
      descripcion: body.descripcion || '',
      categoria,
      fechaHora: body.fechaHora ? new Date(body.fechaHora) : new Date(),
      tipoRecordatorio,
      frecuencia,
      avisos: body.avisos || [],
      activo: true,
      fechaCreacion: new Date(),
      fechaActualizacion: new Date(),
    };
    const result = await db.collection('recordatorios_calendario').insertOne(data, { bypassDocumentValidation: true });
    res.status(201).json(serialize({ _id: result.insertedId, ...data }));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.put('/api/recordatorios/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const body = req.body;
    const data = {};
    if (body.titulo !== undefined) data.titulo = body.titulo;
    if (body.descripcion !== undefined) data.descripcion = body.descripcion;
    if (body.categoria !== undefined) data.categoria = body.categoria;
    if (body.fechaHora !== undefined) data.fechaHora = new Date(body.fechaHora);
    if (body.tipoRecordatorio !== undefined) data.tipoRecordatorio = body.tipoRecordatorio;
    if (body.frecuencia !== undefined) data.frecuencia = body.frecuencia;
    if (body.avisos !== undefined) data.avisos = Array.isArray(body.avisos) ? body.avisos : [];
    if (body.mascotaNombre !== undefined) data.mascotaNombre = body.mascotaNombre;
    if (body.mascotaId !== undefined) {
      const mid = toObjectId(body.mascotaId);
      data.mascotaId = mid || body.mascotaId;
    }
    if (body.activo !== undefined) data.activo = Boolean(body.activo);
    data.fechaActualizacion = new Date();
    const result = await db.collection('recordatorios_calendario').findOneAndUpdate(
      { _id },
      { $set: data },
      { returnDocument: 'after', bypassDocumentValidation: true }
    );
    const updated = result && (result.value !== undefined ? result.value : result);
    if (!updated) return res.status(404).json({ error: 'Recordatorio no encontrado' });
    res.json(serialize(updated));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

app.delete('/api/recordatorios/:id', async (req, res) => {
  const _id = toObjectId(req.params.id);
  if (!_id) return res.status(400).json({ error: 'ID inválido' });
  try {
    const db = await connectDB();
    const result = await db.collection('recordatorios_calendario').deleteOne({ _id });
    if (result.deletedCount === 0) return res.status(404).json({ error: 'Recordatorio no encontrado' });
    res.json({ ok: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ══════════════════════════════════════════════════════════════════════════════
// Fotos Álbum (GET únicamente — upload requiere multer/storage externo)
// ══════════════════════════════════════════════════════════════════════════════
app.get('/api/fotos_album', async (req, res) => {
  try {
    const db = await connectDB();
    const query = {};
    if (req.query.mascotaId) {
      const mid = toObjectId(req.query.mascotaId);
      if (!mid) return res.status(400).json({ error: 'mascotaId inválido' });
      query.mascotaId = mid;
    }
    if (req.query.userId) {
      const uid = toObjectId(req.query.userId);
      if (!uid) return res.status(400).json({ error: 'userId inválido' });
      query.userId = uid;
    }
    const items = await db.collection('fotos_album').find(query).sort({ fechaSubida: -1 }).toArray();
    res.json(items.map(serialize));
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Iniciar servidor
async function start() {
  try {
    await connectDB();
    console.log(`Conectado a MongoDB -> Base de datos: ${DATABASE_NAME}`);
    // Log inicial de cantidad de usuarios y mascotas
    try {
      const usuariosCount = await db.collection('usuarios').countDocuments();
      const mascotasCount = await db.collection('mascotas').countDocuments();
      console.log(`Usuarios existentes: ${usuariosCount}`);
      console.log(`Mascotas existentes: ${mascotasCount}`);
    } catch (e) {
      console.warn('No se pudo contar documentos aún:', e.message);
    }
    const server = app.listen(PORT, () => console.log(`API escuchando en http://localhost:${PORT}`));
    server.on('error', (err) => {
      console.error('Error del servidor HTTP:', err.message);
    });
  } catch (e) {
    console.error('No se pudo iniciar el servidor:', e.message);
    process.exit(1);
  }
}

start();

process.on('SIGINT', async () => {
  try { await client?.close(); } catch {}
  process.exit(0);
});
