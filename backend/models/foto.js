const mongoose = require('mongoose');

const fotoSchema = new mongoose.Schema({
  url: {
    type: String,
    required: [true, 'La URL de la foto es obligatoria'],
    maxlength: [500, 'La URL no puede exceder 500 caracteres'],
    validate: {
      validator: function(v) {
        return /^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-._~:/?#[\]@!$&'()*+,;=]*)?$/.test(v) || /^[a-zA-Z0-9_\-\/\.]+$/.test(v);
      },
      message: 'La URL de la foto no es válida'
    }
  },
  titulo: {
    type: String,
    trim: true,
    default: '',
    maxlength: [100, 'El título no puede exceder 100 caracteres']
  },
  descripcion: {
    type: String,
    trim: true,
    default: '',
    maxlength: [500, 'La descripción no puede exceder 500 caracteres']
  },
  fecha: {
    type: Date,
    required: [true, 'La fecha de la foto es obligatoria'],
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
  ubicacion: {
    type: String,
    trim: true,
    maxlength: [200, 'La ubicación no puede exceder 200 caracteres']
  },
  etiquetas: [{
    type: String,
    trim: true,
    maxlength: [50, 'Cada etiqueta no puede exceder 50 caracteres'],
    validate: {
      validator: function(v) {
        return /^[a-zA-Z0-9áéíóúÁÉÍÓÚñÑüÜ_\-\s]+$/.test(v);
      },
      message: 'Las etiquetas solo pueden contener letras, números, guiones y espacios'
    }
  }],
  esPortada: {
    type: Boolean,
    default: false,
    required: [true, 'El campo esPortada es obligatorio']
  },
  mascota: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Mascota',
    required: [true, 'La mascota asociada a la foto es obligatoria'],
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
    required: [true, 'El usuario asociado a la foto es obligatorio'],
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

// Solo una foto puede ser portada por mascota
fotoSchema.pre('save', async function(next) {
  if (this.esPortada) {
    await mongoose.model('Foto').updateMany(
      { mascota: this.mascota, _id: { $ne: this._id } },
      { esPortada: false }
    );
  }
  next();
});

module.exports = mongoose.model('Foto', fotoSchema);