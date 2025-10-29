const mongoose = require('mongoose');

const soporteSchema = new mongoose.Schema({
  usuario: { 
    type: mongoose.Schema.Types.ObjectId, 
    ref: 'Usuario', 
    required: false, // opcional si se permite anónimo
    validate: {
      validator: function(v) {
        if (!v) return true; // Es opcional
        return mongoose.Types.ObjectId.isValid(v);
      },
      message: 'ID de usuario no válido'
    }
  },
  tipo: {
    type: String,
    enum: {
      values: ['Soporte técnico', 'Sugerencia', 'Reporte de error', 'Solicitud de función', 'Otro'],
      message: 'El tipo debe ser: Soporte técnico, Sugerencia, Reporte de error, Solicitud de función u Otro'
    },
    required: [true, 'El tipo de solicitud es obligatorio']
  },
  mensaje: { 
    type: String, 
    required: [true, 'El mensaje es obligatorio'],
    trim: true,
    minlength: [10, 'El mensaje debe tener al menos 10 caracteres'],
    maxlength: [2000, 'El mensaje no puede exceder 2000 caracteres']
  },
  estado: { 
    type: String, 
    enum: {
      values: ['nuevo', 'en_progreso', 'resuelto', 'cerrado'],
      message: 'El estado debe ser: nuevo, en_progreso, resuelto o cerrado'
    },
    default: 'nuevo',
    required: [true, 'El estado es obligatorio']
  },
  origen: { 
    type: String, 
    default: 'app',
    maxlength: [50, 'El origen no puede exceder 50 caracteres'],
    validate: {
      validator: function(v) {
        return /^[a-zA-Z0-9_\-]+$/.test(v);
      },
      message: 'El origen solo puede contener letras, números, guiones y guiones bajos'
    }
  },
  metadata: { 
    type: Object, 
    default: {},
    validate: {
      validator: function(v) {
        try {
          JSON.stringify(v);
          return true;
        } catch(e) {
          return false;
        }
      },
      message: 'Los metadatos deben ser un objeto JSON válido'
    }
  },
  respuesta: { 
    type: String, 
    default: '',
    maxlength: [2000, 'La respuesta no puede exceder 2000 caracteres']
  },
  leido: { 
    type: Boolean, 
    default: false,
    required: [true, 'El campo leido es obligatorio']
  }
}, { timestamps: true });

module.exports = mongoose.model('Soporte', soporteSchema);
