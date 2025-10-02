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
  // Campo opcional: cómo llegó el usuario a la app (referencia de marketing / adquisición)
  comoLlegaste: { type: String, trim: true, maxlength: 200 },
  preferencias: {
    notificaciones: { type: Boolean, default: true },
    idioma: { type: String, enum: ['es', 'en'], default: 'es' },
    timezone: { type: String, default: 'America/Mexico_City' }
  },
  mascotas: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Mascota' }],
  // Tokens de dispositivos (FCM) para notificaciones push
  deviceTokens: [{ type: String }],
  activo: { type: Boolean, default: true },
}, {
  timestamps: true
});

// Campos adicionales para recuperación y recordar sesión
usuarioSchema.add({
  resetPasswordCode: { type: String, select: false },
  resetPasswordExpira: { type: Date, select: false },
  rememberToken: { type: String, select: false }
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
