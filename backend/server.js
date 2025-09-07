const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const path = require('path');
const fs = require('fs');
const envPath = path.resolve(__dirname, '../.env');
console.log('ENV path resolved to:', envPath);
console.log('ENV file exists:', fs.existsSync(envPath));
try {
  const raw = fs.readFileSync(envPath, { encoding: 'utf8' });
  console.log('ENV file preview:', raw.split('\n').slice(0,4).join(' | '));
} catch (e) {
  console.log('Could not read .env file:', e.message);
}
require('dotenv').config({ path: envPath, debug: true });

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());
console.log('🔍 URI:', process.env.MONGO_URI);

console.log('DEBUG ENV:', require('fs').existsSync(require('path').resolve(__dirname, '../.env')));
console.log('MONGO_URI:', process.env.MONGO_URI);

// Conexión a MongoDB Atlas
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ Conectado a MongoDB Atlas'))
  .catch(err => console.error('❌ Error al conectar a MongoDB:', err));

// Ruta de prueba
app.get('/', (req, res) => {
  res.send('API funcionando correctamente con MongoDB Atlas');
});

// Puerto
const PORT = process.env.PORT || 3000;

const util = require('util');
const usuariosRoutes = require('./routes/usuarios');
console.log('Debug: tipo usuariosRoutes =', typeof usuariosRoutes);
console.log('Debug: usuariosRoutes inspect:', util.inspect(usuariosRoutes, { depth: 2 }));
if (!usuariosRoutes || (typeof usuariosRoutes !== 'function' && typeof usuariosRoutes !== 'object')) {
  console.error('usuariosRoutes export inválido:', usuariosRoutes);
} else {
  app.use('/api/usuarios', usuariosRoutes);
}

const mascotasRoutes = require('./routes/ruta_mascotas');
console.log('Debug: tipo mascotasRoutes =', typeof mascotasRoutes);
console.log('Debug: mascotasRoutes inspect:', util.inspect(mascotasRoutes, { depth: 4 }));
try {
  const mrStack = mascotasRoutes && mascotasRoutes.stack ? mascotasRoutes.stack.map((l) => ({
    path: l.route ? l.route.path : undefined,
    methods: l.route ? Object.keys(l.route.methods) : undefined,
    name: l.name,
    handleName: l.handle ? l.handle.name : undefined
  })) : null;
  console.log('Debug: mascotasRoutes.stack summary =', util.inspect(mrStack, { depth: 5 }));
} catch (e) {
  console.log('Error inspecting mascotasRoutes.stack:', e.message);
}
if (!mascotasRoutes || (typeof mascotasRoutes !== 'function' && typeof mascotasRoutes !== 'object')) {
  console.error('mascotasRoutes export inválido:', mascotasRoutes);
} else {
  app.use('/api/mascotas', mascotasRoutes);

// Log resumen del stack de rutas para depuración
try {
  const summary = (app._router && app._router.stack) ? app._router.stack.map((m) => ({
    name: m.name,
    route: m.route ? m.route.path : undefined,
    hasHandle: !!m.handle,
    handleName: m.handle ? m.handle.name : undefined,
    hasInnerStack: !!(m.handle && m.handle.stack),
    innerStackLen: m.handle && m.handle.stack ? m.handle.stack.length : 0
  })) : [];
  console.log('RUTAS REGISTRADAS RESUMEN:', JSON.stringify(summary, null, 2));
} catch (e) {
  console.log('Error al resumir rutas:', e.message);
}

// Ruta de depuración: lista rutas registradas (útil para diagnosticar)
app.get('/__routes', (req, res) => {
  try {
    const routes = [];
    const stack = app._router && app._router.stack ? app._router.stack : [];
    stack.forEach((middleware) => {
      try {
        if (middleware && middleware.route) {
          const methods = Object.keys(middleware.route.methods || {}).join(',');
          routes.push({ path: middleware.route.path || '/', methods });
          return;
        }

        // Some middlewares are routers mounted with a handle that has a stack
        const handle = middleware && (middleware.handle || middleware);
        const innerStack = handle && handle.stack ? handle.stack : null;
        if (Array.isArray(innerStack)) {
          innerStack.forEach((layer) => {
            if (layer && layer.route) {
              const methods = Object.keys(layer.route.methods || {}).join(',');
              routes.push({ path: layer.route.path || '/', methods });
            }
          });
        }
      } catch (e) {
        // ignore individual middleware errors
      }
    });
    res.json(routes);
  } catch (err) {
    res.status(500).json({ error: String(err) });
  }
});
// Iniciar servidor después de montar rutas
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
});
}