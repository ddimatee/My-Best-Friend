const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const usuarioSchema = new mongoose.Schema({
  nombre: { type: String, required: true, trim: true },
  apellido: { type: String, required: true, trim: true },
  correo: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    match: /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/
  },
  celular: {
    type: String,
    required: true,
    trim: true,
    match: /^[0-9]{10}$/
  },
  contraseña: { type: String, required: true },
  fotoPerfil: { type: String, default: '' },
  preferencias: {
    tema: { type: String, enum: ['claro', 'oscuro'], default: 'claro' },
    inicioSemana: { type: String, enum: ['domingo', 'lunes'], default: 'lunes' },
    notificaciones: { type: Boolean, default: true },
    idioma: { type: String, enum: ['es', 'en'], default: 'es' },
    timezone: { type: String, default: 'America/Mexico_City' }
  },
  mascotas: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Mascota' }],
  activo: { type: Boolean, default: true },
  ultimoAcceso: { type: Date, default: Date.now }
}, {
  timestamps: true
});

// Encriptar contraseña antes de guardar
usuarioSchema.pre('save', async function (next) {
  if (!this.isModified('contraseña')) return next();
  try {
    const salt = await bcrypt.genSalt(10);
    this.contraseña = await bcrypt.hash(this.contraseña, salt);
    next();
  } catch (err) {
    next(err);
  }
});

// Método para validar contraseña
usuarioSchema.methods.validarContraseña = async function (contraseñaIngresada) {
  return await bcrypt.compare(contraseñaIngresada, this.contraseña);
};

module.exports = mongoose.model('Usuario', usuarioSchema);
