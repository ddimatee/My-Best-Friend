const mongoose = require('mongoose');

const registroPesoSchema = new mongoose.Schema({
  peso: {
    type: Number,
    required: [true, 'El peso es obligatorio'],
    min: [0.1, 'El peso debe ser al menos 0.1 kg'],
    max: [200, 'El peso no puede exceder 200 kg'],
    validate: {
      validator: function(v) {
        return !isNaN(v) && isFinite(v);
      },
      message: 'El peso debe ser un número válido'
    }
  },
  fecha: {
    type: Date,
    required: [true, 'La fecha del registro es obligatoria'],
    default: Date.now,
    validate: {
      validator: function(v) {
        const hoy = new Date();
        const hace50Years = new Date();
        hace50Years.setFullYear(hoy.getFullYear() - 50);
        return v <= hoy && v >= hace50Years;
      },
      message: 'La fecha debe ser una fecha pasada válida (últimos 50 años)'
    }
  },
  observaciones: {
    type: String,
    trim: true,
    maxlength: [500, 'Las observaciones no pueden exceder 500 caracteres']
  },
  tipoRegistro: {
    type: String,
    enum: {
      values: ['rutina', 'veterinario', 'enfermedad', 'otro'],
      message: 'El tipo de registro debe ser: rutina, veterinario, enfermedad u otro'
    },
    default: 'rutina',
    required: [true, 'El tipo de registro es obligatorio']
  },
  mascota: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Mascota',
    required: [true, 'La mascota asociada al registro es obligatoria'],
    validate: {
      validator: function(v) {
        return mongoose.Types.ObjectId.isValid(v);
      },
      message: 'ID de mascota no válido'
    }
  },
  usuario: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: [true, 'El usuario asociado al registro es obligatorio'],
    validate: {
      validator: function(v) {
        return mongoose.Types.ObjectId.isValid(v);
      },
      message: 'ID de usuario no válido'
    }
  }
}, {
  timestamps: true
});

// Índice para optimizar búsquedas por mascota y fecha
registroPesoSchema.index({ mascota: 1, fecha: -1 });

module.exports = mongoose.model('RegistroPeso', registroPesoSchema);