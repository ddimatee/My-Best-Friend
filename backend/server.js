const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const DatabaseService = require('./services/databaseService');
require('dotenv').config();

const app = express();

// Middlewares de seguridad
app.use(helmet()); // Añade headers de seguridad
app.use(compression()); // Comprime las respuestas

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100 // máximo 100 requests por ventana de tiempo
});
app.use(limiter);

// Middlewares básicos
app.use(cors({
  origin: process.env.FRONTEND_URL || 'http://localhost:8080',
  credentials: true
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Configurar eventos de base de datos
DatabaseService.configurarEventos();

// Conectar a MongoDB Atlas
DatabaseService.conectar(process.env.MONGO_URI)
  .then(conectado => {
    if (conectado) {
      console.log('✅ Base de datos inicializada correctamente');
      
      // Solo iniciar el servidor si la BD está conectada
      const PORT = process.env.PORT || 3000;
      app.listen(PORT, () => {
        console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
        console.log(`📍 API disponible en: http://localhost:${PORT}`);
        console.log(`📋 Endpoints disponibles en: http://localhost:${PORT}/api/utils/info`);
      });
    } else {
      console.error('❌ Error al inicializar la base de datos');
      console.error('💡 Revisa tu configuración de MongoDB en el archivo .env');
      console.error('📖 Lee el archivo MONGODB_SETUP.md para más información');
      process.exit(1);
    }
  })
  .catch(error => {
    console.error('❌ Error crítico al conectar a la base de datos:', error.message);
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

app.use('/api/usuarios', usuariosRoutes);
app.use('/api/mascotas', mascotasRoutes);
app.use('/api/eventos', eventosRoutes);
app.use('/api/vacunas', vacunasRoutes);
app.use('/api/peso', pesoRoutes);
app.use('/api/album', albumRoutes);
app.use('/api/utils', utilsRoutes);

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({
    mensaje: '🐕 API My Best Friend funcionando correctamente',
    version: '1.0.0',
    estado: 'Activo',
    documentacion: '/api/utils/info'
  });
});

// Middleware para rutas no encontradas
app.use('*', (req, res) => {
  res.status(404).json({
    error: 'Ruta no encontrada',
    mensaje: 'La ruta solicitada no existe',
    endpoints_disponibles: '/api/utils/info'
  });
});

// Middleware global de manejo de errores
app.use((error, req, res, next) => {
  console.error('❌ Error:', error);
  res.status(error.status || 500).json({
    error: 'Error interno del servidor',
    mensaje: process.env.NODE_ENV === 'development' ? error.message : 'Algo salió mal'
  });
});