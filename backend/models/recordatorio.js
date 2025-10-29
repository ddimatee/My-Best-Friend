const mongoose = require('mongoose');

const avisoSchema = new mongoose.Schema({
  tipo: { 
    type: String, 
    enum: {
      values: ['a_la_hora', 'antes_de'],
      message: 'El tipo debe ser "a_la_hora" o "antes_de"'
    },
    required: [true, 'El tipo de aviso es obligatorio']
  },
  minutos: { 
    type: Number, 
    default: 0,
    min: [0, 'Los minutos no pueden ser negativos'],
    max: [10080, 'Los minutos no pueden exceder 7 días (10080 minutos)'],
    validate: {
      validator: function(v) {
        return Number.isInteger(v);
      },
      message: 'Los minutos deben ser un número entero'
    }
  },
  descripcion: { 
    type: String, 
    trim: true,
    maxlength: [200, 'La descripción no puede exceder 200 caracteres']
  }
}, { _id: false });

const recordatorioSchema = new mongoose.Schema({
  usuario: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Usuario', 
    required: [true, 'El usuario es obligatorio'],
    validate: {
      validator: function(v) {
        return mongoose.Types.ObjectId.isValid(v);
      },
      message: 'ID de usuario no válido'
    }
  },
  titulo: { 
    type: String, 
    required: [true, 'El título del recordatorio es obligatorio'],
    trim: true,
    minlength: [1, 'El título debe tener al menos 1 carácter'],
    maxlength: [100, 'El título no puede exceder 100 caracteres']
  },
  descripcion: { 
    type: String, 
    trim: true,
    maxlength: [500, 'La descripción no puede exceder 500 caracteres']
  },
  // Categoria: permitir texto libre (UI usa "Juegos y entretenimiento", etc.)
  categoria: { 
    type: String, 
    trim: true, 
    default: 'otro', 
    maxlength: [60, 'La categoría no puede exceder 60 caracteres'],
    minlength: [1, 'La categoría debe tener al menos 1 carácter']
  },
  fechaHora: { 
    type: Date, 
    required: [true, 'La fecha y hora del recordatorio es obligatoria'],
    validate: {
      validator: function(v) {
        const hace10Years = new Date();
        hace10Years.setFullYear(hace10Years.getFullYear() - 10);
        const en10Years = new Date();
        en10Years.setFullYear(en10Years.getFullYear() + 10);
        return v >= hace10Years && v <= en10Years;
      },
      message: 'La fecha debe estar dentro de un rango válido'
    }
  },
  tipoRecordatorio: { 
    type: String, 
    enum: {
      values: ['una_vez', 'repetir'],
      message: 'El tipo de recordatorio debe ser "una_vez" o "repetir"'
    },
    default: 'una_vez',
    required: [true, 'El tipo de recordatorio es obligatorio']
  },
  frecuencia: { 
    type: String, 
    enum: {
      values: ['una_vez', 'diario', 'semanal', 'mensual', 'anual'],
      message: 'La frecuencia debe ser: una_vez, diario, semanal, mensual o anual'
    },
    default: 'una_vez',
    required: [true, 'La frecuencia es obligatoria']
  },
  avisos: { 
    type: [avisoSchema], 
    default: [],
    validate: {
      validator: function(v) {
        return v.length <= 10;
      },
      message: 'No puede haber más de 10 avisos por recordatorio'
    }
  },
  activo: { 
    type: Boolean, 
    default: true,
    required: [true, 'El campo activo es obligatorio']
  }
}, { timestamps: true });

recordatorioSchema.index({ usuario: 1, fechaHora: 1 });

module.exports = mongoose.model('Recordatorio', recordatorioSchema);