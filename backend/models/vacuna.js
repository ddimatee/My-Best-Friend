const mongoose = require('mongoose');

const vacunaSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: [true, 'El nombre de la vacuna es obligatorio'],
    trim: true,
    minlength: [2, 'El nombre debe tener al menos 2 caracteres'],
    maxlength: [100, 'El nombre no puede exceder 100 caracteres']
  },
  fechaAplicacion: {
    type: Date,
    required: [true, 'La fecha de aplicación es obligatoria'],
    validate: {
      validator: function(v) {
        const hoy = new Date();
        const hace50Years = new Date();
        hace50Years.setFullYear(hoy.getFullYear() - 50);
        return v <= hoy && v >= hace50Years;
      },
      message: 'La fecha de aplicación debe ser una fecha pasada válida (últimos 50 años)'
    }
  },
  fechaVencimiento: {
    type: Date,
    validate: {
      validator: function(v) {
        if (!v) return true; // Es opcional
        const en50Years = new Date();
        en50Years.setFullYear(en50Years.getFullYear() + 50);
        return v >= this.fechaAplicacion && v <= en50Years;
      },
      message: 'La fecha de vencimiento debe ser posterior a la fecha de aplicación'
    }
  },
  veterinario: {
    nombre: {
      type: String,
      trim: true,
      maxlength: [100, 'El nombre del veterinario no puede exceder 100 caracteres'],
      validate: {
        validator: function(v) {
          if (!v) return true;
          return /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s\.]+$/.test(v);
        },
        message: 'El nombre del veterinario solo puede contener letras, espacios y puntos'
      }
    },
    clinica: {
      type: String,
      trim: true,
      maxlength: [150, 'El nombre de la clínica no puede exceder 150 caracteres']
    },
    telefono: {
      type: String,
      trim: true,
      validate: {
        validator: function(v) {
          if (!v) return true;
          return /^[0-9\-\+\(\)\s]{7,20}$/.test(v);
        },
        message: 'El teléfono debe contener entre 7 y 20 caracteres válidos'
      }
    }
  },
  lote: {
    type: String,
    trim: true,
    maxlength: [50, 'El lote no puede exceder 50 caracteres']
  },
  laboratorio: {
    type: String,
    trim: true,
    maxlength: [100, 'El laboratorio no puede exceder 100 caracteres']
  },
  observaciones: {
    type: String,
    trim: true,
    maxlength: [500, 'Las observaciones no pueden exceder 500 caracteres']
  },
  ubicacion: {
    type: String,
    trim: true,
    maxlength: [200, 'La ubicación no puede exceder 200 caracteres']
  },
  recordatorio: {
    activo: {
      type: Boolean,
      default: false,
      required: [true, 'El campo activo del recordatorio es obligatorio']
    },
    fechaRecordatorio: {
      type: Date,
      validate: {
        validator: function(v) {
          if (!v) return true;
          if (!this.recordatorio.activo) return true;
          const en50Years = new Date();
          en50Years.setFullYear(en50Years.getFullYear() + 50);
          return v <= en50Years;
        },
        message: 'La fecha del recordatorio debe ser una fecha futura válida'
      }
    }
  },
  estado: {
    type: String,
    enum: {
      values: ['vigente', 'vencida', 'proxima_vencer'],
      message: 'El estado debe ser: vigente, vencida o proxima_vencer'
    },
    default: 'vigente',
    required: [true, 'El estado de la vacuna es obligatorio']
  },
  mascota: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Mascota',
    required: [true, 'La mascota asociada a la vacuna es obligatoria'],
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
    required: [true, 'El usuario asociado a la vacuna es obligatorio'],
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