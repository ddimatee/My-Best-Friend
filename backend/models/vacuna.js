const mongoose = require('mongoose');

const vacunaSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    trim: true
  },
  fechaAplicacion: {
    type: Date,
    required: true
  },
  fechaVencimiento: {
    type: Date
  },
  veterinario: {
    nombre: {
      type: String,
      trim: true
    },
    clinica: {
      type: String,
      trim: true
    },
    telefono: {
      type: String,
      trim: true
    }
  },
  lote: {
    type: String,
    trim: true
  },
  laboratorio: {
    type: String,
    trim: true
  },
  observaciones: {
    type: String,
    trim: true
  },
  estado: {
    type: String,
    enum: ['vigente', 'vencida', 'proxima_vencer'],
    default: 'vigente'
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

// Middleware para calcular automáticamente el estado de la vacuna
vacunaSchema.pre('save', function(next) {
  if (this.fechaVencimiento) {
    const hoy = new Date();
    const diasParaVencer = Math.ceil((this.fechaVencimiento - hoy) / (1000 * 60 * 60 * 24));
    
    if (diasParaVencer < 0) {
      this.estado = 'vencida';
    } else if (diasParaVencer <= 30) {
      this.estado = 'proxima_vencer';
    } else {
      this.estado = 'vigente';
    }
  }
  next();
});

module.exports = mongoose.model('Vacuna', vacunaSchema);