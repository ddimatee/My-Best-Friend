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
  if (payload.cumpleanos) data.cumpleanos = new Date(payload.cumpleanos);
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
    const db = await connectDB();
    const query = {};
    if (req.query.userId) {
      const uid = toObjectId(req.query.userId);
      if (!uid) return res.status(400).json({ error: 'userId inválido' });
      query.userId = uid;
    }
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
    const db = await connectDB();
    // Intento 1: buscar por ObjectId
    let item = await db.collection('mascotas').findOne({ _id });
    // Intento 2: en algunos entornos el _id pudo guardarse como string
    if (!item) item = await db.collection('mascotas').findOne({ _id: rawId });
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
    const data = coerceMascota(req.body, { isCreate: true });
    if (!data.userId || !ObjectId.isValid(data.userId)) return res.status(400).json({ error: 'userId requerido o inválido' });
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
  // Validar userId si viene en la carga útil
  if (req.body.userId !== undefined && typeof req.body.userId === 'string' && !ObjectId.isValid(req.body.userId.trim())) {
    return res.status(400).json({ error: 'userId inválido (formato ObjectId requerido)' });
  }
  try {
    const data = coerceMascota(req.body);
    data.fechaActualizacion = new Date();
    const db = await connectDB();

    let result = await db.collection('mascotas').findOneAndUpdate({ _id }, { $set: data }, { returnDocument: 'after' });
    let updated = result && (result.value !== undefined ? result.value : result);

    if (!updated) {
      result = await db.collection('mascotas').findOneAndUpdate({ _id: rawId }, { $set: data }, { returnDocument: 'after' });
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
    const db = await connectDB();
    let result = await db.collection('mascotas').deleteOne({ _id });
    if (result.deletedCount === 0) {
      result = await db.collection('mascotas').deleteOne({ _id: rawId });
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
