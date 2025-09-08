const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Conexión a MongoDB Atlas
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('✅ Conectado a MongoDB Atlas'))
  .catch(err => console.error('❌ Error al conectar a MongoDB:', err));

// Rutas
const usuariosRoutes = require('./routes/usuarios');
const mascotasRoutes = require('./routes/ruta_mascotas');

app.use('/api/usuarios', usuariosRoutes);
app.use('/api/mascotas', mascotasRoutes);

// Ruta de prueba
app.get('/', (req, res) => {
  res.send('API funcionando correctamente con MongoDB Atlas');
});

// Puerto
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
});