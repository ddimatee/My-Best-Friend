const mongoose = require('mongoose');

const mascotaSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: [true, 'El nombre de la mascota es obligatorio'],
    trim: true,
    minlength: [1, 'El nombre debe tener al menos 1 carácter'],
    maxlength: [50, 'El nombre no puede exceder 50 caracteres'],
    validate: {
      validator: function(v) {
        return /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ0-9\s]+$/.test(v);
      },
      message: 'El nombre solo puede contener letras, números y espacios'
    }
  },
  especie: {
    type: String,
    trim: true,
    default: 'perro',
    minlength: [2, 'La especie debe tener al menos 2 caracteres'],
    maxlength: [50, 'La especie no puede exceder 50 caracteres'],
    validate: {
      validator: function(v) {
        return /^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$/.test(v);
      },
      message: 'La especie solo puede contener letras y espacios'
    }
  },
  sexo: {
    type: String,
    enum: {
      values: ['macho', 'hembra'],
      message: 'El sexo debe ser "macho" o "hembra"'
    },
    required: [true, 'El sexo de la mascota es obligatorio']
  },
  raza: {
    type: String,
    required: [true, 'La raza es obligatoria'],
    trim: true,
    minlength: [2, 'La raza debe tener al menos 2 caracteres'],
    maxlength: [100, 'La raza no puede exceder 100 caracteres']
  },
  fecha_nac: {
    type: Date,
    validate: {
      validator: function(v) {
        if (!v) return true; // Es opcional
        const hoy = new Date();
        const hace150Years = new Date();
        hace150Years.setFullYear(hoy.getFullYear() - 150);
        return v <= hoy && v >= hace150Years;
      },
      message: 'La fecha de nacimiento debe ser una fecha pasada válida'
    }
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
  oculto: {
    type: Boolean,
    default: false,
    required: [true, 'El campo oculto es obligatorio']
  },
  estiloVida: {
    type: String,
    enum: {
      values: ['activo', 'tranquilo', 'mixto'],
      message: 'El estilo de vida debe ser "activo", "tranquilo" o "mixto"'
    },
    default: 'mixto',
    required: [true, 'El estilo de vida es obligatorio']
  },
  cuidaConAlguien: {
    type: Boolean,
    default: false,
    required: [true, 'El campo cuidaConAlguien es obligatorio']
  },
  dueño: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: [true, 'El dueño de la mascota es obligatorio'],
    validate: {
      validator: function(v) {
        return mongoose.Types.ObjectId.isValid(v);
      },
      message: 'ID de dueño no válido'
    }
  },
  cuidador: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    validate: {
      validator: function(v) {
        if (!v) return true; // Es opcional
        return mongoose.Types.ObjectId.isValid(v);
      },
      message: 'ID de cuidador no válido'
    }
  }
}, {
  timestamps: true
});

// Virtual para exponer fechaNacimiento homogénea al frontend
mascotaSchema.virtual('fechaNacimiento').get(function() {
  return this.fecha_nac;
});

// Asegurar inclusión de virtuales al serializar
mascotaSchema.set('toJSON', { virtuals: true });
mascotaSchema.set('toObject', { virtuals: true });

// Índices recomendados
mascotaSchema.index({ dueño: 1 });
mascotaSchema.index({ dueño: 1, oculto: 1 });

module.exports = mongoose.model('Mascota', mascotaSchema);