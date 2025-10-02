const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const DatabaseService = require('./services/databaseService');
require('dotenv').config();

const app = express();
const path = require('path');

// Middlewares de seguridad
app.use(helmet()); // Añade headers de seguridad
app.use(compression()); // Comprime las respuestas

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100 // máximo 100 requests por ventana de tiempo
});
app.use(limiter);

// ---------------- CORS -----------------
// Ampliamos CORS para desarrollo: permite múltiples orígenes dinámicamente.
// Puedes definir CORS_ORIGINS en .env como lista separada por comas.
const allowedOrigins = (process.env.CORS_ORIGINS || process.env.FRONTEND_URL || 'http://localhost:8080,http://localhost:3000,http://127.0.0.1:3000')
  .split(',')
  .map(o => o.trim())
  .filter(o => o.length);

// Helper para detectar cualquier localhost/127.0.0.1/10.0.2.2 en cualquier puerto
const isLocalhostOrigin = origin => {
  if (!origin) return false;
  try {
    const url = new URL(origin);
    return ['localhost', '127.0.0.1', '10.0.2.2'].includes(url.hostname);
  } catch {
    return false;
  }
};

app.use(cors({
  origin: (origin, callback) => {
    // Sin origin (Postman, curl) -> permitir
    if (!origin) return callback(null, true);

    // Coincidencia exacta en lista
    if (allowedOrigins.includes(origin)) return callback(null, true);

    // Localhost dinámico (cualquier puerto) en desarrollo
    if (process.env.NODE_ENV !== 'production' && isLocalhostOrigin(origin)) {
      if (!process.env.CORS_SILENCE_LOCALHOST) {
        console.log(`ℹCORS localhost permitido: ${origin}`);
      }
      return callback(null, true);
    }

    
    if (process.env.NODE_ENV !== 'production' && process.env.CORS_ALLOW_ALL_DEV === '1') {
      if (!process.env.CORS_SILENCE_LOCALHOST) {
        console.warn(`Origen no listado en CORS (${origin}) - permitido por CORS_ALLOW_ALL_DEV`);
      }
      return callback(null, true);
    }

    return callback(new Error('Origen no permitido por CORS: ' + origin));
  },
  credentials: true,
  allowedHeaders: ['Content-Type', 'Authorization'],
  methods: ['GET','POST','PUT','PATCH','DELETE','OPTIONS']
}));

// Responder preflight rápidamente
app.options('*', cors());

// Logger simple de requests (evita agregar dependencia morgan)
app.use((req, res, next) => {
  console.log(`[REQ] ${req.method} ${req.originalUrl}`);
  next();
});
// ----------------------------------------
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Servir archivos estáticos de uploads
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Configurar eventos de base de datos
DatabaseService.configurarEventos();

// Conectar a MongoDB Atlas
DatabaseService.conectar(process.env.MONGO_URI)
  .then(conectado => {
    if (conectado) {
      console.log('Base de datos inicializada correctamente');
      
      // Solo iniciar el servidor si la BD está conectada
      const PORT = process.env.PORT || 3000;
      app.listen(PORT, () => {
        console.log(`Servidor corriendo en puerto ${PORT}`);
        console.log(`API disponible en: http://localhost:${PORT}`);
        console.log(`Endpoints disponibles en: http://localhost:${PORT}/api/utils/info`);
      });
    } else {
      console.error('Error al inicializar la base de datos');
      console.error('📖 Lee el archivo MONGODB_SETUP.md para más información');
      process.exit(1);
    }
  })
  .catch(error => {
    console.error('Error crítico al conectar a la base de datos:', error.message);
    process.exit(1);
  });

// Rutas
const usuariosRoutes = require('./routes/usuarios');
const mascotasRoutes = require('./routes/ruta_mascotas');
const eventosRoutes = require('./routes/eventos');
const vacunasRoutes = require('./routes/vacunas');
const pesoRoutes = require('./routes/peso');
const albumRoutes = require('./routes/album');
const utilsRoutes = require('./routes/utils');
const soporteRoutes = require('./routes/soporte');

app.use('/api/usuarios', usuariosRoutes);
app.use('/api/mascotas', mascotasRoutes);
app.use('/api/eventos', eventosRoutes);
app.use('/api/vacunas', vacunasRoutes);
app.use('/api/peso', pesoRoutes);
app.use('/api/album', albumRoutes);
app.use('/api/utils', utilsRoutes);
app.use('/api/soporte', soporteRoutes);

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({
    mensaje: 'API My Best Friend funcionando correctamente',
    version: '1.0.0',
    estado: 'Activo',
    documentacion: '/api/utils/info'
  });
});


app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Ruta no encontrada',
    mensaje: 'La ruta solicitada no existe',
    endpoints_disponibles: '/api/utils/info'
  });
});

// Middleware global de manejo de errores
app.use((error, req, res, next) => {
  console.error('Error:', error);
  res.status(error.status || 500).json({
    error: 'Error interno del servidor',
    mensaje: process.env.NODE_ENV === 'development' ? error.message : 'Algo salió mal'
  });
});