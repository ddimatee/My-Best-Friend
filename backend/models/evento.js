const mongoose = require('mongoose');

const eventoSchema = new mongoose.Schema({
  titulo: {
    type: String,
    required: [true, 'El título del evento es obligatorio'],
    trim: true,
    minlength: [1, 'El título debe tener al menos 1 carácter'],
    maxlength: [100, 'El título no puede exceder 100 caracteres']
  },
  descripcion: {
    type: String,
    trim: true,
    maxlength: [500, 'La descripción no puede exceder 500 caracteres']
  },
  fecha: {
    type: Date,
    required: [true, 'La fecha del evento es obligatoria'],
    validate: {
      validator: function(v) {
        const hace10Years = new Date();
        hace10Years.setFullYear(hace10Years.getFullYear() - 10);
        const en10Years = new Date();
        en10Years.setFullYear(en10Years.getFullYear() + 10);
        return v >= hace10Years && v <= en10Years;
      },
      message: 'La fecha debe estar dentro de un rango válido (últimos 10 años o próximos 10 años)'
    }
  },
  hora: {
    type: String,
    required: [true, 'La hora del evento es obligatoria'],
    validate: {
      validator: function(v) {
        return /^([01]?[0-9]|2[0-3]):[0-5][0-9]$/.test(v);
      },
      message: 'La hora debe estar en formato HH:MM (24 horas)'
    }
  },
  tipo: {
    type: String,
    enum: {
      values: ['veterinario', 'alimentacion', 'ejercicio', 'medicamento', 'baño', 'otro'],
      message: 'El tipo debe ser: veterinario, alimentacion, ejercicio, medicamento, baño u otro'
    },
    required: [true, 'El tipo de evento es obligatorio']
  },
  prioridad: {
    type: String,
    enum: {
      values: ['baja', 'media', 'alta'],
      message: 'La prioridad debe ser: baja, media o alta'
    },
    default: 'media',
    required: [true, 'La prioridad es obligatoria']
  },
  completado: {
    type: Boolean,
    default: false,
    required: [true, 'El campo completado es obligatorio']
  },
  recordatorio: {
    activo: {
      type: Boolean,
      default: true,
      required: [true, 'El campo activo del recordatorio es obligatorio']
    },
    tiempoAntes: {
      type: Number, // minutos antes del evento
      default: 30,
      min: [0, 'El tiempo antes no puede ser negativo'],
      max: [10080, 'El tiempo antes no puede exceder 7 días (10080 minutos)'],
      validate: {
        validator: function(v) {
          return Number.isInteger(v);
        },
        message: 'El tiempo antes debe ser un número entero'
      }
    }
  },
  mascota: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Mascota',
    required: [true, 'La mascota asociada al evento es obligatoria'],
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
    required: [true, 'El usuario asociado al evento es obligatorio'],
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

module.exports = mongoose.model('Evento', eventoSchema);