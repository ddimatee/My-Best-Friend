const mongoose = require('mongoose');

const registroPesoSchema = new mongoose.Schema({
  peso: {
    type: Number,
    required: true,
    min: 0.1,
    max: 200 // kg
  },
  fecha: {
    type: Date,
    required: true,
    default: Date.now
  },
  observaciones: {
    type: String,
    trim: true,
    maxlength: 500
  },
  tipoRegistro: {
    type: String,
    enum: ['rutina', 'veterinario', 'enfermedad', 'otro'],
    default: 'rutina'
  },
  mascota: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Mascota',
    required: true
  },
  usuario: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true
  }
}, {
  timestamps: true
});

// Índice para optimizar búsquedas por mascota y fecha
registroPesoSchema.index({ mascota: 1, fecha: -1 });

module.exports = mongoose.model('RegistroPeso', registroPesoSchema);