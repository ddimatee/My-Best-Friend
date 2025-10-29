const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const usuarioSchema = new mongoose.Schema({
  nombre: { 
    type: String, 
    required: [true, 'El nombre es obligatorio'],
    trim: true,
    minlength: [2, 'El nombre debe tener al menos 2 caracteres'],
    maxlength: [50, 'El nombre no puede exceder 50 caracteres'],
    validate: {
      validator: function(v) {
        return /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/.test(v);
      },
      message: 'El nombre solo puede contener letras y espacios'
    }
  },
  apellido: { 
    type: String, 
    required: [true, 'El apellido es obligatorio'],
    trim: true,
    minlength: [2, 'El apellido debe tener al menos 2 caracteres'],
    maxlength: [50, 'El apellido no puede exceder 50 caracteres'],
    validate: {
      validator: function(v) {
        return /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/.test(v);
      },
      message: 'El apellido solo puede contener letras y espacios'
    }
  },
  correo: {
    type: String,
    required: [true, 'El correo electrónico es obligatorio'],
    unique: true,
    lowercase: true,
    trim: true,
    maxlength: [100, 'El correo no puede exceder 100 caracteres'],
    match: [/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/, 'Por favor ingrese un correo electrónico válido']
  },
  celular: {
    type: String,
    required: [true, 'El número de celular es obligatorio'],
    trim: true,
    match: [/^[0-9]{10}$/, 'El celular debe contener exactamente 10 dígitos numéricos']
  },
  contraseña: { 
    type: String, 
    required: [true, 'La contraseña es obligatoria'],
    minlength: [6, 'La contraseña debe tener al menos 6 caracteres'],
    maxlength: [255, 'La contraseña no puede exceder 255 caracteres']
  },
  fotoPerfil: { 
    type: String, 
    default: '',
    maxlength: [500, 'La URL de la foto de perfil no puede exceder 500 caracteres'],
    validate: {
      validator: function(v) {
        if (!v || v === '') return true;
        return /^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?$/.test(v) || /^[a-zA-Z0-9_\-\/\.]+$/.test(v);
      },
      message: 'La URL de la foto de perfil no es válida'
    }
  },
  preferencias: {
    notificaciones: { 
      type: Boolean, 
      default: true,
      required: [true, 'El campo de notificaciones es obligatorio']
    },
    idioma: { 
      type: String, 
      enum: {
        values: ['es', 'en'],
        message: 'El idioma debe ser "es" o "en"'
      },
      default: 'es',
      required: [true, 'El idioma es obligatorio']
    },
    timezone: { 
      type: String, 
      default: 'America/Mexico_City',
      required: [true, 'La zona horaria es obligatoria'],
      maxlength: [100, 'La zona horaria no puede exceder 100 caracteres']
    }
  },
  mascotas: [{ 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Mascota',
    validate: {
      validator: function(v) {
        return mongoose.Types.ObjectId.isValid(v);
      },
      message: 'ID de mascota no válido'
    }
  }],
  // Tokens de dispositivos (FCM) para notificaciones push
  deviceTokens: [{
    type: String,
    maxlength: [500, 'El token del dispositivo no puede exceder 500 caracteres'],
    validate: {
      validator: function(v) {
        return v && v.length > 0;
      },
      message: 'El token del dispositivo no puede estar vacío'
    }
  }],
  activo: { 
    type: Boolean, 
    default: true,
    required: [true, 'El campo activo es obligatorio']
  },
  // Flag para indicar si el usuario ya completó el onboarding en el dispositivo
  hasSeenOnboarding: { 
    type: Boolean, 
    default: false,
    required: [true, 'El campo hasSeenOnboarding es obligatorio']
  },
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
